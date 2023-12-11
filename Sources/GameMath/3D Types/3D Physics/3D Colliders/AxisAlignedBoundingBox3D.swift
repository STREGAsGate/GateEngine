/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct AxisAlignedBoundingBox3D: Collider3D, Sendable {
    @inlinable @inline(__always)
    public var volume: Float {
        return self.radius.x * self.radius.y * self.radius.z
    }
    
    public var center: Position3
    public var radius: Size3 {
        willSet {
            _radius = newValue
        }
    }
    public var offset: Position3 {
        willSet {
            _offset = newValue
        }
    }
    
    @usableFromInline
    internal var _radius: Size3
    @usableFromInline
    internal var _offset: Position3
    
    @inlinable @inline(__always)
    public var size: Size3 {
        get {
            return radius * 2
        }
        set {
            radius = newValue * 0.5
        }
    }
    
    @inlinable @inline(__always)
    public var originalSize: Size3 {
        return originalRadius * 2
    }
    @inlinable @inline(__always)
    public var originalRadius: Size3 {
        return _radius
    }
    @inlinable @inline(__always)
    public var originalOffset: Position3 {
        return _offset
    }
    
    @inlinable @inline(__always)
    public var boundingBox: AxisAlignedBoundingBox3D {
        return self
    }
    
    public init(center: Position3 = .zero, offset: Position3 = .zero, radius: Size3 = .one) {
        self.center = center
        self._offset = offset
        self.offset = _offset
        self._radius = radius
        self.radius = _radius
    }
    
    public init(_ positions: [Position3]) {
        var minPosition: Position3 = positions.first ?? .zero
        var maxPosition: Position3 = positions.first ?? .zero
        for index in 1 ..< positions.count {
            let position = positions[index]
            minPosition = min(minPosition, position)
            maxPosition = max(maxPosition, position)
        }
        
        self._offset = (minPosition + maxPosition) / 2
        self.offset = _offset
        self.center = .zero
        self._radius = Size3(maxPosition - minPosition) / 2
        self.radius = _radius
    }
    
    @available(*, unavailable  /*0.0.8*/, message: "Use self.center = newValue instead.")
    mutating public func update(center: Position3) {
        self.center = center
    }
    @available(*, unavailable  /*0.0.8*/, message: "Use self.offset = newValue instead.")
    mutating public func update(offset: Position3) {
        self.offset = offset
        self._offset = offset
    }
    @available(*, unavailable  /*0.0.8*/, message: "Use self.radius = newValue instead.")
    mutating public func update(radius: Size3) {
        self._radius = radius
        self.radius = radius
    }
    
    mutating public func update(transform: Transform3) {
        center = transform.position
        offset = _offset * transform.scale
        radius = _radius * transform.scale
    }
    
    mutating public func update(sizeAndOffsetUsingTransform transform: Transform3) {
        _offset = transform.position
        _radius = transform.scale
    }
    
    public var minPosition: Position3 {self.position - self.radius}
    public var maxPosition: Position3 {self.position + self.radius}

    @inline(__always)
    public func interpenetration(comparing collider: AxisAlignedBoundingBox3D) -> Interpenetration3D? {
        guard self.isColiding(with: collider) else {return nil}
        let p1 = self.position
        let p2 = collider.position
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration3D(depth: -.ulpOfOne, direction: .up, points: [self.center])
        }

        let point = collider.closestSurfacePoint(from: center)
        let depth = -point.distance(from: collider.position)
        let direction = self.surfaceNormal(facing: point)
        return Interpenetration3D(depth: depth, direction: direction, points: [point])
    }

    @inline(__always)
    public func interpenetration(comparing collider: BoundingSphere3D) -> Interpenetration3D? {
        let p1 = self.position
        let p2 = collider.position
        if p1 == p2 {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration3D(depth: -self.radius.y, direction: .up, points: [Position3(p1.x, p1.y + radius.y, p1.z)])
        }

        let point1: Position3 = collider.closestSurfacePoint(from: p1)
        guard self.contains(point1) else {return nil}
        let point2: Position3 = self.closestSurfacePoint(from: p2)
        
        let depth = -point1.distance(from: point2)
        guard depth < 0 else {return nil}
        let direction = self.surfaceNormal(facing: point2)
        return Interpenetration3D(depth: depth, direction: direction, points: [point2])
    }

    @inline(__always)
    public func interpenetration(comparing collider: BoundingEllipsoid3D) -> Interpenetration3D? {
        let position = self.position
        if position == collider.position {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration3D(depth: -self.radius.y, direction: .up, points: [Position3(position.x, position.y + radius.y, position.z)])
        }

        let center = collider.position / collider.radius
        func closestUnitSphereSurfacePoint(from point: Position3) -> Position3 {
            return ((point - center).normalized * 1) + center
        }
        
        let p: Position3 = movedInsideEllipsoidSpace(collider.radius).closestSurfacePoint(from: center)
        let v: Position3 = p - center
        guard v.dot(v) <= 1 else {return nil}
        
        let point = p * collider.radius
        let depth = -point.distance(from: closestUnitSphereSurfacePoint(from: p) * collider.radius)
        let direction = self.surfaceNormal(facing: point)
        return Interpenetration3D(depth: depth, direction: direction, points: [point])
    }

    @inline(__always)
    public func interpenetration(comparing collider: OrientedBoundingBox3D) -> Interpenetration3D? {
        if self.position == collider.position {
            // When the centers are the same a collision is always happening no matter the radius
            return Interpenetration3D(depth: -.ulpOfOne, direction: .up, points: [self.center])
        }

        let p1: Position3 = collider.closestSurfacePoint(from: self.position)
        guard self.contains(p1) else {return nil}
        let p2: Position3 = self.closestSurfacePoint(from: collider.position)
        
        let depth = -p1.distance(from: p2)
        let direction = self.surfaceNormal(facing: p2)
        return Interpenetration3D(depth: depth, direction: direction, points: [p2])
    }

    @inline(__always)
    public func interpenetration(comparing collider: Collider3D) -> Interpenetration3D? {
        switch collider {
        case let collider as BoundingSphere3D:
            return interpenetration(comparing: collider)
        case let collider as BoundingEllipsoid3D:
            return interpenetration(comparing: collider)
        case let collider as AxisAlignedBoundingBox3D:
            return interpenetration(comparing: collider)
        case let collider as OrientedBoundingBox3D:
            return interpenetration(comparing: collider)
        default:
            fatalError()
        }
    }
    
    @inline(__always)
    public func isColiding(with rhs: Self) -> Bool {
        let a = self
        let aPosition = a.position
        let rhsPosition = rhs.position
        
        guard aPosition != rhsPosition else {return true}

        if abs(a.position.x - rhsPosition.x) > a.radius.x + rhs.radius.x {
            return false
        }
        if abs(a.position.y - rhsPosition.y) > a.radius.y + rhs.radius.y {
            return false
        }
        if abs(a.position.z - rhsPosition.z) > a.radius.z + rhs.radius.z {
            return false
        }
        return true
    }
    
    @inline(__always)
    public func isColiding(with rhs: Ray3D) -> Bool {
        if self.contains(rhs.origin) {
            return true
        }
        return self.surfacePoint(for: rhs) != nil
    }
    
    @inline(__always)
    public func contains(_ rhs: Self, withThreshold threshold: Float = 0) -> Bool {
        guard self.contains(rhs.minPosition, withThreshold: threshold) else {return false}
        guard self.contains(rhs.maxPosition, withThreshold: threshold) else {return false}
        return true
    }
    
    @inline(__always)
    public func contains(_ rhs: Position3, withThreshold threshold: Float = 0) -> Bool {
        let position = self.position - (self.radius + threshold)

        guard rhs.x >= position.x else {return false}
        guard rhs.y >= position.y else {return false}
        guard rhs.z >= position.z else {return false}

        let size = self.size + threshold
        guard rhs.x <= position.x + size.x else {return false}
        guard rhs.y <= position.y + size.y else {return false}
        guard rhs.z <= position.z + size.z else {return false}

        return true
    }
    
    @inline(__always)
    public func contains(any positions: [Position3]) -> Bool {
        for position in positions {
            if self.contains(position) {
                return true
            }
        }
        return false
    }
    
    @inline(__always)
    public func closestSurfacePoint(from point: Position3) -> Position3 {
        var pos: Position3 = .zero
        let minPosition = self.minPosition
        let maxPosition = self.maxPosition
        for i in 0..<3 {
            var v = point[i]
            let min = minPosition[i]
            if v < min {
                v = min // v = max(v, b.min[i])
            }
            let max = maxPosition[i]
            if v > max {
                v = max // v = min(v, b.max[i])
            }
            pos[i] = v
        }
        return pos
    }
}

extension AxisAlignedBoundingBox3D {
    @inline(__always)
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return AxisAlignedBoundingBox3D(center: self.center / ellipsoidRadius, offset: self.offset / ellipsoidRadius, radius: self.radius / ellipsoidRadius)
    }
    
    @inline(__always)
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return AxisAlignedBoundingBox3D(center: self.center * ellipsoidRadius, offset: self.offset * ellipsoidRadius, radius: self.radius * ellipsoidRadius)
    }
}

extension AxisAlignedBoundingBox3D {
    @inline(__always)
    public func planes() -> [Plane3D] {
        return [Plane3D(origin: position + radius, normal: .right),
                Plane3D(origin: position + radius, normal: .up),
                Plane3D(origin: position + radius, normal: .forward),
                
                Plane3D(origin: position - radius, normal: .left),
                Plane3D(origin: position - radius, normal: .down),
                Plane3D(origin: position - radius, normal: .backward)]
    }
    
    @inline(__always)
    public func rects() -> [Rect] {
        let position: Position3 = self.position - radius
        return [Rect(position: Position2(x: Float(position.x), y: Float(position.y)), size: Size2(width: Float(radius.x) * 2, height: Float(radius.y) * 2)),
                Rect(position: Position2(x: Float(position.x), y: Float(position.z)), size: Size2(width: Float(radius.x) * 2, height: Float(radius.z) * 2)),
                Rect(position: Position2(x: Float(position.y), y: Float(position.z)), size: Size2(width: Float(radius.y) * 2, height: Float(radius.z) * 2))]
    }
    
    @inline(__always)
    public func points() -> [Position3] {
        let p1 = position - radius
        let p2 = Position3(x: p1.x + (radius.x * 2), y: p1.y, z: p1.z)
        let p3 = Position3(x: p1.x,                  y: p1.y, z: p1.z + (radius.z * 2))
        let p4 = Position3(x: p1.x + (radius.x * 2), y: p1.y, z: p1.z + (radius.z * 2))
        
        let p5 = Position3(x: p1.x, y: p1.y + (radius.y * 2), z: p1.z)
        let p6 = Position3(x: p2.x, y: p2.y + (radius.y * 2), z: p2.z)
        let p7 = Position3(x: p3.x, y: p3.y + (radius.y * 2), z: p3.z)
        let p8 = Position3(x: p4.x, y: p4.y + (radius.y * 2), z: p4.z)
        
        return [p1, p2, p3, p4, p5, p6, p7, p8]
    }
}

public extension AxisAlignedBoundingBox3D {
    @inline(__always)
    func surfacePoint(for ray: Ray3D) -> Position3? {
        let minPosition = self.minPosition
        let maxPosition = self.maxPosition
        
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
      
        var tzmin = (minPosition.z - ray.origin.z) / ray.direction.z
        var tzmax = (maxPosition.z - ray.origin.z) / ray.direction.z
      
        if tzmin > tzmax {
            swap(&tzmin, &tzmax)
        }
      
        if tmin > tzmax || tzmin > tmax {
             return nil
        }
      
        if tzmin > tmin {
            tmin = tzmin
        }
      
        if tzmax < tmax {
            tmax = tzmax
        }
        let t = min(tmin, tmax)
        guard t > 0 else {return nil}
        return ray.origin.moved(t, toward: ray.direction)
    }
    
    @inline(__always)
    func surfaceNormal(facing point: Position3) -> Direction3 {
        let point = point - position
        if point == .zero {
            // The boxes are directly on top of each other
            // return a default direction
            return .forward
        }

        var normal: Direction3 = .forward
        var min: Float = .infinity
        var distance: Float = .nan
        
        distance = abs(radius.x - abs(point.x))
        if distance < min && distance != radius.x {
            min = distance
            if point.x > 0 {
                normal = Direction3(1, 0, 0)
            }else{
                normal = Direction3(-1, 0, 0)
            }
        }
        
        distance = abs(radius.y - abs(point.y))
        if distance < min && distance != radius.y {
            min = distance
            if point.y > 0 {
                normal = Direction3(0, 1, 0)
            }else{
                normal = Direction3(0, -1, 0)
            }
        }
        
        distance = abs(radius.z - abs(point.z))
        if distance < min && distance != radius.z {
            min = distance
            if point.z > 0 {
                normal = Direction3(0, 0, 1)
            }else{
                normal = Direction3(0, 0, -1)
            }
        }
        
        return normal
    }
}

public extension AxisAlignedBoundingBox3D {
    func clamping(_ position: Position3, inset: Float = 0) -> Position3 {
        var position = position
        let box = self
        
        let minPosition = box.minPosition
        let maxPosition = box.maxPosition
                
        if position.x < minPosition.x + inset {
            position.x = max(position.x, minPosition.x + inset)
        }else{
            position.x = min(position.x, maxPosition.x - inset)
        }
        if position.y < minPosition.y + inset {
            position.y = max(position.y, minPosition.y + inset)
        }else{
            position.y = min(position.y, maxPosition.y - inset)
        }
        if position.z < minPosition.z + inset {
            position.z = max(position.z, minPosition.z + inset)
        }else{
            position.z = min(position.z, maxPosition.z - inset)
        }
        return position
    }
}

public extension AxisAlignedBoundingBox3D {
    @inline(__always)
    func expandedToEnclose(_ rhs: Self) -> Self {
        return AxisAlignedBoundingBox3D([self.maxPosition, self.minPosition, rhs.maxPosition, rhs.minPosition])
    }
}

extension AxisAlignedBoundingBox3D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([center.x, center.y, center.z,
                              _offset.x, _offset.y, _offset.z,
                              _radius.x, _radius.y, radius.z])
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let floats = try container.decode(Array<Float>.self)
        
        self.center = Position3(x: floats[0], y: floats[1], z: floats[2])
        self._offset = Position3(x: floats[3], y: floats[4], z: floats[5])
        self.offset = _offset
        let radius = Size3(width: floats[6], height: floats[7], depth: floats[8])
        self._radius = radius
        self.radius = radius
    }
}
