/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Triangle2f = Triangle2n<Float32>
public typealias Triangle2d = Triangle2n<Float64>

@frozen
public struct Triangle2n<Scalar: Vector2n.ScalarType & FloatingPoint> {
    /// The cartesian position of the triangle's first point.
    public var p1: Position2n<Scalar>
    /// The cartesian position of the triangle's second point.
    public var p2: Position2n<Scalar>
    /// The cartesian position of the triangle's third point.
    public var p3: Position2n<Scalar>
    
    /**
     - parameter p1: The cartesian position of the triangle's first point.
     - parameter p2: The cartesian position of the triangle's second point.
     - parameter p3: The cartesian position of the triangle's third point.
     */
    public init(p1: Position2n<Scalar>, p2: Position2n<Scalar>, p3: Position2n<Scalar>) {
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
}

public extension Triangle2n where Scalar: ExpressibleByFloatLiteral {
    var center: Position2n<Scalar> {
        return Position2n<Scalar>(x: (p1.x + p2.x + p3.x) / 3.0, y: (p1.y + p2.y + p3.y) / 3.0)
    }
}

public extension Triangle2n {
    @inlinable
    func contains(_ position: Position2n<Scalar>) -> Bool where Scalar: ExpressibleByFloatLiteral {
        let pa = self.p1
        let pb = self.p2
        let pc = self.p3
        
        let e10 = pb - pa
        let e20 = pc - pa
        let a = e10.dot(e10)
        let b = e10.dot(e20)
        let c = e20.dot(e20)
        let ac_bb = (a * c) - (b * b)
        let vp = Position2n(x: position.x - pa.x, y: position.y - pa.y)
        let d = vp.dot(e10)
        let e = vp.dot(e20)
        let x = (d * c) - (e * b)
        let y = (e * a) - (d * b)
        let z = x + y - ac_bb
        
        return z < 0.0 && x >= 0.0 && y >= 0.0
    }
    
    /**
     Locates a position on the surface of this triangle that is as close to the given point as possible.
     - parameter position: A point in space to use as an reference
     - returns: The point on the triangle's surface that is nearest to `p`
     */
    func nearestSurfacePosition(to position: Position2n<Scalar>) -> Position2n<Scalar> where Scalar: ExpressibleByFloatLiteral {
        let a = self.p1
        let b = self.p2
        let c = self.p3
        let p = position
        
        // Check if P in vertex region outside A
        let ab = b - a
        let ac = c - a
        let ap = p - a
        
        let d1 = ab.dot(ap)
        let d2 = ac.dot(ap)
        if d1 <= 0 && d2 <= 0 {
            return a // barycentric coordinates (1,0,0)
        }
        // Check if P in vertex region outside B
        let bp = p - b
        let d3 = ab.dot(bp)
        let d4 = ac.dot(bp)
        if d3 >= 0 && d4 <= d3 {
            return b // barycentric coordinates (0,1,0)
        }
        // Check if P in edge region of AB, if so return projection of P onto AB
        let vc = d1 * d4 - d3 * d2
        if vc <= 0 && d1 >= 0 && d3 <= 0 {
            let v = d1 / (d1 - d3)
            return a + ab * v // barycentric coordinates (1-v,v,0)
        }
        // Check if P in vertex region outside C
        let cp = p - c
        let d5 = ab.dot(cp)
        let d6 = ac.dot(cp)
        if d6 >= 0 && d5 <= d6 {
            return c // barycentric coordinates (0,0,1)
        }
        // Check if P in edge region of AC, if so return projection of P onto AC
        let vb = d5 * d2 - d1 * d6
        if vb <= 0 && d2 >= 0 && d6 <= 0 {
            let w = d2 / (d2 - d6)
            return a + ac * w  // barycentric coordinates (1-w,0,w)
        }
        // Check if P in edge region of BC, if so return projection of P onto BC
        let va = d3 * d6 - d5 * d4
        if va <= 0 && (d4 - d3) >= 0 && (d5 - d6) >= 0 {
            let w = (d4 - d3) / ((d4 - d3) + (d5 - d6))
            return b + (c - b) * w // barycentric coordinates (0,1-w,w)
        }
        // P inside face region. Compute Q through its barycentric coordinates (u,v,w)
        let denom = 1.0 / (va + vb + vc)
        let v = vb * denom
        let w = vc * denom
        return a + ab * v + ac * w //=u*a+v*b+w*c,u=va*denom=1.0f-v-w
    }
}

// MARK: - Barycentric
public extension Triangle2n where Scalar: ExpressibleByFloatLiteral {
    /**
     Converts a cartesian position to barycentric coordinate.
     - parameter cartesianPosition: A cartesian point inside the triangle.
     - returns: A barycentric coordinate.
     - note: Assumes `position` is within the triangle.
     */
    @inlinable
    func uncheckedBarycentric(from cartesianPosition: Position2n<Scalar>) -> Position3n<Scalar> {
        let y2y3: Scalar = p2.y - p3.y
        let x3x2: Scalar = p3.x - p2.x
        let x1x3: Scalar = p1.x - p3.x
        let y1y3: Scalar = p1.y - p3.y
        let y3y1: Scalar = p3.y - p1.y
        let xx3: Scalar = cartesianPosition.x - p3.x
        let yy3: Scalar = cartesianPosition.y - p3.y
        
        let d: Scalar = y2y3 * x1x3 + x3x2 * y1y3
        let lambda1: Scalar = (y2y3 * xx3 + x3x2 * yy3) / d
        let lambda2: Scalar = (y3y1 * xx3 + x1x3 * yy3) / d
        let lambda3: Scalar = 1.0 - lambda1 - lambda2
        
        return Position3n(
            lambda1,
            lambda2,
            lambda3,
        )
    }
    
    /**
     Converts a cartesian position to barycentric coordinate.
     - parameter cartesianPosition: Any cartesian position.
     - returns: A barycentric coordinate if `position` was within the triangle, or `nil`.
     */
    @inlinable
    func barycentric(from cartesianPosition: Position2n<Scalar>) -> Position3n<Scalar>? {
        let barycentric = self.uncheckedBarycentric(from: cartesianPosition)

        // Check if the coordiante is within the triangle
        if barycentric < 0.0 || barycentric >= 1.0 {
            return nil
        }
        
        return barycentric
    }
}

// MARK: - Common Protocol Conformances
extension Triangle2n: Equatable where Scalar: Equatable { }
extension Triangle2n: Hashable where Scalar: Hashable { }
extension Triangle2n: Sendable where Scalar: Sendable { }
extension Triangle2n: Codable where Scalar: Codable { }
extension Triangle2n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Triangle2n: BinaryCodable where Self: BitwiseCopyable { }
