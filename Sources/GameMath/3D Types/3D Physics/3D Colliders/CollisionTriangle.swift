/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct CollisionTriangle: Sendable {
    public var positions: [Position3]
    public var colors: [Color]
    public var normal: Direction3
    public var _attributes: UInt32
    
    public var plane: Plane3D
    public var center: Position3
    
    public static var attributeParser = {(u: Float, v: Float, section: UInt32) -> UInt32 in
        let range: Float = 3
        let uidx: Float = floor(u * range)
        let vidx: Float = floor(v * range)
        
        guard uidx >= 0 && uidx < range else {return 0}
        guard vidx >= 0 && vidx < range else {return 0}
        
        let row = UInt32(vidx) * UInt32(range)
        let shift = (UInt32(range * range) * section) + (row + UInt32(uidx) + 1)
        return 1 << shift
    }
    
    public mutating func recomputeCenter() {
        self.center = (p1 + p2 + p3) / Position3(3.0)
    }
    
    public mutating func recomputeNormal() {
        self.normal = Direction3((p2 - p1).cross(p3 - p1)).normalized
    }
    
    public mutating func recomputePlane() {
        self.plane = Plane3D(origin: center, normal: normal)
    }
    
    public mutating func recomputeAll() {
        self.recomputeCenter()
        self.recomputeNormal()
        self.recomputePlane()
    }
    
    public init(_ p1: Position3, _ p2: Position3, _ p3: Position3, _ c1: Color = .white, _ c2: Color = .white, _ c3: Color = .white, normal: Direction3? = nil, attributes: UInt32 = 0) {
        self.positions = [p1, p2, p3]
        self.colors = [c1, c2, c3]
        let normal = normal ?? Direction3((p2 - p1).cross(p3 - p1)).normalized
        let center = (p1 + p2 + p3) / Position3(3.0)
        self.normal = normal
        self._attributes = attributes
        self.plane = Plane3D(origin: center, normal: normal)
        self.center = (p1 + p2 + p3) / Position3(3.0)
    }
}

public extension CollisionTriangle {
    init(positions: [Position3], colors: [Color], offset: Position3 = .zero, attributeUV: [Position2]) {
        var attributes: UInt32 = 0
        for index in 0 ..< attributeUV.count {
            let uv = attributeUV[index]
            attributes |= Self.attributeParser(uv.x, uv.y, UInt32(index))
        }
        self.init(positions[0] + offset,
                  positions[1] + offset,
                  positions[2] + offset,
                  colors[0],
                  colors[1],
                  colors[2],
                  attributes: attributes)
    }
}

extension CollisionTriangle: Surface3D {}

public extension CollisionTriangle {
    @inlinable @inline(__always)
    var p1: Position3 {return positions[0]}
    @inlinable @inline(__always)
    var p2: Position3 {return positions[1]}
    @inlinable @inline(__always)
    var p3: Position3 {return positions[2]}
    
    @inlinable @inline(__always)
    var c1: Color {return colors[0]}
    @inlinable @inline(__always)
    var c2: Color {return colors[1]}
    @inlinable @inline(__always)
    var c3: Color {return colors[2]}
}

public extension CollisionTriangle {
    @inline(__always)
    func interpolated(to rhs: CollisionTriangle, _ method: InterpolationMethod) -> CollisionTriangle {
        var normal: Direction3? = self.normal.interpolated(to: rhs.normal, method)
        if normal?.isFinite == false {
            normal = nil//Rebuild the normal if its broken
        }
        
        return CollisionTriangle(p1.interpolated(to: rhs.p1, method),
                                 p2.interpolated(to: rhs.p2,  method),
                                 p3.interpolated(to: rhs.p3,  method),
                                 c1.interpolated(to: rhs.c1,  method),
                                 c2.interpolated(to: rhs.c2,  method),
                                 c3.interpolated(to: rhs.c3,  method),
                                 normal: normal, attributes: rhs._attributes)
    }
}

extension CollisionTriangle {
    @inline(__always)
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> CollisionTriangle {
        let p1 = self.p1 / ellipsoidRadius
        let p2 = self.p2 / ellipsoidRadius
        let p3 = self.p3 / ellipsoidRadius
        let normal = (self.normal / ellipsoidRadius).normalized
        return CollisionTriangle(p1, p2, p3, c1, c2, c3, normal: normal, attributes: _attributes)
    }
    
    @inline(__always)
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> CollisionTriangle {
        let p1 = self.p1 * ellipsoidRadius
        let p2 = self.p2 * ellipsoidRadius
        let p3 = self.p3 * ellipsoidRadius
        let normal = (self.normal * ellipsoidRadius).normalized
        return CollisionTriangle(p1, p2, p3, c1, c2, c3, normal: normal, attributes: _attributes)
    }
}


extension CollisionTriangle: Collider3D {
    @inline(__always)
    public var offset: Position3 {
        return .zero
    }
    
    @inline(__always)
    public func update(transform: Transform3) {
        
    }
    
    @inline(__always)
    public func update(sizeAndOffsetUsingTransform transform: Transform3) {

    }
    
    @inlinable @inline(__always)
    public var boundingBox: AxisAlignedBoundingBox3D {
        return AxisAlignedBoundingBox3D(self.positions)
    }
    
    @inline(__always)
    public func isPotentiallyColliding(with collider: Collider3D) -> Bool {
        var collider = collider.boundingBox
        // We grab all possible triangles to respond to in one phase.
        // To ensure we can respond to triangles after a position change from a response,
        // we make the box larger. This will grab additional nearby triangles.
        collider.radius *= 1.5
        let p = closestSurfacePoint(from: collider.position)
        return collider.contains(p)
    }
    
    @inline(__always)
    public func interpenetration(comparing collider: Collider3D) -> Interpenetration3D? {
        guard self.isPotentiallyColliding(with: collider) else {return nil}

        switch collider {
        case let sphere as BoundingSphere3D:
            let p = closestSurfacePoint(from: sphere.position)
            let v = p - sphere.position
            guard v.dot(v) <= sphere.radius * sphere.radius else {return nil}
            
            let point = sphere.closestSurfacePoint(from: p)
            let depth = -p.distance(from: point)
            let direction = normal
            let interpenetration = Interpenetration3D(depth: depth, direction: direction, points: [point])

            guard interpenetration.depth.isFinite else {return nil}
            
            return interpenetration
        case let ellipsoid as BoundingEllipsoid3D:
            // TODO: Size less than 0.6 cause the collider to incorrectly pass through the triangle
            // Can probably fix this by scaling both up for the check then scale the result back down
            let position = ellipsoid.position / ellipsoid.radius
            @_transparent
            func closestUnitSphereSurfacePoint(from point: Position3) -> Position3 {
                let scale: Float = 1
                return ((point - position).normalized * scale) + position
            }

            let p = movedInsideEllipsoidSpace(ellipsoid.radius).closestSurfacePoint(from: position)
            let v = p - position
            guard v.dot(v) <= 1 else {return nil}

            let point = closestUnitSphereSurfacePoint(from: p) * ellipsoid.radius
            let depth = -(p * ellipsoid.radius).distance(from: point)
            let direction = normal
            let interpenetration = Interpenetration3D(depth: depth, direction: direction, points: [point])

            guard interpenetration.depth.isFinite else {return nil}

            return interpenetration
        case let obb as OrientedBoundingBox3D:
            #warning("This is broken")
            let p = closestSurfacePoint(from: obb.position)
            guard obb.contains(p) else {return nil}
  
            let point = obb.closestSurfacePoint(from: p)
            let depth = -p.distance(from: point)
            let direction = normal
            let interpenetration = Interpenetration3D(depth: depth, direction: direction, points: [point])

            guard interpenetration.depth.isFinite else {return nil}
            
            return interpenetration
        default:
            fatalError()
        }
    }
    
    @inline(__always)
    public func surfacePoint(for ray: Ray3D) -> Position3? {
        let e1 = p2 - p1
        let e2 = p3 - p1
        let h = ray.direction.cross(e2)
        let a = e1.dot(h)
        guard (a > -0.00001 && a < 0.00001) == false else {return nil}
    
        let s = ray.origin - p1
        let f = 1 / a
        let u = f * s.dot(h)
        guard (u < 0.0 || u > 1.0) == false else {return nil}
        
        let q = s.cross(e1)
        
        
        let v = f * ray.direction.dot(q)
        guard (v < 0.0 || u + v > 1.0) == false else {return nil}
        
        // at this stage we can compute t to find out where
        // the intersection point is on the line
        let t = f * e2.dot(q)
        if t > 0.00001 {
            return ray.origin.moved(t, toward: ray.direction)
        }
        return nil
    }
    
    @inline(__always)
    public func surfaceNormal(facing point: Position3) -> Direction3 {
        return normal
    }
    
    @inline(__always)
    public func closestSurfacePoint(from p: Position3) -> Position3 {
        let a = p1, b = p2, c = p3
        
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
    
    @inline(__always)
    public func edgeNear(_ p: Position3) -> Line3D {
        let edges: [Line3D] = [Line3D(p1, p2), Line3D(p1, p3), Line3D(p2, p3)]
        let edgesWithDistance: [(d: Float, edge: Line3D)] = edges.map({
            let projected = $0.pointNear(p)
            return (p.distance(from: projected), $0)
        }).sorted(by: {$0.d < $1.d})
        let edge = edgesWithDistance[0]
        return edge.edge
    }
    
    @inline(__always)
    public func edgeNormal(toward p: Position3) -> Direction3 {
        let edge = edgeNear(p)
        return normal.cross(Direction3(from: edge.p1, to: edge.p2))
    }
    
    @inline(__always)
    func contains(_ position: Position3) -> Bool {
        let pa = p1
        let pb = p2
        let pc = p3
        
        let e10 = pb - pa
        let e20 = pc - pa
        let a = e10.dot(e10)
        let b = e10.dot(e20)
        let c = e20.dot(e20)
        let ac_bb = (a * c) - (b * b)
        let vp = Position3(x: position.x - pa.x, y: position.y - pa.y, z: position.z - pa.z)
        let d = vp.dot(e10)
        let e = vp.dot(e20)
        let x = (d * c) - (e * b)
        let y = (e * a) - (d * b)
        let z = x + y - ac_bb
        
        return z < 0 && x >= 0 && y >= 0
    }
}

extension CollisionTriangle: Hashable {
    @_transparent
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
    }
    
    @_transparent
    public static func ==(lhs: CollisionTriangle, rhs: CollisionTriangle) -> Bool {
        return lhs.positions == rhs.positions
    }
}

public extension CollisionTriangle {
    @_transparent
    static func +(lhs: CollisionTriangle, rhs: Position3) -> CollisionTriangle {
        return CollisionTriangle(lhs.p1 + rhs, lhs.p2 + rhs, lhs.p3 + rhs, lhs.c1, lhs.c2, lhs.c3, normal: lhs.normal, attributes: lhs._attributes)
    }
    @_transparent
    static func +=(lhs: inout CollisionTriangle, rhs: Position3) {
        lhs = lhs + rhs
    }
    
    @_transparent
    static func *(lhs: CollisionTriangle, rhs: Matrix4x4) -> CollisionTriangle {
        return CollisionTriangle(lhs.p1 * rhs, lhs.p2 * rhs, lhs.p3 * rhs, lhs.c1, lhs.c2, lhs.c3, normal: nil, attributes: lhs._attributes)
    }
    @_transparent
    static func *=(lhs: inout CollisionTriangle, rhs: Matrix4x4) {
        lhs = lhs * rhs
    }
}

extension CollisionTriangle: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([positions[0].x, positions[0].y, positions[0].z,
                              positions[1].x, positions[1].y, positions[1].z,
                              positions[2].x, positions[2].y, positions[2].z])
        try container.encode([colors[0].red, colors[0].green, colors[0].blue, colors[0].alpha,
                              colors[1].red, colors[1].green, colors[1].blue, colors[1].alpha,
                              colors[2].red, colors[2].green, colors[2].blue, colors[2].alpha])
        try container.encode(_attributes)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let floats: [Float] = try container.decode([Float].self)
        let attributes = try container.decode(UInt32.self)

        let positions = [Position3(floats[0], floats[1], floats[2]), Position3(floats[3], floats[4], floats[5]), Position3(floats[6], floats[7], floats[8])]
        let colors = [Color(floats[8], floats[9], floats[10], floats[11]), Color(floats[12], floats[13], floats[14], floats[15]), Color(floats[16], floats[17], floats[18], floats[19])]
        let normal = Direction3((positions[1] - positions[0]).cross(positions[2] - positions[0])).normalized
        self.init(positions[0], positions[1], positions[2], colors[0], colors[1], colors[2], normal: normal, attributes: attributes)
    }
}
