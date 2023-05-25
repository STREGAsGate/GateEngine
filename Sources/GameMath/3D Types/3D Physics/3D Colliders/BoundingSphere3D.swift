/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct BoundingSphere3D: Collider3D {
    public private(set) var offset: Position3
    public private(set) var center: Position3
    public private(set) var radius: Float
    internal var _radius: Float
    internal var _offset: Position3
    
    public init(center: Position3 = .zero, offset: Position3 = .zero, radius: Float) {
        self.center = center
        self.offset = offset
        self._offset = offset
        self.radius = radius
        self._radius = radius
        self.boundingBox = AxisAlignedBoundingBox3D(center: center, offset: offset, radius: Size3(radius))
    }
    
    @inline(__always)
    public var volume: Float {
        return (4.0 * Float.pi * radius * radius * radius) / 3.0
    }
    
    public var boundingBox: AxisAlignedBoundingBox3D
    
    @inline(__always)
    mutating public func update(center: Position3) {
        self.center = center
        self.boundingBox.update(center: center)
    }
    @inline(__always)
    mutating public func update(offset: Position3) {
        self.offset = offset
        self._offset = offset
        self.boundingBox.update(offset: offset)
    }
    @inline(__always)
    public mutating func update(transform: Transform3) {
        center = transform.position
        offset = _offset * transform.scale
        self.radius = _radius * (transform.scale.length / 3)
        self.boundingBox.update(transform: transform)
    }
    
    @inline(__always)
    public mutating func update(sizeAndOffsetUsingTransform transform: Transform3) {
        _offset = transform.position
        _radius = transform.scale.length / 3 / 2
        self.boundingBox.update(sizeAndOffsetUsingTransform: transform)
    }
    
    @inline(__always)
    public func closestSurfacePoint(from point: Position3) -> Position3 {
        let position = self.position
        let direction = Direction3(from: position, to: point)
        return position.moved(radius, toward: direction)
    }
    
    @inline(__always)
    public func interpenetration(comparing collider: BoundingSphere3D) -> Interpenetration3D? {
        let p1 = self.position
        let p2 = collider.position
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration3D(depth: -.ulpOfOne, direction: .up, points: [self.center])
        }
        let radiusSum = self.radius + collider.radius
        let distance = p1.distance(from: p2)
        guard distance < radiusSum else {return nil}

        let depth = -distance
        let direction = Direction3(from: p1, to: p2)
        let point = self.closestSurfacePoint(from: p2)
        let interpenetration = Interpenetration3D(depth: depth, direction: direction, points: [point])

        assert(interpenetration.isValid)

        return interpenetration
    }
    
    @inline(__always)
    public func interpenetration(comparing collider: BoundingEllipsoid3D) -> Interpenetration3D? {
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
    public func interpenetration(comparing collider: OrientedBoundingBox3D) -> Interpenetration3D? {
        let point = collider.closestSurfacePoint(from: center)
        let direction = self.surfaceNormal(facing: point)
        var depth = point.distance(from: center)
        guard depth < radius else {return nil}
        depth = -(depth + radius)
        return Interpenetration3D(depth: depth, direction: direction, points: [point])
    }
    
    @inline(__always)
    public func interpenetration(comparing collider: Collider3D) -> Interpenetration3D? {
        switch collider {
        case let collider as BoundingSphere3D:
            return self.interpenetration(comparing: collider)
        case let collider as BoundingEllipsoid3D:
            return self.interpenetration(comparing: collider)
        case let collider as OrientedBoundingBox3D:
            return self.interpenetration(comparing: collider)
        default:
            return collider.interpenetration(comparing: self)
        }
    }
    
    @inline(__always)
    func isColliding(with rhs: BoundingSphere3D) -> Bool {
        // Calculate squared distance between centers
        let center = self.center - rhs.center
        let dist = center.dot(center)
        // Spheres intersect if squared distance is less than squared sum of radii
        let radiusSum = self.radius + rhs.radius
        return dist <= radiusSum * radiusSum
    }
    
    @inline(__always)
    public func contains(_ rhs: Position3, withThreshold threshold: Float = 0) -> Bool {
        return rhs.distance(from: self.position) < radius + threshold
    }
}

internal extension BoundingSphere3D {
    @inline(__always)
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        assert(ellipsoidRadius.x != 0 && ellipsoidRadius.y != 0 && ellipsoidRadius.z != 0)
        return BoundingSphere3D(center: self.center / ellipsoidRadius, offset: self._offset / ellipsoidRadius, radius: self._radius / (ellipsoidRadius.length / 3))
    }
    
    @inline(__always)
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return BoundingSphere3D(center: self.center * ellipsoidRadius, offset: self._offset * ellipsoidRadius, radius: self._radius * (ellipsoidRadius.length / 3))
    }
}

public extension BoundingSphere3D {
    init(_ positions: [Position3]) {
        var x: Size2 = Size2(width: Float(Int.max), height: Float(Int.min)) //min, max
        var y: Size2 = Size2(width: Float(Int.max), height: Float(Int.min)) //min, max
        var z: Size2 = Size2(width: Float(Int.max), height: Float(Int.min)) //min, max
        
        for position in positions {
            x.x = min(position.x, x.x)
            x.y = max(position.x, x.y)
            
            y.x = min(position.y, y.x)
            y.y = max(position.y, y.y)
            
            z.x = min(position.z, z.x)
            z.y = max(position.z, z.y)
        }
        
        self.offset = Position3(x: (x.y + x.x) / 2.0, y: (y.y + y.x) / 2.0, z: (z.y + z.x) / 2.0)
        self._offset = offset
        self.center = Position3.zero
        
        var radius: Float = 0.0
        for position in positions {
            let center = offset - position
            let dist = center.dot(center)
            radius = max(radius, dist)
        }
        _radius = radius
        self.radius = _radius
        self.boundingBox = AxisAlignedBoundingBox3D(center: center, offset: offset, radius: Size3(radius))
    }
}

public extension BoundingSphere3D {
    @inline(__always)
    func surfacePoint(for ray: Ray3D) -> Position3? {
        let L = Direction3(self.center - ray.origin)
        let tca = L.dot(ray.direction)
        if tca < 0 {return nil}
        let d2 = L.dot(L) - tca * tca
        let radius2 = radius * radius
        if d2 > radius2 {return nil}
        let thc = (radius2 - d2).squareRoot()
        var t0 = tca - thc;
        var t1 = tca + thc;

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
    
    @inline(__always)
    func surfaceNormal(facing point: Position3) -> Direction3 {
        return Direction3(from: self.position, to: point)
    }
}
