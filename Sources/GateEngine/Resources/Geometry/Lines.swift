/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Geometry represents a mangaed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class Lines: Resource, _Resource {
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
        self.cacheKey = resourceManager.linesCacheKey(path: path, options: options)
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    internal init(optionalRawLines rawLines: RawLines?) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.linesCacheKey(rawLines: rawLines)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public convenience init(_ rawLines: RawLines) {
        self.init(optionalRawLines: rawLines)
    }

    deinit {
        let cacheKey = self.cacheKey
        Task { @MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
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

extension RawLines {
    @inlinable @_disfavoredOverload
    public init(_ path: GeoemetryPath, options: GeometryImporterOptions = .none) async throws {
        try await self.init(path: path.value, options: options)
    }
    public init(path: String, options: GeometryImporterOptions = .none) async throws {
        guard let importer: any GeometryImporter = try await Game.unsafeShared.resourceManager.geometryImporterForPath(path) else {
            throw GateEngineError.failedToLoad("No importer for \(URL(fileURLWithPath: path).pathExtension).")
        }

        do {
            self = RawLines(wireframeFrom: try await importer.loadGeometry(options: options).generateTriangles())
        } catch {
            throw GateEngineError(error)
        }
    }
}


// MARK: - Resource Manager
@MainActor
extension ResourceManager {
    func linesCacheKey(path: String, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, kind: .lines, geometryOptions: options)
        let cache = self.cache
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let lines = RawLines(wireframeFrom: geometry.generateTriangles())
                    Task { @MainActor in
                        if let cache = cache.geometries[key] {
                            cache.geometryBackend = ResourceManager.geometryBackend(from: lines)
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
    
    func linesCacheKey(rawLines lines: RawLines?) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, kind: .lines, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let lines = lines {
                Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
                
                if let cache = self.cache.geometries[key] {
                    cache.geometryBackend = ResourceManager.geometryBackend(from: lines)
                    cache.state = .ready
                }else{
                    Log.warn("Resource \"(Generated Lines)\" was deallocated before being loaded.")
                }
                Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
            }
        }
        return key
    }

    static func geometryBackend(from raw: RawLines) -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return OpenGLGeometry(lines: raw)
        #elseif canImport(MetalKit)
        #if canImport(GLKit)
        if MetalRenderer.isSupported == false {
            return OpenGLGeometry(lines: raw)
        }
        #endif
        return MetalGeometry(lines: raw)
        #elseif canImport(WebGL2)
        return WebGL2Geometry(lines: raw)
        #elseif canImport(WinSDK)
        return DX12Geometry(lines: raw)
        #elseif canImport(OpenGL_GateEngine)
        return OpenGLGeometry(lines: raw)
        #else
        #error("Not implemented")
        #endif
    }
}
