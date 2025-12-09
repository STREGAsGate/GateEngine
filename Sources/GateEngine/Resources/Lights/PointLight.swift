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
    public var softness: Float

    public var position: Position3

    public init(
        brightness: Float,
        color: Color,
        radius: Float,
        softness: Float,
        position: Position3
    ) {
        self.brightness = brightness
        self.color = color
        self.radius = radius
        self.softness = softness
        self.position = position
    }
}
