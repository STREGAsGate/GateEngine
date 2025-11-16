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
    public var animation: ObjectAnimation3D.Animation {
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
    
    public init(name: String, duration: Float, animation: ObjectAnimation3D.Animation) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.objectAnimation3DCacheKey(
            name: name,
            duration: duration, 
            animation: animation
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
        
        animation.updateTransform(
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

extension ObjectAnimation3D {
    public nonisolated struct Animation: Sendable {
        public enum Interpolation: Sendable {
            case step
            case linear
        }

        public init() {

        }

        public mutating func setPositions(
            _ positions: [Position3],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(positions.count == times.count)
            self.positionOutput.positions = positions
            self.positionOutput.times = times
            self.positionOutput.interpolation = interpolation
        }
        public mutating func setRotations(
            _ rotations: [Quaternion],
            times: [Float],
            interpolation: Interpolation
        ) {
            assert(rotations.count == times.count)
            self.rotationOutput.rotations = rotations
            self.rotationOutput.times = times
            self.rotationOutput.interpolation = interpolation
        }
        public mutating func setScales(_ scales: [Size3], times: [Float], interpolation: Interpolation) {
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
        struct PositionOutput: Sendable {
            var times: [Float]
            var interpolation: Interpolation
            var positions: [Position3]

            func position(forTime time: Float, duration: Float, repeating: Bool) -> Position3? {
                guard positions.isEmpty == false else { return nil }
                if let index = times.firstIndex(where: { $0 == time }) {
                    // perfect frame time
                    return positions[index]
                }
                if times.count == 1, times[0] < time {
                    return positions[0]
                }

                if let firstIndex = times.lastIndex(where: { $0 < time }) {
                    if let lastIndex = times.firstIndex(where: { $0 > time }) {
                        let time1 = times[firstIndex]
                        let time2 = times[lastIndex]

                        let position1 = positions[firstIndex]
                        let position2 = positions[lastIndex]

                        let currentTime = Float(time2 - time)
                        let currentDuration = Float(time2 - time1)

                        let factor: Float = 1 - (currentTime / currentDuration)
                        guard factor.isFinite else { return position2 }

                        switch interpolation {
                        case .linear:
                            return position1.interpolated(to: position2, .linear(factor))
                        case .step:
                            if factor < 0.5 {
                                return position1
                            }
                            return position2
                        }
                    }
                    return positions[firstIndex]
                }
                if repeating {
                    let time1: Float = 0
                    let time2: Float = times[0]

                    let position1 = positions.last!
                    let position2 = positions[0]

                    let currentTime = Float(time2 - time)
                    let currentDuration = Float(time2 - time1)

                    let factor: Float = 1 - (currentTime / currentDuration)
                    guard factor.isFinite else { return position2 }

                    switch interpolation {
                    case .linear:
                        return position1.interpolated(to: position2, .linear(factor))
                    case .step:
                        if factor < 0.5 {
                            return position1
                        }
                        return position2
                    }
                }
                return positions.first
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

            func rotation(forTime time: Float, duration: Float, repeating: Bool) -> Quaternion? {
                guard rotations.isEmpty == false else { return nil }
                if let index = times.firstIndex(where: { $0 == time }) {
                    // perfect frame time
                    return rotations[index]
                }
                if times.count == 1, times[0] < time {
                    return rotations[0]
                }

                if let firstIndex = times.lastIndex(where: { $0 < time }) {
                    if let lastIndex = times.firstIndex(where: { $0 > time }) {
                        let time1 = times[firstIndex]
                        let time2 = times[lastIndex]

                        let rotation1 = rotations[firstIndex]
                        let rotation2 = rotations[lastIndex]

                        let currentTime = Float(time2 - time)
                        let currentDuration = Float(time2 - time1)

                        let factor: Float = 1 - (currentTime / currentDuration)
                        guard factor.isFinite else { return rotation2 }

                        switch interpolation {
                        case .linear:
                            return rotation1.interpolated(to: rotation2, .linear(factor))
                        case .step:
                            if factor < 0.5 {
                                return rotation1
                            }
                            return rotation2
                        }
                    }
                    return rotations[firstIndex]
                }
                if repeating {
                    let time1: Float = 0
                    let time2: Float = times[0]

                    let rotation1 = rotations.last!
                    let rotation2 = rotations[0]

                    let currentTime = Float(time2 - time)
                    let currentDuration = Float(time2 - time1)

                    let factor: Float = 1 - (currentTime / currentDuration)
                    guard factor.isFinite else { return rotation2 }

                    switch interpolation {
                    case .linear:
                        return rotation1.interpolated(to: rotation2, .linear(factor))
                    case .step:
                        if factor < 0.5 {
                            return rotation1
                        }
                        return rotation2
                    }
                }
                return rotations.first
            }
        }

        var scaleOutput: ScaleOutput = ScaleOutput(times: [], interpolation: .linear, scales: [])
        struct ScaleOutput {
            var times: [Float]
            var interpolation: Interpolation
            var scales: [Size3]

            func scale(forTime time: Float, duration: Float, repeating: Bool) -> Size3? {
                guard scales.isEmpty == false else { return nil }
                if let index = times.firstIndex(where: { $0 == time }) {
                    // perfect frame time
                    return scales[index]
                }
                if times.count == 1, times[0] < time {
                    return scales[0]
                }

                if let firstIndex = times.lastIndex(where: { $0 < time }) {
                    if let lastIndex = times.firstIndex(where: { $0 > time }) {
                        let time1 = times[firstIndex]
                        let time2 = times[lastIndex]

                        let scale1 = scales[firstIndex]
                        let scale2 = scales[lastIndex]

                        let currentTime = Float(time2 - time)
                        let currentDuration = Float(time2 - time1)

                        let factor: Float = 1 - (currentTime / currentDuration)
                        guard factor.isFinite else { return scale2 }

                        switch interpolation {
                        case .linear:
                            return scale1.interpolated(to: scale2, .linear(factor))
                        case .step:
                            if factor < 0.5 {
                                return scale1
                            }
                            return scale2
                        }
                    }
                    return scales[firstIndex]
                }
                if repeating {
                    let time1: Float = 0
                    let time2: Float = times[0]

                    let scale1 = scales.last!
                    let scale2 = scales[0]

                    let currentTime = Float(time2 - time)
                    let currentDuration = Float(time2 - time1)

                    let factor: Float = 1 - (currentTime / currentDuration)
                    guard factor.isFinite else { return scale2 }

                    switch interpolation {
                    case .linear:
                        return scale1.interpolated(to: scale2, .linear(factor))
                    case .step:
                        if factor < 0.5 {
                            return scale1
                        }
                        return scale2
                    }
                }
                return scales.first
            }
        }

        @discardableResult
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

public final class ObjectAnimation3DBackend {
    let name: String
    let duration: Float
    let animation: ObjectAnimation3D.Animation

    init(name: String, duration: Float, animation: ObjectAnimation3D.Animation) {
        self.name = name
        self.duration = duration
        self.animation = animation
    }
}

// MARK: - Resource Manager

public protocol ObjectAnimation3DImporter: ResourceImporter {
    init()

    func process(data: Data, baseURL: URL, options: ObjectAnimation3DImporterOptions) async throws -> ObjectAnimation3DBackend
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
    
    func objectAnimation3DCacheKey(
        name: String,
        duration: Float,
        animation: ObjectAnimation3D.Animation
    ) -> Cache.ObjectAnimation3DKey {
        let key = Cache.ObjectAnimation3DKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", options: .none)
        let cache = self.cache
        if cache.objectAnimation3Ds[key] == nil {
            cache.objectAnimation3Ds[key] = Cache.ObjectAnimation3DCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            Task.detached {
                let backend = ObjectAnimation3DBackend(
                    name: name, 
                    duration: duration, 
                    animation: animation
                )
                Task { @MainActor in
                    if let cache = cache.objectAnimation3Ds[key] {
                        cache.objectAnimation3DBackend = backend
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"(Generated TileSet)\" was deallocated before being loaded.")
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
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
                let importer: any ObjectAnimation3DImporter = try await Game.unsafeShared.resourceManager.objectAnimation3DImporterForPath(path)
                
                let data = try await Platform.current.loadResource(from: path)
                let backend = try await importer.process(
                    data: data,
                    baseURL: URL(string: path)!.deletingLastPathComponent(),
                    options: key.options
                )
                
                Task { @MainActor in
                    if let cache = cache.objectAnimation3Ds[key] {
                        cache.objectAnimation3DBackend = backend
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
