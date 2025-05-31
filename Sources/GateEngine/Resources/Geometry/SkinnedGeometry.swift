/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif

internal protocol SkinnedGeometryBackend: AnyObject {
    init(geometry: RawGeometry, skin: Skin)
}

/// Geometry represents a managed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class SkinnedGeometry: Resource, _Resource {
    @usableFromInline
    internal let cacheKey: ResourceManager.Cache.SkinnedGeometryKey

    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.skinnedGeometryCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: (any GeometryBackend)? {
        return Game.unsafeShared.resourceManager.skinnedGeometryCache(for: cacheKey)?.geometryBackend
    }

    public var skinJoints: [Skin.Joint] {
        assert(state == .ready, "The state must be ready before accessing this property.")
        return Game.unsafeShared.resourceManager.skinnedGeometryCache(for: cacheKey)!.skinJoints!
    }

    @inlinable @_disfavoredOverload
    public convenience init(
        as path: GeoemetryPath,
        geometryOptions: GeometryImporterOptions = .none,
        skinOptions: SkinImporterOptions = .none
    ) {
        self.init(path: path.value, geometryOptions: geometryOptions, skinOptions: skinOptions)
    }

    public init(
        path: String,
        geometryOptions: GeometryImporterOptions = .none,
        skinOptions: SkinImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.skinnedGeometryCacheKey(
            path: path,
            geometryOptions: geometryOptions,
            skinOptions: skinOptions
        )
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    public init(rawGeometry: RawGeometry, skin: Skin) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.skinnedGeometryCacheKey(
            rawGeometry: rawGeometry,
            skin: skin
        )
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    deinit {
        let cacheKey = self.cacheKey
        Task {@MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
        }
    }
}
extension SkinnedGeometry: Equatable, Hashable {
    nonisolated public static func == (lhs: SkinnedGeometry, rhs: SkinnedGeometry) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}


// MARK: - Resource Manager

extension ResourceManager.Cache {
    @usableFromInline
    struct SkinnedGeometryKey: Hashable, Sendable, CustomStringConvertible {
        let requestedPath: String
        let geometryOptions: GeometryImporterOptions
        let skinOptions: SkinImporterOptions
        
        @usableFromInline
        var description: String {
            var string = requestedPath.first == "$" ? "(Generated)" : requestedPath
            if let name = geometryOptions.subobjectName {
                string += ", Named: \(name)"
            }
            return string
        }
    }

    final class SkinnedGeometryCache: ResourceCache {
        var geometryBackend: (any GeometryBackend)?
        var skinJoints: [Skin.Joint]?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.geometryBackend = nil
            self.skinJoints = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.defaultCacheHint = .until(minutes: 5)
        }
    }
}

@MainActor
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.SkinnedGeometryKey) {
        if let cache = self.cache.skinnedGeometries[key] {
            cache.cacheHint = cacheHint
            cache.minutesDead = 0
        }
    }

    func skinnedGeometryCacheKey(
        path: String,
        geometryOptions: GeometryImporterOptions,
        skinOptions: SkinImporterOptions
    ) -> Cache.SkinnedGeometryKey {
        let key = Cache.SkinnedGeometryKey(
            requestedPath: path,
            geometryOptions: geometryOptions,
            skinOptions: skinOptions
        )
        let cache = self.cache
        if cache.skinnedGeometries[key] == nil {
            cache.skinnedGeometries[key] = Cache.SkinnedGeometryCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached {
                do {
                    let geometry = try await RawGeometry(path: path, options: geometryOptions)
                    let skin = try await Skin(path: key.requestedPath, options: skinOptions)
                    Task { @MainActor in
                        if let cache = cache.skinnedGeometries[key] {
                            cache.geometryBackend = ResourceManager.geometryBackend(from: geometry, skin: skin)
                            cache.skinJoints = skin.joints
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"\(path)\" was deallocated before being loaded.")
                        }
                        Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                } catch let error as GateEngineError {
                    Task { @MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        if let cache = cache.skinnedGeometries[key] {
                            cache.state = .failed(error: error)
                        }
                        Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                } catch {
                    Log.fatalError("error must be a GateEngineError")
                }
            }
        }
        return key
    }

    func skinnedGeometryCacheKey(rawGeometry geometry: RawGeometry?, skin: Skin) -> Cache.SkinnedGeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.SkinnedGeometryKey(
            requestedPath: path,
            geometryOptions: .none,
            skinOptions: .none
        )
        if cache.skinnedGeometries[key] == nil {
            cache.skinnedGeometries[key] = Cache.SkinnedGeometryCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            if let geometry = geometry {
                if let cache = self.cache.skinnedGeometries[key] {
                    cache.geometryBackend = ResourceManager.geometryBackend(from: geometry, skin: skin)
                    cache.skinJoints = skin.joints
                    cache.state = .ready
                }else{
                    Log.warn("Resource \"(Generated SkinnedGeometry)\" was deallocated before being loaded.")
                }
                Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
            }
        }
        return key
    }

    func skinnedGeometryCache(for key: Cache.SkinnedGeometryKey) -> Cache.SkinnedGeometryCache? {
        return cache.skinnedGeometries[key]
    }

    func incrementReference(_ key: Cache.SkinnedGeometryKey) {
        self.skinnedGeometryCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.SkinnedGeometryKey) {
        guard let cache = self.skinnedGeometryCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.skinnedGeometries.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), SkinnedGeometry: \(key)")
            }
        }
    }

    func reloadSkinnedGeometryIfNeeded(key: Cache.SkinnedGeometryKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.skinnedGeometryNeedsReload(key: key) else { return }
        let cache = self.cache
        Task.detached {
            let geometry = try await RawGeometry(
                path: key.requestedPath,
                options: key.geometryOptions
            )
            let skin = try await Skin(path: key.requestedPath, options: key.skinOptions)
            Task { @MainActor in
                if let cache = cache.skinnedGeometries[key] {
                    cache.geometryBackend = ResourceManager.geometryBackend(from: geometry, skin: skin)
                    cache.skinJoints = skin.joints
                }else{
                    Log.warn("Resource \"\(key.requestedPath)\" was deallocated before being re-loaded.")
                }
            }
        }
    }

    func skinnedGeometryNeedsReload(key: Cache.SkinnedGeometryKey) -> Bool {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        #if GATEENGINE_ENABLE_HOTRELOADING
        guard let cache = cache.skinnedGeometries[key] else { return false }
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: key.requestedPath)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date
            {
                return modified > cache.lastLoaded
            } else {
                return false
            }
        } catch {
            Log.error(error)
            return false
        }
        #else
        return false
        #endif
    }

    static func geometryBackend(from raw: RawGeometry, skin: Skin) -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return OpenGLGeometry(geometry: raw, skin: skin)
        #elseif canImport(MetalKit)
        #if canImport(OpenGL_GateEngine)
        if MetalRenderer.isSupported == false {
            return OpenGLGeometry(geometry: raw, skin: skin)
        }
        #endif
        return MetalGeometry(geometry: raw, skin: skin)
        #elseif canImport(WebGL2)
        return WebGL2Geometry(geometry: raw, skin: skin)
        #elseif canImport(WinSDK)
        return DX12Geometry(geometry: raw, skin: skin)
        #elseif canImport(OpenGL_GateEngine)
        return OpenGLGeometry(geometry: raw, skin: skin)
        #else
        #error("Not implemented")
        #endif
    }
}

