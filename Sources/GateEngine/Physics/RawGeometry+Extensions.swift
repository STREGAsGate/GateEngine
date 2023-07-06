/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension RawGeometry {
    func generateCollisionTrianges() -> [CollisionTriangle] {
        var positions: [Position3] = []
        var uvs: [[Position2]] = Array(repeating: [], count: uvSets.count)
        var colors: [Color] = []
        var colorComponents: Int = 0
        if self.colors.count / 3 == indices.count {
            colorComponents = 3
        }else if self.colors.count / 4 == indices.count {
            colorComponents = 4
        }
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
                colors.append(Color(self.colors[start3],
                                    self.colors[start3 + 1],
                                    self.colors[start3 + 2]))
            }else if colorComponents == 4 {
                colors.append(Color(self.colors[start4],
                                    self.colors[start4 + 1],
                                    self.colors[start4 + 2],
                                    self.colors[start4 + 3]))
            }else{
                colors.append(.gray)
            }
            
            positions.append(Position3(self.positions[start3],
                                       self.positions[start3 + 1],
                                       self.positions[start3 + 2]))
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
            CollisionTriangle(positions: [positions[$0 + 0], positions[$0 + 1], positions[$0 + 2]],
                              colors: [colors[$0 + 0], colors[$0 + 1], colors[$0 + 2]],
                              attributeUV: attributeUVs(forTiangle: $0))
        })
    }
}
