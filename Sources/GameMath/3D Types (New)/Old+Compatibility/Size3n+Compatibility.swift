/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Size3n where Scalar: BinaryInteger {
    var oldVector: Size3 {
        return Size3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}

public extension Size3n where Scalar: BinaryFloatingPoint {
    var oldVector: Size3 {
        return Size3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}
