/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// Common opperations used on triangle types for surface calculations
public protocol Triangle3nSurfaceMath {
    typealias ScalarType = Vector3n.ScalarType & FloatingPoint
    associatedtype Scalar: ScalarType
    
    var p1: Position3n<Scalar> { get }
    var p2: Position3n<Scalar> { get }
    var p3: Position3n<Scalar> { get }
    
    var faceNormal: Direction3n<Scalar> { get }
}

public extension Triangle3nSurfaceMath {
    /**
     Locates a position on the surface of this triangle that is as close to the given point as possible.
     - parameter position: A point in space to use as an reference
     - returns: The point on the triangle's surface that is nearest to `p`
     */
    func nearestSurfacePosition(to position: Position3n<Scalar>) -> Position3n<Scalar> where Scalar: ExpressibleByFloatLiteral {
        let a = self.p1
        let b = self.p2
        let c = self.p3
        let p = position
        
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
    func edges(winding: Winding = .default) -> [Line3n<Scalar>] {
        switch winding {
        case .clockwise:
            return [
                Line3n<Scalar>(p1: p1, p2: p2),
                Line3n<Scalar>(p1: p2, p2: p3),
                Line3n<Scalar>(p1: p3, p2: p1)
            ]
        case .counterClockwise:
            return [
                Line3n<Scalar>(p1: p1, p2: p3),
                Line3n<Scalar>(p1: p3, p2: p2),
                Line3n<Scalar>(p1: p2, p2: p1)
            ]
        }
    }
    
    @inlinable
    func nearestEdge(to position: Position3n<Scalar>, winding: Winding = .default) -> Line3n<Scalar> where Scalar: ExpressibleByFloatLiteral {
        let edges = self.edges(winding: winding)
        
        var edgeIndicesWithDistance: [(distance: Scalar, index: Int)]
        
        edgeIndicesWithDistance = edges.indices.map({
            let edge = edges[$0]
            let projected: Position3n<Scalar> = edge.nearestSurfacePosition(to: position)
            return (distance: position.distance(from: projected), index: $0)
        })
        
        edgeIndicesWithDistance.sort(by: {$0.distance < $1.distance})

        return edges[edgeIndicesWithDistance[0].index]
    }
    
    /// A normal of the edge nearest to `position`. The normal faces away from the center of the triangle along the triangles plane and is perpendicular to the edge.
    @inlinable
    func nearestPlanarEdgeNormal(to position: Position3n<Scalar>) -> Direction3n<Scalar> where Scalar: ExpressibleByFloatLiteral {
        let edge = self.nearestEdge(to: position)
        return self.faceNormal.cross(edge.direction)
    }
    
    @inlinable
    func contains(_ position: Position3n<Scalar>) -> Bool where Scalar: ExpressibleByFloatLiteral {
        let pa = self.p1
        let pb = self.p2
        let pc = self.p3
        
        let e10 = pb - pa
        let e20 = pc - pa
        let a = e10.dot(e10)
        let b = e10.dot(e20)
        let c = e20.dot(e20)
        let ac_bb = (a * c) - (b * b)
        let vp = Position3n(x: position.x - pa.x, y: position.y - pa.y, z: position.z - pa.z)
        let d = vp.dot(e10)
        let e = vp.dot(e20)
        let x = (d * c) - (e * b)
        let y = (e * a) - (d * b)
        let z = x + y - ac_bb
        
        return z < 0.0 && x >= 0.0 && y >= 0.0
    }
    
    @inlinable
    func nearestVertexIndex(to position: Position3n<Scalar>) -> Int {
        var vertexIndicesWithDistance: [(distance: Scalar, index: Int)] = [
            (self.p1.distance(from: position), 0),
            (self.p2.distance(from: position), 1),
            (self.p3.distance(from: position), 2)
        ]
        vertexIndicesWithDistance.sort(by: {$0.distance < $1.distance})
        return vertexIndicesWithDistance[0].index
    }
}

// MARK: Ray3nIntersectable
public extension Triangle3nSurfaceMath where Scalar: Ray3nIntersectable.ScalarType, Scalar: ExpressibleByFloatLiteral {
    func intersection(of ray: Ray3n<Scalar>) -> Position3n<Scalar>? {
        let e1: Position3n<Scalar> = p2 - p1
        let e2: Position3n<Scalar> = p3 - p1
        let h: Direction3n<Scalar> = ray.direction.cross(e2)
        let a: Scalar = e1.dot(h)
        guard (a > -0.00001 && a < 0.00001) == false else {return nil}
    
        let s: Direction3n<Scalar> = Direction3n<Scalar>(ray.origin - p1)
        let f: Scalar = 1.0 / a
        let u: Scalar = f * s.dot(h)
        guard (u < 0.0 || u > 1.0) == false else {return nil}
        
        let q: Direction3n<Scalar> = s.cross(e1)
        
        
        let v: Scalar = f * ray.direction.dot(q)
        guard (v < 0.0 || u + v > 1.0) == false else {return nil}
        
        // at this stage we can compute t to find out where
        // the intersection point is on the line
        let t: Scalar = f * e2.dot(q)
        if t > 0.00001 {
            return ray.origin.moved(t, toward: ray.direction)
        }
        return nil
    }
}
