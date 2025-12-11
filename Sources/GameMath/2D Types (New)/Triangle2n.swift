/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

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
    public init(_ p1: Position2n<Scalar>, p2: Position2n<Scalar>, p3: Position2n<Scalar>) {
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
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
