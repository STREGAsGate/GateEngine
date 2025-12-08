/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Ray3f = Ray3n<Float>

@frozen
public struct Ray3n<Scalar: Vector3n.ScalarType> {
    var origin: Position3n<Scalar>
    var direction: Direction3n<Scalar>

    init(origin: Position3n<Scalar>, direction: Direction3n<Scalar>) {
        self.origin = origin
        self.direction = direction
    }
}
