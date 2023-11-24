/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
import class Foundation.FileManager
#endif
import Atomics

extension ResourceManager {
    struct Importers {
        internal var textureImporters: [any TextureImporter.Type] = [
            PNGImporter.self
        ]

        internal var geometryImporters: [any GeometryImporter.Type] = [
            GLTransmissionFormat.self, 
            WavefrontOBJImporter.self,
        ]
        
        internal var skeletonImporters: [any SkeletonImporter.Type] = [
            GLTransmissionFormat.self,
        ]
        internal var skinImporters: [any SkinImporter.Type] = [
            GLTransmissionFormat.self,
        ]
        internal var skeletalAnimationImporters: [any SkeletalAnimationImporter.Type] = [
            GLTransmissionFormat.self,
        ]
        
        internal var objectAnimation3DImporters: [any ObjectAnimation3DImporter.Type] = [
            GLTransmissionFormat.self,
        ]

        internal var tileSetImporters: [any TileSetImporter.Type] = [
            TiledTSJImporter.self,
        ]
        internal var tileMapImporters: [any TileMapImporter.Type] = [
            TiledTMJImporter.self,
        ]
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

public class ResourceManager {
    internal var importers: Importers = Importers()
    internal let cache: Cache = Cache()

    let rawCacheIDGenerator = IDGenerator<UInt>()

    var accumulatedSeconds: Float = 0
    

    @MainActor public var currentlyLoading: [String] {
        return paths.map({
            if $0.hasPrefix("$") {
                return "Generated(\($0))"
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

    let game: Game
    init(game: Game) {
        self.game = game
    }

    func update(withTimePassed deltaTime: Float) {
        accumulatedSeconds += deltaTime
        if accumulatedSeconds > 60 {
            accumulatedSeconds -= 60
            incrementMinutes()
        }
    }
    
    func incrementMinutes() {
        for key in cache.textures.keys {
            guard let cache = cache.textures[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.textures.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), Texture:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }

        for key in cache.geometries.keys {
            guard let cache = cache.geometries[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.geometries.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), Geometry:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.skinnedGeometries.keys {
            guard let cache = cache.skinnedGeometries[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.skinnedGeometries.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), SkinnedGeometry:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.skeletons.keys {
            guard let cache = cache.skeletons[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.skeletons.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), Skeleton:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.skeletalAnimations.keys {
            guard let cache = cache.skeletalAnimations[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.skeletalAnimations.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), SkeletalAnimation:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.tileSets.keys {
            guard let cache = cache.tileSets[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.tileSets.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), TileSet:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
        
        for key in cache.tileMaps.keys {
            guard let cache = cache.tileMaps[key] else { continue }
            switch cache.cacheHint {
            case .forever, .whileReferenced:
                continue
            case .until(let minutes):
                if cache.referenceCount == 0 {
                    cache.minutesDead += 1
                    if cache.minutesDead == minutes {
                        self.cache.tileMaps.removeValue(forKey: key)
                        Log.debug(
                            "Removing cache (unused for \(cache.minutesDead) min), TileMap:",
                            key.requestedPath.first == "$"
                                ? "(Generated)" : key.requestedPath
                        )
                    }
                } else {
                    cache.minutesDead = 0
                }
            }
        }
    }
}

extension ResourceManager {
    @usableFromInline
    class Cache {
        var textures: [TextureKey: TextureCache] = [:]
        var geometries: [GeometryKey: GeometryCache] = [:]
        var skinnedGeometries: [SkinnedGeometryKey: SkinnedGeometryCache] = [:]

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
    }
}
