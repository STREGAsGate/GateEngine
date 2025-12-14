/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Rect3f = Rect3n<Float32>
public typealias Rect3d = Rect3n<Float64>

@frozen
public struct Rect3n<Scalar: Vector3n.ScalarType> {
    public var center: Position3n<Scalar>
    public var radius: Size3n<Scalar>

    public init(size: Size3n<Scalar>, center: Position3n<Scalar>) where Scalar: FixedWidthInteger {
        self.center = center
        self.radius = size / Size3n<Scalar>(width: 2, height: 2, depth: 2)
    }
    
    public init(size: Size3n<Scalar>, center: Position3n<Scalar>) where Scalar: FloatingPoint, Scalar: ExpressibleByFloatLiteral {
        self.center = center
        self.radius = size * 0.5
    }
}

extension Rect3n: Rect3nSurfaceMath where Scalar: Rect3nSurfaceMath.ScalarType { }
extension Rect3n: Ray3nIntersectable where Scalar: Ray3nIntersectable.ScalarType { }
