/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct AxisAlignedBoundingBox2D: Collider2D {
    public var volume: Float {
        return self.radius.x * self.radius.y
    }

    /// The updated center of the collider
    /// Use the `update(transform:)` function to update this value.
    public private(set) var center: Position2
    /// The updated radius of the collider
    /// Use the `update(transform:)` function to update this value.
    public private(set) var radius: Size2
    /// The updated offest of the collider
    /// Use the `update(transform:)` function to update this value.
    public private(set) var offset: Position2

    // The unmolested radius
    internal var _radius: Size2
    // The unmolested offset
    internal var _offset: Position2
    
    public var size: Size2 {return radius * 2}

    /// A frame representation of the collider
    @inlinable @inline(__always)
    public var rect: Rect {
        return Rect(position: (position - radius) + offset, size: size)
    }

    /// The point on the box closest to negative infiintiy
    @inlinable @inline(__always)
    public var minPoint: Position2 {
        return position - radius
    }
    /// The point on the box closest to positive infiintiy
    @inlinable @inline(__always)
    public var maxPoint: Position2 {
        return position + radius
    }
    
    public init(center: Position2 = .zero, offset: Position2 = .zero, radius: Size2) {
        self.center = center
        self._offset = offset
        self.offset = _offset
        self._radius = radius
        self.radius = _radius
    }

    /// Create a collider that contains all of the provided positions, a bounding box
    public init(_ positions: [Position2]) {
        var x: Size2 = .zero //min, max
        var y: Size2 = .zero //min, max
        
        var accumulated: Position2 = .zero
        
        for position in positions {
            x.x = Swift.min(position.x, x.x)
            x.y = Swift.max(position.x, x.y)
            
            y.x = Swift.min(position.y, y.x)
            y.y = Swift.max(position.y, y.y)
            
            accumulated += position
        }
        
        self._offset = Position2(x: x.y + x.x, y: y.y + y.x) / 2
        self.offset = _offset
        self.center = .zero
        self._radius = Size2(width: x.y - x.x, height: y.y - y.x) / 2
        self.radius = _radius
    }

    /// Moves and scales the collider based on the transform.
    mutating public func update(transform: Transform2) {
        center = transform.position
        offset = _offset * transform.scale
        radius = _radius * transform.scale
    }

    public func interpenetration(comparing collider: AxisAlignedBoundingBox2D) -> Interpenetration2D? {
        guard self.isColiding(with: collider) else {return nil}
        
        let p1 = self.position
        let p2 = collider.position
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration2D(depth: -radius.y, direction: .up, points: [self.center])
        }
        
        let point1 = collider.closestSurfacePoint(from: p1)
        guard self.contains(point1) else {return nil}
        let point2 = self.closestSurfacePoint(from: p2)
        
        let depth = -point1.distance(from: point2)
        let direction = self.surfaceNormal(facing: point2)
        let points: Set<Position2> = [point1, point2]
        let interpenetration = Interpenetration2D(depth: depth, direction: direction, points: points)
        
        assert(interpenetration.isValid)

        return interpenetration
    }

    public func interpenetration(comparing collider: BoundingCircle2D) -> Interpenetration2D? {
        let p1 = self.position
        let p2 = collider.position
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration2D(depth: -radius.y, direction: .up, points: [self.center.moved(radius.y, toward: .up)])
        }
        
        let point1 = collider.closestSurfacePoint(from: p1)
        guard self.contains(point1) else {return nil}
        let point2 = self.closestSurfacePoint(from: p2)
        
        let depth = -point1.distance(from: point2)
        let direction = self.surfaceNormal(facing: point2)
        let points: Set<Position2> = [point1, point2]
        let interpenetration = Interpenetration2D(depth: depth, direction: direction, points: points)

        assert(interpenetration.isValid)
        
        return interpenetration
    }

    public func interpenetration(comparing collider: BoundingEllipsoid2D) -> Interpenetration2D? {
        let p1 = self.position
        let p2 = collider.position
        
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            // Push the collider out
            return Interpenetration2D(depth: -self.radius.y, direction: .up, points: [self.center.moved(radius.y, toward: .up)])
        }
        
        if self.contains(p2) {
            // The center of the collider is inside, start pushing it outward
            let depth = -(collider.radius.length / 2)
            let direction = self.surfaceNormal(facing: p2)
            let points: Set<Position2> = []
            let interpenetration = Interpenetration2D(depth: depth, direction: direction, points: points)
            assert(interpenetration.isValid)
            return interpenetration
        }

        let unitCenter = p2 / collider.radius
        func closestUnitSphereSurfacePoint(from point: Position2) -> Position2 {
            let p = point - unitCenter
            if p == .zero {
                return unitCenter
            }
            return p.normalized + unitCenter
        }
        
        let p: Position2 = movedInsideEllipsoidSpace(collider.radius).closestSurfacePoint(from: unitCenter)
        let v: Position2 = p - unitCenter
        guard v.dot(v) <= 1 else {return nil}
        
        let point1 = p * collider.radius
        let point2 = closestUnitSphereSurfacePoint(from: p) * collider.radius

        let depth = -point1.distance(from: point2)
        let direction = self.surfaceNormal(facing: point1)
        let points: Set<Position2> = [point1, point2]
        let interpenetration = Interpenetration2D(depth: depth, direction: direction, points: points)
        
        assert(interpenetration.isValid)
        
        return interpenetration
    }

    @_disfavoredOverload
    public func interpenetration(comparing collider: Collider2D) -> Interpenetration2D? {
        switch collider {
        case let collider as BoundingCircle2D:
            return interpenetration(comparing: collider)
        case let collider as BoundingEllipsoid2D:
            return interpenetration(comparing: collider)
        case let collider as AxisAlignedBoundingBox2D:
            return interpenetration(comparing: collider)
        default:
            // Other colliders forward their check to AABB. If we get here there is no implimentation.
            fatalError("Unhandled collider: \(type(of: collider))")
        }
    }

    /// `true` if `rhs` is overlapping `self`
    public func isColiding(with rhs: Self) -> Bool {
        // When the centers are the same a collision is always happening no matter the radius
        guard self.position != rhs.position else {return true}

        let a = self
        
        if abs((a.center.x + a.offset.x) - (rhs.center.x + rhs.offset.x)) > a.radius.x + rhs.radius.x {
            return false
        }
        if abs((a.center.y + a.offset.y) - (rhs.center.y + rhs.offset.y)) > a.radius.y + rhs.radius.y {
            return false
        }
        return true
    }

    /// `true` if `rhs` is fully contained by `self`
    public func contains(_ rhs: Self, withThreshold threshold: Float = 0) -> Bool {
        let minPosition = rhs.center + rhs.offset - rhs.radius
        guard self.contains(minPosition, withThreshold: threshold) else {return false}
        
        let maxPositon = minPosition + rhs.size
        guard self.contains(maxPositon, withThreshold: threshold) else {return false}
        
        return true
    }

    /// `true` if `rhs` is inside `self`
    public func contains(_ rhs: Position2, withThreshold threshold: Float = 0) -> Bool {
        let positon = self.position - (self.radius + threshold)
        
        guard rhs.x >= positon.x else {return false}
        guard rhs.y >= positon.y else {return false}
        
        let size = self.size + threshold
        guard rhs.x <= positon.x + size.x else {return false}
        guard rhs.y <= positon.y + size.y else {return false}
        
        return true
    }
    
    public func closestSurfacePoint(from point: Position2) -> Position2 {
        var pos: Position2 = point

        let max = self.maxPoint
        let min = self.minPoint

        if point.x > max.x {
            pos.x = max.x
        }else if point.x < min.x {
            pos.x = min.x
        }
        if point.y > max.y {
            pos.y = max.y
        }else if point.y < min.y {
            pos.y = min.y
        }

        return pos
    }
}

extension AxisAlignedBoundingBox2D {
    public func points() -> [Position2] {
        let p1 = Position2(x: center.x - radius.x, y: center.y - radius.y)
        let p2 = Position2(x: center.x + radius.x, y: center.y - radius.y)
        let p3 = Position2(x: center.x - radius.x, y: center.y + radius.y)
        let p4 = Position2(x: center.x + radius.x, y: center.y + radius.y)
        
        return [p1, p2, p3, p4]
    }
}

internal extension AxisAlignedBoundingBox2D {
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Self {
        return AxisAlignedBoundingBox2D(center: self.center / ellipsoidRadius, offset: self.offset / ellipsoidRadius, radius: self.radius / ellipsoidRadius)
    }
    
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size2) -> Self {
        return AxisAlignedBoundingBox2D(center: self.center * ellipsoidRadius, offset: self.offset * ellipsoidRadius, radius: self.radius * ellipsoidRadius)
    }
}

public extension AxisAlignedBoundingBox2D {
    func surfacePoint(for ray: Ray2D) -> Position2? {
        let minPosition = self.minPoint
        let maxPosition = self.maxPoint
        
        var tmin = (minPosition.x - ray.origin.x) / ray.direction.x
        var tmax = (maxPosition.x - ray.origin.x) / ray.direction.x
      
        if tmin > tmax {
            swap(&tmin, &tmax)
        }
      
        var tymin = (minPosition.y - ray.origin.y) / ray.direction.y
        var tymax = (maxPosition.y - ray.origin.y) / ray.direction.y
      
        if tymin > tymax {
            swap(&tymin, &tymax)
        }
      
        if tmin > tymax || tymin > tmax {
             return nil
        }
      
        if tymin > tmin {
            tmin = tymin
        }
      
        if tymax < tmax {
            tmax = tymax
        }
      
        let t = Swift.min(tmin, tmax)
        guard t > 0 else {return nil}
        return ray.origin.moved(t, toward: ray.direction)
    }
    
    func surfaceNormal(facing point: Position2) -> Direction2 {
        let point = point - position

        var normal: Direction2 = .zero
        var min: Float = .infinity
        
        var distance = abs(radius.x - abs(point.x))
        if distance < min {
            min = distance
            if point.x > 0 {
                normal = .right
            }else{
                normal = .left
            }
        }
        distance = abs(radius.y - abs(point.y))
        if distance < min {
            min = distance
            if point.y > 0 {
                normal = .up
            }else{
                normal = .down
            }
        }

        return normal
    }
}

public extension AxisAlignedBoundingBox2D {
    func expandedToEnclose(_ rhs: Self) -> Self {
        var points = self.points()
        points.append(contentsOf: rhs.points())
        return AxisAlignedBoundingBox2D(points)
    }
}

extension AxisAlignedBoundingBox2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([center.x, center.y,
                              _offset.x, _offset.y,
                              _radius.x, _radius.y])
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let floats = try container.decode(Array<Float>.self)
        
        self.center = Position2(x: floats[0], y: floats[1])
        self._offset = Position2(x: floats[2], y: floats[3])
        self.offset = _offset
        let radius = Size2(width: floats[4], height: floats[5])
        self._radius = radius
        self.radius = radius
    }
}
