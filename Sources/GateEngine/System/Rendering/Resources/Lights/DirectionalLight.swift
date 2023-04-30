/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class DirectionalLight: Light {
    /// `true` if the light can create shadows
    public var drawShadows: DrawShadows

    public var direction: Direction3
    public func setTransform(_ transform: Transform3) {
        self.direction = transform.rotation.forward
    }
    public func setRotation(_ rotation: Quaternion) {
        self.direction = rotation.forward
    }
    
    init(brightness: Float, color: Color, drawShadows: DrawShadows, direction: Direction3) {
        self.direction = direction
        self.drawShadows = drawShadows
        super.init(brightness: brightness, color: color)
    }
}
