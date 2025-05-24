/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif

public extension Geometry {
    static let rectOriginCentered: Geometry = {
        let positions: [Float] = [
            -0.5, -0.5, 0.0,
            0.5, -0.5, 0.0,
            -0.5, 0.5, 0.0,
            -0.5, 0.5, 0.0,
            0.5, -0.5, 0.0,
            0.5, 0.5, 0.0,
        ]
        let uvs: [Float] = [
            0.0, 0.0,
            1.0, 0.0,
            0.0, 1.0,
            0.0, 1.0,
            1.0, 0.0,
            1.0, 1.0,
        ]
        let indices: [UInt16] = [0, 1, 2, 3, 4, 5]
        let raw = RawGeometry(
            positions: positions,
            uvSets: [uvs],
            normals: nil,
            tangents: nil,
            colors: nil,
            indices: indices
        )
        return Geometry(raw)
    }()

    static let rectOriginTopLeft: Geometry = {
        let positions: [Float] = [
            0.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            0.0, 1.0, 0.0,
            1.0, 0.0, 0.0,
            1.0, 1.0, 0.0,
        ]
        let uvs: [Float] = [
            0.0, 0.0,
            1.0, 0.0,
            0.0, 1.0,
            0.0, 1.0,
            1.0, 0.0,
            1.0, 1.0,
        ]
        let indices: [UInt16] = [0, 1, 2, 3, 4, 5]
        let raw = RawGeometry(
            positions: positions,
            uvSets: [uvs],
            normals: nil,
            tangents: nil,
            colors: nil,
            indices: indices
        )
        return Geometry(raw)
    }()
}

/// Geometry represents a mangaed vertex buffer object.
/// It's contents are stored within GPU accessible memory and this object represents a reference to that memory.
/// When this object deinitializes it's contents will also be removed from GPU memory.
@MainActor public class Geometry: Resource, _Resource {
    @usableFromInline
    internal let cacheKey: ResourceManager.Cache.GeometryKey
    
    var cache: any ResourceCache {
        return Game.shared.resourceManager.geometryCache(for: cacheKey)!
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
        self.cacheKey = resourceManager.geometryCacheKey(path: path, kind: .geometry, options: options)
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    internal init(optionalRawGeometry rawGeometry: RawGeometry?, immediate: Bool = false) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(rawGeometry: rawGeometry, kind: .geometry, immediate: immediate)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    /**
    - parameter immediate: true will block the thread while uploading to the GPU. For smaller geometry this may be faster.
     */
    public convenience init(_ rawGeometry: RawGeometry, immediate: Bool = false) {
        self.init(optionalRawGeometry: rawGeometry, immediate: immediate)
    }

    deinit {
        Game.unsafeShared.resourceManager.decrementReference(cacheKey)
    }
}
extension Geometry: Equatable, Hashable {
    nonisolated public static func == (lhs: Geometry, rhs: Geometry) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}


// MARK: - Resource Manager

public protocol GeometryImporter: ResourceImporter {
    func loadGeometry(options: GeometryImporterOptions) async throws -> RawGeometry
}

public struct GeometryImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil
    public var applyRootTransform: Bool = false

    /// Unique to each importer
    public var option1: Bool = false

    public static func with(name: String? = nil, applyRootTransform: Bool = false) -> Self {
        return GeometryImporterOptions(subobjectName: name, applyRootTransform: applyRootTransform)
    }

    public static var applyRootTransform: GeometryImporterOptions {
        return GeometryImporterOptions(applyRootTransform: true)
    }

    public static func named(_ name: String) -> Self {
        return GeometryImporterOptions(subobjectName: name)
    }

    public static var none: GeometryImporterOptions {
        return GeometryImporterOptions()
    }

    public static var option1: GeometryImporterOptions {
        return GeometryImporterOptions(subobjectName: nil, applyRootTransform: false, option1: true)
    }
}

extension ResourceManager {
    public func addGeometryImporter(_ type: any GeometryImporter.Type, atEnd: Bool = false) {
        guard importers.geometryImporters.contains(where: { $0 == type }) == false else { return }
        if atEnd {
            importers.geometryImporters.append(type)
        } else {
            importers.geometryImporters.insert(type, at: 0)
        }
    }

    func geometryImporterForPath(_ path: String) async throws -> (any GeometryImporter)? {
        for type in self.importers.geometryImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        return nil
    }
}

extension RawGeometry {
    @inlinable @_disfavoredOverload
    public init(_ path: GeoemetryPath, options: GeometryImporterOptions = .none) async throws {
        try await self.init(path: path.value, options: options)
    }
    public init(path: String, options: GeometryImporterOptions = .none) async throws {
        guard
            let importer: any GeometryImporter = try await Game.shared.resourceManager.geometryImporterForPath(path)
        else {
            throw GateEngineError.failedToLoad("No importer for \(URL(fileURLWithPath: path).pathExtension).")
        }

        do {
            self = try await importer.loadGeometry(options: options)
        } catch {
            throw GateEngineError(error)
        }
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct GeometryKey: Hashable, Sendable, CustomStringConvertible {
        enum Kind: Hashable {
            case geometry
            case lines
            case points
        }
        let requestedPath: String
        let kind: Kind
        let geometryOptions: GeometryImporterOptions
        
        @usableFromInline
        var description: String {
            var string = requestedPath.first == "$" ? "(Generated)" : requestedPath
            if let name = geometryOptions.subobjectName {
                string += ", Named: \(name)"
            }
            return string
        }
    }

    @usableFromInline
    final class GeometryCache: ResourceCache {
        @usableFromInline var geometryBackend: (any GeometryBackend)?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.geometryBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = nil
            self.defaultCacheHint = .until(minutes: 5)
        }
    }
}

extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.GeometryKey) {
        if let cache = self.cache.geometries[key] {
            cache.cacheHint = cacheHint
            cache.minutesDead = 0
        }
    }

    @MainActor func geometryCacheKey(path: String, kind: Cache.GeometryKey.Kind, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, kind: kind, geometryOptions: options)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached(priority: .high) {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    let backend = await self.geometryBackend(from: geometry)
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

    @MainActor func geometryCacheKey(rawGeometry geometry: RawGeometry?, kind: Cache.GeometryKey.Kind, immediate: Bool) -> Cache.GeometryKey {
        let path = "$\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, kind: kind, geometryOptions: .none)
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let geometry = geometry {
                if immediate {
                    let backend = self.geometryBackendImmadiate(from: geometry)
                    if let cache = self.cache.geometries[key] {
                        cache.geometryBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"(Generated Geometry)\" was deallocated before being loaded.")
                    }
                }else{
                    Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
                    Task.detached(priority: .high) {
                        let backend = await self.geometryBackend(from: geometry)
                        Task { @MainActor in
                            if let cache = self.cache.geometries[key] {
                                cache.geometryBackend = backend
                                cache.state = .ready
                            }else{
                                Log.warn("Resource \"(Generated Geometry)\" was deallocated before being loaded.")
                            }
                            Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                        }
                    }
                }
            }
        }
        return key
    }

    @usableFromInline
    func geometryCache(for key: Cache.GeometryKey) -> Cache.GeometryCache? {
        return cache.geometries[key]
    }

    func incrementReference(_ key: Cache.GeometryKey) {
        self.geometryCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.GeometryKey) {
        guard let cache = self.geometryCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.geometries.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), Geometry: \(key)")
            }
        }
    }

    func reloadGeometryIfNeeded(key: Cache.GeometryKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        Task.detached {
            guard self.geometryNeedsReload(key: key) else { return }
            guard let cache = self.geometryCache(for: key) else { return }
            let geometry = try await RawGeometry(
                path: key.requestedPath,
                options: key.geometryOptions
            )
            let backend = await self.geometryBackend(from: geometry)
            Task { @MainActor in
                cache.geometryBackend = backend
            }
        }
    }

    func geometryNeedsReload(key: Cache.GeometryKey) -> Bool {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
        guard let cache = cache.geometries[key] else { return false }
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

    func geometryBackend(from raw: RawGeometry) async -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return await OpenGLGeometry(geometry: raw)
        #elseif canImport(MetalKit)
        #if canImport(OpenGL_GateEngine)
        if await MetalRenderer.isSupported == false {
            return await OpenGLGeometry(geometry: raw)
        }
        #endif
        return await MetalGeometry(geometry: raw)
        #elseif canImport(WebGL2)
        return await WebGL2Geometry(geometry: raw)
        #elseif canImport(WinSDK)
        return await DX12Geometry(geometry: raw)
        #elseif canImport(OpenGL_GateEngine)
        return await OpenGLGeometry(geometry: raw)
        #else
        #error("Not implemented")
        #endif
    }
    
    @MainActor
    func geometryBackendImmadiate(from raw: RawGeometry) -> any GeometryBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        return OpenGLGeometry(geometry: raw)
        #elseif canImport(MetalKit)
        #if canImport(OpenGL_GateEngine)
        if MetalRenderer.isSupported == false {
            return OpenGLGeometry(geometry: raw)
        }
        #endif
        return MetalGeometry(geometry: raw)
        #elseif canImport(WebGL2)
        return WebGL2Geometry(geometry: raw)
        #elseif canImport(WinSDK)
        return DX12Geometry(geometry: raw)
        #elseif canImport(OpenGL_GateEngine)
        return OpenGLGeometry(geometry: raw)
        #else
        #error("Not implemented")
        #endif
    }
}


