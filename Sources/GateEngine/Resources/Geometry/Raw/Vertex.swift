/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

//TODO: Subscripts index by 0..<2 for all sub types would be nice

/// A 3D point and associated values. This is used to construct `Triangle`s.
public struct Vertex: Codable, Equatable, Hashable, Sendable {
    /// The x component of the position
    public var position: Position3
    
    /// The x component of the normal
    public var normal: Direction3
    
    /// The tangent. Used to compute tangent space normals of a `Triangle`.
    public var tangent: Direction3
    
    /// The TextureCoordinate for UV set #1 (index 0)
    public var uv1: TextureCoordinate
    
    /// The TextureCoordinate for UV set #2 (index 1)
    public var uv2: TextureCoordinate
    
    /// The vertex color.
    public var color: Color

    public init(
        position: Position3 = .zero,
        normal: Direction3 = .zero,
        tangent: Direction3 = .zero,
        uvSet1: TextureCoordinate = .zero,
        uvSet2: TextureCoordinate = .zero,
        color: Color = .gray
    ) {
        self.position = position
        self.normal = normal
        self.tangent = tangent
        self.uv1 = uvSet1
        self.uv2 = uvSet2
        self.color = color
    }

    public init(
        px: Float,
        py: Float,
        pz: Float,
        nx: Float = 0,
        ny: Float = 0,
        nz: Float = 0,
        tanX: Float = 0,
        tanY: Float = 0,
        tanZ: Float = 0,
        tu1: Float = 0,
        tv1: Float = 0,
        tu2: Float = 0,
        tv2: Float = 0,
        cr: Float = 0.5,
        cg: Float = 0.5,
        cb: Float = 0.5,
        ca: Float = 1
    ) {
        self.init(
            position: Position3(px, py, pz),
            normal: Direction3(nx, ny, nz),
            tangent: Direction3(tanX, tanY, tanZ),
            uvSet1: TextureCoordinate(tu1, tv1),
            uvSet2: TextureCoordinate(tu2, tv2),
            color: Color(cr, cg, cb, ca)
        )
    }

    internal func isPositionSimilar(to vertex: Vertex, threshold: Float = 0.001) -> Bool {
        guard threshold > 0 else { return self == vertex }
        guard self.position.distance(from: vertex.position) <= threshold else { return false }
        return true
    }

    /// - returns: `true` if `self` is within `threshold` of `v`.
    internal func isSimilar(to vertex: Vertex, threshold: Float = 0.001) -> Bool {
        guard isPositionSimilar(to: vertex, threshold: threshold) else {return false}
        guard self.normal.angle(to: vertex.normal) <= Radians(threshold) else { return false }
        guard self.uv1.distance(from: vertex.uv1) <= threshold else {return false}
        return true
    }

    public static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        var copy = lhs
        copy.position = copy.position * rhs
        copy.normal = copy.normal.rotated(by: rhs.rotation.conjugate)
        copy.tangent = copy.tangent.rotated(by: rhs.rotation.conjugate)
        return copy
    }
}
extension Vertex {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.position == rhs.position else {return false}
        guard lhs.normal == rhs.normal else {return false}
        guard lhs.tangent == rhs.tangent else {return false}
        guard lhs.uv1 == rhs.uv1 else {return false}
        guard lhs.uv2 == rhs.uv2 else {return false}
        guard lhs.color == rhs.color else {return false}
        return true
    }
    
    public static func *= (lhs: inout Self, rhs: Float) {
        lhs = lhs * rhs
    }
    public static func * (lhs: Self, rhs: Float) -> Self {
        return Vertex(position: lhs.position * rhs, normal: lhs.normal * rhs, tangent: lhs.tangent * rhs, uvSet1: lhs.uv1, uvSet2: lhs.uv2, color: lhs.color)
    }

    public static func /= (lhs: inout Self, rhs: Float) {
        lhs = lhs * rhs
    }
    public static func / (lhs: Self, rhs: Float) -> Self {
        return Vertex(position: lhs.position / rhs, normal: lhs.normal / rhs, tangent: lhs.tangent / rhs, uvSet1: lhs.uv1, uvSet2: lhs.uv2, color: lhs.color)
    }
}

extension Array where Element == Vertex {
    /// An array of triangles constructed from the vertex array
    public var triangles: [Triangle] {
        return stride(from: 0, to: count, by: 3).map({
            let slice = Array(self[$0 ..< Swift.min($0 + 3, count)])
            return Triangle(v1: slice[0], v2: slice[1], v3: slice[2], repairIfNeeded: false)
        })
    }
}
