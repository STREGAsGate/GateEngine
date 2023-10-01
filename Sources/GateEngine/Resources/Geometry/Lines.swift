/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Geometry represents a mangaed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class Lines: Resource {
    @usableFromInline
    let cacheKey: ResourceManager.Cache.GeometryKey

    @usableFromInline
    internal var backend: (any GeometryBackend)? {
        return Game.shared.resourceManager.geometryCache(for: cacheKey)?.geometryBackend
    }

    public var cacheHint: CacheHint {
        get { Game.shared.resourceManager.geometryCache(for: cacheKey)!.cacheHint }
        set { Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey) }
    }

    public var state: ResourceState {
        return Game.shared.resourceManager.geometryCache(for: cacheKey)!.state
    }

    @inlinable @inline(__always) @_disfavoredOverload
    public convenience init(as path: GeoemetryPath, options: GeometryImporterOptions = .none) {
        self.init(path: path.value, options: options)
    }

    public init(path: String, options: GeometryImporterOptions = .none) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(path: path, options: options)
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    public init(_ rawLines: RawLines) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(rawLines: rawLines)
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

extension Lines: Equatable, Hashable {
    nonisolated public static func == (lhs: Lines, rhs: Lines) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}


// MARK: - Resource Manager

extension ResourceManager {
    func geometryCacheKey(rawLines lines: RawLines?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let lines = lines {
                Task.detached(priority: .low) {
                    let backend = await self.geometryBackend(from: lines)
                    Task { @MainActor in
                        self.cache.geometries[key]!.geometryBackend = backend
                        self.cache.geometries[key]!.state = .ready
                    }
                }
            }
        }
        return key
    }

    func geometryBackend(from raw: RawLines) async -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(lines: raw)
        #elseif canImport(MetalKit)
        #if canImport(GLKit)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(lines: raw)
        }
        #endif
        return await MetalGeometry(lines: raw)
        #elseif canImport(WebGL2)
        return await WebGL2Geometry(lines: raw)
        #elseif canImport(WinSDK)
        return await DX12Geometry(lines: raw)
        #elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(lines: raw)
        #else
        #error("Not implemented")
        #endif
    }
}
