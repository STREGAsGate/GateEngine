/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Plane3h = Plane3n<Float16>
public typealias Plane3f = Plane3n<Float32>
public typealias Plane3d = Plane3n<Float64>

@frozen
public struct Plane3n<Scalar: Vector3n.ScalarType> where Scalar: FloatingPoint {
    public var normal: Direction3n<Scalar>
    public var constant: Scalar
    
    @inlinable
    public var origin: Position3n<Scalar> {
        return Position3n(normal * constant)
    }
    
    public init(normal: Direction3n<Scalar>, constant: Scalar) {
        self.constant = constant
        self.normal = normal
    }
    
    @inlinable
    public init(origin: Position3n<Scalar>, normal: Direction3n<Scalar>) {
        self.init(normal: normal, constant: -origin.dot(normal))
    }
    
    @inlinable
    public init(_ a: Scalar, _ b: Scalar, _ c: Scalar, _ d: Scalar) {
        self.init(normal: Direction3n<Scalar>(a, b, c), constant: d)
    }
    
    @inlinable
    public var normalized: Self {
        let m = normal.magnitude
        return Self(normal: normal / m, constant: constant / m)
    }
    
    /// true if a line in `direction` will intersect the plane
    @inlinable
    public func isIntersecting(with direction: Direction3n<Scalar>) -> Bool {
        return normal.isFrontFacing(toward: direction) == false
    }
}

public extension Plane3n {
    enum Side {
        case front
        case back
    }
    
    @inlinable
    func classifyPoint(_ p: Position3n<Scalar>) -> Side {
        let dot: Scalar = p.dot(normal)
        if dot + constant < 0 {
            return .back
        }
        return .front
    }
    
    @inlinable
    func distanceToPoint(_ p: Position3n<Scalar>) -> Scalar {
        return (p.x * normal.x + p.y * normal.y + p.z * normal.z) + constant
    }
    
    @inlinable
    func intersectionOfLine(_ line: Line3D) -> Position3n<Scalar> where Scalar == Float {
        let distance = self.constant
        
        let lineP1 = Position3n<Scalar>(oldVector: line.p1)
        let lineP2 = Position3n<Scalar>(oldVector: line.p2)
        
        let dp1 = distanceToPoint(lineP1)
        
        let dir = lineP2 - lineP1
    
        let dot1 = dir.dot(normal)
        let dot2 = dp1 - distance
        
        let t = -(distance + dot2) / dot1
        
        return (dir * t) + lineP1
    }
    
    @inlinable
    func intersectionOfRay(_ ray: Ray3n<Scalar>) -> Position3n<Scalar> {
        let p1 = ray.origin
        let p2 = ray.origin.moved(.greatestFiniteMagnitude, toward: ray.direction)
        let distance = self.constant
        
        let dp1 = distanceToPoint(p1)
        
        let dir = p2 - p1
    
        let dot1 = dir.dot(normal)
        let dot2 = dp1 - distance
        
        let t = -(distance + dot2) / dot1
        
        return Position3n((dir * t) + p1)
    }
    
    @inlinable
    func isCollidingWith(_ box: AxisAlignedBoundingBox3D) -> Bool where Scalar: BinaryFloatingPoint {
        // Convert AABB to center-extents representation
        let c = Position3n<Scalar>(oldVector: box.center) + Position3n<Scalar>(oldVector: box.offset) // Compute AABB center
        let e = (c + Size3n<Scalar>(oldVector: box.radius)) - c // Compute positive extents
        
        // Compute the projection interval radius of b onto L(t) = b.c + t * p.n
        let r: Scalar = Scalar(e.x * abs(normal.x)) + Scalar(e.y * abs(normal.y)) + Scalar(e.z * abs(normal.z))
        
        // Compute distance of box center from plane
        let s = normal.dot(c) - constant
        
        // Intersection occurs when distance s falls within [-r,+r] interval
        return abs(s) <= r
    }
}

public extension Plane3n where Scalar == Float {
    @inlinable
    static func *= (lhs: inout Self, rhs: Matrix4x4){
        lhs = lhs * rhs
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        let origin = rhs * lhs.origin.oldVector
        let normal = rhs.transposed().inverse * lhs.normal.oldVector
        return Self(normal: .init(oldVector: normal), constant: origin.dot(normal))
    }

    @inlinable
    static func *= (lhs: inout Self, rhs: Rotation3n<Scalar>) where Scalar == Float {
        lhs = lhs * rhs
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Rotation3n<Scalar>) -> Self where Scalar == Float {
        var plane = lhs
        plane.normal.rotate(by: rhs)
        return plane
    }
}

extension Plane3n: Equatable where Scalar: Equatable { }
extension Plane3n: Hashable where Scalar: Hashable { }
extension Plane3n: Sendable where Scalar: Sendable { }
extension Plane3n: Codable where Scalar: Codable { }
extension Plane3n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Plane3n: BinaryCodable where Self: BitwiseCopyable { }
