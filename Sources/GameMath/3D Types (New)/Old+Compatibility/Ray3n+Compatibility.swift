/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Ray3n where Scalar: BinaryInteger {
    var oldRay: Ray3D {
        return Ray3D(from: self.origin.oldVector, toward: self.direction.oldVector)
    }
}

public extension Ray3n where Scalar: BinaryFloatingPoint {
    var oldRay: Ray3D {
        return Ray3D(from: self.origin.oldVector, toward: self.direction.oldVector)
    }
}

public extension Ray3n where Scalar: BinaryFloatingPoint {
    init(oldRay ray: Ray3D) {
        self.init(origin: .init(oldVector: ray.origin), direction: .init(oldVector: ray.direction))
    }
}
