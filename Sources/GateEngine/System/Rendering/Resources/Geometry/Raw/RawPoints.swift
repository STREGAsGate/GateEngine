/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

/// An element array object formatted as Point primitives
public struct RawPoints: Codable, Equatable, Hashable {
    var positions: [Float]
    var colors: [Float]
    var indicies: [UInt16]

    public init() {
        self.positions = []
        self.colors = []
        self.indicies = []
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
        hasher.combine(colors)
        hasher.combine(indicies)
    }
}

public extension RawPoints {// 3D
    init(points: [Position3], color: Color) {
        var positions: [Float] = []
        positions.reserveCapacity(points.count * 3)
        var colors: [Float] = []
        colors.reserveCapacity(points.count * 4)
        var indicies: [UInt16] = []
        indicies.reserveCapacity(points.count)
        for point in points {
            positions.append(contentsOf: point.valuesArray())
            colors.append(contentsOf: color.valuesArray())
            indicies.append(UInt16(indicies.count))
        }
        self.positions = positions
        self.colors = colors
        self.indicies = indicies
    }

    /** Creates a Line primitve element array object from triangles.
    - parameter boxEdgesOnly when true only the outermost vertices are kept. If the trinagles make up a cube the result would be the cube's edges as lines.
     */
    init(pointCloudFrom triangles: [Triangle]) {
        func getSimilarVertex(to vertext: Vertex, from vertices: [Vertex]) -> Array<Vertex>.Index? {
            return vertices.firstIndex(where: {$0.isSimilar(to: vertext)})
        }

        let inVertices: [Vertex] = triangles.vertices
        var outVerticies: [Vertex] = []

        var positions: [Position3] = []
        var colors: [Color] = []
        var indicies: [UInt16] = []

        var pairs: [(v1: Vertex, v2: Vertex)] = []

        for triangle in triangles {
            func optimizedInsert(_ v1: Vertex) {
                if let index = getSimilarVertex(to: v1, from: outVerticies) {
                    indicies.append(UInt16(index))

                    let vertex = inVertices[index]
                    colors[index] += vertex.color
                }else{
                    insert(v1)
                }
            }
            func insert(_ v1: Vertex) {
                outVerticies.append(v1)
                positions.append(v1.position)
                colors.append(v1.color)
                indicies.append(UInt16(outVerticies.count - 1))
            }
            func append(_ v1: Vertex, _ v2: Vertex) {
                func pairExists() -> Bool {
                    for pair in pairs {
                        if (pair.v1.isSimilar(to: v1) || pair.v1.isSimilar(to: v2)) && (pair.v2.isSimilar(to: v1) || pair.v2.isSimilar(to: v2)) {
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
        self.indicies = indicies
    }

    mutating func insert(_ point: Position3, color: Color) {
        positions.append(contentsOf: point.valuesArray())
        colors.append(contentsOf: color.valuesArray())
        indicies.append(UInt16(indicies.count))
    }
}

public extension RawPoints {// 2D
    @_transparent
    init(points: [Position2], color: Color) {
        let points = points.map({Position3($0.x, $0.y, 0)})
        self.init(points: points, color: color)
    }

    @_transparent
    mutating func insert(_ point: Position2, color: Color) {
        let point = Position3(point.x, point.y, 0)
        self.insert(point, color: color)
    }
}
