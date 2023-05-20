/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct Ray2D {
    public var origin: Position2
    public var direction: Direction2
    public init(from origin: Position2, toward direction: Direction2) {
        self.origin = origin
        self.direction = direction
    }
    
    public init(from origin: Position2, toward destination: Position2) {
        self.origin = origin
        self.direction = Direction2(from: origin, to: destination)
    }
    
    internal func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Ray2D {
        return Ray2D(from: self.origin / ellipsoidRadius, toward: (self.direction / ellipsoidRadius).normalized)
    }
}
