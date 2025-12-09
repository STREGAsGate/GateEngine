/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Ray3h = Ray3n<Float16>
public typealias Ray3f = Ray3n<Float32>
public typealias Ray3d = Ray3n<Float64>

@frozen
public struct Ray3n<Scalar: Intersectable.ScalarType> {
    public var origin: Position3n<Scalar>
    public var direction: Direction3n<Scalar>

    public init(origin: Position3n<Scalar>, direction: Direction3n<Scalar>) {
        self.origin = origin
        self.direction = direction
    }
}

public protocol Intersectable {
    typealias ScalarType = Vector3n.ScalarType & FloatingPoint
    associatedtype Scalar: ScalarType
    
    func intersectionOfRay(_ ray: Ray3n<Scalar>) -> Position3n<Scalar>
}
