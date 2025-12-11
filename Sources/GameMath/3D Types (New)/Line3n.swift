/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Line3f = Line3n<Float32>
public typealias Line3d = Line3n<Float64>

@frozen
public struct Line3n<Scalar: FloatingPoint & SIMDScalar> {
    public let p1: Position3n<Scalar>
    public let p2: Position3n<Scalar>
    
    public init(p1: Position3n<Scalar>, p2: Position3n<Scalar>) {
        self.p1 = p1
        self.p2 = p2
    }
}

public extension Line3n {
    @inlinable
    var length: Scalar {
        return p1.distance(from: p2)
    }
    
    @inlinable
    var direction: Direction3n<Scalar> {
        return Direction3n(from: p1, to: p2)
    }
}

public extension Line3n where Scalar: ExpressibleByFloatLiteral {
    @inlinable
    var center: Position3n<Scalar> {
        return (p1 + p2) * 0.5
    }
    
    @inlinable
    func nearestSurfacePosition(to p: Position3n<Scalar>) -> Position3n<Scalar> {
        let ab: Position3n<Scalar> = p2 - p1
        let ap: Position3n<Scalar> = p - p1
        
        var t: Scalar = ap.dot(ab) / ab.squaredLength
        if t < 0.0 {
            t = 0.0
        }
        if t > 1.0 {
            t = 1.0
        }
        
        return p1 + (ab * t)
    }
}

public extension Line3n {
    @inlinable
    static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        fatalError("Not implemented.")
//        return Line3n(lhs.p1 * rhs, lhs.p2 * rhs)
    }
    
    @inlinable
    static func * (lhs: Matrix4x4, rhs: Self) -> Self {
        fatalError("Not implemented.")
//        return Line3n(lhs * rhs.p1, lhs * rhs.p2)
    }
}
