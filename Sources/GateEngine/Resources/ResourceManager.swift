/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import class Foundation.FileManager
#endif

public protocol ResourceImporter: Sendable {
    init()
    
    #if GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
    mutating func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError)
    #endif
    #if GATEENGINE_PLATFORM_HAS_AsynchronousFileSystem
    mutating func prepareToImportResourceFrom(path: String) async throws(GateEngineError)
    #endif
    
    static func supportedFileExtensions() -> [String]
    static func canProcessFile(_ path: String) -> Bool
    
    /**
     Importers can report if they are capable of returning multiple resource instances from the same file.
     
     Properly returning `true` or `false` will effect performance. If the importer can decode multiple resources, 
     it will be kept in memory for a period of time allowing it to deocde more resources from the already accessed file data.
     - returns: `true` if this importer is able to return more then one resources from a single file, otherwise `false`.
     */
    mutating func currentFileContainsMutipleResources() -> Bool
}

public protocol GateEngineNativeResourceImporter: ResourceImporter {
    static var fileExtension: String { get }
}
extension GateEngineNativeResourceImporter {
    public static func supportedFileExtensions() -> [String] {
        return [Self.fileExtension]
    }
}

public extension ResourceImporter {
    static func supportedFileExtensions() -> [String] {
        return []
    }
    
    static func canProcessFile(_ path: String) -> Bool {
        let supportedExtensions = self.supportedFileExtensions()
        precondition(supportedExtensions.isEmpty == false, "Imporers must implement `supportedFileExtensions()` or  `canProcessFile(_:)`.")
        let fileExtension = URL(fileURLWithPath: path).pathExtension
        guard fileExtension.isEmpty == false else {return false}
        for supportedFileExtension in supportedExtensions {
            if fileExtension.caseInsensitiveCompare(supportedFileExtension) == .orderedSame {
                return true
            }
        }
        return false
    }
    
    func currentFileContainsMutipleResources() -> Bool {
        return false
    }
}

extension ResourceManager {
    struct Importers {
        internal var textureImporters: [any TextureImporter.Type] = [
            PNGImporter.self,
            GLTransmissionFormat.self,
        ]

        internal var geometryImporters: [any GeometryImporter.Type] = [
            RawGeometryImporter.self,
            GLTransmissionFormat.self,
            WavefrontOBJImporter.self,
        ]
        
        internal var collisionMeshImporters: [any CollisionMeshImporter.Type] = [
            RawCollisionMeshImporter.self,
            GLTransmissionFormat.self,
        ]
        
        internal var skeletonImporters: [any SkeletonImporter.Type] = [
            RawSkeletonImporter.self,
            GLTransmissionFormat.self,
        ]
        internal var skinImporters: [any SkinImporter.Type] = [
            RawSkinImporter.self,
            GLTransmissionFormat.self,
        ]
        internal var skeletalAnimationImporters: [any SkeletalAnimationImporter.Type] = [
            RawSkeletalAnimationImporter.self,
            GLTransmissionFormat.self,
        ]
        
        internal var objectAnimation3DImporters: [any ObjectAnimation3DImporter.Type] = [
            RawObjectAnimation3DImporter.self,
            GLTransmissionFormat.self,
        ]

        internal var tileSetImporters: [any TileSetImporter.Type] = [
            TiledTSJImporter.self,
        ]
        internal var tileMapImporters: [any TileMapImporter.Type] = [
            TiledTMJImporter.self,
        ]
        
        private var activeImporters: [ActiveImporterKey : ActiveImporter] = [:]
        private struct ActiveImporterKey: Hashable, Sendable {
            let path: String
        }
        private struct ActiveImporter: Sendable {
            let importer: any ResourceImporter
            var lastAccessed: Date = .now
        }
        
        internal mutating func getImporter<I: ResourceImporter>(path: String, type: I.Type) async throws(GateEngineError) -> I {
            let key = ActiveImporterKey(path: path)
            if let existing = activeImporters[key] {
                // Make sure the importer can be the type requested
                if let importer = existing.importer as? I {
                    activeImporters[key]?.lastAccessed = .now
                    return importer
                }
            }
            var importer = type.init()
            try await importer.prepareToImportResourceFrom(path: path)
            if importer.currentFileContainsMutipleResources() {
                let active = ActiveImporter(importer: importer, lastAccessed: .now)
                activeImporters[key] = active
            }
            return importer
        }
        
        internal mutating func clean() {
            for key in activeImporters.keys {
                if activeImporters[key]!.lastAccessed.timeIntervalSinceNow < -60 {
                    activeImporters.removeValue(forKey: key)
                }
            }
        }
    }
}

internal protocol ResourceCache: AnyObject {
    var lastLoaded: Date {get set}
    var state: ResourceState {get set}
    var referenceCount: UInt {get set}
    var minutesDead: UInt {get set}
    var cacheHint: CacheHint? {get set}
    var defaultCacheHint: CacheHint {get set}
}

extension ResourceCache {
    @inlinable
    var effectiveCacheHint: CacheHint {
        return cacheHint ?? defaultCacheHint
    }
}

public enum CacheHint {
    /// The resource will stay in memory until the CachedHint is manually changed to something else
    case forever
    /// The resource will remain cached while it is referenced
    case whileReferenced
    /// The resource will remain cached for `minutes` of not being referenced
    case until(minutes: UInt)
}

public final class ResourceManager {
    internal var importers: Importers = Importers()
    @MainActor internal let cache: Cache = Cache()

    let rawCacheIDGenerator = IDGenerator<UInt>()

    var accumulatedSeconds1: Float = 0
    var accumulatedSeconds2: Float = 0
    
    /// Automatically reloads cached resources when the source path file changes
    /// - note: This feature is designed for development use and is not recommended for use in a release build
    public var enableHotReloading: Bool = false

    @MainActor public var currentlyLoading: [String] {
        return paths.map({
            if $0.hasPrefix("$") {
                return "Generated(\($0))"
            }
            if $0.hasPrefix("@") {
                return "Text(\($0))"
            }
            return $0
        })
    }
    @MainActor var paths: Array<String> = []
    @MainActor internal func incrementLoading(path: String) {
        paths.append(path)
    }
    @MainActor internal func decrementLoading(path: String) {
        let index = paths.firstIndex(where: {$0 == path})!
        paths.remove(at: index)
    }


    nonisolated init() {
        
    }

    @MainActor
    func update(withTimePassed deltaTime: Float) {
        self.accumulatedSeconds1 += deltaTime
        if self.accumulatedSeconds1 > 60 {
            self.accumulatedSeconds1 -= 60
            self.incrementMinutes()
            self.importers.clean()
        }
        
        if self.enableHotReloading {
            self.accumulatedSeconds2 += deltaTime
            if self.accumulatedSeconds2 > 5 {
                self.accumulatedSeconds2 -= 5
                self.performHotReloading()
            }
        }
    }
    enum Phase {
        case texture
        case geometry
        case skinnedGeometry
        case skeleton
    }
    @MainActor
    func incrementMinutes() {
        for key in cache.textures.keys {
            guard let cache = cache.textures[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.textures.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), Texture: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }

        for key in cache.geometries.keys {
            guard let cache = cache.geometries[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.geometries.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), Geometry: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.skinnedGeometries.keys {
            guard let cache = cache.skinnedGeometries[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.skinnedGeometries.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), SkinnedGeometry: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.skeletons.keys {
            guard let cache = cache.skeletons[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.skeletons.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), Skeleton: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.skeletalAnimations.keys {
            guard let cache = cache.skeletalAnimations[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.skeletalAnimations.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), SkeletalAnimation: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.tileSets.keys {
            guard let cache = cache.tileSets[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.tileSets.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), TileMap: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.tileMaps.keys {
            guard let cache = cache.tileMaps[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.tileMaps.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), TileMap: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.collisionMeshes.keys {
            guard let cache = cache.collisionMeshes[key] else { continue }
            switch cache.effectiveCacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.collisionMeshes.removeValue(forKey: key)
                        Log.debug("Removing cache (unused for \(cache.minutesDead) min), CollisionMesh: \(key)")
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
    }
    
    @MainActor
    func performHotReloading() {
        for key in cache.textures.keys {
            self.reloadTextureIfNeeded(key: key)
        }

        for key in cache.geometries.keys {
            self.reloadGeometryIfNeeded(key: key)
        }
        
        for key in cache.skinnedGeometries.keys {
            self.reloadSkinnedGeometryIfNeeded(key: key)
        }
        
        for key in cache.skeletons.keys {
            self.reloadSkeletonIfNeeded(key: key)
        }
        
        for key in cache.skeletalAnimations.keys {
            self.reloadSkeletalAniamtionIfNeeded(key: key)
        }
        
        for key in cache.objectAnimation3Ds.keys {
            self.reloadObjectAniamtion3DIfNeeded(key: key)
        }
        
        for key in cache.tileSets.keys {
            self.reloadTileSetIfNeeded(key: key)
        }
        
        for key in cache.tileMaps.keys {
            self.reloadTileMapIfNeeded(key: key)
        }
        
        for key in cache.collisionMeshes.keys {
            self.reloadCollisionMeshIfNeeded(key: key)
        }
    }
}

extension ResourceManager {
    @MainActor
    @usableFromInline
    final class Cache {
        var textures: [TextureKey: TextureCache] = [:]
        var geometries: [GeometryKey: GeometryCache] = [:]
        var skinnedGeometries: [SkinnedGeometryKey: SkinnedGeometryCache] = [:]
        var collisionMeshes: [CollisionMeshKey: CollisionMeshCache] = [:]

        var skeletons: [SkeletonKey: SkeletonCache] = [:]
        var skeletalAnimations: [SkeletalAnimationKey: SkeletalAnimationCache] = [:]

        var tileSets: [TileSetKey: TileSetCache] = [:]
        var tileMaps: [TileMapKey: TileMapCache] = [:]
        
        var objectAnimation3Ds: [ObjectAnimation3DKey: ObjectAnimation3DCache] = [:]
        
        var audioBuffers: [AudioBufferKey: AudioBufferCache] = [:]
        
        // AudioBuffer
        struct AudioBufferKey: Hashable, Sendable {
            let path: String
        }
        struct AudioBufferCache {
            weak var audioBuffer: (any AudioBufferBackend)? = nil
        }
        
        nonisolated init() {
            
        }
    }
}
