/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Rotation3n where Scalar: BinaryInteger {
    var oldVector: Quaternion {
        return Quaternion(x: Float(self.x), y: Float(self.y), z: Float(self.z), w: Float(self.w))
    }
    init(oldVector vector4: some Vector4) {
        self.init(x: Scalar(vector4.x), y: Scalar(vector4.y), z: Scalar(vector4.z), w: Scalar(vector4.w))
    }
}

public extension Rotation3n where Scalar: BinaryFloatingPoint {
    var oldVector: Quaternion {
        return Quaternion(x: Float(self.x), y: Float(self.y), z: Float(self.z), w: Float(self.w))
    }
    init(oldVector vector4: some Vector4) {
        self.init(x: Scalar(vector4.x), y: Scalar(vector4.y), z: Scalar(vector4.z), w: Scalar(vector4.w))
    }
}
