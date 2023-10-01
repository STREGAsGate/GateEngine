/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct BoundingCircle2D: Collider2D, Sendable {
    @usableFromInline
    internal var _radius: Float
    @usableFromInline
    internal var _offset: Position2
    
    public var center: Position2
    public var radius: Float {
        willSet {
            _radius = newValue
        }
    }
    public var offset: Position2 {
        willSet {
            _offset = newValue
        }
    }
    
    public init(center: Position2 = .zero, offset: Position2 = .zero, radius: Float) {
        self.offset = offset
        self.center = center
        self.radius = radius
        self._radius = radius
        self._offset = offset
    }
    
    @inlinable @inline(__always)
    public var volume: Float {
        return (4.0 * Float.pi * radius * radius * radius) / 3.0
    }
    
    @inlinable @inline(__always)
    public var boundingBox: AxisAlignedBoundingBox2D {
        return AxisAlignedBoundingBox2D(center: center, offset: offset, radius: Size2(radius))
    }
    
    @inlinable @inline(__always)
    public mutating func update(transform: Transform2) {
        self.center = transform.position
        self.offset = _offset * transform.scale
        self.radius = _radius * (transform.scale.length / 2)
    }
    
    @inlinable @inline(__always)
    public mutating func update(sizeAndOffsetUsingTransform transform: Transform2) {
        self.offset = _offset * transform.scale
        self.radius = _radius * (transform.scale.length / 2)
    }
    
    @inlinable @inline(__always)
    public func closestSurfacePoint(from point: Position2) -> Position2 {
        let position: Position2 = self.position
        let d = Direction2(from: position, to: point)
        return Position2(d * radius) + position
    }
    
    @inlinable @inline(__always)
    public func interpenetration(comparing collider: BoundingCircle2D) -> Interpenetration2D? {
        let p1 = self.position
        let p2 = collider.position
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration2D(depth: -.ulpOfOne, direction: .up, points: [self.center])
        }
        let radiusSum = self.radius + collider.radius
        let distance = p1.distance(from: p2)
        guard distance < radiusSum else {return nil}
        
        let depth = -distance
        let direction = Direction2(from: p1, to: p2)
        let point = self.closestSurfacePoint(from: p2)
        let interpenetration = Interpenetration2D(depth: depth, direction: direction, points: [point])
        
        assert(interpenetration.isValid)

        return interpenetration
    }
    
    @inlinable @inline(__always)
    public func interpenetration(comparing collider: BoundingEllipsoid2D) -> Interpenetration2D? {
        if self.position == collider.position {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration2D(depth: -.ulpOfOne, direction: .up, points: [self.center])
        }
        
        let ellipsoidSpace = self.movedInsideEllipsoidSpace(collider.radius)
        let unitCircle = BoundingCircle2D(center: collider.center, offset: collider.offset, radius: 1)

        guard var interpenetration = ellipsoidSpace.interpenetration(comparing: unitCircle) else {return nil}
        if let p = interpenetration.points.first {
            // Take the ellipsoid space contact, move it out of ellipsoid space.
            // Then find the closest point on our surface to that point. That's our contact point.
            interpenetration.points = [self.closestSurfacePoint(from: p * collider.radius)]
        }
        return interpenetration
    }
    
    @inlinable @inline(__always)
    public func interpenetration(comparing collider: Collider2D) -> Interpenetration2D? {
        switch collider {
        case let collider as BoundingCircle2D:
            return self.interpenetration(comparing: collider)
        case let collider as BoundingEllipsoid2D:
            return self.interpenetration(comparing: collider)
        default:
            return collider.interpenetration(comparing: self)
        }
    }
    
    @inlinable @inline(__always)
    public func contains(_ rhs: Position2, withThreshold threshold: Float = 0) -> Bool {
        return self.position.distance(from: rhs) < radius + threshold
    }
    
    @inlinable @inline(__always)
    func isColliding(with rhs: BoundingCircle2D) -> Bool {
        // Calculate squared distance between centers
        let center = self.center - rhs.center
        let dist = center.dot(center)
        // Spheres intersect if squared distance is less than squared sum of radii
        let radiusSum = self.radius + rhs.radius
        return dist <= radiusSum * radiusSum
    }
}

public extension BoundingCircle2D {
    @inlinable @inline(__always)
    func surfacePoint(for ray: Ray2D) -> Position2? {
        let L = Direction2(self.center - ray.origin)
        let tca = L.dot(ray.direction)
        if tca < 0 {return nil}
        let d2 = L.dot(L) - tca * tca
        let radius2 = radius * radius
        if d2 > radius2 {return nil}
        let thc = (radius2 - d2).squareRoot()
        var t0 = tca - thc
        var t1 = tca + thc

        if t0 > t1 {
            swap(&t0, &t1)
        }
 
        if t0 < 0 {
            t0 = t1 // if t0 is negative, let's use t1 instead
            if t0 < 0 {
                return nil // both t0 and t1 are negative
            }
        }
  
        return ray.origin.moved(t0, toward: ray.direction)
    }
    
    @inlinable @inline(__always)
    func surfaceNormal(facing point: Position2) -> Direction2 {
        let position = self.position
        // If the points are the same there is no direction, return a default
        guard point != position else {return .up}
        return Direction2(from: self.position, to: point)
    }
}

internal extension BoundingCircle2D {
    @inlinable @inline(__always)
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Self {
        assert(ellipsoidRadius.x != 0 && ellipsoidRadius.y != 0)
        return BoundingCircle2D(center: self.center / ellipsoidRadius, offset: self.offset / ellipsoidRadius, radius: self.radius / (ellipsoidRadius.length / 2))
    }
    
    @inlinable @inline(__always)
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Self {
        return BoundingCircle2D(center: self.center * ellipsoidRadius, offset: self.offset * ellipsoidRadius, radius: self.radius * (ellipsoidRadius.length / 2))
    }
}
