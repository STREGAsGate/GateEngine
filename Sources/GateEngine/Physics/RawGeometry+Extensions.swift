/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension RawGeometry {
    public func generateCollisionTriangles() -> [CollisionTriangle] {
        var positions: [Position3] = []
        positions.reserveCapacity(indices.count * 3)
        var uvs: [[Position2]] = Array(repeating: [], count: uvSets.count)
        for uvSet in uvs.indices {
            uvs[uvSet].reserveCapacity(positions.capacity)
        }
        var colors: [Color] = []
        colors.reserveCapacity(positions.capacity)
        let colorComponents: Int = self.colors.count / (self.positions.count / 3)

        for vertexIndex in indices.indices {
            let index = Int(indices[vertexIndex])
            let start3 = index * 3
            let start2 = index * 2
            let start4 = index * 4

            for uvIndex in 0 ..< uvSets.count {
                let uvSet = uvSets[uvIndex]
                uvs[uvIndex].append(Position2(uvSet[start2], uvSet[start2 + 1]))
            }

            if colorComponents == 3 {
                colors.append(
                    Color(
                        self.colors[start3],
                        self.colors[start3 + 1],
                        self.colors[start3 + 2]
                    )
                )
            } else {
                colors.append(
                    Color(
                        self.colors[start4],
                        self.colors[start4 + 1],
                        self.colors[start4 + 2],
                        self.colors[start4 + 3]
                    )
                )
            }

            positions.append(
                Position3(
                    self.positions[start3],
                    self.positions[start3 + 1],
                    self.positions[start3 + 2]
                )
            )
        }

        func attributeUVs(forTiangle index: Int) -> [Position2] {
            var _uvs: [Position2] = []
            for uvIndex in 0 ..< uvSets.count {
                _uvs.append(uvs[uvIndex][index])
            }
            return _uvs
        }

        let stride = stride(from: 0, to: positions.count, by: 3)
        return stride.map({
            CollisionTriangle(
                positions: [positions[$0 + 0], positions[$0 + 1], positions[$0 + 2]],
                colors: [colors[$0 + 0], colors[$0 + 1], colors[$0 + 2]],
                attributeUV: attributeUVs(forTiangle: $0)
            )
        })
    }
}
