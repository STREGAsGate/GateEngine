/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Position2n where Scalar: BinaryInteger {
    var oldVector: Position2 {
        return Position2(x: Float(self.x), y: Float(self.y))
    }
}

public extension Position2n where Scalar: BinaryFloatingPoint {
    var oldVector: Position2 {
        return Position2(x: Float(self.x), y: Float(self.y))
    }
}
