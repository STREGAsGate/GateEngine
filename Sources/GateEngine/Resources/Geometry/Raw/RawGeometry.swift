/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// An element array object formatted as triangle primitives
public struct RawGeometry: Codable, Sendable, Equatable, Hashable {
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
        return stride(from: 0, to: positions.count, by: 3).map { index in
            let start3 = index
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
            vertices[vertexIndex].uv1 = TextureCoordinate(uvSet1[start2], uvSet1[start2 + 1])
            vertices[vertexIndex].uv2 = TextureCoordinate(uvSet2[start2], uvSet2[start2 + 1])
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
        return RawGeometry(triangles: self.generateTriangles().map({ $0.flipped() }))
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
        
        var colors: [Float]! = colors
        if colors == nil {
            colors = Array(repeating: 0.5, count: indices.count * 4)
            for index in stride(from: 3, to: colors.count, by: 4) {
                colors[index] = 1
            }
        }
        self.colors = colors
        self.indices = indices
    }
    
    public enum Optimization {
        /// Keeps every vertex as is, including duplicates.
        /// This option is required for skins as the indices are pre computed
        case dontOptimize
        /// Compares each vertex using equality. If equal,  they are considered the same and will be folded into a single vertex.
        case byEquality
        /// Compares the vertex components. If the difference between components is within `threshold` they are considered the same and will be folded into a single vertex.
        case byThreshold(_ threshold: Float)
        /// Checks the result of the provided comparator. If true, the vertices will be folded into a single vertex. The vertex kept is always lhs.
        case usingComparator(_ comparator: (_ lhs: Vertex, _ rhs: Vertex) -> Bool)
    }

    /// Create `Geometry` from counter-clockwise wound `Triangles` and optionanly attempts to optimize the arrays by distance.
    /// Optimization is extremely slow and may result in loss of data. It should be used to pre-optimize assets and should not be used at runtime.
    public init(triangles: [Triangle], optimization: Optimization = .dontOptimize) {
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

        var optimizedIndicies: [UInt16]
        switch optimization {
        case .dontOptimize:
            assert(inVertices.count < UInt16.max, "Exceeded the maximum number of indices (\(inVertices.count)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
            optimizedIndicies = Array(0 ..< UInt16(inVertices.count))
        case .byEquality:
            optimizedIndicies = Array(repeating: 0, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                assert(index <= UInt16.max, "Exceeded the maximum number of indices (\(index)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
                let vertex = inVertices[index]
                if let similarIndex = inVertices.firstIndex(where: {$0 == vertex}) {
                    optimizedIndicies[index] = UInt16(similarIndex)
                }else{
                    optimizedIndicies[index] = UInt16(index)
                }
            }
        case .byThreshold(let threshold):
            optimizedIndicies = Array(repeating: 0, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                assert(index <= UInt16.max, "Exceeded the maximum number of indices (\(index)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
                let vertex = inVertices[index]
                if let similarIndex = inVertices.firstIndex(where: {$0.isSimilar(to: vertex, threshold: threshold)}) {
                    optimizedIndicies[index] = UInt16(similarIndex)
                }else{
                    optimizedIndicies[index] = UInt16(index)
                }
            }
        case .usingComparator(let comparator):
            optimizedIndicies = Array(repeating: 0, count: inVertices.count)
            for index in 0 ..< inVertices.count {
                assert(index <= UInt16.max, "Exceeded the maximum number of indices (\(index)\\\(UInt16.max)) for a single geometry. This geometry needs to be spilt up.")
                let vertex = inVertices[index]
                if let similarIndex = inVertices.firstIndex(where: { comparator($0, vertex)}) {
                    optimizedIndicies[index] = UInt16(similarIndex)
                }else{
                    optimizedIndicies[index] = UInt16(index)
                }
            }
        }
        
        // The next real indices index
        var nextIndex = 0
        if case .dontOptimize = optimization {
            for vertex in inVertices {
                self.positions.append(contentsOf: vertex.storage[0 ..< 3])
                self.normals.append(contentsOf: vertex.storage[3 ..< 6])
                uvSet1.append(contentsOf: vertex.storage[6 ..< 8])
                uvSet2.append(contentsOf: vertex.storage[8 ..< 10])
                self.tangents.append(contentsOf: vertex.storage[10 ..< 13])
                self.colors.append(contentsOf: vertex.storage[13 ..< 17])

                self.indices.append(UInt16(nextIndex))
                // Increment the next real indicies index
                nextIndex += 1
            }
        }else{
            // Store the optimized vertex index using the actual indicies index
            // so we can look up the real index for repeated verticies
            var indicesMap: [UInt16:UInt16] = [:]
            indicesMap.reserveCapacity(inVertices.count)
            for vertexIndexInt in inVertices.indices {
                // Obtain the optimized vertexIndex for this vertex
                let vertexIndex: UInt16 = optimizedIndicies[vertexIndexInt]
                
                // Check our map to see if this vertex was already added
                if let index = indicesMap[vertexIndex] {
                    // Add the repeated index to the indices and continue to the next
                    self.indices.append(index)
                    continue
                }
                
                let vertex = inVertices[vertexIndexInt]
                self.positions.append(contentsOf: vertex.storage[0 ..< 3])
                self.normals.append(contentsOf: vertex.storage[3 ..< 6])
                uvSet1.append(contentsOf: vertex.storage[6 ..< 8])
                uvSet2.append(contentsOf: vertex.storage[8 ..< 10])
                self.tangents.append(contentsOf: vertex.storage[10 ..< 13])
                self.colors.append(contentsOf: vertex.storage[13 ..< 17])
                
                let index = UInt16(nextIndex)
                self.indices.append(index)
                // Update the map
                indicesMap[vertexIndex] = index
                // Increment the next real indicies index
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
        self.init(triangles: triangles)
    }

    /// Creates a new `Geometry` by merging multiple geometry. This is usful for loading files that store geometry speretly base don material if you intend to only use a single material for them all.
    public init(geometries: [RawGeometry]) {
        var triangles: [Triangle] = []
        for geometry in geometries {
            triangles.append(contentsOf: geometry.generateTriangles())
        }
        self.init(triangles: triangles)
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
