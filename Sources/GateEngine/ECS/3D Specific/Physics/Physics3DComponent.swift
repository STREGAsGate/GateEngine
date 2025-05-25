/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Physics3DComponent: Component {
    public var velocity: Size3 = .zero {
        didSet {
            self._velocityXZMagnitude = nil
        }
    }
    private var _velocityXZMagnitude: Float? = nil
    private var velocityXZMagnitude: Float {
        if let existing = _velocityXZMagnitude {
            return existing
        }
        let new = Size2(velocity.x, velocity.z).magnitude
        _velocityXZMagnitude = new
        return new
    }

    public private(set) var xzSpeed: Float = 0

    public var xzAcceleration: Float? = nil {
        didSet {
            accelerationAccumulator = 0
        }
    }
    public var xzDeceleration: Float? = nil {
        didSet {
            accelerationAccumulator = 0
        }
    }
    var accelerationAccumulator: Float = 0
    public private(set) var isAccelerating: Bool = false
    
    public func applyForce(_ force: Float, inDirection direction: Direction3) {
        self.velocity += direction.normalized * force
    }

    func update(_ deltaTime: Float) {
        let wasAccelerating = self.isAccelerating
        self.isAccelerating = velocityXZMagnitude >= xzSpeed
        if wasAccelerating != isAccelerating {
            self.accelerationAccumulator = 0
        }
        self.accelerationAccumulator += deltaTime
        
        if let xzAcceleration = xzAcceleration, xzAcceleration > 0, self.isAccelerating {
            xzSpeed.interpolate(to: velocityXZMagnitude, .easeIn(max(0, min(1, accelerationAccumulator / xzAcceleration))))
        } else if let xzDeceleration = xzDeceleration, xzDeceleration > 0, self.isAccelerating == false {
            xzSpeed.interpolate(to: velocityXZMagnitude, .easeOut(max(0, min(1, accelerationAccumulator / xzDeceleration))))
            if xzSpeed < 0.1 {
                xzSpeed = 0
            }
        } else {
            xzSpeed = velocityXZMagnitude
        }
    }

    static var universalGravity: Size3 = Size3(0, -9.807 * 2, 0)
    public var gravity: Size3? = nil

    public func effectiveGravity() -> Size3 {
        return self.gravity ?? Self.universalGravity
    }

    public var shouldApplyGravity: Bool = true

    public static func == (lhs: Physics3DComponent, rhs: Physics3DComponent) -> Bool {
        return lhs.velocity == rhs.velocity
    }

    public required init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable
    public var physics3DComponent: Physics3DComponent {
        return self[Physics3DComponent.self]
    }
}
