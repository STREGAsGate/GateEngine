/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Size2n where Scalar: BinaryInteger {
    var oldVector: Size2 {
        return Size2(x: Float(self.x), y: Float(self.y))
    }
}

public extension Size2n where Scalar: BinaryFloatingPoint {
    var oldVector: Size2 {
        return Size2(x: Float(self.x), y: Float(self.y))
    }
}
