/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
import Foundation
#endif

@MainActor public final class SkeletalAnimation: Resource {
    internal let cacheKey: ResourceManager.Cache.SkeletalAnimationKey
    
    public var cacheHint: CacheHint {
        get { Game.shared.resourceManager.skeletalAnimationCache(for: cacheKey)!.cacheHint }
        set { Game.shared.resourceManager.changeCacheHint(newValue, for: cacheKey) }
    }

    public var state: ResourceState {
        return Game.shared.resourceManager.skeletalAnimationCache(for: cacheKey)!.state
    }
    
    @usableFromInline
    internal var backend: SkeletalAnimationBackend {
        assert(state == .ready, "This resource is not ready to be used. Make sure it's state property is .ready before accessing!")
        return Game.shared.resourceManager.skeletalAnimationCache(for: cacheKey)!.skeletalAnimationBackend!
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
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.skeletalAnimationCacheKey(
            path: path,
            options: options
        )
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(name: String, duration: Float, animations: [Skeleton.Joint.ID: JointAnimation]) {
        let resourceManager = Game.shared.resourceManager
        self.cacheKey = resourceManager.skeletalAnimationCacheKey(
            name: name,
            duration: duration, 
            animations: animations
        )
        self.cacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
}

extension SkeletalAnimation: Equatable, Hashable {
    nonisolated public static func == (lhs: SkeletalAnimation, rhs: SkeletalAnimation) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

extension SkeletalAnimation {
    public final class JointAnimation {
        public enum Interpolation {
            case step
            case linear
        }

        public init() {

        }

        public func setPositions(
            _ positions: [Position3],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(positions.count == times.count)
            self.positionOutput.positions = positions
            self.positionOutput.times = times
            self.positionOutput.interpolation = interpolation
        }
        public func setRotations(
            _ rotations: [Quaternion],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(rotations.count == times.count)
            self.rotationOutput.rotations = rotations
            self.rotationOutput.times = times
            self.rotationOutput.interpolation = interpolation
        }
        public func setScales(_ scales: [Size3], times: [Float], interpolation: Interpolation) {
            assert(scales.count == times.count)
            self.scaleOutput.scales = scales
            self.scaleOutput.times = times
            self.scaleOutput.interpolation = interpolation
        }

        var positionOutput: PositionOutput = PositionOutput(
            times: [],
            interpolation: .linear,
            positions: []
        )
        struct PositionOutput {
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
        struct RotationOutput {
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
        struct ScaleOutput {
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

        @_transparent
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
}

// MARK: - Resource Manager

public protocol SkeletalAnimationImporter: AnyObject {
    init()

    func process(data: Data, baseURL: URL, options: SkeletalAnimationImporterOptions) async throws -> SkeletalAnimationBackend

    static func supportedFileExtensions() -> [String]
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

    fileprivate func importerForFileType(_ file: String) -> (any SkeletalAnimationImporter)? {
        for type in self.importers.skeletalAnimationImporters {
            if type.supportedFileExtensions().contains(where: {
                $0.caseInsensitiveCompare(file) == .orderedSame
            }) {
                return type.init()
            }
        }
        return nil
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct SkeletalAnimationKey: Hashable {
        let requestedPath: String
        let options: SkeletalAnimationImporterOptions
    }

    @usableFromInline
    final class SkeletalAnimationCache {
        @usableFromInline var skeletalAnimationBackend: SkeletalAnimationBackend?
        var lastLoaded: Date
        var state: ResourceState
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint
        init() {
            self.skeletalAnimationBackend = nil
            self.lastLoaded = Date()
            self.state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = .until(minutes: 5)
        }
    }
}
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
    
    @MainActor func skeletalAnimationCacheKey(
        name: String, 
        duration: Float, 
        animations: [Skeleton.Joint.ID: SkeletalAnimation.JointAnimation]
    ) -> Cache.SkeletalAnimationKey {
        let key = Cache.SkeletalAnimationKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", options: .none)
        if cache.skeletalAnimations[key] == nil {
            cache.skeletalAnimations[key] = Cache.SkeletalAnimationCache()
            Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached(priority: .high) {
                let backend = SkeletalAnimationBackend(
                    name: name, 
                    duration: duration, 
                    animations: animations
                )
                Task { @MainActor in
                    if let cache = self.cache.skeletalAnimations[key] {
                        cache.skeletalAnimationBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"(Generated TileSet)\" was deallocated before being loaded.")
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            }
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
        
        if case .whileReferenced = cache.cacheHint {
            if cache.referenceCount == 0 {
                self.cache.skeletalAnimations.removeValue(forKey: key)
                Log.debug(
                    "Removing cache (no longer referenced), SkeletalAnimation:",
                    key.requestedPath.first == "$" ? "(Generated)" : key.requestedPath
                )
            }
        }
    }
    
    func reloadSkeletalAniamtionIfNeeded(key: Cache.SkeletalAnimationKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        Task.detached(priority: .high) {
            guard self.skeletalAnimationNeedsReload(key: key) else { return }
            await self._reloadSkeletalAnimation(for: key, isFirstLoad: false)
        }
    }
    
    @MainActor func _reloadSkeletalAnimation(for key: Cache.SkeletalAnimationKey, isFirstLoad: Bool) {
        Game.shared.resourceManager.incrementLoading(path: key.requestedPath)
        Task.detached(priority: .high) {
            let path = key.requestedPath
            
            do {
                guard let fileExtension = path.components(separatedBy: ".").last else {
                    throw GateEngineError.failedToLoad("Unknown file type.")
                }
                guard
                    let importer: any SkeletalAnimationImporter = await Game.shared.resourceManager
                        .importerForFileType(fileExtension)
                else {
                    throw GateEngineError.failedToLoad("No importer for \(fileExtension).")
                }

                let data = try await Game.shared.platform.loadResource(from: path)
                let backend = try await importer.process(
                    data: data,
                    baseURL: URL(string: path)!.deletingLastPathComponent(),
                    options: key.options
                )

                Task { @MainActor in
                    if let cache = self.cache.skeletalAnimations[key] {
                        cache.skeletalAnimationBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = self.cache.skeletalAnimations[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = self.cache.skeletalAnimations[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.shared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func skeletalAnimationNeedsReload(key: Cache.SkeletalAnimationKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_FOUNDATION_FILEMANAGER
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return false }
        guard let cache = cache.skeletalAnimations[key] else { return false }
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
}
