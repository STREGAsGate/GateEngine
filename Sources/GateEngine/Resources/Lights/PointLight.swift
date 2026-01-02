/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct PointLight: LightEmitter {
    public var brightness: Float
    public var color: Color
    public var radius: Float
    public var softness: Float
    public var position: Position3f

    public init(
        brightness: Float,
        color: Color,
        radius: Float,
        softness: Float,
        position: Position3f
    ) {
        self.brightness = brightness
        self.color = color
        self.radius = radius
        self.softness = softness
        self.position = position
    }
}


extension PointLight: BakingLightEmitter {
    public func attenuation(to position: Position3f) -> Float? {
        func square(_ x: Float) -> Float {
            return x * x
        }
        
        let d = self.position.distance(from: position)
        if d > radius {
            return nil
        }
        
        let s = d / radius
        if s >= 1.0 {
            return 0
        }

//        let s2 = square(s)

        return Float(brightness).interpolated(to: 0.0, .linear(s * softness))
    }
}
