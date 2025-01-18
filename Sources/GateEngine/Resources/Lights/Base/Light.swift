/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public class Light: OldResource {
    /// How much the light illuminates what it touches
    public var brightness: Float
    /// The color emitted by the light
    public var color: Color

    public enum UpdateShadows: Equatable {
        /// Shadows get redrawn every frame
        case everyFrame
        /// Shadws get redrawn when the light changes position
        case whenMoving
    }
    public enum DrawShadows: Equatable {
        /// No shadows are created by this light
        case never
        /// Shadows are created
        case always(updating: UpdateShadows = .everyFrame)
    }

    internal init(brightness: Float, color: Color) {
        self.brightness = brightness
        self.color = color
        super.init()

        self.state = .ready
    }
}
