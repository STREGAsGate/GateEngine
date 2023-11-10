/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
import Foundation
#endif

internal protocol SkinnedGeometryBackend: AnyObject {
    init(geometry: RawGeometry, skin: Skin)
}

/// Geometry represents a managed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class SkinnedGeometry: Resource {
    @usableFromInline
    internal let cacheKey: ResourceManager.Cache.SkinnedGeometryKey

    @usableFromInline
    internal var backend: (any GeometryBackend)? {
        return Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)?.geometryBackend
    }

    public var skinJoints: [Skin.Joint] {
        assert(state == .ready, "The state must be ready before accessing this property.")
        return Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)!.skinJoints!
    }

    public var cacheHint: CacheHint {
        get { Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)!.cacheHint }
        set { Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey) }
    }

    public var state: ResourceState {
        return Game.shared.resourceManager.skinnedGeometryCache(for: cacheKey)!.state
    }

    @inlinable @inline(__always) @_disfavoredOverload
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
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.skinnedGeometryCacheKey(
            path: path,
            geometryOptions: geometryOptions,
            skinOptions: skinOptions
        )
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    public init(rawGeometry: RawGeometry, skin: Skin) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.skinnedGeometryCacheKey(
            rawGeometry: rawGeometry,
            skin: skin
        )
        self.cacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    deinit {
        let cacheKey = self.cacheKey
        Task.detached(priority: .low) { @MainActor in
            Game.shared.resourceManager.decrementReference(cacheKey)
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
    struct SkinnedGeometryKey: Hashable, Sendable {
        let requestedPath: String
        let geometryOptions: GeometryImporterOptions
        let skinOptions: SkinImporterOptions
    }

    class SkinnedGeometryCache {
        var geometryBackend: (any GeometryBackend)?
        var skinJoints: [Skin.Joint]?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.geometryBackend = nil
            self.skinJoints = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.SkinnedGeometryKey) {
        if let cache = self.cache.skinnedGeometries[key] {
            cache.cacheHint = cacheHint
            cache.minutesDead = 0
        }
    }

    @MainActor func skinnedGeometryCacheKey(
        path: String,
        geometryOptions: GeometryImporterOptions,
        skinOptions: SkinImporterOptions
    ) -> Cache.SkinnedGeometryKey {
        let key = Cache.SkinnedGeometryKey(
            requestedPath: path,
            geometryOptions: geometryOptions,
            skinOptions: skinOptions
        )
        if cache.skinnedGeometries[key] == nil {
            cache.skinnedGeometries[key] = Cache.SkinnedGeometryCache()
            Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached(priority: .high) {
                do {
                    let geometry = try await RawGeometry(path: path, options: geometryOptions)
                    let skin = try await Skin(path: key.requestedPath, options: skinOptions)
                    let backend = await self.geometryBackend(from: geometry, skin: skin)
                    Task { @MainActor in
                        if let cache = self.cache.skinnedGeometries[key] {
                            cache.geometryBackend = backend
                            cache.skinJoints = skin.joints
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"\(path)\" was deallocated before being loaded.")
                        }
                        Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                } catch let error as GateEngineError {
                    Task { @MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        if let cache = self.cache.skinnedGeometries[key] {
                            cache.state = .failed(error: error)
                        }
                        Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                } catch {
                    Log.fatalError("error must be a GateEngineError")
                }
            }
        }
        return key
    }

    @MainActor func skinnedGeometryCacheKey(rawGeometry geometry: RawGeometry?, skin: Skin)
        -> Cache.SkinnedGeometryKey
    {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.SkinnedGeometryKey(
            requestedPath: path,
            geometryOptions: .none,
            skinOptions: .none
        )
        if cache.skinnedGeometries[key] == nil {
            cache.skinnedGeometries[key] = Cache.SkinnedGeometryCache()
            Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
            if let geometry = geometry {
                Task.detached(priority: .high) {
                    let backend = await self.geometryBackend(from: geometry, skin: skin)
                    Task { @MainActor in
                        if let cache = self.cache.skinnedGeometries[key] {
                            cache.geometryBackend = backend
                            cache.skinJoints = skin.joints
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"(Generated SkinnedGeometry)\" was deallocated before being loaded.")
                        }
                        Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                }
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
        
        if case .whileReferenced = cache.cacheHint {
            if cache.referenceCount == 0 {
                self.cache.skinnedGeometries.removeValue(forKey: key)
                Log.debug(
                    "Removing cache (no longer referenced), SkinnedGeometry:",
                    key.requestedPath.first == "$" ? "(Generated)" : key.requestedPath
                )
            }
        }
    }

    func reloadSkinnedGeometryIfNeeded(key: Cache.SkinnedGeometryKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        Task.detached(priority: .high) {
            guard self.skinnedGeometryNeedsReload(key: key) else { return }
            let geometry = try await RawGeometry(
                path: key.requestedPath,
                options: key.geometryOptions
            )
            let skin = try await Skin(path: key.requestedPath, options: key.skinOptions)
            let backend = await self.geometryBackend(from: geometry, skin: skin)
            Task { @MainActor in
                if let cache = self.cache.skinnedGeometries[key] {
                    cache.geometryBackend = backend
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

    func geometryBackend(from raw: RawGeometry, skin: Skin) async -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(geometry: raw, skin: skin)
        #elseif canImport(MetalKit)
        #if canImport(OpenGL_GateEngine)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(geometry: raw, skin: skin)
        }
        #endif
        return await MetalGeometry(geometry: raw, skin: skin)
        #elseif canImport(WebGL2)
        return await WebGL2Geometry(geometry: raw, skin: skin)
        #elseif canImport(WinSDK)
        return await DX12Geometry(geometry: raw, skin: skin)
        #elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(geometry: raw, skin: skin)
        #else
        #error("Not implemented")
        #endif
    }
}

