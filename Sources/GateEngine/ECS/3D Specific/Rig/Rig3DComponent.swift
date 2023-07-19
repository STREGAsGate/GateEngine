/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public class Rig3DComponent: Component {
    public var disabled: Bool = false
    internal var deltaAccumulator: Float = 0
    public var slowAnimationsPastDistance: Float = 20
    
    public var animationSet: [SkeletalAnimation]? = nil
    public var skeleton: Skeleton! = nil
    
    public var blendingDuration: Float? = nil
    public var blendingAccumulator: Float = 0
    public var blendingProgress: Float {
        guard let duration = blendingDuration, duration > 0 else {return 1}
        return .maximum(0, .minimum(1, Float(blendingAccumulator) / Float(duration)))
    }
    
    internal var additionalTransforms: [String : Transform3] = [:]
    ///Applies the transform after animations for the next update only
    public func setAdditionalTransform(_ transform: Transform3?, forJointNamed jointName: String) {
        if let transform = transform {
            additionalTransforms[jointName] = transform
        }else{
            additionalTransforms.removeValue(forKey: jointName)
        }
    }
    
    public func getAdditionalTransform(forJointNamed jointName: String) -> Transform3? {
        return additionalTransforms[jointName]
    }
    
    public var updateColliderFromBoneNamed: String? = nil
    
    func update(deltaTime: Float, objectScale: Size3) {
        activeAnimation?.update(deltaTime: deltaTime, objectScale: objectScale)
        deltaAccumulator += deltaTime
        blendingAccumulator += deltaTime
    }
    
    public class Animation {
        public var subAnimations: [SubAnimation]
        var primaryIndex: Int = 0
        
        @inline(__always)
        public var progress: Float {
            get {
                return subAnimations[primaryIndex].progress
            }
            set {
                subAnimations[primaryIndex].progress = newValue
            }
        }
        
        @inline(__always)
        public var scale: Float {
            get {
                return subAnimations[primaryIndex].scale
            }
            set {
                subAnimations[primaryIndex].scale = newValue
            }
        }
        
        @inline(__always)
        public var isFinished: Bool {
            return subAnimations[primaryIndex].isFinished
        }
        
        @inline(__always)
        public var repeats: Bool {
            get {
                return subAnimations[primaryIndex].repeats
            }
            set {
                subAnimations[primaryIndex].repeats = newValue
            }
        }
        
        @inline(__always)
        public var skeletalAnimation: SkeletalAnimation {
            get {
                return subAnimations[primaryIndex].skeletalAnimation
            }
            set {
                subAnimations[primaryIndex].skeletalAnimation = newValue
            }
        }
        
        @inline(__always)
        func update(deltaTime: Float, objectScale: Size3) {
            for index in subAnimations.indices {
                let animation = subAnimations[index]
                subAnimations[index].accumulatedTime += deltaTime * (objectScale.length / 3) * animation.scale
            }
        }
        
        @inline(__always)
        func resetAccumulatedTime() {
            for index in subAnimations.indices {
                subAnimations[index].accumulatedTime = 0
            }
        }
        
        public init() {
            subAnimations = []
        }
        
        @inline(__always)
        public init(_ skeletalAnimation: SkeletalAnimation, skipJoints: [Skeleton.SkipJoint] = [], scale: Float = 1, repeats: Bool = false, accumulatedTime: Float = 0) {
            let a = SubAnimation(skeletalAnimation: skeletalAnimation, skipJoints: skipJoints, scale: scale, repeats: repeats, accumulatedTime: accumulatedTime)
            subAnimations = [a]
        }
        
        public func append(_ skeletalAnimation: SkeletalAnimation, skipJoints: [Skeleton.SkipJoint], scale: Float = 1, repeats: Bool, accumulatedTime: Float = 0) {
            let a = SubAnimation(skeletalAnimation: skeletalAnimation, skipJoints: skipJoints, scale: scale, repeats: repeats, accumulatedTime: accumulatedTime)
            self.subAnimations.append(a)
        }
        
        public struct SubAnimation {
            public var skeletalAnimation: SkeletalAnimation
            public var skipJoints: [Skeleton.SkipJoint]
            
            var duration: Float {
                return skeletalAnimation.duration
            }
            public var scale: Float
            public var repeats: Bool
            
            public func currentFrame(assumingFrameRate fps: UInt) -> UInt {
                let totalFrames = Float(fps) * duration
                return UInt(accumulatedTime * totalFrames)
            }
            
            public var accumulatedTime: Float {
                didSet {
                    guard repeats else {return}
                    if accumulatedTime > duration {
                        accumulatedTime -= duration
                    }
                }
            }
            
            @inline(__always)
            public var progress: Float {
                get {
                    return .maximum(0, .minimum(1, (Float(accumulatedTime) * scale) / Float(duration)))
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
            
            @inline(__always)
            public var isFinished: Bool {
                guard duration > 0 else {return true}
                if repeats {
                    return false
                }
                return self.progress >= 1
            }
        }
    }
    
    public var activeAnimation: Animation? = nil
    
    public enum PlaybackState {
        case play
        case pause
    }
    
    public var playbackState: PlaybackState = .play
    
    public var animationProgress: Float {
        get {
            return activeAnimation?.progress ?? 1
        }
        set {
            activeAnimation?.progress = newValue
        }
    }
    
    public var animationIsFinished: Bool {
        return activeAnimation?.isFinished ?? true
    }
    
    public var animationRepeats: Bool {
        get {
            return activeAnimation?.repeats ?? false
        }
        set {
            activeAnimation?.repeats = newValue
        }
    }
    
    public var animationScale: Float {
        get {
            return activeAnimation?.scale ?? 1
        }
        set {
            activeAnimation?.scale = newValue
        }
    }
    
    public func isActiveAnimation(at index: Int) -> Bool {
        guard let activeAnimation = activeAnimation else {return false}
        guard let sa = animationSet?[index] else {return false}
        for animation in activeAnimation.subAnimations {
            if animation.skeletalAnimation === sa {
                return true
            }
        }
        return false
    }
    
    public func setAnimation(at index: Int, scale: Float = 1, repeats: Bool = false) {
        guard let sa = animationSet?[index] else {return}
        self.activeAnimation = Animation(sa, scale: scale, repeats: repeats)
    }
    
    public func replaceActiveAnimation(withAt index: Int, scale: Float? = nil, repeats: Bool? = nil) {
        guard let sa = animationSet?[index] else {return}
        self.activeAnimation?.skeletalAnimation = sa
        if let scale = scale {
            self.activeAnimation?.scale = scale
        }
        if let repeats = repeats {
            self.activeAnimation?.repeats = repeats
        }
    }
    
    public required init(){}
    public static let componentID: ComponentID = ComponentID()
}

public extension Rig3DComponent {
    func reset(keepingAnimationTime keepAnimationTime: Bool = false) {
        self.blendingAccumulator = 0
        self.blendingDuration = nil
        if keepAnimationTime == false {
            activeAnimation?.resetAccumulatedTime()
        }
        self.playbackState = .play
    }
}

public class RigAttachmentComponent: Component {
    public var parentEntityID: ObjectIdentifier! = nil
    public var parentJointName: String! = nil
        
    public required init(){}
    public static let componentID: ComponentID = ComponentID()
}

public extension Entity {
    @inlinable @inline(__always)
    var rig3DComponent: Rig3DComponent {
        return self[Rig3DComponent.self]
    }
}
