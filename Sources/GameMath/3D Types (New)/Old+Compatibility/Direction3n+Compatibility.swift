/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Direction3n where Scalar: BinaryInteger {
    var vector3: Direction3 {
        return Direction3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
    
    init(_ vector3: Direction3) {
        self.init(x: Scalar(vector3.x), y: Scalar(vector3.y), z: Scalar(vector3.z))
    }
}

public extension Direction3n where Scalar: BinaryFloatingPoint {
    var vector3: Direction3 {
        return Direction3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
    
    init(_ vector3: Direction3) {
        self.init(x: Scalar(vector3.x), y: Scalar(vector3.y), z: Scalar(vector3.z))
    }
}
