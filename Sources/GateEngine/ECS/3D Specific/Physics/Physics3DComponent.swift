/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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
    
    public var xzAcceleration: Float? = nil
    public var xzDeceleration: Float? = nil
    
    func update(_ deltaTime: Float) {
        if let xzAcceleration = xzAcceleration, velocityXZMagnitude >= xzSpeed {
            xzSpeed.interpolate(to: velocityXZMagnitude, .linear(deltaTime * xzAcceleration))
        }else if let xzDeceleration = xzDeceleration, velocityXZMagnitude > xzSpeed  {
            xzSpeed.interpolate(to: velocityXZMagnitude, .linear(deltaTime * xzDeceleration))
        }else{
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
    
    public required init(){}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    var physics3DComponent: Physics3DComponent {
        return self[Physics3DComponent.self]
    }
}
