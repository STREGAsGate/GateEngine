/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// An element array object formatted as Line primitives
public struct RawLines: Sendable {
    var positions: [Float]
    var colors: [Float]
    var indices: [UInt16]

    public init() {
        positions = []
        colors = []
        indices = []
    }

    private var lineStartIndex: UInt16? = nil
    private var currentIndex: UInt16 {
        return UInt16(positions.count / 3)
    }

    /** Creates a Line primitive element array object from triangles.
    - parameter boxEdgesOnly when true only the outermost vertices are kept. If the triangles make up a cube the result would be the cube's edges as lines.
     */
    public init(wireframeFrom rawGeometry: RawGeometry) {
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

    public init(boundingBoxFrom rawGeoemtry: RawGeometry, color prefferedColor: Color? = nil) {
        func getSimilarVertex(to vertext: Vertex, from vertices: [Vertex]) -> Array<Vertex>.Index? {
            return vertices.firstIndex(where: { $0.isSimilar(to: vertext) })
        }

        let inVertices = rawGeoemtry.vertices
        var outVertices: [Vertex] = []

        var positions: [Position3] = []
        var colors: [Color] = []
        var indices: [UInt16] = []

        var pairs: [(v1: Vertex, v2: Vertex)] = []

        for triangle in rawGeoemtry {
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
            func pairIsABoxEdge(_ v1: Vertex, _ v2: Vertex) -> Bool {
                var count = 0
                let p1 = v1.position
                let p2 = v2.position
                if abs(p1.x - p2.x) < 0.001 {
                    count += 1
                }
                if abs(p1.y - p2.y) < 0.001 {
                    count += 1
                }
                if abs(p1.z - p2.z) < 0.001 {
                    count += 1
                }
                return count == 2
            }

            if pairIsABoxEdge(triangle.v1, triangle.v2) {
                append(triangle.v1, triangle.v2)
            }
            if pairIsABoxEdge(triangle.v2, triangle.v3) {
                append(triangle.v2, triangle.v3)
            }
            if pairIsABoxEdge(triangle.v3, triangle.v1) {
                append(triangle.v3, triangle.v1)
            }
        }

        var _positions: [Float] = []
        for position in positions {
            _positions.append(contentsOf: position.valuesArray())
        }

        var _colors: [Float] = []
        for color in colors {
            if let prefferedColor {
                _colors.append(contentsOf: [prefferedColor.red, prefferedColor.green, prefferedColor.blue, prefferedColor.alpha])
            }else{
                _colors.append(contentsOf: [color.red, color.green, color.blue, color.alpha])
            }
        }

        self.positions = _positions
        self.colors = _colors
        self.indices = indices
    }
}

extension RawLines {  // 2D
    @inlinable
    public mutating func insert(_ point: Position2, color: Color) {
        let point = Position3(point.x, point.y, 0)
        self.insert(point, color: color)
    }
}

extension RawLines {  // 3D
    public mutating func insert(_ point: Position3, color: Color) {
        let index = currentIndex
        if indices.count % 2 == 1 {
            positions.append(contentsOf: point.valuesArray())
            colors.append(contentsOf: color.valuesArray())
            indices.append(index)
        } else {
            if lineStartIndex == nil {
                self.lineStartIndex = index
            } else {
                indices.append(indices.last!)
            }

            positions.append(contentsOf: point.valuesArray())
            colors.append(contentsOf: color.valuesArray())
            indices.append(index)
        }
    }

    /// Add a segment to from the current point to the lines first point
    public mutating func closeLine() {
        guard indices.isEmpty == false else { return }
        guard let index = lineStartIndex else { return }
        indices.append(indices.last!)
        indices.append(index)
    }

    public mutating func endLine() {
        guard indices.isEmpty == false else { return }
        if indices.count % 2 == 1 {
            indices.removeLast()
        }
        lineStartIndex = nil
    }

    public mutating func becomePixelPerfect() {
        for index in stride(from: 0, through: positions.count - 1, by: 3) {
            for index in index ..< index + 1 {
                positions[index] = floor(positions[index]) + 0.5
            }
        }
    }
}

extension RawLines: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.indices.count == rhs.indices.count else { return false }
        return lhs.positions == rhs.positions && lhs.colors == rhs.colors
            && lhs.indices == rhs.indices
    }
}

extension RawLines: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
        hasher.combine(colors)
        hasher.combine(indices)
    }
}
