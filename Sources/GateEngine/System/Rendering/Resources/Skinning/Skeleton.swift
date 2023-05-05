/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

public final class Skeleton: OldResource {
    internal let path: String?
    internal let options: SkeletonImporterOptions?
    
    @RequiresState(.ready)
    internal var rootJoint: Skeleton.Joint! = nil
    @RequiresState(.ready)
    internal var bindPose: Pose! = nil
    
    public func getPose() -> Pose {
        self.updateIfNeeded()
        return Pose(self.rootJoint)
    }
    
    private var jointIDCache: [Int : Joint] = [:]
    public func jointWithID(_ id: Skeleton.Joint.ID) -> Joint? {
        if let cached = jointIDCache[id] {
            return cached
        }
        if let joint = rootJoint.firstDescendant(withID: id) {
            jointIDCache[id] = joint
            return joint
        }
        return nil
    }
    
    private var jointNameCache: [String : Joint] = [:]
    public func jointNamed(_ name: String) -> Joint? {
        if let cached = jointNameCache[name] {
            return cached
        }
        if let joint = rootJoint.firstDescendant(named: name) {
            jointNameCache[name] = joint
            return joint
        }
        return nil
    }
    
    public init(rootJoint joint: Skeleton.Joint) {
        self.path = nil
        self.options = nil
        self.rootJoint = joint
        self.bindPose = Pose(joint)
        super.init()
        self.state = .ready
        
        #if DEBUG
        self._bindPose.configure(withOwner: self)
        self._rootJoint.configure(withOwner: self)
        #endif
    }
    
    @usableFromInline
    internal func updateIfNeeded() {
        func update(joint: Joint) {
            joint.updateIfNeeded()
            for child in joint.children {
                update(joint: child)
            }
        }
        update(joint: rootJoint)
    }
}

public extension Skeleton {
    struct SkipJoint: ExpressibleByStringLiteral {
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
    public func applyBindPose() {
        self.applyPose(bindPose)
    }
    
    public func applyPose(_ pose: Pose) {
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
    
    public func applyAnimation(_ skeletalAnimation: SkeletalAnimation, withTime time: Float, duration: Float, repeating: Bool, skipJoints: [SkipJoint], interpolateProgress: Float) {
        
        let interpolate = interpolateProgress < 1
        
        func applyToJoint(_ joint: Skeleton.Joint) {
            var keyedComponets: SkeletalAnimation.KeyedComponents = []
            var transform: Transform3 = .default
            if let animation = skeletalAnimation.animations[joint.id] {
                keyedComponets = animation.updateTransform(&transform, withTime: time, duration: duration, repeating: repeating)
            }
            
            if keyedComponets.isFull == false, let pose = bindPose.jointWithID(joint.id)?.localTransform {
                if keyedComponets.contains(.position) == false {
                    transform.position = pose.position
                }
                if keyedComponets.contains(.rotation) == false {
                    transform.rotation = pose.rotation
                }
                if keyedComponets.contains(.scale) == false {
                    transform.scale = pose.scale
                }
            }
            
            let skipJoint = skipJoints.first(where: {$0.name == joint.name})
            let skipChildren: Bool = {
                guard let skipJoint = skipJoint else {return false}
                return skipJoint.method == .includingChildren
            }()
            let skip: Bool = {
                guard let skipJoint = skipJoint else {return false}
                return skipJoint.method == .justThis
            }()
            
            if skipChildren == false {
                for child in joint.children {
                    applyToJoint(child)
                }
            }
            
            if skip == false {
                if interpolate {
                    joint.localTransform.interpolate(to: transform, .linear(interpolateProgress))
                }else{
                    joint.localTransform = transform
                }
            }
        }
        applyToJoint(rootJoint)
    }
}

extension Skeleton {
    public final class Joint {
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
            guard needsUpdate == false else {return}
            self.needsUpdate = true
            for child in children {
                child.markNeedsUpdate()
            }
        }
        
        fileprivate func updateIfNeeded() {
            guard needsUpdate else {return}
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
            var updateRoationMTX: Matrix4x4 = .identity
            var updateScaleMTX: Matrix4x4 = .identity
            
            var new: Matrix4x4 = .identity
            for node in nodeArray {
                updateMTX.becomeIdentity()
                updateMTX.position = node.localTransform.position
                
                updateRoationMTX.rotation = node.localTransform.rotation
                updateMTX *= updateRoationMTX
                
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
    }
}

extension Skeleton.Joint {
    public func firstDescendant(withID id: Skeleton.Joint.ID) -> Skeleton.Joint? {
        func firstNode(withID id: Int, within node: Skeleton.Joint) -> Skeleton.Joint? {
            if node.id == id {return node}
            for node in node.children {
                if node.id == id {return node}
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
            if node.name == name {return node}
            for node in node.children {
                if node.name == name {return node}
                if let node = firstNode(named: name, within: node) {
                    return node
                }
            }
            return nil
        }
        return firstNode(named: name, within: self)
    }
}

extension Skeleton.Joint: Hashable {
    final public class func ==(lhs: Skeleton.Joint, rhs: Skeleton.Joint) -> Bool {
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
            if node.id == id {return node}
            for node in node.children {
                if node.id == id {return node}
                if let node = firstNode(withID: id, within: node) {
                    return node
                }
            }
            return nil
        }
        return firstNode(withID: id, within: self)
    }
}

public extension Skeleton.Pose {
    @inlinable
    func shaderMatrixArray(orderedFromSkinJoints joints: [Skin.Joint]) -> [Matrix4x4] {
//        return joints.map({$0.inverseBindMatrix.inverse})

        return joints.map({(rootJoint.firstDescendant(withID: $0.id)?.modelSpace ?? .identity) * $0.inverseBindMatrix})
    }
}

extension Skeleton.Pose.Joint: Hashable {
    public static func ==(lhs: Skeleton.Pose.Joint, rhs: Skeleton.Pose.Joint) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
