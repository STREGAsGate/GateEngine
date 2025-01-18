/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct BoundingEllipsoid3D: Collider3D, Sendable {
    public private(set) var offset: Position3 {
        didSet {
            self.boundingBox.offset = offset
        }
    }
    public private(set) var center: Position3 {
        didSet {
            self.boundingBox.center = center
        }
    }
    public private(set) var radius: Size3 {
        didSet {
            self.boundingBox.radius = radius
        }
    }
    internal var _radius: Size3
    internal var _offset: Position3
    
    public init(center: Position3 = .zero, offset: Position3 = .zero, radius: Size3) {
        self.offset = offset
        self.center = center
        self.radius = radius
        self._radius = radius
        self._offset = offset
        self.boundingBox = AxisAlignedBoundingBox3D(center: center, offset: offset, radius: radius)
    }
    
    public init(_ aabb: AxisAlignedBoundingBox3D) {
        self.init(center: aabb.center, offset: aabb.originalOffset, radius: aabb.originalRadius)
    }
    
    public var size: Size3 {return radius * 2}
    
    @inline(__always)
    public var volume: Float {
        return (4 / 3) * Float.pi * radius.x * radius.y * radius.z
    }
    
    public private(set) var boundingBox: AxisAlignedBoundingBox3D
    
    @inline(__always)
    public mutating func update(transform: Transform3) {
        center = transform.position
        offset = _offset * transform.scale
        radius = _radius * transform.scale
        boundingBox.update(transform: transform)
    }
    
    @inline(__always)
    public mutating func update(sizeAndOffsetUsingTransform transform: Transform3) {
        _offset = transform.position
        _radius = transform.scale / 2
        boundingBox.update(sizeAndOffsetUsingTransform: transform)
    }
    
    @inline(__always)
    public func closestSurfacePoint(from point: Position3) -> Position3 {
        let point = point / self.radius
        let center = self.position
        let scale: Float = 1
        return (((point - center).normalized * scale) + center) * self.radius
    }

    @inline(__always)
    public func interpenetration(comparing collider: BoundingEllipsoid3D) -> Interpenetration3D? {
        return self.boundingBox.interpenetration(comparing: collider)
        if self.position == collider.position {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration3D(depth: -.ulpOfOne, direction: .up, points: [self.center])
        }
        
        let ellipsoidSpace = self.movedInsideEllipsoidSpace(collider.radius)
        let unitSphere = BoundingSphere3D(center: collider.center, offset: collider.offset, radius: 1)

        guard var interpenetration = ellipsoidSpace.interpenetration(comparing: unitSphere) else {return nil}
        if let p = interpenetration.points.first {
            // Take the ellipsoid space contact, move it out of ellipsoid space.
            // Then find the closest point on our surface to that point. That's our contact point.
            interpenetration.points = [self.closestSurfacePoint(from: p * collider.radius)]
        }
        return interpenetration
    }
    
    @inline(__always)
    public func interpenetration(comparing collider: Collider3D) -> Interpenetration3D? {
        switch collider {
        case let collider as BoundingEllipsoid3D:
            return interpenetration(comparing: collider)
        default:
            return collider.interpenetration(comparing: self)
        }
    }
    
    @inline(__always)
    public func contains(_ rhs: Position3, withThreshold threshold: Float = 0) -> Bool {
        return rhs.distance(from: self.position / self.radius) < 1 + threshold
    }
}

internal extension BoundingEllipsoid3D {
    @inline(__always)
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return BoundingEllipsoid3D(center: self.center / ellipsoidRadius, offset: self.offset / ellipsoidRadius, radius: self.radius / ellipsoidRadius)
    }
    
    @inline(__always)
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return BoundingEllipsoid3D(center: self.center * ellipsoidRadius, offset: self.offset * ellipsoidRadius, radius: self.radius * ellipsoidRadius)
    }
}

public extension BoundingEllipsoid3D {
    @inline(__always)
    func surfacePoint(for ray: Ray3D) -> Position3? {
        let ray = ray.movedInsideEllipsoidSpace(self.radius)
        
        let L = Direction3((self.position / self.radius) - ray.origin)
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
    
    @inline(__always)
    func surfaceNormal(facing point: Position3) -> Direction3 {
        return Direction3(from: position / radius, to: point / radius) * radius
    }
}
