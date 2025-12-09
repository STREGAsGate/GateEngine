/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Position3n where Scalar: BinaryInteger {
    var oldVector: Position3 {
        return Position3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}

public extension Position3n where Scalar: BinaryFloatingPoint {
    var oldVector: Position3 {
        return Position3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}
