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
        self.cacheKey = resourceManager.linesCacheKey(path: path, options: options)
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    public init(_ rawLines: RawLines) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.linesCacheKey(rawLines: rawLines)
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

extension RawLines {
    @inlinable @inline(__always) @_disfavoredOverload
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
            self = RawLines(wireframeFrom: try await importer.loadData(path: path, options: options).generateTriangles())
        } catch {
            throw GateEngineError(decodingError: error)
        }
    }
}


// MARK: - Resource Manager

extension ResourceManager {
    func linesCacheKey(path: String, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: options)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Task.detached(priority: .low) {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let lines = RawLines(wireframeFrom: geometry.generateTriangles())
                    let backend = await self.geometryBackend(from: lines)
                    Task { @MainActor in
                        if let cache = self.cache.geometries[key] {
                            cache.geometryBackend = backend
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"\(path)\" was deallocated before being loaded.")
                        }
                    }
                } catch let error as GateEngineError {
                    Task { @MainActor in
                        Log.warn("Resource \"\(path)\"", error)
                        if let cache = self.cache.geometries[key] {
                            cache.state = .failed(error: error)
                        }
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
        let key = Cache.GeometryKey(requestedPath: path, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let lines = lines {
                Task.detached(priority: .low) {
                    let backend = await self.geometryBackend(from: lines)
                    Task { @MainActor in
                        if let cache = self.cache.geometries[key] {
                            cache.geometryBackend = backend
                            cache.state = .ready
                        }else{
                            Log.warn("Resource \"(Generated Lines)\" was deallocated before being loaded.")
                        }
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
