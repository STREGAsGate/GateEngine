/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public protocol LightEmitter: Equatable, Hashable, Sendable {
    /// How much the light illuminates what it touches
    var brightness: Float {get}
    /// The color emitted by the light
    var color: Color {get}
}
