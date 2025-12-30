/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_SUPPORTS_FOUNDATION_FILEMANAGER
import Foundation
#endif

@MainActor public final class Skeleton: Resource, _Resource {
    internal let cacheKey: ResourceManager.Cache.SkeletonKey
    
    var cache: any ResourceCache {
        return Game.unsafeShared.resourceManager.skeletonCache(for: cacheKey)!
    }
    
    @usableFromInline
    internal var backend: SkeletonBackend {
        assert(state == .ready, "This resource is not ready to be used. Make sure it's state property is .ready before accessing!")
        return Game.unsafeShared.resourceManager.skeletonCache(for: cacheKey)!.skeletonBackend!
    }
    
    var _rootJoint: Skeleton.Joint! = nil
    var rootJoint: Skeleton.Joint {
        if _rootJoint == nil {
            _rootJoint = Skeleton.Joint(copying: backend.rootJoint)
        }
        return _rootJoint
    }
    
    var bindPose: Skeleton.Pose {
        return backend.bindPose
    }

    public func getPose() -> Skeleton.Pose {
        self.updateIfNeeded()
        return Skeleton.Pose(self.rootJoint)
    }
    
    private var jointIDCache: [Int: Skeleton.Joint] = [:]
    public func jointWithID(_ id: Skeleton.Joint.ID) -> Skeleton.Joint? {
        if let cached = jointIDCache[id] {
            return cached
        }
        if let joint = rootJoint.firstDescendant(withID: id) {
            jointIDCache[id] = joint
            return joint
        }
        return nil
    }

    private var jointNameCache: [String: Skeleton.Joint] = [:]
    public func jointNamed(_ name: String) -> Skeleton.Joint? {
        if let cached = jointNameCache[name] {
            return cached
        }
        if let joint = rootJoint.firstDescendant(named: name) {
            jointNameCache[name] = joint
            return joint
        }
        return nil
    }

    @usableFromInline
    func updateIfNeeded() {
        func update(joint: Skeleton.Joint) {
            joint.updateIfNeeded()
            for child in joint.children {
                update(joint: child)
            }
        }
        update(joint: rootJoint)
    }
    
    public init(
        path: String,
        options: SkeletonImporterOptions = .none
    ) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.skeletonCacheKey(
            path: path,
            options: options
        )
        self.defaultCacheHint = .until(minutes: 5)
        resourceManager.incrementReference(self.cacheKey)
    }
    
    public init(rootjoint: Skeleton.Joint) {
        let resourceManager = Game.unsafeShared.resourceManager
        self.cacheKey = resourceManager.skeletonCacheKey(rootJoint: rootjoint)
        self.defaultCacheHint = .whileReferenced
        resourceManager.incrementReference(self.cacheKey)
    }
    
    deinit {
        let cacheKey = self.cacheKey
        Task { @MainActor in
            Game.unsafeShared.resourceManager.decrementReference(cacheKey)
        }
    }
}

extension Skeleton: Equatable, Hashable {
    nonisolated public static func == (lhs: Skeleton, rhs: Skeleton) -> Bool {
        return lhs.cacheKey == rhs.cacheKey
    }
    
    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(cacheKey)
    }
}

@usableFromInline
final class SkeletonBackend {
    @usableFromInline
    let rootJoint: Skeleton.Joint
    @usableFromInline
    let bindPose: Skeleton.Pose

    init(rootJoint joint: Skeleton.Joint) {
        self.rootJoint = joint
        self.bindPose = Skeleton.Pose(joint)
    }
    
    init(rawSkeleton: RawSkeleton) {
        func createJoint(from rawJoint: RawSkeleton.RawJoint) -> Skeleton.Joint {
            let joint = Skeleton.Joint(rawJoint: rawJoint)
            joint.localTransform = rawJoint.localTransform
            for rawJoint in rawSkeleton.joints {
                if rawJoint.parent == joint.id {
                    let child = createJoint(from: rawJoint)
                    child.parent = joint
                }
            }
            return joint
        }
        let rootJoint = createJoint(from: rawSkeleton.joints.first(where: {$0.parent == nil})!)
        self.rootJoint = rootJoint
        self.bindPose = Skeleton.Pose(rootJoint)
    }
}
fileprivate extension Skeleton.Joint {

}

extension Skeleton {
    public struct SkipJoint: ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        public var name: StringLiteralType
        public var method: Method
        public enum Method {
            case justThis
            case includingChildren
        }

        public init(stringLiteral: StringLiteralType) {
            self.name = stringLiteral
            self.method = .includingChildren
        }

        public init(name: StringLiteralType, method: Method) {
            self.name = name
            self.method = method
        }

        public static func named(_ name: String, _ method: Method) -> Self {
            return Self(name: name, method: method)
        }
    }
}

extension Skeleton {
    @inlinable
    public func applyBindPose() {
        self.applyPose(backend.bindPose)
    }

    public func applyPose(_ pose: Skeleton.Pose) {
        func applyToJoint(_ joint: Skeleton.Joint) {
            if let poseJoint = pose.jointWithID(joint.id) {
                joint.localTransform.position = poseJoint.localTransform.position
                joint.localTransform.rotation = poseJoint.localTransform.rotation
                joint.localTransform.scale = poseJoint.localTransform.scale
            }
            for child in joint.children {
                applyToJoint(child)
            }
        }
        applyToJoint(rootJoint)
    }


    @MainActor 
    public func applyAnimation(
        _ skeletalAnimation: SkeletalAnimation,
        atTime _time: Float,
        duration: Float,
        repeating: Bool,
        skipJoints: [Skeleton.SkipJoint],
        interpolateProgress: Float
    ) {
        let time: Float
        if _time < 0 {
            time = 0
        }else if _time > duration {
            if repeating {
                time = _time.truncatingRemainder(dividingBy: duration)
            }else{
                time = duration
            }
        }else{
            time = _time
        }
        
        func applyToJoint(_ joint: Skeleton.Joint) {
            var keyedComponents: SkeletalAnimation.KeyedComponents = []
            var transform: Transform3 = .default
            if let animation = skeletalAnimation.animations[joint.id] {
                keyedComponents = animation.updateTransform(
                    &transform,
                    withTime: time,
                    duration: duration,
                    repeating: repeating
                )
            }

            if keyedComponents.isFull == false,
                let pose = bindPose.jointWithID(joint.id)?.localTransform
            {
                if keyedComponents.contains(.position) == false {
                    transform.position = pose.position
                }
                if keyedComponents.contains(.rotation) == false {
                    transform.rotation = pose.rotation
                }
                if keyedComponents.contains(.scale) == false {
                    transform.scale = pose.scale
                }
            }

            let skipJoint = skipJoints.first(where: { $0.name == joint.name })
            let skipChildren: Bool = {
                guard let skipJoint = skipJoint else { return false }
                return skipJoint.method == .includingChildren
            }()
            let skip: Bool = {
                guard let skipJoint = skipJoint else { return false }
                return skipJoint.method == .justThis
            }()

            if skipChildren == false {
                for child in joint.children {
                    applyToJoint(child)
                }
            }

            if skip == false {
                if interpolateProgress < 1 {
                    joint.localTransform.interpolate(to: transform, .linear(interpolateProgress))
                } else {
                    joint.localTransform = transform
                }
            }
        }
        applyToJoint(rootJoint)
    }
}

extension Skeleton {
    public final class Joint: Identifiable {
        public typealias ID = Int
        public let id: ID
        public let name: String?
        public weak var parent: Skeleton.Joint? = nil {
            willSet {
                if let index = self.parent?.children.firstIndex(of: self) {
                    self.parent?.children.remove(at: index)
                }
            }
            didSet {
                self.parent?.children.insert(self)
            }
        }
        public private(set) var children: Set<Skeleton.Joint> = []

        public var localTransform: Transform3 = .default {
            didSet {
                if needsUpdate == false && localTransform != oldValue {
                    markNeedsUpdate()
                }
            }
        }

        internal var needsUpdate: Bool = true
        internal func markNeedsUpdate() {
            guard needsUpdate == false else { return }
            self.needsUpdate = true
            for child in children {
                child.markNeedsUpdate()
            }
        }

        fileprivate func updateIfNeeded() {
            guard needsUpdate else { return }
            needsUpdate = false
            updateModelSpace()
        }

        private var _modelSpace: Matrix4x4 = .identity
        public var modelSpace: Matrix4x4 {
            updateIfNeeded()
            return _modelSpace
        }

        ///Reusable to decrease allocations in the Skeleton.Joint.updateModelSpace() function

        private func updateModelSpace() {
            var current: Skeleton.Joint? = self
            var nodeArray: [Skeleton.Joint] = []
            while current != nil {
                nodeArray.append(current!)
                current = current?.parent
            }

            var updateMTX: Matrix4x4 = .identity
            var updateRotationMTX: Matrix4x4 = .identity
            var updateScaleMTX: Matrix4x4 = .identity

            var new: Matrix4x4 = .identity
            for node in nodeArray {
                updateMTX.becomeIdentity()
                updateMTX.position = node.localTransform.position

                updateRotationMTX.rotation = node.localTransform.rotation
                updateMTX *= updateRotationMTX

                updateScaleMTX.scale = node.localTransform.scale
                updateMTX *= updateScaleMTX

                new = updateMTX * new
            }
            if new.isFinite && new != .identity {
                _modelSpace = new
            }
        }

        public init(id: Joint.ID, name: String?) {
            self.id = id
            self.name = name
        }
        
        /// Convenince for constructing a Skeleton from a RawSkeleton
        fileprivate convenience init(rawJoint: RawSkeleton.RawJoint) {
            self.init(id: rawJoint.id, name: rawJoint.name)
            self.localTransform = rawJoint.localTransform
        }
    }
}

extension Skeleton.Joint {
    public func firstDescendant(withID id: Skeleton.Joint.ID) -> Skeleton.Joint? {
        func firstNode(withID id: Int, within node: Skeleton.Joint) -> Skeleton.Joint? {
            if node.id == id { return node }
            for node in node.children {
                if node.id == id { return node }
                if let node = firstNode(withID: id, within: node) {
                    return node
                }
            }
            return nil
        }
        return firstNode(withID: id, within: self)
    }
    public func firstDescendant(named name: String) -> Skeleton.Joint? {
        func firstNode(named name: String, within node: Skeleton.Joint) -> Skeleton.Joint? {
            if node.name == name { return node }
            for node in node.children {
                if node.name == name { return node }
                if let node = firstNode(named: name, within: node) {
                    return node
                }
            }
            return nil
        }
        return firstNode(named: name, within: self)
    }
}

extension Skeleton.Joint {
    convenience init(copying: Skeleton.Joint) {
        self.init(id: copying.id, name: copying.name)
        self.localTransform = copying.localTransform
        self._modelSpace = copying._modelSpace
        self.needsUpdate = copying.needsUpdate
        self.children = Set(copying.children.map({
            let child = Self(copying: $0)
            child.parent = self
            return child
        }))
    }
}

extension Skeleton.Joint: Hashable {
    public static func == (lhs: Skeleton.Joint, rhs: Skeleton.Joint) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: - Pose

extension Skeleton {
    public struct Pose {
        public let rootJoint: Skeleton.Pose.Joint

        @usableFromInline
        internal init(_ rootJoint: Skeleton.Joint) {
            self.rootJoint = Skeleton.Pose.Joint(rootJoint)
        }
    }
}

extension Skeleton.Pose {
    public struct Joint {
        public let id: Skeleton.Joint.ID
        public let parentID: Skeleton.Joint.ID?
        public let children: Set<Skeleton.Pose.Joint>
        public let localTransform: Transform3

        public let modelSpace: Matrix4x4

        internal init(_ joint: Skeleton.Joint) {
            self.id = joint.id
            self.parentID = joint.parent?.id

            func children(from joint: Skeleton.Joint) -> Set<Skeleton.Pose.Joint> {
                var children: Set<Skeleton.Pose.Joint> = []
                for child in joint.children {
                    let joint = Skeleton.Pose.Joint(child)
                    children.insert(joint)
                }
                return children
            }
            self.children = children(from: joint)

            self.localTransform = joint.localTransform
            self.modelSpace = joint.modelSpace
        }
    }

    public func jointWithID(_ id: Skeleton.Joint.ID) -> Skeleton.Pose.Joint? {
        if let joint = rootJoint.firstDescendant(withID: id) {
            return joint
        }
        return nil
    }
}

extension Skeleton.Pose.Joint {
    @inlinable
    public func firstDescendant(withID id: Skeleton.Joint.ID) -> Skeleton.Pose.Joint? {
        func firstNode(withID id: Int, within node: Skeleton.Pose.Joint) -> Skeleton.Pose.Joint? {
            if node.id == id { return node }
            for node in node.children {
                if node.id == id { return node }
                if let node = firstNode(withID: id, within: node) {
                    return node
                }
            }
            return nil
        }
        return firstNode(withID: id, within: self)
    }
}

extension Skeleton.Pose {
    @inlinable
    public func shaderMatrixArray(orderedFromSkinJoints joints: [Skin.Joint]) -> [Matrix4x4] {
        return joints.map({
            (rootJoint.firstDescendant(withID: $0.id)?.modelSpace ?? .identity)
                * $0.inverseBindMatrix
        })
    }
}

extension Skeleton.Pose.Joint: Hashable {
    public static func == (lhs: Skeleton.Pose.Joint, rhs: Skeleton.Pose.Joint) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


// MARK: - Resource Manager

public protocol SkeletonImporter: ResourceImporter {
    mutating func loadSkeleton(options: SkeletonImporterOptions) async throws(GateEngineError) -> RawSkeleton
}

public struct SkeletonImporterOptions: Equatable, Hashable, Sendable {
    public var subobjectName: String? = nil

    public static func named(_ name: String) -> Self {
        return SkeletonImporterOptions(subobjectName: name)
    }

    public static var none: SkeletonImporterOptions {
        return SkeletonImporterOptions()
    }
}

extension ResourceManager {
    public func addSkeletonImporter(_ type: any SkeletonImporter.Type) {
        guard importers.skeletonImporters.contains(where: { $0 == type }) == false else { return }
        importers.skeletonImporters.insert(type, at: 0)
    }
    
    func skeletonImporterForPath(_ path: String) async throws(GateEngineError) -> any SkeletonImporter {
        for type in self.importers.skeletonImporters {
            if type.canProcessFile(at: path) {
                return try await self.importers.getImporter(path: path, type: type)
            }
        }
        throw .custom(category: "\(Self.self)", message: "No SkeletonImporter could be found for \(path)")
    }
}

extension ResourceManager.Cache {
    @usableFromInline
    struct SkeletonKey: Hashable, Sendable, CustomStringConvertible {
        let requestedPath: String
        let options: SkeletonImporterOptions
        
        
        @usableFromInline
        var isGenerated: Bool {
            return self.requestedPath[self.requestedPath.startIndex] == "$"
        }
        
        @usableFromInline
        var description: String {
            var string = self.isGenerated ? "(Generated)" : self.requestedPath
            if let name = self.options.subobjectName {
                string += ", Named: \(name)"
            }
            return string
        }
    }

    @usableFromInline
    final class SkeletonCache: ResourceCache {
        @usableFromInline var skeletonBackend: SkeletonBackend?
        var lastLoaded: Date
        var _state: ResourceState
        var state: ResourceState {
            get {
                return _state
            }
            set {
                _state = newValue
            }
        }
        var referenceCount: UInt
        var minutesDead: UInt
        var cacheHint: CacheHint?
        var defaultCacheHint: CacheHint
        init() {
            self.skeletonBackend = nil
            self.lastLoaded = Date()
            self._state = .pending
            self.referenceCount = 0
            self.minutesDead = 0
            self.cacheHint = nil
            self.defaultCacheHint = .until(minutes: 5)
        }
    }
}

extension RawSkeleton {
    public init(path: String, options: SkeletonImporterOptions = .none) async throws {
        var importer: any SkeletonImporter = try await Game.unsafeShared.resourceManager.skeletonImporterForPath(path)
        self = try await importer.loadSkeleton(options: options)
    }
}

@MainActor
extension ResourceManager {
    func changeCacheHint(_ cacheHint: CacheHint, for key: Cache.SkeletonKey) {
        if let tileSetCache = cache.skeletons[key] {
            tileSetCache.cacheHint = cacheHint
            tileSetCache.minutesDead = 0
        }
    }
    
    func skeletonCacheKey(path: String, options: SkeletonImporterOptions) -> Cache.SkeletonKey {
        let key = Cache.SkeletonKey(requestedPath: path, options: options)
        if cache.skeletons[key] == nil {
            cache.skeletons[key] = Cache.SkeletonCache()
            self._reloadSkeleton(for: key, isFirstLoad: true)
        }
        return key
    }
    
    func skeletonCacheKey(rootJoint: Skeleton.Joint) -> Cache.SkeletonKey {
        let key = Cache.SkeletonKey(requestedPath: "$\(rawCacheIDGenerator.generateID())", options: .none)
        let cache = self.cache
        if cache.skeletons[key] == nil {
            cache.skeletons[key] = Cache.SkeletonCache()
            Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
            
            if let cache = cache.skeletons[key] {
                cache.skeletonBackend = SkeletonBackend(rootJoint: rootJoint)
                cache.state = .ready
            }else{
                Log.warn("Resource \"(Generated TileSet)\" was deallocated before being loaded.")
            }
            Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
        }
        return key
    }
    
    @usableFromInline
    func skeletonCache(for key: Cache.SkeletonKey) -> Cache.SkeletonCache? {
        return cache.skeletons[key]
    }
    
    func incrementReference(_ key: Cache.SkeletonKey) {
        self.skeletonCache(for: key)?.referenceCount += 1
    }
    func decrementReference(_ key: Cache.SkeletonKey) {
        guard let cache = self.skeletonCache(for: key) else {return}
        cache.referenceCount -= 1
        
        if case .whileReferenced = cache.effectiveCacheHint {
            if cache.referenceCount == 0 {
                self.cache.skeletons.removeValue(forKey: key)
                Log.debug("Removing cache (no longer referenced), Skeleton: \(key)")
            }
        }
    }
    
    func reloadSkeletonIfNeeded(key: Cache.SkeletonKey) {
        // Skip if made from RawGeometry
        guard key.requestedPath[key.requestedPath.startIndex] != "$" else { return }
        guard self.skeletonNeedsReload(key: key) else { return }
        self._reloadSkeleton(for: key, isFirstLoad: false)
    }
    
    func _reloadSkeleton(for key: Cache.SkeletonKey, isFirstLoad: Bool) {
        Game.unsafeShared.resourceManager.incrementLoading(path: key.requestedPath)
        let cache = self.cache
        Task {
            let path = key.requestedPath
            
            do {
                let rawSkeleton = try await RawSkeleton(
                    path: key.requestedPath,
                    options: key.options
                )
                Task { @MainActor in
                    if let cache = cache.skeletons[key] {
                        cache.skeletonBackend = SkeletonBackend(rawSkeleton: rawSkeleton)
                        cache.state = .ready
                    }else{
                        Log.warn("Resource \"\(path)\" was deallocated before being " + (isFirstLoad ? "loaded." : "re-loaded."))
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.skeletons[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch let error as DecodingError {
                let error = GateEngineError(error)
                Task { @MainActor in
                    Log.warn("Resource \"\(path)\"", error)
                    if let cache = cache.skeletons[key] {
                        cache.state = .failed(error: error)
                    }
                    Game.unsafeShared.resourceManager.decrementLoading(path: key.requestedPath)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
    }
    
    func skeletonNeedsReload(key: Cache.SkeletonKey) -> Bool {
        #if GATEENGINE_ENABLE_HOTRELOADING && GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
        guard key.isGenerated == false else { return false }
        guard let cache = cache.skeletons[key], cache.referenceCount > 0 else { return false }
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
