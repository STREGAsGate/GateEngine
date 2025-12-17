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
    
    /// The unit distance the light can travel
    public var radius: Float
    /// How smooth the transition from the light center to the radius appears. 0 is the softest, 1 is the hardest
    public var falloff: Float
    
    @inlinable
    public var softness: Float {
        nonmutating get {
            self.radius / self.falloff
        }
        mutating set {
            self.falloff = self.radius * newValue
        }
    }

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
        self.falloff = self.radius * softness
        self.position = position
    }
    
    public init(
        brightness: Float,
        color: Color,
        radius: Float,
        falloff: Float,
        position: Position3f
    ) {
        self.brightness = brightness
        self.color = color
        self.radius = radius
        self.falloff = falloff
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

        let s2 = square(s)

//        if cusp == true {
//        return brightness * square(1 - s2) / (1 + falloff * s)
//        }
        return brightness * square(1 - s2) / (1 + falloff * s2)
    }
}
