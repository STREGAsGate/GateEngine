/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// An element array object formatted as Point primitives
public struct RawPoints: Codable, Equatable, Hashable {
    var positions: [Float]
    var colors: [Float]
    var indices: [UInt16]
    
    public var isEmpty: Bool {
        return indices.isEmpty
    }

    public init() {
        self.positions = []
        self.colors = []
        self.indices = []
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
        hasher.combine(colors)
        hasher.combine(indices)
    }
}

extension RawPoints {  // 3D
    public init(points: [Position3], color: Color) {
        var positions: [Float] = []
        positions.reserveCapacity(points.count * 3)
        var colors: [Float] = []
        colors.reserveCapacity(points.count * 4)
        var indices: [UInt16] = []
        indices.reserveCapacity(points.count)
        for point in points {
            positions.append(contentsOf: point.valuesArray())
            colors.append(contentsOf: color.valuesArray())
            indices.append(UInt16(indices.count))
        }
        self.positions = positions
        self.colors = colors
        self.indices = indices
    }

    /** Creates a Line primitive element array object from triangles.
    - parameter boxEdgesOnly when true only the outermost vertices are kept. If the triangles make up a cube the result would be the cube's edges as lines.
     */
    public init(pointCloudFrom rawGeometry: RawGeometry) {
        func getSimilarVertex(to vertext: Vertex, from vertices: [Vertex]) -> Array<Vertex>.Index? {
            return vertices.firstIndex(where: { $0.isSimilar(to: vertext) })
        }

        let inVertices = rawGeometry.vertices
        var outVertices: [Vertex] = []

        var positions: [Position3] = []
        var colors: [Color] = []
        var indices: [UInt16] = []

        var pairs: [(v1: Vertex, v2: Vertex)] = []

        for triangle in rawGeometry {
            func optimizedInsert(_ v1: Vertex) {
                if let index = getSimilarVertex(to: v1, from: outVertices) {
                    indices.append(UInt16(index))

                    let vertex = inVertices[index]
                    colors[index] += vertex.color
                } else {
                    insert(v1)
                }
            }
            func insert(_ v1: Vertex) {
                outVertices.append(v1)
                positions.append(v1.position)
                colors.append(v1.color)
                indices.append(UInt16(outVertices.count - 1))
            }
            func append(_ v1: Vertex, _ v2: Vertex) {
                func pairExists() -> Bool {
                    for pair in pairs {
                        if (pair.v1.isSimilar(to: v1) || pair.v1.isSimilar(to: v2))
                            && (pair.v2.isSimilar(to: v1) || pair.v2.isSimilar(to: v2))
                        {
                            return true
                        }
                    }
                    return false
                }
                if pairExists() == false {
                    optimizedInsert(v1)
                    optimizedInsert(v2)
                    pairs.append((v1, v2))
                }
            }

            insert(triangle.v1)
            insert(triangle.v2)

            insert(triangle.v2)
            insert(triangle.v3)

            insert(triangle.v3)
            insert(triangle.v1)
        }

        var _positions: [Float] = []
        for position in positions {
            _positions.append(contentsOf: position.valuesArray())
        }

        var _colors: [Float] = []
        for color in colors {
            _colors.append(contentsOf: [color.red, color.green, color.blue, color.alpha])
        }

        self.positions = _positions
        self.colors = _colors
        self.indices = indices
    }

    public mutating func insert(_ point: Position3, color: Color) {
        positions.append(contentsOf: point.valuesArray())
        colors.append(contentsOf: color.valuesArray())
        indices.append(UInt16(indices.count))
    }
}

extension RawPoints {  // 2D
    @inlinable
    public init(points: [Position2], color: Color) {
        let points = points.map({ Position3($0.x, $0.y, 0) })
        self.init(points: points, color: color)
    }

    @inlinable
    public mutating func insert(_ point: Position2, color: Color) {
        let point = Position3(point.x, point.y, 0)
        self.insert(point, color: color)
    }
}
