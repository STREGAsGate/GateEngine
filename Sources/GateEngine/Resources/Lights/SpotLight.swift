/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class SpotLight: Light {
    /// The maximum distance light can appear
    public var radius: Float
    /// How large the spot appears
    public var coneAngle: Degrees
    /// How sharp the cone edge appears
    public var sharpness: Float

    /// `true` if the light can create shadows
    public var drawShadows: DrawShadows

    public var position: Position3
    public var direction: Direction3
    public func setTransform(_ transform: Transform3) {
        self.position = transform.position
        self.direction = transform.rotation.forward
    }
    public func setRotation(_ rotation: Quaternion) {
        self.direction = rotation.forward
    }

    init(
        brightness: Float = 1,
        radius: Float = 5,
        coneAngle: Degrees = Degrees(45),
        sharpness: Float,
        color: Color,
        drawShadows: DrawShadows,
        position: Position3,
        direction: Direction3
    ) {
        self.radius = radius
        self.coneAngle = coneAngle
        self.sharpness = sharpness
        self.drawShadows = drawShadows
        self.position = position
        self.direction = direction
        super.init(brightness: brightness, color: color)
    }
}
