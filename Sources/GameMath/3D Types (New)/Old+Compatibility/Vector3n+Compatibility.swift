/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Vector3n where Scalar: BinaryInteger {
    init(oldVector vector3: some Vector3) {
        self.init(x: Scalar(vector3.x), y: Scalar(vector3.y), z: Scalar(vector3.z))
    }
}

public extension Vector3n where Scalar: BinaryFloatingPoint {
    init(oldVector vector3: some Vector3) {
        self.init(x: Scalar(vector3.x), y: Scalar(vector3.y), z: Scalar(vector3.z))
    }
}
