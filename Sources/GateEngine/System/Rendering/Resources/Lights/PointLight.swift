/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class PointLight: Light {
    /// The unit distance the light can travel
    public var radius: Float
    /// How smooth the transition from the light center to the radius appears. 0 is the softest, 1 is the hardest
    public var softness: Float
    /// How to handle shadows
    public var drawShadows: DrawShadows

    public var position: Position3
    public func setTransform(_ transform: Transform3) {
        self.position = transform.position
    }

    init(
        brightness: Float,
        radius: Float,
        softness: Float,
        color: Color,
        drawShadows: DrawShadows,
        position: Position3
    ) {
        self.radius = radius
        self.softness = softness
        self.drawShadows = drawShadows
        self.position = position
        super.init(brightness: brightness, color: color)
    }
}
