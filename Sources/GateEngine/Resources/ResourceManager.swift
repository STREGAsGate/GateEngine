/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
import class Foundation.FileManager
#endif

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

    public let game: Game
    public init(game: Game) {
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
                            "Removing cache (unused for \(cache.minutesDead) min), Object:",
                            key.requestedPath.first == "$"
                                ? "(Generated Texture)" : key.requestedPath
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
                            "Removing cache (unused for \(cache.minutesDead) min), Object:",
                            key.requestedPath.first == "$"
                                ? "(Generated Geometry)" : key.requestedPath
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

        var skeletalAnimations: [SkeletalAnimationKey: SkeletalAnimationCache] = [:]

        var tileSets: [TileSetKey: TileSetCache] = [:]
        var tileMaps: [TileMapKey: TileMapCache] = [:]
        
        var audioBuffers: [AudioBufferKey: AudioBufferCache] = [:]
        
        // Skeleton
        struct SkeletalAnimationKey: Hashable, Sendable {
            let path: String
            let options: SkeletalAnimationImporterOptions
        }
        struct SkeletalAnimationCache {
            weak var skeletalAnimation: SkeletalAnimation? = nil
        }

        // AudioBuffer
        struct AudioBufferKey: Hashable, Sendable {
            let path: String
        }
        struct AudioBufferCache {
            weak var audioBuffer: (any AudioBufferBackend)? = nil
        }
    }
}
