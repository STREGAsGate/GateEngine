/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct SpotLight: LightEmitter {
    public var brightness: Float
    
    public var color: Color
    
    /// The maximum distance light can appear
    public var radius: Float
    /// How large the spot appears
    public var coneAngle: Degrees
    /// How sharp the cone edge appears
    public var sharpness: Float

    public var position: Position3
    public var direction: Direction3
    
    public mutating func setTransform(_ transform: Transform3) {
        self.position = transform.position
        self.direction = transform.rotation.forward
    }
    public mutating func setRotation(_ rotation: Quaternion) {
        self.direction = rotation.forward
    }

    public init(
        brightness: Float,
        color: Color,
        radius: Float,
        coneAngle: Degrees,
        sharpness: Float,
        position: Position3,
        direction: Direction3
    ) {
        self.brightness = brightness
        self.color = color
        self.radius = radius
        self.coneAngle = coneAngle
        self.sharpness = sharpness
        self.position = position
        self.direction = direction
    }
}
