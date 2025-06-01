/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Geometry represents a mangaed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class Points: Resource, _Resource {
    @usableFromInline
    internal let cacheKey: ResourceManager.Cache.GeometryKey

    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.geometryCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: (any GeometryBackend)? {
        return Game.unsafeShared.resourceManager.geometryCache(for: cacheKey)?.geometryBackend
    }

    @inlinable @_disfavoredOverload
    public convenience init(as path: GeoemetryPath, options: GeometryImporterOptions = .none) {
        self.init(path: path.value, options: options)
    }

    public init(path: String, options: GeometryImporterOptions = .none) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.pointsCacheKey(path: path, options: options)
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    internal init(optionalRawPoints rawPoints: RawPoints?) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.pointsCacheKey(rawPoints: rawPoints)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    public convenience init(_ rawPoints: RawPoints) {
        self.init(optionalRawPoints: rawPoints)
    }

    deinit {
        let cacheKey = self.cacheKey
        Task {@MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
        }
    }
}

extension Points: Equatable, Hashable {
    nonisolated public static func == (lhs: Points, rhs: Points) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

extension RawPoints {
    @inlinable @_disfavoredOverload
    public init(_ path: GeoemetryPath, options: GeometryImporterOptions = .none) async throws {
        try await self.init(path: path.value, options: options)
    }
    public init(path: String, options: GeometryImporterOptions = .none) async throws {
        guard let importer: any GeometryImporter = try await Game.unsafeShared.resourceManager.geometryImporterForPath(path) else {
            throw GateEngineError.failedToLoad("No importer for \(URL(fileURLWithPath: path).pathExtension).")
        }

        do {
            self = RawPoints(pointCloudFrom: try await importer.loadGeometry(options: options).generateTriangles())
        } catch {
            throw GateEngineError(error)
        }
    }
}

// MARK: - Resource Manager

@MainActor
extension ResourceManager {
    func pointsCacheKey(path: String, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, kind: .points, geometryOptions: options)
        let cache = self.cache
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let points = RawPoints(pointCloudFrom: geometry.generateTriangles())
                    Task { @MainActor in
                        if let cache = cache.geometries[key] {
                            cache.geometryBackend = ResourceManager.geometryBackend(from: points)
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"\(path)\" was deallocated before being loaded.")
                        }
                        Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                } catch let error as GateEngineError {
                    Task { @MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        if let cache = cache.geometries[key] {
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
    
    func pointsCacheKey(rawPoints points: RawPoints?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, kind: .points, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let points {
                Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
                if let cache = self.cache.geometries[key] {
                    cache.geometryBackend = ResourceManager.geometryBackend(from: points)
                    cache.state = .ready
                }else{
                    Log.warn("Resource \"(Generated Points)\" was deallocated before being loaded.")
                }
                Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
            }
        }
        return key
    }

    static func geometryBackend(from raw: RawPoints) -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return OpenGLGeometry(points: raw)
        #elseif canImport(MetalKit)
        #if canImport(GLKit)
        if MetalRenderer.isSupported == false {
            return OpenGLGeometry(points: raw)
        }
        #endif
        return MetalGeometry(points: raw)
        #elseif canImport(WebGL2)
        return WebGL2Geometry(points: raw)
        #elseif canImport(WinSDK)
        return DX12Geometry(points: raw)
        #elseif canImport(OpenGL_GateEngine)
        return OpenGLGeometry(points: raw)
        #else
        #error("Not implemented")
        #endif
    }
}
