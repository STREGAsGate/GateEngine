/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif

@MainActor public final class SkeletalAnimation: Resource, _Resource {
    internal let cacheKey: ResourceManager.Cache.SkeletalAnimationKey
    
    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.skeletalAnimationCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: SkeletalAnimationBackend {
        assert(state == .ready, "This resource is not ready to be used. Make sure it's state property is .ready before accessing!")
        return Game.unsafeShared.resourceManager.skeletalAnimationCache(for: cacheKey)!.skeletalAnimationBackend!
    }
    
    public var name: String {
        return backend.name
    }
    public var duration: Float {
        return backend.duration
    }
    public var animations: [Skeleton.Joint.ID: SkeletalAnimation.JointAnimation] {
        return backend.animations
    }
    
    public init(
        path: String,
        options: SkeletalAnimationImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.skeletalAnimationCacheKey(
            path: path,
            options: options
        )
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(name: String, duration: Float, animations: [Skeleton.Joint.ID: JointAnimation]) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.skeletalAnimationCacheKey(
            name: name,
            duration: duration, 
            animations: animations
        )
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
}

extension SkeletalAnimation: Equatable, Hashable {
    nonisolated public static func == (lhs: SkeletalAnimation, rhs: SkeletalAnimation) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

extension SkeletalAnimation {
    public struct JointAnimation: Sendable {
        public enum Interpolation: Sendable {
            case step
            case linear
            
            init(_ raw: RawSkeletalAnimation.JointAnimation.Interpolation) {
                switch raw {
                case .linear:
                    self = .linear
                case .step:
                    self = .step
                }
            }
        }

        public init(_ rawJointAnimation: RawSkeletalAnimation.JointAnimation) {
            self.positionOutput = PositionOutput(
                times: rawJointAnimation.positionOutput.times, 
                interpolation: .init(rawJointAnimation.positionOutput.interpolation), 
                positions: rawJointAnimation.positionOutput.positions, 
                bind: rawJointAnimation.positionOutput.bind
            )
            self.rotationOutput = RotationOutput(
                times: rawJointAnimation.rotationOutput.times, 
                interpolation: .init(rawJointAnimation.rotationOutput.interpolation), 
                rotations: rawJointAnimation.rotationOutput.rotations, 
                bind: rawJointAnimation.rotationOutput.bind
            )
            self.scaleOutput = ScaleOutput(
                times: rawJointAnimation.scaleOutput.times, 
                interpolation: .init(rawJointAnimation.rotationOutput.interpolation), 
                scales: rawJointAnimation.scaleOutput.scales, 
                bind: rawJointAnimation.scaleOutput.bind
            )
        }

        var positionOutput: PositionOutput = PositionOutput(
            times: [],
            interpolation: .linear,
            positions: []
        )
        struct PositionOutput: Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var positions: [Position3]
            var bind: Position3 = .zero

            func position(forTime time: Float, duration: Float, repeating: Bool) -> Position3? {
                guard positions.isEmpty == false else { return nil }
                guard let currentIndex: Int = times.lastIndex(where: { $0 < time }) else {return positions.first}

                switch interpolation {
                case .linear:
                    let plus1 = currentIndex + 1
                    let nextIndex: Int = times.indices.contains(plus1) ? plus1 : times.endIndex - 1
                    
                    let time1 = times[currentIndex]
                    let time2 = times[nextIndex]
                    
                    let position1 = positions[currentIndex]
                    let position2 = positions[nextIndex]

                    let currentTime: Float = time - time1
                    let currentDuration: Float = time2 - time1
                    let factor: Float = currentTime / currentDuration
                    
                    guard factor.isFinite else { return position1 }
                    return position1.interpolated(to: position2, .linear(factor))
                case .step:
                    return positions[currentIndex]
                }
            }
        }
        var rotationOutput: RotationOutput = RotationOutput(
            times: [],
            interpolation: .linear,
            rotations: []
        )
        struct RotationOutput: Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var rotations: [Quaternion]
            var bind: Quaternion = .zero
            
            func rotation(forTime time: Float, duration: Float, repeating: Bool) -> Quaternion? {
                guard rotations.isEmpty == false else { return nil }
                guard let currentIndex: Int = times.lastIndex(where: { $0 < time }) else {return rotations.first}

                switch interpolation {
                case .linear:
                    let plus1 = currentIndex + 1
                    let nextIndex: Int = times.indices.contains(plus1) ? plus1 : times.endIndex - 1
                    
                    let time1 = times[currentIndex]
                    let time2 = times[nextIndex]
                    
                    let rotation1 = rotations[currentIndex]
                    let rotation2 = rotations[nextIndex]

                    let currentTime: Float = time - time1
                    let currentDuration: Float = time2 - time1
                    let factor: Float = currentTime / currentDuration
                    
                    guard factor.isFinite else { return rotation1 }
                    return rotation1.interpolated(to: rotation2, .linear(factor))
                case .step:
                    return rotations[currentIndex]
                }
            }
        }

        var scaleOutput: ScaleOutput = ScaleOutput(times: [], interpolation: .linear, scales: [])
        struct ScaleOutput: Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var scales: [Size3]
            var bind: Size3 = .one
            
            func scale(forTime time: Float, duration: Float, repeating: Bool) -> Size3? {
                guard scales.isEmpty == false else { return nil }
                guard let currentIndex: Int = times.lastIndex(where: { $0 < time }) else {return scales.first}

                switch interpolation {
                case .linear:
                    let plus1 = currentIndex + 1
                    let nextIndex: Int = times.indices.contains(plus1) ? plus1 : times.endIndex - 1
                    
                    let time1 = times[currentIndex]
                    let time2 = times[nextIndex]
                    
                    let scale1 = scales[currentIndex]
                    let scale2 = scales[nextIndex]

                    let currentTime: Float = time - time1
                    let currentDuration: Float = time2 - time1
                    let factor: Float = currentTime / currentDuration
                    
                    guard factor.isFinite else { return scale1 }
                    return scale1.interpolated(to: scale2, .linear(factor))
                case .step:
                    return scales[currentIndex]
                }
            }
        }

        func updateTransform(
            _ transform: inout Transform3,
            withTime time: Float,
            duration: Float,
            repeating: Bool
        ) -> KeyedComponents {
            var keyedComponents: KeyedComponents = []
            if let position = positionOutput.position(
                forTime: time,
                duration: duration,
                repeating: repeating
            ) {
                assert(position.isFinite)
                transform.position = position
                keyedComponents.insert(.position)
            }
            if let rotation = rotationOutput.rotation(
                forTime: time,
                duration: duration,
                repeating: repeating
            ) {
                assert(rotation.isFinite)
                transform.rotation = rotation
                keyedComponents.insert(.rotation)
            }
            if let scale = scaleOutput.scale(
                forTime: time,
                duration: duration,
                repeating: repeating
            ) {
                assert(scale.isFinite)
                transform.scale = scale
                keyedComponents.insert(.scale)
            }
            return keyedComponents
        }
    }

    struct KeyedComponents: OptionSet {
        typealias RawValue = UInt8
        let rawValue: RawValue
        static let position = KeyedComponents(rawValue: 1 << 1)
        static let rotation = KeyedComponents(rawValue: 1 << 2)
        static let scale = KeyedComponents(rawValue: 1 << 3)

        var isFull: Bool {
            return self == [.position, .rotation, .scale]
        }
    }
}

public final class SkeletalAnimationBackend {
    let name: String
    let duration: Float
    let animations: [Skeleton.Joint.ID: SkeletalAnimation.JointAnimation]

    init(name: String, duration: Float, animations: [Skeleton.Joint.ID: SkeletalAnimation.JointAnimation]) {
        self.name = name
        self.duration = duration
        self.animations = animations
    }
    
    init(rawSkeletalAnimation: RawSkeletalAnimation) {
        self.name = rawSkeletalAnimation.name
        self.duration = rawSkeletalAnimation.duration
        let keys = rawSkeletalAnimation.animations.keys
        let values = keys.map({
            let rawValue = rawSkeletalAnimation.animations[$0]!
            return SkeletalAnimation.JointAnimation(rawValue)
        })
        
        self.animations = .init(uniqueKeysWithValues: zip(keys, values))
    }
}

// MARK: - Resource Manager

public protocol SkeletalAnimationImporter: ResourceImporter {
    func loadSkeletalAnimation(options: SkeletalAnimationImporterOptions) async throws(GateEngineError) -> RawSkeletalAnimation
}

public struct SkeletalAnimationImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkeletalAnimationImporterOptions(subobjectName: name)
    }

    public static var none: SkeletalAnimationImporterOptions {
        return SkeletalAnimationImporterOptions()
    }
}

extension ResourceManager {
    public func addSkeletalAnimationImporter(_ type: any SkeletalAnimationImporter.Type) {
        guard importers.skeletalAnimationImporters.contains(where: { $0 == type }) == false else {
            return
        }
        importers.skeletalAnimationImporters.insert(type, at: 0)
    }
    
    func skeletalAnimationImporterForPath(_ path: String) async throws -> (any SkeletalAnimationImporter)? {
        for type in self.importers.skeletalAnimationImporters {
            if type.canProcessFile(path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        return nil
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct SkeletalAnimationKey: Hashable, CustomStringConvertible, Sendable {
        let requestedPath: String
        let options: SkeletalAnimationImporterOptions
        
        @usableFromInline
        var description: String {
            var string = requestedPath.first == "$" ? "(Generated)" : requestedPath
            if let name = options.subobjectName {
                string += ", Named: \(name)"
            }
            return string
        }
    }

    @usableFromInline
    final class SkeletalAnimationCache: ResourceCache {
        @usableFromInline var skeletalAnimationBackend: SkeletalAnimationBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.skeletalAnimationBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = nil
            self.defaultCacheHint = .until(minutes: 5)
        }
    }
}

extension RawSkeletalAnimation {
    public init(path: String, options: SkeletalAnimationImporterOptions = .none) async throws {
        guard
            let importer: any SkeletalAnimationImporter = try await Game.unsafeShared.resourceManager.skeletalAnimationImporterForPath(path)
        else {
            throw GateEngineError.failedToLoad(resource: path, "No importer for \(URL(fileURLWithPath: path).pathExtension).")
        }

        do {
            self = try await importer.loadSkeletalAnimation(options: options)
        } catch {
            throw GateEngineError(error)
        }
    }
}

@MainActor
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.SkeletalAnimationKey) {
        if let tileSetCache = cache.skeletalAnimations[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    func skeletalAnimationCacheKey(path: String, options: SkeletalAnimationImporterOptions) -> Cache.SkeletalAnimationKey {
        let key = Cache.SkeletalAnimationKey(requestedPath: path, options: options)
        if cache.skeletalAnimations[key] == nil {
            cache.skeletalAnimations[key] = Cache.SkeletalAnimationCache()
            Task { @MainActor in
                self._reloadSkeletalAnimation(for: key, isFirstLoad: true)
            }
        }
        return key
    }
    
    func skeletalAnimationCacheKey(
        name: String, 
        duration: Float, 
        animations: [Skeleton.Joint.ID: SkeletalAnimation.JointAnimation]
    ) -> Cache.SkeletalAnimationKey {
        let key = Cache.SkeletalAnimationKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", options: .none)
        let cache = self.cache
        if cache.skeletalAnimations[key] == nil {
            cache.skeletalAnimations[key] = Cache.SkeletalAnimationCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            if let cache = cache.skeletalAnimations[key] {
                cache.skeletalAnimationBackend = SkeletalAnimationBackend(
                    name: name,
                    duration: duration,
                    animations: animations
                )
                cache.state = .ready
            }else{
                Log.warn("Resource \"(Generated TileSet)\" was deallocated before being loaded.")
            }
            Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
        }
        return key
    }
    
    @usableFromInline
    func skeletalAnimationCache(for key: Cache.SkeletalAnimationKey) -> Cache.SkeletalAnimationCache? {
        return cache.skeletalAnimations[key]
    }
    
    func incrementReference(_ key: Cache.SkeletalAnimationKey) {
        self.skeletalAnimationCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.SkeletalAnimationKey) {
        guard let cache = self.skeletalAnimationCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.skeletalAnimations.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), SkeletalAnimation: \(key)")
            }
        }
    }
    
    func reloadSkeletalAniamtionIfNeeded(key: Cache.SkeletalAnimationKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.skeletalAnimationNeedsReload(key: key) else { return }
        self._reloadSkeletalAnimation(for: key, isFirstLoad: false)
    }
    
    func _reloadSkeletalAnimation(for key: Cache.SkeletalAnimationKey, isFirstLoad: Bool) {
        Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
        let cache = self.cache
        Task.detached {
            let path = key.requestedPath
            
            do {
                let rawSkeletalAnimation = try await RawSkeletalAnimation(
                    path: key.requestedPath,
                    options: key.options
                )
                Task { @MainActor in
                    if let cache = cache.skeletalAnimations[key] {
                        cache.skeletalAnimationBackend = SkeletalAnimationBackend(rawSkeletalAnimation: rawSkeletalAnimation)
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.skeletalAnimations[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.skeletalAnimations[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func skeletalAnimationNeedsReload(key: Cache.SkeletalAnimationKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        guard let cache = cache.skeletalAnimations[key] else { return false }
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
