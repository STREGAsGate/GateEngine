/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor public final class ObjectAnimation3DComponent: ResourceConstrainedComponent {
    public var disabled: Bool = false
    internal var deltaAccumulator: Float = 0
    public var slowAnimationsPastDistance: Float = 20
    
    public var animationSet: [ObjectAnimation3D]? = nil {
        didSet {
            self.resourcesState = .pending
        }
    }

    public var blendingDuration: Float? = nil
    public var blendingAccumulator: Float = 0
    public var blendingProgress: Float {
        guard let duration = blendingDuration, duration > 0 else { return 1 }
        return .maximum(0, .minimum(1, Float(blendingAccumulator) / Float(duration)))
    }

    func update(deltaTime: Float, objectScale: Size3) {
        if let activeAnimation, activeAnimation.isReady {
            activeAnimation.accumulatedTime += deltaTime * (objectScale.length / 3) * activeAnimation.scale
            deltaAccumulator += deltaTime
            blendingAccumulator += deltaTime
        }
    }

    public var activeAnimation: ObjectAnimation3D? = nil {
        didSet {
            resourcesState = .pending
        }
    }

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
        guard activeAnimation?.isReady == true else {return false}
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
        guard let activeAnimation else { return false }
        guard let animation = animationSet?[index] else { return false }
        return activeAnimation == animation
    }

    public func setAnimation(at index: Int, scale: Float = 1, repeats: Bool = false) {
        guard let animation = animationSet?[index] else { return }
        self.activeAnimation = animation
    }

    public func replaceActiveAnimation(withAt index: Int, scale: Float? = nil, repeats: Bool? = nil) {
        guard let animation = animationSet?[index] else { return }
        self.activeAnimation = animation
        if let scale = scale {
            self.activeAnimation?.scale = scale
        }
        if let repeats = repeats {
            self.activeAnimation?.repeats = repeats
        }
    }
    
    public var resourcesState: ResourceState = .pending
    public var resources: [any Resource] {
        return animationSet ?? []
    }

    nonisolated public required init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension ObjectAnimation3DComponent {
    public func reset(keepingAnimationTime keepAnimationTime: Bool = false) {
        self.blendingAccumulator = 0
        self.blendingDuration = nil
        if keepAnimationTime == false, activeAnimation?.isReady == true {
            activeAnimation?.accumulatedTime = 0
        }
        self.playbackState = .play
    }
}

extension Entity {
    @inlinable @inline(__always)
    public var objectAnimation3DComponent: ObjectAnimation3DComponent {
        return self[ObjectAnimation3DComponent.self]
    }
}
