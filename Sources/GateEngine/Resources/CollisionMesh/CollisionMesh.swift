/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
 
#if GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif
import GameMath

@MainActor 
public final class CollisionMesh: Resource, _Resource {
    internal let cacheKey: ResourceManager.Cache.CollisionMeshKey
    
    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.collisionMeshCache(for: cacheKey)!
    }
    
    var receipt: UInt8 {
        return Game.unsafeShared.resourceManager.collisionMeshCache(for: cacheKey)!.receipt
    }
    
    @usableFromInline
    internal var backend: CollisionMeshBackend {
        return Game.unsafeShared.resourceManager.collisionMeshCache(for: cacheKey)!.collisionMeshBackend!
    }
    
    @inlinable
    public func generateCollisionTriangles() -> [CollisionTriangle] {
        return backend.rawCollisionMesh.generateCollisionTriangles()
    }
    
    @inlinable
    public func withTriangle<A: CollisionAttributesGroup, ResultType>(
        atIndex index: Int,
        with attributesType: A.Type = BasicCollisionAttributes.self,
        _ provideTriangle: (_ triangle: borrowing RawCollisionMesh.Triangle<A>) -> ResultType
    ) -> ResultType {
        backend.rawCollisionMesh.withTriangle(atIndex: index, with: attributesType, provideTriangle)
    }
    
    public init(
        path: String,
        options: CollisionMeshImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.collisionMeshCacheKey(
            path: path,
            options: options
        )
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(rawCollisionMesh: RawCollisionMesh) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.collisionMeshCacheKey(rawCollisionMesh: rawCollisionMesh)
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

extension CollisionMesh: Equatable, Hashable {
    nonisolated public static func == (lhs: CollisionMesh, rhs: CollisionMesh) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }

    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

public final class CollisionMeshBackend {
    @usableFromInline
    let rawCollisionMesh: RawCollisionMesh
    var state: ResourceState = .pending
    
    init(rawCollisionMesh: RawCollisionMesh) {
        self.rawCollisionMesh = rawCollisionMesh
        self.state = .ready
    }
}


// MARK: - Resource Manager

public protocol CollisionMeshImporter: ResourceImporter {
    func loadCollisionMesh(options: CollisionMeshImporterOptions) async throws(GateEngineError) -> RawCollisionMesh
}

public struct CollisionMeshImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil
    public var applyRootTransform: Bool = false
    public var makeInstancesReal: Bool = false
    public var collisionAttributes: any CollisionAttributesGroup.Type = BasicCollisionAttributes.self

    /// Unique to each importer
    public var option1: Bool = false

    public static func with(name: String? = nil, applyRootTransform: Bool = false) -> Self {
        return Self(subobjectName: name, applyRootTransform: applyRootTransform)
    }
    
    public static func with(name: String? = nil, applyRootTransform: Bool = false, collisionAttributes: any CollisionAttributesGroup.Type) -> Self {
        return Self(subobjectName: name, applyRootTransform: applyRootTransform, collisionAttributes: collisionAttributes)
    }
    
    public static func with(name: String? = nil, makeInstancesReal: Bool = false) -> Self {
        return Self(subobjectName: name, makeInstancesReal: makeInstancesReal)
    }
    
    @_disfavoredOverload
    public static func with(name: String? = nil, makeInstancesReal: Bool = false, collisionAttributes: any CollisionAttributesGroup.Type) -> Self {
        return Self(subobjectName: name, makeInstancesReal: makeInstancesReal, collisionAttributes: collisionAttributes)
    }
    
    public static func using(_ collisionAttributes: any CollisionAttributesGroup.Type) -> Self {
        return Self(collisionAttributes: collisionAttributes)
    }

    public static var applyRootTransform: Self {
        return Self(applyRootTransform: true)
    }

    public static func named(_ name: String, using collisionAttributes: any CollisionAttributesGroup.Type) -> Self {
        return Self(subobjectName: name, collisionAttributes: collisionAttributes)
    }

    public static var none: Self {
        return Self()
    }
    
    public static var option1: Self {
        return Self(subobjectName: nil, applyRootTransform: false, option1: true)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.subobjectName == rhs.subobjectName && 
        lhs.applyRootTransform == rhs.applyRootTransform && 
        lhs.option1 == rhs.option1 && 
        "\(type(of: lhs.collisionAttributes))" == "\(type(of: rhs.collisionAttributes))"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.subobjectName)
        hasher.combine(self.applyRootTransform)
        hasher.combine(self.makeInstancesReal)
        hasher.combine(self.option1)
        hasher.combine("\(type(of: self.collisionAttributes))")
    }
}

extension ResourceManager {
    public func addCollisionMeshImporter(_ type: any CollisionMeshImporter.Type) {
        guard importers.collisionMeshImporters.contains(where: { $0 == type }) == false else { return }
        importers.collisionMeshImporters.insert(type, at: 0)
    }

    func collisionMeshImporterForPath(_ path: String) async throws(GateEngineError) -> any CollisionMeshImporter {
        for type in self.importers.collisionMeshImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        throw .custom(category: "\(Self.self)", message: "No CollisionMeshImporter could be found for \(path)")
    }
}

public extension RawCollisionMesh {
    init(path: String, options: CollisionMeshImporterOptions = .none) async throws {
        let importer: any CollisionMeshImporter = try await Game.unsafeShared.resourceManager.collisionMeshImporterForPath(path)
        self = try await importer.loadCollisionMesh(options: options)
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct CollisionMeshKey: Hashable, Sendable, CustomStringConvertible {
        let requestedPath: String
        let collisionMeshOptions: CollisionMeshImporterOptions
        
        @usableFromInline
        var isGenerated: Bool {
            return self.requestedPath[self.requestedPath.startIndex] == "$"
        }
        
        @usableFromInline
        var description: String {
            return self.isGenerated ? "(Generated)" : self.requestedPath
        }
    }

    @usableFromInline
    final class CollisionMeshCache: ResourceCache {
        @usableFromInline var collisionMeshBackend: CollisionMeshBackend? {
            didSet {
                self.receipt &+= 1
            }
        }
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        var receipt: UInt8 = 0
        init() {
            self.collisionMeshBackend = nil
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
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.CollisionMeshKey) {
        if let collisionMeshCache = cache.collisionMeshes[key] {
            collisionMeshCache.cacheHint = cacheHint
            collisionMeshCache.minutesDead = 0
        }
    }
    
    @MainActor func collisionMeshCacheKey(path: String, options: CollisionMeshImporterOptions) -> Cache.CollisionMeshKey {
        let key = Cache.CollisionMeshKey(requestedPath: path, collisionMeshOptions: options)
        if cache.collisionMeshes[key] == nil {
            cache.collisionMeshes[key] = Cache.CollisionMeshCache()
            self._reloadCollisionMesh(for: key, isFirstLoad: true)
        }
        return key
    }
    
    @MainActor func collisionMeshCacheKey(rawCollisionMesh: RawCollisionMesh) -> Cache.CollisionMeshKey {
        let key = Cache.CollisionMeshKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", collisionMeshOptions: .none)
        let cache = self.cache
        if cache.collisionMeshes[key] == nil {
            cache.collisionMeshes[key] = Cache.CollisionMeshCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            if let cache = cache.collisionMeshes[key] {
                cache.collisionMeshBackend = CollisionMeshBackend(rawCollisionMesh: rawCollisionMesh)
                cache.state = .ready
            }else{
                Log.warn("Resource \"(Generated CollisionMesh)\" was deallocated before being loaded.")
            }
            Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
        }
        return key
    }
    
    @usableFromInline
    func collisionMeshCache(for key: Cache.CollisionMeshKey) -> Cache.CollisionMeshCache? {
        return cache.collisionMeshes[key]
    }
    
    func incrementReference(_ key: Cache.CollisionMeshKey) {
        self.collisionMeshCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.CollisionMeshKey) {
        guard let cache = self.collisionMeshCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.collisionMeshes.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), CollisionMesh: \(key)")
            }
        }
    }
    
    func reloadCollisionMeshIfNeeded(key: Cache.CollisionMeshKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.collisionMeshNeedsReload(key: key) else { return }
        self._reloadCollisionMesh(for: key, isFirstLoad: false)
    }
    
    @MainActor func _reloadCollisionMesh(for key: Cache.CollisionMeshKey, isFirstLoad: Bool) {
        Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
        let cache = self.cache
        Task.detached {
            let path = key.requestedPath
            
            do {
                let rawCollisionMesh = try await RawCollisionMesh(path: path, options: key.collisionMeshOptions)
                
                Task { @MainActor in
                    if let cache = cache.collisionMeshes[key] {
                        cache.collisionMeshBackend = CollisionMeshBackend(rawCollisionMesh: rawCollisionMesh)
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.collisionMeshes[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.collisionMeshes[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func collisionMeshNeedsReload(key: Cache.CollisionMeshKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
        guard key.isGenerated == false else { return false }
        guard let cache = cache.collisionMeshes[key], cache.referenceCount > 0 else { return false }
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
}
