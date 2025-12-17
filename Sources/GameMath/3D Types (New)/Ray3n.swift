/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Ray3f = Ray3n<Float32>
public typealias Ray3d = Ray3n<Float64>

@frozen
public struct Ray3n<Scalar: Ray3nIntersectable.ScalarType> {
    public var origin: Position3n<Scalar>
    public var direction: Direction3n<Scalar>

    public init(origin: Position3n<Scalar>, direction: Direction3n<Scalar>) {
        self.origin = origin
        self.direction = direction
    }
    
    public init(from origin: Position3n<Scalar>, toward destination: Position3n<Scalar>) {
        self.origin = origin
        self.direction = Direction3n<Scalar>(from: origin, to: destination)
    }
}

public protocol Ray3nIntersectable {
    typealias ScalarType = Vector3n.ScalarType & FloatingPoint
    associatedtype Scalar: ScalarType
    
    func intersects(with ray: Ray3n<Scalar>) -> Bool
    func intersection(of ray: Ray3n<Scalar>) -> Position3n<Scalar>?
}
