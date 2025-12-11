/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum Winding {
    case clockwise
    case counterClockwise
    
    /// The default value used across GateEngine for triangle types
    @_transparent
    @inlinable
    public static var `default`: Self {
        return .clockwise
    }
}
