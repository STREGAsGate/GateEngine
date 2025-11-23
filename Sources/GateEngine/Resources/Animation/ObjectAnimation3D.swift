/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif

@MainActor public final class ObjectAnimation3D: Resource, _Resource {
    public typealias NodeAnimation = SkeletalAnimation.JointAnimation
    internal let cacheKey: ResourceManager.Cache.ObjectAnimation3DKey
    
    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.objectAnimation3DCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: ObjectAnimation3DBackend {
        assert(state == .ready, "This resource is not ready to be used. Make sure it's state property is .ready before accessing!")
        return Game.unsafeShared.resourceManager.objectAnimation3DCache(for: cacheKey)!.objectAnimation3DBackend!
    }
    
    public var name: String {
        return backend.name
    }
    public var duration: Float {
        return backend.duration
    }
    public var animation: ObjectAnimation3D.NodeAnimation {
        return backend.animation
    }
    
    public var scale: Float = 1
    public var repeats: Bool = false

    public func currentFrame(assumingFrameRate fps: UInt) -> UInt {
        let totalFrames = Float(fps) * duration
        guard accumulatedTime <= duration else {return UInt(totalFrames)}            
        return UInt(accumulatedTime * totalFrames)
    }

    public var accumulatedTime: Float = 0 {
        didSet {
            guard repeats else { return }
            if accumulatedTime > duration {
                accumulatedTime -= duration
            }
        }
    }

    @inlinable
    public var progress: Float {
        get {
            return .maximum(
                0,
                .minimum(1, (Float(accumulatedTime) * scale) / Float(duration))
            )
        }
        set {
            var newValue = newValue
            if repeats && newValue > 1 {
                while newValue > 1 {
                    newValue -= 1
                }
            }
            accumulatedTime = duration * newValue
        }
    }

    @inlinable
    public var isFinished: Bool {
        guard duration > 0 else { return true }
        if repeats {
            return false
        }
        return self.progress >= 1
    }
    
    public init(
        path: String,
        options: ObjectAnimation3DImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.objectAnimation3DCacheKey(
            path: path,
            options: options
        )
        if cachHintIsDefault {
            self.cacheHint = .until(minutes: 5)
        }
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(name: String, duration: Float, animation: RawObjectAnimation3D.NodeAnimation) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.objectAnimation3DCacheKey(
            RawObjectAnimation3D(name: name, duration: duration, animation: animation)
        )
        if cachHintIsDefault {
            self.cacheHint = .until(minutes: 5)
        }
        resourceManager.incrementReference(self.cacheKey)
    }
    
    @MainActor 
    public func applyAnimation(
        atTime time: Float,
        repeating: Bool,
        interpolateProgress: Float,
        to transform: inout Transform3
    ) {
        let interpolate = interpolateProgress < 1
        var newTransform = transform
        
        _ = animation.updateTransform(
            &newTransform,
            withTime: time,
            duration: duration,
            repeating: repeating
        )
        
        if interpolate {
            transform.interpolate(to: newTransform, .linear(interpolateProgress))
        } else {
            transform = newTransform
        }
    }
}

extension ObjectAnimation3D: Equatable, Hashable {
    nonisolated public static func == (lhs: ObjectAnimation3D, rhs: ObjectAnimation3D) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

public struct RawObjectAnimation3D {
    public typealias NodeAnimation = RawSkeletalAnimation.JointAnimation
    var name: String
    var duration: Float
    var animation: NodeAnimation
    
    public init(name: String, duration: Float, animation: RawObjectAnimation3D.NodeAnimation) {
        self.name = name
        self.duration = duration
        self.animation = animation
    }
}

@usableFromInline
internal struct ObjectAnimation3DBackend {
    let name: String
    let duration: Float
    let animation: ObjectAnimation3D.NodeAnimation
    
    init(_ rawObjectAnimation3D: RawObjectAnimation3D) {
        self.name = rawObjectAnimation3D.name
        self.duration = rawObjectAnimation3D.duration
        self.animation = .init(rawObjectAnimation3D.animation)
    }
}

extension RawObjectAnimation3D: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try self.name.encode(into: &data, version: version)
            try self.duration.encode(into: &data, version: version)
            try self.animation.encode(into: &data, version: version)
        }
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            self.name = try .init(decoding: data, at: &offset, version: version)
            self.duration = try .init(decoding: data, at: &offset, version: version)
            self.animation = try .init(decoding: data, at: &offset, version: version)
        }
    }
}

// MARK: - Resource Manager

public protocol ObjectAnimation3DImporter: ResourceImporter {
    func loadObjectAnimation(options: ObjectAnimation3DImporterOptions) async throws(GateEngineError) -> RawObjectAnimation3D
}

public struct ObjectAnimation3DImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return ObjectAnimation3DImporterOptions(subobjectName: name)
    }

    public static var none: ObjectAnimation3DImporterOptions {
        return ObjectAnimation3DImporterOptions()
    }
}

extension ResourceManager {
    public func addObjectAnimation3DImporter(_ type: any ObjectAnimation3DImporter.Type) {
        guard importers.objectAnimation3DImporters.contains(where: { $0 == type }) == false else {
            return
        }
        importers.objectAnimation3DImporters.insert(type, at: 0)
    }
    
    func objectAnimation3DImporterForPath(_ path: String) async throws(GateEngineError) -> any ObjectAnimation3DImporter {
        for type in self.importers.objectAnimation3DImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        throw .custom(category: "\(Self.self)", message: "No ObjectAnimation3DImporter could be found for \(path)")
    }
}

extension RawObjectAnimation3D {
    init(path: String, options: ObjectAnimation3DImporterOptions = .none) async throws {
        let importer: any ObjectAnimation3DImporter = try await Game.unsafeShared.resourceManager.objectAnimation3DImporterForPath(path)
        self = try await importer.loadObjectAnimation(options: options)
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct ObjectAnimation3DKey: Hashable, CustomStringConvertible, Sendable {
        let requestedPath: String
        let options: ObjectAnimation3DImporterOptions
        
        var isGenerated: Bool {
            return self.requestedPath[self.requestedPath.startIndex] == "$"
        }
        
        @usableFromInline
        var description: String {
            var string = self.isGenerated ? "(Generated)" : self.requestedPath
            if let name = self.options.subobjectName {
                string += "named: \(name)"
            }
            return string
        }
    }

    @usableFromInline
    final class ObjectAnimation3DCache: ResourceCache {
        @usableFromInline var objectAnimation3DBackend: ObjectAnimation3DBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.objectAnimation3DBackend = nil
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
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.ObjectAnimation3DKey) {
        if let tileSetCache = cache.objectAnimation3Ds[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    func objectAnimation3DCacheKey(path: String, options: ObjectAnimation3DImporterOptions) -> Cache.ObjectAnimation3DKey {
        let key = Cache.ObjectAnimation3DKey(requestedPath: path, options: options)
        if cache.objectAnimation3Ds[key] == nil {
            cache.objectAnimation3Ds[key] = Cache.ObjectAnimation3DCache()
            self._reloadObjectAnimation3D(for: key, isFirstLoad: true)
        }
        return key
    }
    
    func objectAnimation3DCacheKey(_ rawObjectAnimation3D: RawObjectAnimation3D) -> Cache.ObjectAnimation3DKey {
        let key = Cache.ObjectAnimation3DKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", options: .none)
        let cache = self.cache
        if cache.objectAnimation3Ds[key] == nil {
            cache.objectAnimation3Ds[key] = Cache.ObjectAnimation3DCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task { @MainActor in
                if let cache = cache.objectAnimation3Ds[key] {
                    cache.objectAnimation3DBackend = .init(rawObjectAnimation3D)
                    cache.state = .ready
                }else{
                    Log.warn("Resource \"(Generated TileSet)\" was deallocated before being loaded.")
                }
                Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
            }
        }
        return key
    }
    
    @usableFromInline
    func objectAnimation3DCache(for key: Cache.ObjectAnimation3DKey) -> Cache.ObjectAnimation3DCache? {
        return cache.objectAnimation3Ds[key]
    }
    
    func incrementReference(_ key: Cache.ObjectAnimation3DKey) {
        self.objectAnimation3DCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.ObjectAnimation3DKey) {
        guard let cache = self.objectAnimation3DCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.objectAnimation3Ds.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), ObjectAnimation3D: \(key)")
            }
        }
    }
    
    func reloadObjectAniamtion3DIfNeeded(key: Cache.ObjectAnimation3DKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.objectAnimation3DNeedsReload(key: key) else { return }
        self._reloadObjectAnimation3D(for: key, isFirstLoad: false)
    }
    
    func _reloadObjectAnimation3D(for key: Cache.ObjectAnimation3DKey, isFirstLoad: Bool) {
        Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
        let cache = self.cache
        Task.detached {
            let path = key.requestedPath
            
            do {
                let rawObjectAnimation = try await RawObjectAnimation3D(path: path, options: key.options)
                
                Task { @MainActor in
                    if let cache = cache.objectAnimation3Ds[key] {
                        cache.objectAnimation3DBackend = .init(rawObjectAnimation)
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.objectAnimation3Ds[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.objectAnimation3Ds[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    @MainActor func objectAnimation3DNeedsReload(key: Cache.ObjectAnimation3DKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
        // Skip if generated
        guard key.isGenerated == false else { return false }
        guard let cache = cache.objectAnimation3Ds[key], cache.referenceCount > 0 else { return false }
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
