/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct CollisionTriangle: Sendable {
    public var positions: [Position3]
    public var normal: Direction3
    public var rawAttributes: UInt64
    
    public var plane: Plane3D {
        return Plane3D(origin: center, normal: normal)
    }
    public var center: Position3
    
    public mutating func recomputeCenter() {
        self.center = (p1 + p2 + p3) / 3
    }
    
    public mutating func recomputeNormal() {
        self.normal = Direction3((p2 - p1).cross(p3 - p1)).normalized
    }
    
    public mutating func recompute() {
        self.recomputeCenter()
        self.recomputeNormal()
    }
    
    public mutating func setAttributes<AttributesType: CollisionAttributesGroup>(_ attributes: AttributesType) {
        self.rawAttributes = attributes.rawValue
    }
    
    public func attributes<AttributesType: CollisionAttributesGroup>(as type: AttributesType.Type) -> AttributesType {
        return AttributesType(rawValue: rawAttributes)
    }
    
    public mutating func editAttributes<AttributesType: CollisionAttributesGroup, ResultType>(
        as type: AttributesType.Type,
        _ editAttributes: (_ attributes: inout AttributesType) -> ResultType
    ) -> ResultType {
        var attributes = AttributesType(rawValue: rawAttributes)
        let result = editAttributes(&attributes)
        self.rawAttributes = attributes.rawValue
        return result
    }
    
    public init<AttributesType: CollisionAttributesGroup>(p1: Position3, p2: Position3, p3: Position3, normal: Direction3? = nil, attributes: AttributesType) {
        self.init(p1: p1, p2: p2, p3: p3, normal: normal, rawAttributes: attributes.rawValue)
    }
    
    public init(p1: Position3, p2: Position3, p3: Position3, normal: Direction3? = nil, rawAttributes: UInt64) {
        self.positions = [p1, p2, p3]
        self.normal = normal ?? Direction3((p2 - p1).cross(p3 - p1)).normalized
        self.center = (p1 + p2 + p3) / 3
        self.rawAttributes = rawAttributes
    }
}

public extension CollisionTriangle {
    init<AttributesType: CollisionAttributesGroup>(positions: [Position3], offset: Position3 = .zero, attributesType: AttributesType.Type, triangleUVs: CollisionAttributeUVs) {
        self.init(
            p1: positions[0] + offset,
            p2: positions[1] + offset,
            p3: positions[2] + offset,
            attributes: AttributesType(parsingUVs: triangleUVs)
        )
    }
    
    init(positions: [Position3], offset: Position3 = .zero, rawAttributes: UInt64 = 0) {
        self.init(
            p1: positions[0] + offset,
            p2: positions[1] + offset,
            p3: positions[2] + offset,
            rawAttributes: rawAttributes
        )
    }
}

extension CollisionTriangle: Surface3D {}

public extension CollisionTriangle {
    @inlinable
    var p1: Position3 {return positions[0]}
    @inlinable
    var p2: Position3 {return positions[1]}
    @inlinable
    var p3: Position3 {return positions[2]}
}

public extension CollisionTriangle {
    @inlinable
    func interpolated(to rhs: CollisionTriangle, _ method: InterpolationMethod<Float>) -> CollisionTriangle {
        var normal: Direction3? = self.normal.interpolated(to: rhs.normal, method)
        if normal?.isFinite == false {
            normal = nil//Rebuild the normal if its broken
        }
        
        return CollisionTriangle(
            p1: p1.interpolated(to: rhs.p1, method),
            p2: p2.interpolated(to: rhs.p2, method),
            p3: p3.interpolated(to: rhs.p3, method),
            normal: normal,
            rawAttributes: rhs.rawAttributes
        )
    }
}

extension CollisionTriangle {
    @inlinable
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> CollisionTriangle {
        let p1 = self.p1 / ellipsoidRadius
        let p2 = self.p2 / ellipsoidRadius
        let p3 = self.p3 / ellipsoidRadius
        let normal = (self.normal / ellipsoidRadius).normalized
        return CollisionTriangle(p1: p1, p2: p2, p3: p3, normal: normal, rawAttributes: rawAttributes)
    }
    
    @inlinable
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> CollisionTriangle {
        let p1 = self.p1 * ellipsoidRadius
        let p2 = self.p2 * ellipsoidRadius
        let p3 = self.p3 * ellipsoidRadius
        let normal = (self.normal * ellipsoidRadius).normalized
        return CollisionTriangle(p1: p1, p2: p2, p3: p3, normal: normal, rawAttributes: rawAttributes)
    }
}


extension CollisionTriangle: Collider3D {
    @inlinable
    public var offset: Position3 {
        return .zero
    }
    
    @inlinable
    public func update(transform: Transform3) {
        
    }
    
    @inlinable
    public func update(sizeAndOffsetUsingTransform transform: Transform3) {

    }
    
    @inlinable
    public var boundingBox: AxisAlignedBoundingBox3D {
        return AxisAlignedBoundingBox3D(self.positions)
    }
    
    @inlinable
    public func isPotentiallyColliding(with collider: any Collider3D) -> Bool {
        var collider = collider.boundingBox
        // We grab all possible triangles to respond to in one phase.
        // To ensure we can respond to triangles after a position change from a response,
        // we make the box larger. This will grab additional nearby triangles.
        collider.radius *= 1.5
        let p = closestSurfacePoint(from: collider.position)
        return collider.contains(p)
    }
    
    @inlinable
    public func interpenetration(comparing collider: any Collider3D) -> Interpenetration3D? {
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
    
    @inlinable
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
    
    @inlinable
    public func surfaceNormal(facing point: Position3) -> Direction3 {
        return normal
    }
    
    @inlinable
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
    
    @inlinable
    public func edgeNear(_ p: Position3) -> Line3D {
        let edges: [Line3D] = [Line3D(p1, p2), Line3D(p1, p3), Line3D(p2, p3)]
        let edgesWithDistance: [(d: Float, edge: Line3D)] = edges.map({
            let projected = $0.pointNear(p)
            return (p.distance(from: projected), $0)
        }).sorted(by: {$0.d < $1.d})
        let edge = edgesWithDistance[0]
        return edge.edge
    }
    
    @inlinable
    public func edgeNormal(toward p: Position3) -> Direction3 {
        let edge = edgeNear(p)
        return normal.cross(Direction3(from: edge.p1, to: edge.p2))
    }
    
    @inlinable
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
    @inlinable
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
    }
    
    @inlinable
    public static func ==(lhs: CollisionTriangle, rhs: CollisionTriangle) -> Bool {
        return lhs.positions == rhs.positions
    }
}

public extension CollisionTriangle {
    @inlinable
    static func +(lhs: CollisionTriangle, rhs: Position3) -> CollisionTriangle {
        return CollisionTriangle(p1: lhs.p1 + rhs, p2: lhs.p2 + rhs, p3: lhs.p3 + rhs, normal: lhs.normal, rawAttributes: lhs.rawAttributes)
    }
    @inlinable
    static func +=(lhs: inout CollisionTriangle, rhs: Position3) {
        lhs = lhs + rhs
    }
    
    @inlinable
    static func *(lhs: CollisionTriangle, rhs: Matrix4x4) -> CollisionTriangle {
        return CollisionTriangle(p1: lhs.p1 * rhs, p2: lhs.p2 * rhs, p3: lhs.p3 * rhs, normal: nil, rawAttributes: lhs.rawAttributes)
    }
    @inlinable
    static func *=(lhs: inout CollisionTriangle, rhs: Matrix4x4) {
        lhs = lhs * rhs
    }
}

extension CollisionTriangle: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([positions[0].x, positions[0].y, positions[0].z,
                              positions[1].x, positions[1].y, positions[1].z,
                              positions[2].x, positions[2].y, positions[2].z])
        try container.encode(rawAttributes)
    }
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let floats: [Float] = try container.decode([Float].self)
        let attributes = try container.decode(UInt64.self)

        let positions = [Position3(floats[0], floats[1], floats[2]), Position3(floats[3], floats[4], floats[5]), Position3(floats[6], floats[7], floats[8])]
        let normal = Direction3((positions[1] - positions[0]).cross(positions[2] - positions[0])).normalized
        self.init(p1: positions[0], p2: positions[1], p3: positions[2], normal: normal, rawAttributes: attributes)
    }
}

extension Array where Element == CollisionTriangle {
    public func generatePositions() -> [Position3] {
        return self.map(\.positions).flatMap(\.self)
    }
    
    public func generateBoundingBox() -> AxisAlignedBoundingBox3D {
        return AxisAlignedBoundingBox3D(generatePositions())
    }
}
