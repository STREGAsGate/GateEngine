/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct DirectionalLight: LightEmitter {
    public var brightness: Float
    public var color: Color
    public var direction: Direction3

    public init(brightness: Float, color: Color, direction: Direction3) {
        self.brightness = brightness
        self.color = color
        self.direction = direction
    }
}
