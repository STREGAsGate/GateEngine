/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// A three point polygon primitive.
public struct Triangle: Codable, Equatable, Hashable {
    private var storage: [Vertex]

    public var v1: Vertex {
        get {
            return storage[0]
        }
        set {
            storage[0] = newValue
        }
    }
    public var v2: Vertex {
        get {
            return storage[1]
        }
        set {
            storage[1] = newValue
        }
    }
    public var v3: Vertex {
        get {
            return storage[2]
        }
        set {
            storage[2] = newValue
        }
    }

    public var center: Position3 {
        return (v1.position + v2.position + v3.position) / 3
    }

    public func flipped() -> Triangle {
        return Triangle(v1: v3, v2: v2, v3: v1, repairIfNeeded: false)
    }

    /// Vertices are expected to be counter-clockwise wound at all times
    public init(v1: Vertex, v2: Vertex, v3: Vertex, repairIfNeeded: Bool) {
        self.storage = [v1, v2, v3]
        if repairIfNeeded {
            self.repairIfNeeded()
        }
    }

    /// Vertices are expected to be counter-clockwise wound at all times
    public init(p1: Position3, p2: Position3, p3: Position3) {
        self.storage = [Vertex(p1), Vertex(p2), Vertex(p3)]
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
        return [v1.color, v2.color, v3.color]
    }
    /// Positions as an element array
    public var vertices: [Float] {
        return [v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z]
    }
    /// Texture coordinates as an element array
    public var uvsFromSet1: [Float] {
        return [v1.u1, v1.v1, v2.u1, v2.v1, v3.u1, v3.v1]
    }
    /// Texture coordinates as an element array
    public var uvsFromSet2: [Float] {
        return [v1.u2, v1.v2, v2.u2, v2.v2, v3.u2, v3.v2]
    }
    /// Vertex normals as an element array
    public var normals: [Float] {
        return [v1.nx, v1.ny, v1.nz, v2.nx, v2.ny, v2.nz, v3.nx, v3.ny, v3.nz]
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

        if v1.texturePosition1 == .zero && v2.texturePosition1 == .zero
            && v3.texturePosition1 == .zero
        {
            //Assign some UVs, no way to know what they should be...
            v1.texturePosition1 = Position2(x: 0, y: 0)
            v2.texturePosition1 = Position2(x: 1, y: 1)
            v3.texturePosition1 = Position2(x: 0, y: 1)
        }

        if v1.texturePosition2 == .zero && v2.texturePosition2 == .zero
            && v3.texturePosition2 == .zero
        {
            //Assign some UVs, no way to know what they should be...
            v1.texturePosition2 = Position2(x: 0, y: 0)
            v2.texturePosition2 = Position2(x: 1, y: 1)
            v3.texturePosition2 = Position2(x: 0, y: 1)
        }

        if v1.tangent.length == 0 || v2.tangent.length == 0 || v3.tangent.length == 0 {
            //Compute tangents
            let deltaPos1 = v2.position - v1.position
            let deltaPos2 = v3.position - v1.position

            let deltaUV1 = v2.texturePosition1 - v1.texturePosition1
            let deltaUV2 = v3.texturePosition1 - v1.texturePosition1

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

extension Array where Element == Triangle {
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
