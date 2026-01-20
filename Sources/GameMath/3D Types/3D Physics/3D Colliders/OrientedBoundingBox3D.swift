/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct OrientedBoundingBox3D: Collider3D, Sendable {
    public private(set) var offset: Position3
    public private(set) var center: Position3
    public private(set) var rotation: Quaternion
    public private(set) var radius: Size3 // Positive halfwidth extents of OBB along each axis
    internal var _radius: Size3
    internal var _offset: Position3
    internal var _rotation: Quaternion
    
    public var size: Size3 {return radius * 2}
    
    public init(center: Position3 = .zero, offset: Position3 = .zero, radius: Size3, rotation: Quaternion) {
        self.center = center
        self.rotation = rotation
        self._rotation = rotation
        self.offset = offset
        self._offset = offset
        self._radius = radius
        self.radius = _radius
        // TODO: radius * 2 is probably overkill. Figure out the exact max radius.
        self.boundingBox = AxisAlignedBoundingBox3D(center: center, offset: offset, radius: radius * 2)
    }
    
    fileprivate var matrix: Matrix4x4 {
        return Matrix4x4(position: position) * Matrix4x4(rotation: rotation)
    }
    
    @inlinable
    public var volume: Float {
        return (radius.x * 2.0) * (radius.y * 2.0) * (radius.z * 2.0)
    }
    
    public private(set) var boundingBox: AxisAlignedBoundingBox3D

    mutating public func update(withWorldTransform transform: Transform3) {
        center = transform.position
        offset = _offset * transform.scale
        radius = _radius * transform.scale
        rotation = _rotation * transform.rotation.conjugate
        self.boundingBox.update(withWorldTransform: transform)
    }
    
    public mutating func update(withLocalTransform transform: Transform3) {
        _offset = transform.position
        _radius = transform.scale / 2
        _rotation = transform.rotation
        self.boundingBox.update(withLocalTransform: transform)
    }
}

public extension OrientedBoundingBox3D {
    init(_ positions: [Position3]) {
        var x: Size2 = Size2(width: Float(Int.max), height: Float(Int.min)) //min, max
        var y: Size2 = Size2(width: Float(Int.max), height: Float(Int.min)) //min, max
        var z: Size2 = Size2(width: Float(Int.max), height: Float(Int.min)) //min, max
        
        for position in positions {
            x.x = min(Float(position.x), x.x)
            x.y = max(Float(position.x), x.y)
            
            y.x = min(Float(position.y), y.x)
            y.y = max(Float(position.y), y.y)
            
            z.x = min(Float(position.z), z.x)
            z.y = max(Float(position.z), z.y)
        }
        
        self.offset = Position3(x: (x.y + x.x) / 2.0, y: (y.y + y.x) / 2.0, z: (z.y + z.x) / 2.0)
        self._offset = offset
        self.center = .zero
        self._radius = Size3(width: (x.y - x.x) / 2.0, height: (y.y - y.x) / 2.0, depth: (z.y - z.x) / 2.0)
        self.radius = _radius
        self.rotation = .zero
        self._rotation = .zero
        self.boundingBox = AxisAlignedBoundingBox3D(center: center, offset: offset, radius: radius)
    }
}

public extension OrientedBoundingBox3D {
    @inlinable
    func surfacePoint(for ray: Ray3D) -> Position3? {
        var tMin: Float = -.infinity
        var tMax: Float = .infinity

        let p = position - ray.origin // Bcenter is the center of the OBB. Ray3D.o is the origin of the ray.
        let arr: [Direction3] = [Direction3(1, 0, 0), Direction3(0, 1, 0), Direction3(0, 0, 1)] // Direction/base vectors. (1,0,0), (0,1,0), (0,0,1)
        let rai = [radius.x, radius.y, radius.z]
        
        for i in 0 ..< 3 {
            let radius = rai[i]
            let i = arr[i].rotated(by: rotation)
            let e = i.dot(p)
            let f = i.dot(ray.direction)
            
            let q = -e - radius // The distance between the center and each side. 100.
            let w = -e + radius
            
            if abs(f) > .ulpOfOne {
                var t1 = (e + radius) / f
                var t2 = (e - radius) / f
                
                if t1 > t2 {
                    swap(&t1, &t2)
                }
                if t1 > tMin {
                    tMin = t1
                }
                if t2 < tMax {
                    tMax = t2
                }
                
                if tMin > tMax {
                    return nil
                }
                if tMax < 0 {
                    return nil
                }
            }else if q > 0 || w < 0 {
                return nil
            }
        }
        var distance: Float? = nil
        if tMin > 0 {
            distance = tMin
        }else if tMax <= 0 {
            distance = tMax
        }
        if let distance = distance {
            return ray.origin.moved(distance, toward: ray.direction)
        }
        return nil
    }
    
    @inlinable
    func surfaceNormal(facing point: Position3) -> Direction3 {
        let arr: [Direction3] = [Direction3(1, 0, 0).rotated(by: rotation),
                                        Direction3(0, 1, 0).rotated(by: rotation),
                                        Direction3(0, 0, 1).rotated(by: rotation)] // Direction/base vectors. (1,0,0), (0,1,0), (0,0,1)
        let halfArr = [radius.x, radius.y, radius.z]
        let center = self.center + self.offset
        
        var returnValue: Direction3 = .zero
        for i in 0 ..< 3 {
            let sPlus = center + (arr[i] * halfArr[i])
            let sMinus = center - (arr[i] * halfArr[i])
            
            if (point - sPlus).dot(arr[i]) < 0.0001 && (point - sPlus).dot(arr[i]) > -0.0001 {
                returnValue = arr[i]
            }else if (point - sMinus).dot(arr[i] * -1) < 0.0001 && (point - sMinus).dot(arr[i] * -1) > -0.0001 {
                returnValue = arr[i] * -1
            }
        }
        return returnValue
    }
}

extension OrientedBoundingBox3D {
    @inlinable
    func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return OrientedBoundingBox3D(center: self.center / ellipsoidRadius, offset: self.offset / ellipsoidRadius, radius: self.radius / ellipsoidRadius, rotation: rotation)
    }
    
    @inlinable
    func movedOutsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Self {
        return OrientedBoundingBox3D(center: self.center * ellipsoidRadius, offset: self.offset * ellipsoidRadius, radius: self.radius * ellipsoidRadius, rotation: rotation)
    }
}

extension OrientedBoundingBox3D {
    @inlinable
    public func interpenetration(comparing collider: any Collider3D) -> Interpenetration3D? {
        switch collider {
        case let collider as OrientedBoundingBox3D:
            guard self.isColliding(with: collider) else {return nil}
            return OrientedBoundingBox3D.cubeCubeCollisionCheck(self, collider)
        case let collider as BoundingEllipsoid3D:
            return self.interpenetration(comparing: collider)
        default:
            return collider.interpenetration(comparing: self)
        }
    }
    
    @inlinable
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
    
    @inlinable
    func isColliding(with rhs: OrientedBoundingBox3D) -> Bool {
        let rhsRotation = [rhs.rotation.right, rhs.rotation.up, rhs.rotation.forward]
        let lhs = self
        let lhsRotation = [lhs.rotation.right, lhs.rotation.up, lhs.rotation.forward]
        var ra: Float = 0
        var rb: Float = 0
        var r = Matrix3x3()
        var absR = Matrix3x3()
        
        // Compute rotation matrix expressing b in a’s coordinate frame
        for i in 0..<3 {
            for j in 0..<3 {
                var v0: Direction3 = r[i]
                let v1: Direction3 = lhsRotation[i]
                let v2: Direction3 = rhsRotation[j]
                v0[j] = v1.dot(v2)
                r[i] = v0
            }
        }
        
        // Compute translation vector t
        var t: Direction3 = Direction3(rhs.center - lhs.center)
        // Bring translation into a’s coordinate frame
        t = Direction3(x: t.dot(lhsRotation[0] as Direction3), y: t.dot(lhsRotation[1] as Direction3), z: t.dot(lhsRotation[2] as Direction3))
        // Compute common subexpressions. Add in an epsilon term to
        // counteract arithmetic errors when two edges are parallel and // their cross product is (near) null (see text for details) for (int i = 0; i < 3; i++)
        
        for i in 0..<3 {
            for j in 0..<3 {
                var v: Direction3 = absR[i]
                v[j] = abs(r[i][j]) + Float.ulpOfOne
                absR[i] = v
            }
        }
        
        // Test axes L = A0, L = A1, L = A2
        for i in 0..<3 {
            let v: Direction3 = absR[i]
            ra = lhs.radius[i]
            rb = rhs.radius[0] * v.x + rhs.radius[1] * v.y + rhs.radius[2] * v.z
            if abs(t[i]) > ra + rb {
                return false
            }
        }
        // Test axes L = B0, L = B1, L = B2
        for i in 0..<3 {
            ra = lhs.radius[0] * absR[0][i] + lhs.radius[1] * absR[1][i] + lhs.radius[2] * absR[2][i]
            rb = rhs.radius[i]
            if abs(t[0] * r[0][i] + t[1] * r[1][i] + t[2] * r[2][i]) > ra + rb {
                return false
            }
        }
        // Test axis L = A0 x B0
        ra = lhs.radius[1] * absR[2][0] + lhs.radius[2] * absR[1][0]
        rb = rhs.radius[1] * absR[0][2] + rhs.radius[2] * absR[0][1]
        if abs(t[2] * r[1][0] - t[1] * r[2][0]) > ra + rb {
            return false
        }
        // Test axis L = A0 x B1
        ra = lhs.radius[1] * absR[2][1] + lhs.radius[2] * absR[1][1]
        rb = rhs.radius[0] * absR[0][2] + rhs.radius[2] * absR[0][0]
        if abs(t[2] * r[1][1] - t[1] * r[2][1]) > ra + rb {
            return false
        }
        // Test axis L = A0 x B2
        ra = lhs.radius[1] * absR[2][2] + lhs.radius[2] * absR[1][2]
        rb = rhs.radius[0] * absR[0][1] + rhs.radius[1] * absR[0][0]
        if abs(t[2] * r[1][2] - t[1] * r[2][2]) > ra + rb {
            return false
        }
        // Test axis L = A1 x B0
        ra = lhs.radius[0] * absR[2][0] + lhs.radius[2] * absR[0][0]
        rb = rhs.radius[1] * absR[1][2] + rhs.radius[2] * absR[1][1]
        if abs(t[0] * r[2][0] - t[2] * r[0][0]) > ra + rb {
            return false
        }
        // Test axis L = A1 x B1
        ra = lhs.radius[0] * absR[2][1] + lhs.radius[2] * absR[0][1]
        rb = rhs.radius[0] * absR[1][2] + rhs.radius[2] * absR[1][0]
        if abs(t[0] * r[2][1] - t[2] * r[0][1]) > ra + rb {
            return false
        }
        // Test axis L = A1 x B2
        ra = lhs.radius[0] * absR[2][2] + lhs.radius[2] * absR[0][2]
        rb = rhs.radius[0] * absR[1][1] + rhs.radius[1] * absR[1][0]
        if abs(t[0] * r[2][2] - t[2] * r[0][2]) > ra + rb {
            return false
        }
        // Test axis L = A2 x B0
        ra = lhs.radius[0] * absR[1][0] + lhs.radius[1] * absR[0][0]
        rb = rhs.radius[1] * absR[2][2] + rhs.radius[2] * absR[2][1]
        if abs(t[1] * r[0][0] - t[0] * r[1][0]) > ra + rb {
            return false
        }
        // Test axis L = A2 x B1
        ra = lhs.radius[0] * absR[1][1] + lhs.radius[1] * absR[0][1]
        rb = rhs.radius[0] * absR[2][2] + rhs.radius[2] * absR[2][0]
        if abs(t[1] * r[0][1] - t[0] * r[1][1]) > ra + rb {
            return false
        }
        // Test axis L = A2 x B2
        ra = lhs.radius[0] * absR[1][2] + lhs.radius[1] * absR[0][2]
        rb = rhs.radius[0] * absR[2][1] + rhs.radius[1] * absR[2][0]
        if abs(t[1] * r[0][2] - t[0] * r[1][2]) > ra + rb {
            return false
        }
        // Since no separating axis is found, the OBBs must be intersecting
        return true
    }
    
    @inlinable
    public func closestSurfacePoint(from point: Position3) -> Position3 {
        let rotation = [self.rotation.right, self.rotation.up, self.rotation.forward]
        
        let d = point - position
        // Start result at center of box; make steps from there
        var q = position
        // For each OBB axis...
        for i in 0 ..< 3 {
            // ...project d onto that axis to get the distance
            // along the axis of d from the box center
            var dist = d.dot(rotation[i])
            // If distance farther than the box extents, clamp to the box
            if dist > radius[i] {
                dist = radius[i]
            }
            if dist < -radius[i] {
                dist = -radius[i]
            }
            // Step that distance along the axis to get world coordinate
            q += rotation[i] * dist
        }
        
        return q
    }
    
    public func contains(_ point: Position3) -> Bool {
        #warning("This might be wrong")
        let p = point * matrix.inverse
        
        let halfX = radius.width
        let halfY = radius.height
        let halfZ = radius.depth
        if p.x < halfX && p.x > -halfX && p.y < halfY && p.y > -halfY && p.z < halfZ && p.z > -halfZ {
            return true
        }
        return false
    }
}

extension OrientedBoundingBox3D {
    public var vertices: [Position3] {
        let x = self.radius.width
        let y = self.radius.height
        let z = self.radius.depth
        
        return [Position3(  x,  y,  z),
                Position3( -x,  y,  z),
                Position3(  x, -y,  z),
                Position3( -x, -y,  z),
                
                Position3(  x,  y, -z),
                Position3( -x,  y, -z),
                Position3(  x, -y, -z),
                Position3( -x, -y, -z)].map({$0 * self.matrix})
    }
    @inlinable
    func vertexSpan(along axis: Direction3) -> ClosedRange<Float> {
        let vertices = self.vertices
        
        var min = vertices[0].dot(axis)
        var max = min
        
        for vertex in vertices {
            let d = vertex.dot(axis)
            
            if d < min {
                min = d
            }
            if d > max {
                max = d
            }
        }
        return min ... max
    }
    
    @inlinable
    static func spanIntersect(_ box0: OrientedBoundingBox3D,
                              _ box1: OrientedBoundingBox3D,
                              _ axisc: Direction3,
                              _ minPenetration: inout Float?,
                              _ axisPenetration: inout Direction3?,
                              _ pen: inout Float?) -> Bool {
        
        var axis = axisc
        
        let lq = axis.squaredLength
        if lq <= 0.02 {
            if (pen != nil) {
                pen = 100000.0
            }
            return true
        }
        
        axis.normalize()
        
        let a = box0.vertexSpan(along: axis)
        let b = box1.vertexSpan(along: axis)
        
        let lena = a.upperBound - a.lowerBound
        let lenb = b.upperBound - b.lowerBound
        
        let minv = min(a.lowerBound, b.lowerBound)
        let maxv = max(a.upperBound, b.upperBound)
        let lenv = maxv - minv
        
        if lenv > (lena + lenb) {
            // Collision
            return false
        }
        
        let penetration = (lena + lenb) - lenv
        
        if pen != nil {
            pen = penetration
        }
        
        if minPenetration != nil && axisPenetration != nil {
            if penetration < minPenetration! {
                minPenetration = penetration
                axisPenetration = axis
                
                // BoxA pushes BoxB away in the correct Direction
                if b.lowerBound < a.lowerBound {
                    axisPenetration = axisPenetration! * -1.0
                }
            }
        }
        
        // Colllision
        return true
    }
    
    @inlinable
    static func getNumHitPoints(_ box0: OrientedBoundingBox3D, _ hitNormal: Direction3, _ penetration: Float, _ vertIndexes: inout [Array<Position3>.Index]) -> [Position3] {
        let vertices = box0.vertices
        
        var planePoint = vertices[0]
        var maxdist = vertices[0].dot(hitNormal)
        
        for vertex in vertices {
            let d = vertex.dot(hitNormal)
            if d > maxdist {
                maxdist = d
                planePoint = vertex
            }
        }
        
        // Plane Equation (A dot N) - d = 0;
        
        var d = planePoint.dot(hitNormal)
        d -= penetration + 0.01
        
        var collisionPoints: [Position3] = []
        for index in vertices.indices {
            let vertex = vertices[index]
            let side = vertex.dot(hitNormal) - d
            
            if side > 0 {
                collisionPoints.append(vertex)
                vertIndexes.append(index)
            }
        }
        
        return collisionPoints
    }
    
    @inlinable
    static func sortVertices(_ vertices: inout [Position3], _ vertexIndices: inout [Array<Position3>.Index]) {
        let faces = [[4,0,3,7],
                     [1,5,6,2],
                     [0,1,2,3],
                     [7,6,5,4],
                     [5,1,0,4],
                     [6,7,3,2]]
        
        var sortedVerts: [Position3] = [] // New correct clockwise order
        var sortedIndices: [Array<Position3>.Index] = []
        
        for face in faces where sortedVerts.count < 4 {
            var count = 0
            for vertexIndex in vertexIndices where count < 4 {
                if face.contains(vertexIndex) {
                    count += 1
                }
            }
            if count == 4 {
                for index in face {
                    sortedVerts.append(vertices[vertexIndices.firstIndex(of: index)!])
                    sortedIndices.append(index)
                }
                break
            }
        }
        
        assert(sortedVerts.count == 4, "Must be 4 matching verts")
        vertices = sortedVerts
        vertexIndices = sortedIndices
    }
    
    @inlinable
    static func vertInsideFace(_ verts0: [Position3], _ p0: Position3, _ planeErr: Float = 0) -> Bool {
        // Work out the normal for the face
        let v0 = verts0[1] - verts0[0]
        let v1 = verts0[2] - verts0[0]
        let n  = v1.cross(v0).normalized
        
        for i in 0 ..< 4 {
            let s0 = verts0[i]
            let s1 = verts0[(i + 1) % 4]
            let sx = s0 + n * 10.0
            
            // Work out the normal for the face
            let sv0 = s1 - s0
            let sv1 = sx - s0
            let sn  = sv1.cross(sv0).normalized
            
            let d  = s0.dot(sn)
            let d0 = p0.dot(sn) - d
            
            // Outside the plane
            if d0 > planeErr {
                return false
            }
        }
        
        return true
    }
    
    @inlinable
    static func clipFaceFaceVerts(_ verts0: inout [Position3],
                                  _ vertIndexes0: inout [Array<Position3>.Index],
                                  _ verts1: inout [Position3],
                                  _ vertIndexes1: inout [Array<Position3>.Index]) -> [Position3] {
        
        sortVertices(&verts0, &vertIndexes0)
        sortVertices(&verts1, &vertIndexes1)
        
        // Work out the normal for the face
        let v0 = verts0[1] - verts0[0]
        let v1 = verts0[2] - verts0[0]
        let n  = v1.cross(v0).normalized
        
        // Project all the vertices onto a shared plane, plane0
        var vertsTemp1 = Array<Position3>(repeating: .zero, count: 4)
        for i in 0 ..< 4 {
            vertsTemp1[i] = verts1[i] + (n * n.dot(verts0[0]-verts1[i]))
        }
        
        
        var temp = Array<Position3>(repeating: .zero, count: 50)
        var numVerts = 0
        
        for c in 0 ..< 2 {
            let vertA = c == 1 ? vertsTemp1 : verts0
            let vertB = c == 1 ? verts0 : vertsTemp1
            
            // Work out the normal for the face
            let v0 = vertA[1] - vertA[0]
            let v1 = vertA[2] - vertA[0]
            let n  = v1.cross(v0).normalized
            
            for i in 0 ..< 4 {
                let s0 = vertA[i]
                let s1 = vertA[(i + 1) % 4]
                let sx = s0 + n * 10.0
                
                // Work out the normal for the face
                let sv0 = s1 - s0
                let sv1 = sx - s0
                let sn  = sv1.cross(sv0).normalized
                
                let d = s0.dot(sn)
                
                for j in 0 ..< 4 {
                    let p0 = vertB[j]
                    let p1 = vertB[(j + 1) % 4] // Loops back to the 0th for the last one
                    
                    let d0 = p0.dot(sn) - d
                    let d1 = p1.dot(sn) - d
                    
                    // Check there on opposite sides of the plane
                    if (d0 * d1) < 0 {
                        let pX = p0 + (p1 - p0) * (sn.dot(s0 - p0) / sn.dot(p1 - p0))
                        
                        if vertInsideFace(vertA, pX, 0.1) {
                            temp[numVerts] = pX
                            numVerts += 1
                        }
                    }
                    
                    if vertInsideFace(vertA, p0) {
                        temp[numVerts] = p0
                        numVerts += 1
                    }
                }
            }
        }
        
        // Remove verts which are very close to each other
        for i in 0 ..< numVerts {
            for j in 0 ..< numVerts {
                guard i != j else {continue}
                
                let dist = (temp[i] - temp[j]).squaredLength
                
                if dist < 6.5 {
                    for k in 0 ..< numVerts {
                        temp[k] = temp[k + 1]
                    }
                    numVerts -= 1
                }
            }
        }
 
        return temp
    }
    
    @inlinable
    static func closestPtPointOBB(_ point: Position3, _ box0: OrientedBoundingBox3D) -> Position3 {
        let d = point - box0.center
        var q = box0.center
        let box0Rotation = [box0.rotation.right, box0.rotation.up, box0.rotation.forward]
        for i in 0 ..< 3 {
            var dist = d.dot(box0Rotation[i])
            
            if dist > box0.radius[i] {dist = box0.radius[i]}
            if dist < -box0.radius[i] {dist = -box0.radius[i]}
            
            q += box0Rotation[i] * dist
        }
        
        return q
    }
    
    @inlinable
    static func clipLinePlane(_ verts0: [Position3], _ vertIndexes0: [Array<Position3>.Index], _ box0: OrientedBoundingBox3D,
                              _ verts1: [Position3], _ vertIndexes1: [Array<Position3>.Index], _ box1: OrientedBoundingBox3D) -> [Position3] {
        
        let p1 = closestPtPointOBB(verts0[0], box1)
        let p2 = closestPtPointOBB(verts0[1], box1)
        return [p1, p2]
    }
    
    @inlinable
    static func closestPointLineLine(_ verts0: [Position3], _ verts1: [Position3]) -> Position3 {
        let p1 = verts0[0]
        let q1 = verts0[1]
        let p2 = verts1[0]
        let q2 = verts1[1]
        
        let d1 = q1 - p1
        let d2 = q2 - p2
        let r  = p1 - p2
        let a = d1.dot(d1)
        let e = d2.dot(d2)
        let f = d2.dot(r)
        
        let epsilon: Float = 0.00001
        
        var s: Float = 0
        var t: Float = 0
        var c1: Position3 = .zero
        var c2: Position3 = .zero
        
        if a <= epsilon && e <= epsilon {
            t = 0
            s = t
            c1 = p1
            c2 = p2
            
            return c1
        }
        
        if a <= epsilon {
            s = 0.0
            t = f / e
            t = max(0, min(t, 1))
        }else{
            let c = d1.dot(r)
            if e <= epsilon {
                t = 0.0
                s = max(0.0, min(-c / a, 1.0))
            }else{
                let b = d1.dot(d2)
                let denom = a * e - b * b
                
                if denom != 0 {
                    s = max(0.0, min((b * f - c * e) / denom, 1.0))
                }else{
                    s = 0
                }
                
                t = (b * s + f) / e
                
                if t < 0 {
                    t = 0
                    s = max(0.0, min(-c / a, 1.0))
                }else if t > 1 {
                    t = 1
                    s = max(0.0, min((b - c) / a, 1.0))
                }
            }
        }
        
        c1 = p1 + d1 * s
        c2 = p2 + d2 * t
        
        return (c1 + c2) * 0.5
    }
    
    @inlinable
    static func calculateHitPoint(_ box0: OrientedBoundingBox3D, _ box1: OrientedBoundingBox3D, _ penetration: Float, _ hitNormal: inout Direction3) -> [Position3] {
        let norm0 = hitNormal
        var vertIndex0: Array<Array<Position3>.Index> = []
        var verts0 = getNumHitPoints(box0, norm0, penetration, &vertIndex0)
        
        let norm1 = hitNormal
        var vertIndex1: Array<Array<Position3>.Index> = []
        var verts1 = getNumHitPoints(box1, norm1, penetration, &vertIndex1)
        
        // This should never really happen!
        guard verts0.isEmpty == false && verts1.isEmpty == false else {return []}
        
        var vertsX = verts0
        
        if verts0.count >= 4 && verts1.count >= 4 {
            vertsX = clipFaceFaceVerts(&verts0, &vertIndex0, &verts1, &vertIndex1)
        }
        
        // TO-DO - work out which one is the least number
        // of verts, and use that, if both have two, work out
        // the edge point exactly...if its just a single point, only
        // use that single vert
        
        // TO-DO** TO-DO
        //int numVertsX = numVerts0;
        //D3DXVECTOR3* vertsX = verts0;
        
        
        if verts1.count < verts0.count {
            vertsX = verts1
            hitNormal = norm1 * -1.0
        }
        
        if verts0.count == 2 && verts1.count == 2 {
            vertsX = [closestPointLineLine(verts0, verts1)]
        }
        
        if verts0.count == 2 && verts1.count == 4 {
            vertsX = clipLinePlane(verts0, vertIndex0, box0,
                                   verts1, vertIndex1, box1)
        }
        
        if verts0.count == 4 && verts1.count == 2 {
            vertsX = clipLinePlane(verts1, vertIndex1, box1,
                                   verts0, vertIndex0, box0)
        }

        return vertsX
    }
    
    @inlinable
    static func cubeCubeCollisionCheck(_ box0: OrientedBoundingBox3D, _ box1: OrientedBoundingBox3D) -> Interpenetration3D? {
        let box0Rotation = [box0.rotation.right, box0.rotation.up, box0.rotation.forward]
        let box1Rotation = [box1.rotation.right, box1.rotation.up, box1.rotation.forward]
        
        var depth: Float? = Float.greatestFiniteMagnitude
        var normal: Direction3? = .up
        var penetration: Float? = nil
        
        var hit = true
        
        hit = hit && spanIntersect(box0, box1, box0Rotation[0], &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[1], &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[2], &depth, &normal, &penetration)
        
        hit = hit && spanIntersect(box0, box1, box1Rotation[0], &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box1Rotation[1], &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box1Rotation[2], &depth, &normal, &penetration)
        
        hit = hit && spanIntersect(box0, box1, box0Rotation[0].cross(box1Rotation[0]), &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[0].cross(box1Rotation[1]), &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[0].cross(box1Rotation[2]), &depth, &normal, &penetration)
        
        hit = hit && spanIntersect(box0, box1, box0Rotation[1].cross(box1Rotation[0]), &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[1].cross(box1Rotation[1]), &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[1].cross(box1Rotation[2]), &depth, &normal, &penetration)
        
        hit = hit && spanIntersect(box0, box1, box0Rotation[2].cross(box1Rotation[0]), &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[2].cross(box1Rotation[1]), &depth, &normal, &penetration)
        hit = hit && spanIntersect(box0, box1, box0Rotation[2].cross(box1Rotation[2]), &depth, &normal, &penetration)
        
        if hit, let depth = depth, var direction = normal {
            let collisions = calculateHitPoint(box0, box1, depth, &direction)
            return Interpenetration3D(depth: depth, direction: direction * -1.0, points: Set(collisions))
        }

        return nil
    }
}
