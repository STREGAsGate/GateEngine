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
            indexes: indices
        ).cleaned()
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
            indexes: indices
        ).cleaned()
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
        return Game.unsafeShared.resourceManager.geometryCache(for: cacheKey)!
    }

    @usableFromInline
    internal var backend: (any GeometryBackend)? {
        return Game.unsafeShared.resourceManager.geometryCache(for: cacheKey)?.geometryBackend
    }

    @inlinable @_disfavoredOverload
    public convenience init(as path: GeometryPath, options: GeometryImporterOptions = .none) {
        self.init(path: path.value, options: options)
    }

    public init(path: String, options: GeometryImporterOptions = .none) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(path: path, kind: .geometry, options: options)
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }

    internal init(optionalRawGeometry rawGeometry: RawGeometry?, isText: Bool) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.geometryCacheKey(rawGeometry: rawGeometry, kind: .geometry, isText: isText)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }

    /**
    - parameter immediate: true will block the thread while uploading to the GPU. For smaller geometry this may be faster.
     */
    public convenience init(_ rawGeometry: RawGeometry) {
        self.init(optionalRawGeometry: rawGeometry, isText: false)
    }

    deinit {
        let cacheKey = self.cacheKey
        Task { @MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
        }
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
    func loadGeometry(options: GeometryImporterOptions) async throws(GateEngineError) -> RawGeometry
}

public struct GeometryImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil
    public var applyRootTransform: Bool = false
    public var makeInstancesReal: Bool = false

    /// Unique to each importer
    public var option1: Bool = false

    public static func with(name: String? = nil, applyRootTransform: Bool = false) -> Self {
        return GeometryImporterOptions(subobjectName: name, applyRootTransform: applyRootTransform)
    }
    
    public static func with(name: String? = nil, makeInstancesReal: Bool = false) -> Self {
        return GeometryImporterOptions(subobjectName: name, makeInstancesReal: makeInstancesReal)
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
    
    func geometryImporterForPath(_ path: String) async throws(GateEngineError) -> any GeometryImporter {
        for type in self.importers.geometryImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        throw .custom(category: "\(Self.self)", message: "No GeometryImporter could be found for \(path)")
    }
}

extension RawGeometry {
    @inlinable @_disfavoredOverload
    public init(as path: GeometryPath, options: GeometryImporterOptions = .none) async throws(GateEngineError) {
        try await self.init(path: path.value, options: options)
    }
    public init(path: String, options: GeometryImporterOptions = .none) async throws(GateEngineError) {
        let importer = try await Game.unsafeShared.resourceManager.geometryImporterForPath(path)
        self = try await importer.loadGeometry(options: options)
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
        var isGenerated: Bool {
            let firstChar = self.requestedPath[self.requestedPath.startIndex]
            return firstChar == "$" || firstChar == "@"
        }
        
        @usableFromInline
        var description: String {
            var string = switch requestedPath.first {
            case "$":
                "(Generated)"
            case "@":
                "(Text)"
            default:
                requestedPath
            }
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

@MainActor
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.GeometryKey) {
        if let cache = self.cache.geometries[key] {
            cache.cacheHint = cacheHint
            cache.minutesDead = 0
        }
    }

    func geometryCacheKey(path: String, kind: Cache.GeometryKey.Kind, options: GeometryImporterOptions) -> Cache.GeometryKey {
        let key = Cache.GeometryKey(requestedPath: path, kind: kind, geometryOptions: options)
        let cache = self.cache
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached {
                do {
                    let geometry = try await RawGeometry(path: path, options: options)
                    Task { @MainActor in
                        if let cache = cache.geometries[key] {
                            cache.geometryBackend = ResourceManager.geometryBackend(from: geometry)
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

    func geometryCacheKey(rawGeometry geometry: RawGeometry?, kind: Cache.GeometryKey.Kind, isText: Bool) -> Cache.GeometryKey {
        let path = "\(isText ? "@" : "$")\(rawCacheIDGenerator.generateID())"
        let key = Cache.GeometryKey(requestedPath: path, kind: kind, geometryOptions: .none)
        let cache = self.cache
        if cache.geometries[key] == nil {
            cache.geometries[key] = Cache.GeometryCache()
            if let geometry = geometry {
                if let cache = cache.geometries[key] {
                    cache.geometryBackend = ResourceManager.geometryBackend(from: geometry)
                    cache.state = .ready
                }else{
                    Log.warn("Resource \"(Generated Geometry)\" was deallocated before being loaded.")
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
        guard key.requestedPath.first != "$" && key.requestedPath.first != "@" else { return }
        guard self.geometryNeedsReload(key: key) else { return }
        let cache = self.cache
        Task.detached {
            let geometry = try await RawGeometry(
                path: key.requestedPath,
                options: key.geometryOptions
            )
            Task { @MainActor in
                if let cache = cache.geometries[key] {
                    cache.geometryBackend = ResourceManager.geometryBackend(from: geometry)
                }
            }
        }
    }

    func geometryNeedsReload(key: Cache.GeometryKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
        guard key.isGenerated == false else { return false }
        guard let cache = cache.geometries[key], cache.referenceCount > 0 else { return false }
        guard let path = Platform.current.synchronousLocateResource(from: key.requestedPath) else {return false}
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let modified = (attributes[.modificationDate] ?? attributes[.creationDate]) as? Date {
                return Calendar.current.compare(modified, to: cache.lastLoaded, toGranularity: .second) == .orderedDescending
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

    @MainActor
    static func geometryBackend(from raw: RawGeometry) -> any GeometryBackend {
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


