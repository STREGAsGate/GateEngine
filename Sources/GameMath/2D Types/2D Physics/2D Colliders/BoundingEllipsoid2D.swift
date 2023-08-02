/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct BoundingEllipsoid2D: Collider2D {
    public private(set) var offset: Position2
    public private(set) var center: Position2
    public private(set) var radius: Size2
    internal let _radius: Size2
    internal let _offset: Position2
    
    public init(center: Position2 = .zero, offset: Position2 = .zero, radius: Size2) {
        self.offset = offset
        self.center = center
        self.radius = radius
        self._radius = radius
        self._offset = offset
    }
    
    public init(_ aabb: AxisAlignedBoundingBox2D) {
        self.init(center: aabb.center, offset: aabb._offset, radius: aabb._radius)
    }
    
    public var size: Size2 {return radius * 2}
    
    public var volume: Float {
        return (4 / 3) * Float.pi * radius.x * radius.y
    }
    
    public mutating func update(transform: Transform2) {
        center = transform.position
        offset = _offset * transform.scale
        radius = _radius * transform.scale
    }
    
    public func closestSurfacePoint(from point: Position2) -> Position2 {
        let point = point / self.radius
        let center = self.position
        let scale: Float = 1
        return (((point - center).normalized * scale) + center) * self.radius
    }
    
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
    
    public func interpenetration(comparing collider: Collider2D) -> Interpenetration2D? {
        switch collider {
        case let collider as BoundingEllipsoid2D:
            return self.interpenetration(comparing: collider)
        default:
            return collider.interpenetration(comparing: self)
        }
    }
}

internal extension BoundingEllipsoid2D {
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Self {
        return BoundingEllipsoid2D(center: self.center / ellipsoidRadius, offset: self.offset / ellipsoidRadius, radius: self.radius / ellipsoidRadius)
    }
    
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Self {
        return BoundingEllipsoid2D(center: self.center * ellipsoidRadius, offset: self.offset * ellipsoidRadius, radius: self.radius * ellipsoidRadius)
    }
}

public extension BoundingEllipsoid2D {
    func surfacePoint(for ray: Ray2D) -> Position2? {
        let ray = ray.movedInsideEllipsoidSpace(self.radius)
        
        let L = Direction2(((self.center + self.offset) / self.radius) - ray.origin)
        let tca = L.dot(ray.direction)
        if tca < 0 {return nil}
        let d2 = L.dot(L) - tca * tca
        if d2 > 1 {return nil}
        let thc = (1 - d2).squareRoot()
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

        return ray.origin.moved(t0, toward: ray.direction) * self.radius
    }
    
    func surfaceNormal(facing point: Position2) -> Direction2 {
        let position = self.position
        // If the points are the same there is no direction, return a default
        guard point != position else {return .up}
        return Direction2(from: position / radius, to: point / radius) * radius
    }
}
