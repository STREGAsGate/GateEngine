/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

class PhysicsComponent: Component {
    var velocity: Size3 = .zero {
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
    
    private(set) var xzSpeed: Float = 0
    
    var xzAcceleration: Float? = nil
    var xzDeceleration: Float? = nil
    
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
    var gravity: Size3? = nil
    
    func effectiveGravity() -> Size3 {
        return self.gravity ?? Self.universalGravity
    }
    
    var shouldApplyGravity: Bool = true
            
    static func == (lhs: PhysicsComponent, rhs: PhysicsComponent) -> Bool {
        return lhs.velocity == rhs.velocity
    }
    
    required init(){}
    static let componentID: ComponentID = ComponentID()
}
