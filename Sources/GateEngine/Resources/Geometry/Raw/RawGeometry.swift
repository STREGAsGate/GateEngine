/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// An element array object formatted as triangle primitives
public struct RawGeometry: Codable, Equatable, Hashable {
    public enum Attribute: Hashable {
        case position(_ index: UInt8)
        case textureCoordinate(_ index: UInt8)
        case normal(_ index: UInt8)
        case tangent(_ index: UInt8)
        case color(_ index: UInt8)
    }

    public var positions: [Float]
    public var uvSets: [[Float]]
    public var uvSet1: [Float] {
        get {
            return uvSets[0]
        }
        set {
            uvSets[0] = newValue
        }
    }
    public var uvSet2: [Float] {
        get {
            return uvSets[1]
        }
        set {
            uvSets[1] = newValue
        }
    }
    public var normals: [Float]
    public var tangents: [Float]
    public var colors: [Float]
    public var indices: [UInt16]

    func uvSet(_ index: Int) -> [Float]? {
        guard index < uvSets.count else { return nil }
        return uvSets[index]
    }

    /// Creates an array of `Position3`s, representing Vertex positions, from the element array storage.
    public func generatePositions(transformedBy matrix: Matrix4x4? = nil) -> [Position3] {
        return stride(from: 0, to: indices.count, by: 3).map { index in
            let start3 = index * 3
            var p = Position3(positions[start3], positions[start3 + 1], positions[start3 + 2])
            if let matrix = matrix {
                p = p * matrix
            }
            return p
        }
    }

    /// Creates an array of `Vertex`s from the element array storage.
    public func generateVertices() -> [Vertex] {
        var vertices: [Vertex] = Array(repeating: Vertex(), count: indices.count)
        for vertexIndex in indices.indices {
            let index = Int(indices[vertexIndex])
            let start3 = index * 3
            let start2 = index * 2
            let start4 = index * 4

            vertices[vertexIndex].position = Position3(
                positions[start3],
                positions[start3 + 1],
                positions[start3 + 2]
            )
            vertices[vertexIndex].texturePosition1 = Position2(uvSet1[start2], uvSet1[start2 + 1])
            vertices[vertexIndex].texturePosition2 = Position2(uvSet2[start2], uvSet2[start2 + 1])
            vertices[vertexIndex].normal = Direction3(
                normals[start3],
                normals[start3 + 1],
                normals[start3 + 2]
            )
            vertices[vertexIndex].tangent = Direction3(
                tangents[start3],
                tangents[start3 + 1],
                tangents[start3 + 2]
            )
            vertices[vertexIndex].color = Color(
                colors[start4],
                colors[start4 + 1],
                colors[start4 + 2],
                colors[start4 + 3]
            )
        }
        return vertices
    }

    /// Creates an array of `Triangle`s from the element array storage
    public func generateTriangles() -> [Triangle] {
        let vertices: [Vertex] = generateVertices()
        return stride(from: 0, to: vertices.count, by: 3).map({
            Triangle(
                v1: vertices[$0 + 0],
                v2: vertices[$0 + 1],
                v3: vertices[$0 + 2],
                repairIfNeeded: false
            )
        })
    }

    public func flipped() -> RawGeometry {
        return RawGeometry(
            triangles: self.generateTriangles().map({ $0.flipped() }),
            optimizeDistance: nil
        )
    }

    /// Creates a new `Geometry` from element array values.
    public init(
        positions: [Float],
        uvSets: [[Float]],
        normals: [Float]?,
        tangents: [Float]?,
        colors: [Float]?,
        indices: [UInt16]
    ) {
        self.positions = positions
        self.uvSets = uvSets
        if self.uvSets.count < 2 {
            let filler = [Float](repeating: 0, count: indices.count * 2)
            for _ in uvSets.count ..< 2 {
                self.uvSets.append(filler)
            }
        }
        self.normals = normals ?? Array(repeating: 0, count: indices.count * 3)
        self.tangents = tangents ?? Array(repeating: 0, count: indices.count * 3)
        self.colors = colors ?? Array(repeating: 0.5, count: indices.count * 4)
        self.indices = indices
    }

    /// Create `Geometry` from counter-clockwise wound `Triangles` and optionanly attempts to optimize the arrays by distance.
    /// Optimization is extremely slow and may result in loss of data. It should be used to pre-optimize assets and should not be used at runtime.
    public init(triangles: [Triangle], optimizeDistance: Float? = nil) {
        assert(triangles.isEmpty == false)

        self.positions = []
        positions.reserveCapacity(triangles.count * 3 * 3)
        self.normals = []
        normals.reserveCapacity(triangles.count * 3 * 3)
        var uvSet1: [Float] = []
        uvSet1.reserveCapacity(triangles.count * 2 * 3)
        var uvSet2: [Float] = []
        uvSet2.reserveCapacity(triangles.count * 2 * 3)
        self.tangents = []
        tangents.reserveCapacity(triangles.count * 3 * 3)
        self.colors = []
        colors.reserveCapacity(triangles.count * 3 * 4)
        self.indices = []
        indices.reserveCapacity(triangles.count * 3)

        let inVertices: [Vertex] = triangles.vertices

        var similars: [UInt16?]? = nil
        if let threshold = optimizeDistance {
            similars = Array(repeating: nil, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                let vertex = inVertices[index]
                if let similarIndex = Array(inVertices[..<index]).firstIndex(where: {
                    $0.isSimilar(to: vertex, threshold: threshold)
                }) {
                    similars?[index] = UInt16(similarIndex)
                }
            }
        }

        var nextIndex = 0
        for vertexIndex in inVertices.indices {
            if let similarIndex = similars?[vertexIndex] {
                indices.append(similarIndex)
            } else {
                let vertex = inVertices[vertexIndex]
                positions.append(contentsOf: vertex.storage[0 ..< 3])
                normals.append(contentsOf: vertex.storage[3 ..< 6])
                uvSet1.append(contentsOf: vertex.storage[6 ..< 8])
                uvSet2.append(contentsOf: vertex.storage[8 ..< 10])
                tangents.append(contentsOf: vertex.storage[10 ..< 13])
                colors.append(contentsOf: vertex.storage[13 ..< 17])
                indices.append(UInt16(nextIndex))
                nextIndex += 1
            }
        }
        self.uvSets = [uvSet1, uvSet2]
    }

    public init(byCombiningTrianglesFrom geometries: [RawGeometry]) {
        var triangles: [Triangle] = []
        for geom in geometries {
            triangles.append(contentsOf: geom.generateTriangles())
        }
        self.init(triangles: triangles, optimizeDistance: nil)
    }

    /// Creates a new `Geometry` by merging multiple geometry. This is usful for loading files that store geometry speretly base don material if you intend to only use a single material for them all.
    public init(geometries: [RawGeometry]) {
        @_transparent
        func sum(_ array: [Int]) -> Int {
            var val = 0
            for i in array { val += i }
            return val
        }
        self.positions = []
        self.positions.reserveCapacity(sum(geometries.map({ $0.positions.count })))
        self.uvSets = []
        self.normals = []
        self.normals.reserveCapacity(sum(geometries.map({ $0.normals.count })))
        self.tangents = []
        self.tangents.reserveCapacity(sum(geometries.map({ $0.tangents.count })))
        self.colors = []
        self.colors.reserveCapacity(sum(geometries.map({ $0.colors.count })))
        self.indices = []
        self.indices.reserveCapacity(sum(geometries.map({ $0.indices.count })))

        for geometry in geometries {
            self.positions.append(contentsOf: geometry.positions)
            for uvSetIndex in 0 ..< geometry.uvSets.count {
                if self.uvSets.indices.contains(uvSetIndex) == false {
                    self.uvSets.append(geometry.uvSets[uvSetIndex])
                } else {
                    self.uvSets[uvSetIndex].append(contentsOf: geometry.uvSets[uvSetIndex])
                }
            }
            self.normals.append(contentsOf: geometry.normals)
            self.tangents.append(contentsOf: geometry.tangents)
            self.colors.append(contentsOf: geometry.colors)
            let max = self.indices.max() ?? 0
            self.indices.append(contentsOf: geometry.indices.map({ $0 + max }))
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
        hasher.combine(normals)
        hasher.combine(uvSet1)
        hasher.combine(uvSet2)
        hasher.combine(tangents)
        hasher.combine(colors)
        hasher.combine(indices)
    }

    public static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        let triangles = lhs.generateTriangles().map({ $0 * rhs })
        return RawGeometry(triangles: triangles)
    }
}

extension Array where Element == RawGeometry {
    public func generateVertices() -> [Vertex] {
        var vertices: [Vertex] = []
        for geometry in self {
            vertices.append(contentsOf: geometry.generateVertices())
        }
        return vertices
    }
}
