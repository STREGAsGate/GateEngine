/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Direction3n where Scalar: BinaryInteger {
    var oldVector: Direction3 {
        return Direction3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}

public extension Direction3n where Scalar: BinaryFloatingPoint {
    var oldVector: Direction3 {
        return Direction3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}
