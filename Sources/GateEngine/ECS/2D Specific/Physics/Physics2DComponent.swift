/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Physics2DComponent: Component {

    public var velocity: Size2 = .zero {
        didSet {
            self.velocityMagnitudeCache = nil
        }
    }
    private var velocityMagnitudeCache: Float? = nil
    private var velocityMagnitude: Float {
        if let velocityMagnitudeCache {
            return velocityMagnitudeCache
        }
        let newMagnitude = velocity.magnitude
        velocityMagnitudeCache = newMagnitude
        return newMagnitude
    }

    public private(set) var speed: Float = 0

    public var acceleration: Float? = nil
    public var deceleration: Float? = nil

    func update(_ deltaTime: Float) {
        if let xzAcceleration = acceleration, velocityMagnitude >= speed {
            speed.interpolate(to: velocityMagnitude, .linear(deltaTime * xzAcceleration))
        } else if let xzDeceleration = deceleration, velocityMagnitude > speed {
            speed.interpolate(to: velocityMagnitude, .linear(deltaTime * xzDeceleration))
        } else {
            speed = velocityMagnitude
        }
    }

    public init() {}

    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    var physics2DComponent: Physics2DComponent {
        return self[Physics2DComponent.self]
    }
}
