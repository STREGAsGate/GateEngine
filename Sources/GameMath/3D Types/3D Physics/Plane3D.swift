/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Plane3D {
    public let normal: Direction3
    public let constant: Float
    
    @inlinable @inline(__always)
    public var origin: Position3 {return Position3(normal * constant)}
    
    public init(normal: Direction3, constant: Float) {
        self.constant = constant
        self.normal = normal
    }
    
    @inlinable @inline(__always)
    public init(origin: Position3, normal: Direction3) {
        self.init(normal: normal, constant: -origin.dot(normal))
    }
    
    @inlinable @inline(__always)
    public init(_ a: Float, _ b: Float, _ c: Float, _ d: Float) {
        self.init(normal: Direction3(a, b, c), constant: d)
    }
    
    @inlinable @inline(__always)
    public init(_ triangle: CollisionTriangle) {
        self.init(origin: triangle.center, normal: triangle.normal)
    }
    
    @inlinable @inline(__always)
    public var normalized: Self {
        let m = normal.magnitude
        return Plane3D(normal: normal / m, constant: constant / m)
    }
    
    /// true if a line in `direction` will intersect the plane
    @inlinable @inline(__always)
    public func isIntersecting(with direction: Direction3) -> Bool {
        return normal.isFrontFacing(toward: direction) == false
    }
}

public extension Plane3D {
    enum Side {
        case front
        case back
    }
    
    @inlinable @inline(__always)
    func classifyPoint(_ p: Position3) -> Side {
        return (p.dot(normal) + constant) < 0 ? .back : .front
    }
    
    @inlinable @inline(__always)
    func distanceToPoint(_ p: Position3) -> Float {
        return (p.x * normal.x + p.y * normal.y + p.z * normal.z) + constant
    }
    
    @inlinable @inline(__always)
    func intersectionOfLine(_ line: Line3D) -> Position3 {
        let distance = self.constant
        
        let dp1 = distanceToPoint(line.p1)
        
        let dir = line.p2 - line.p1
    
        let dot1 = dir.dot(normal)
        let dot2 = dp1 - distance
        
        let t = -(distance + dot2) / dot1
        
        return Position3((dir * t) + line.p1)
    }
    
    @inlinable @inline(__always)
    func intersectionOfRay(_ ray: Ray3D) -> Position3 {
        let p1 = ray.origin
        let p2 = ray.origin.moved(Float.greatestFiniteMagnitude, toward: ray.direction)
        let distance = self.constant
        
        let dp1 = distanceToPoint(p1)
        
        let dir = p2 - p1
    
        let dot1 = dir.dot(normal)
        let dot2 = dp1 - distance
        
        let t = -(distance + dot2) / dot1
        
        return Position3((dir * t) + p1)
    }
    
    @inlinable @inline(__always)
    func isCollidingWith(_ box: AxisAlignedBoundingBox3D) -> Bool {
        // Convert AABB to center-extents representation
        let c = box.center + box.offset // Compute AABB center
        let e = (c + box.radius) - c // Compute positive extents
        
        // Compute the projection interval radius of b onto L(t) = b.c + t * p.n
        let r: Float = Float(e.x * abs(normal.x)) + Float(e.y * abs(normal.y)) + Float(e.z * abs(normal.z))
        
        // Compute distance of box center from plane
        let s = normal.dot(c) - constant
        
        // Intersection occurs when distance s falls within [-r,+r] interval
        return abs(s) <= r
    }
}

public extension Plane3D {
    @_transparent
    static func *=(lhs: inout Plane3D, rhs: Matrix4x4) {
        lhs = lhs * rhs
    }
    
    @inlinable @inline(__always)
    static func *(lhs: Plane3D, rhs: Matrix4x4) -> Plane3D {
        let origin = rhs * lhs.origin
        let normal = rhs.transposed().inverse * lhs.normal
        return Plane3D(normal: normal, constant: origin.dot(normal))
    }
}

public extension Plane3D {
    @_transparent
    static func *=(lhs: inout Plane3D, rhs: Quaternion) {
        lhs = lhs * rhs
    }
    
    @inlinable @inline(__always)
    static func *(lhs: Plane3D, rhs: Quaternion) -> Plane3D {
        return lhs * Matrix4x4(position: lhs.origin) * Matrix4x4(rotation: rhs)
    }
}
