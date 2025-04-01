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
        return Game.shared.resourceManager.geometryCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: (any GeometryBackend)? {
        return Game.shared.resourceManager.geometryCache(for: cacheKey)?.geometryBackend
    }

    @inlinable @_disfavoredOverload
    public convenience init(as path: GeoemetryPath, options: GeometryImporterOptions = .none) {
        self.init(path: path.value, options: options)
    }

    public init(path: String, options: GeometryImporterOptions = .none) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.pointsCacheKey(path: path, options: options)
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    internal init(optionalRawPoints rawPoints: RawPoints?) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.pointsCacheKey(rawPoints: rawPoints)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    public convenience init(_ rawPoints: RawPoints) {
        self.init(optionalRawPoints: rawPoints)
    }

    deinit {
        let cacheKey = self.cacheKey
        Task.detached(priority: .low) { @MainActor in
            Game.shared.resourceManager.decrementReference(cacheKey)
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
        let file = URL(fileURLWithPath: path)
        guard
            let importer: any GeometryImporter = await Game.shared.resourceManager.geometryImporterForFile(
                file
            )
        else {
            throw GateEngineError.failedToLoad("No importer for \(file.pathExtension).")
        }

        do {
            self = RawPoints(pointCloudFrom: try await importer.loadData(path: path, options: options).generateTriangles())
        } catch {
            throw GateEngineError(error)
        }
    }
}

// MARK: - Resource Manager

extension ResourceManager {
    @MainActor func pointsCacheKey(path: String, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: options)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached(priority: .high) {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let points = RawPoints(pointCloudFrom: geometry.generateTriangles())
                    let backend = await self.geometryBackend(from: points)
                    Task { @MainActor in
                        if let cache = self.cache.geometries[key] {
                            cache.geometryBackend = backend
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"\(path)\" was deallocated before being loaded.")
                        }
                        Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                } catch let error as GateEngineError {
                    Task { @MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        if let cache = self.cache.geometries[key] {
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
    
    @MainActor func pointsCacheKey(rawPoints points: RawPoints?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let points {
                Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
                Task.detached(priority: .high) {
                    let backend = await self.geometryBackend(from: points)
                    Task { @MainActor in
                        if let cache = self.cache.geometries[key] {
                            cache.geometryBackend = backend
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"(Generated Points)\" was deallocated before being loaded.")
                        }
                        Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                    }
                }
            }
        }
        return key
    }

    func geometryBackend(from raw: RawPoints) async -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(points: raw)
        #elseif canImport(MetalKit)
        #if canImport(GLKit)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(points: raw)
        }
        #endif
        return await MetalGeometry(points: raw)
        #elseif canImport(WebGL2)
        return await WebGL2Geometry(points: raw)
        #elseif canImport(WinSDK)
        return await DX12Geometry(points: raw)
        #elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(points: raw)
        #else
        #error("Not implemented")
        #endif
    }
}
