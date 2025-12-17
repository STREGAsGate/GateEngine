/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// A three point polygon primitive.
public struct Triangle: Codable, Equatable, Hashable, Sendable {
    public var v1: Vertex
    public var v2: Vertex
    public var v3: Vertex

    public var center: Position3 {
        return (v1.position + v2.position + v3.position) / 3
    }

    public func flipped() -> Triangle {
        return Triangle(v1: v3, v2: v2, v3: v1, repairIfNeeded: false)
    }

    /// Vertices are expected to be counter-clockwise wound at all times
    public init(v1: Vertex, v2: Vertex, v3: Vertex, repairIfNeeded: Bool) {
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
        if repairIfNeeded {
            self.repairIfNeeded()
        }
    }

    /// Vertices are expected to be counter-clockwise wound at all times
    public init(p1: Position3, p2: Position3, p3: Position3) {
        self.v1 = Vertex(position: p1)
        self.v2 = Vertex(position: p2)
        self.v3 = Vertex(position: p3)
        self.repairIfNeeded()
    }

    /// The  face normal as computed from its positions. This is the face's actual direction an does not consider the vertex normal directions.
    public var faceNormal: Direction3 {
        return Direction3((v2.position - v1.position).cross(v3.position - v1.position)).normalized
    }
    /// The 3 positions counter-clockwise wound as an array
    public var positions: [Position3] {
        return [v1.position, v2.position, v3.position]
    }
    /// The 3 colors counter-clockwise wound as an array
    public var colors: [Color] {
        get {
            return [v1.color, v2.color, v3.color]
        }
        set {
            assert(newValue.count == 3, "1 Color is required for ever vertex (3)")
            v1.color = newValue[0]
            v2.color = newValue[1]
            v3.color = newValue[2]
        }
    }
    /// Positions as an element array
    public var vertices: [Float] {
        return [v1.position.x, v1.position.y, v1.position.z, v2.position.x, v2.position.y, v2.position.z, v3.position.x, v3.position.y, v3.position.z]
    }
    /// Texture coordinates as an element array
    public var uvsFromSet1: [TextureCoordinate] {
        return [v1.uv1, v2.uv1, v3.uv1]
    }
    /// Texture coordinates as an element array
    public var uvsFromSet2: [TextureCoordinate] {
        return [v1.uv2, v2.uv2, v3.uv2]
    }
    /// Vertex normals as an element array
    public var normals: [Direction3] {
        return [v1.normal, v2.normal, v3.normal]
    }
    /**
     Creates UVs, Normals, Tangents, and Bitangents if they are missing or incorrectly formatted.
     This function is called automatically by initializers where any of the elements are missing, such as init with positions only.
     It's not necessary to call this function onless you manipulate the tirnagle storage outside of an initializer.
     */
    public mutating func repairIfNeeded() {
        if v1.normal.length == 0 || v2.normal.length == 0 || v3.normal.length == 0 {
            //Replace normals with the face normal
            let faceNormal = self.faceNormal
            v1.normal = faceNormal
            v2.normal = faceNormal
            v3.normal = faceNormal
        }

        if v1.uv1 == .zero && v2.uv1 == .zero && v3.uv1 == .zero {
            //Assign some UVs, no way to know what they should be...
            v1.uv1 = TextureCoordinate(x: 0, y: 0)
            v2.uv1 = TextureCoordinate(x: 1, y: 1)
            v3.uv1 = TextureCoordinate(x: 0, y: 1)
        }

        if v1.uv2 == .zero && v2.uv2 == .zero && v3.uv2 == .zero {
            //Assign some UVs, no way to know what they should be...
            v1.uv2 = TextureCoordinate(x: 0, y: 0)
            v2.uv2 = TextureCoordinate(x: 1, y: 1)
            v3.uv2 = TextureCoordinate(x: 0, y: 1)
        }

        if v1.tangent.length == 0 || v2.tangent.length == 0 || v3.tangent.length == 0 {
            //Compute tangents
            let deltaPos1 = v2.position - v1.position
            let deltaPos2 = v3.position - v1.position

            let deltaUV1 = v2.uv1 - v1.uv1
            let deltaUV2 = v3.uv1 - v1.uv1

            let r = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x)
            let tangent = Direction3((deltaPos1 * deltaUV2.y - deltaPos2 * deltaUV1.y) * r)

            if tangent.isFinite {
                v1.tangent = tangent
                v2.tangent = tangent
                v3.tangent = tangent
            }
        }
    }

    public static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        return Triangle(v1: lhs.v1 * rhs, v2: lhs.v2 * rhs, v3: lhs.v3 * rhs, repairIfNeeded: false)
    }
}

extension Collection where Element == Triangle {
    /// A counter-clockwise wound vertex array from the triangles
    public var vertices: [Vertex] {
        var vertices: [Vertex] = []
        vertices.reserveCapacity(self.count * 3)
        for tri in self {
            vertices.append(tri.v1)
            vertices.append(tri.v2)
            vertices.append(tri.v3)
        }
        return vertices
    }
}

extension Triangle {
    /// - returns `true` if `position` is on `self`s plane and within it's edges.
    public func contains(_ position: Position3) -> Bool {
        let pa = v1.position
        let pb = v2.position
        let pc = v3.position

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
