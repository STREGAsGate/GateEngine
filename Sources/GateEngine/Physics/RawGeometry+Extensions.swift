/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension RawGeometry {
    public func generateCollisionTriangles<Attributes: CollisionAttributesGroup>(using attributesType: Attributes.Type = BasicCollisionAttributes.self) -> [CollisionTriangle] {
        var positions: [Position3] = []
        positions.reserveCapacity(indices.count * 3)
        var uvs: [[Position2]] = Array(repeating: [], count: uvSets.count)
        for uvSet in uvs.indices {
            uvs[uvSet].reserveCapacity(positions.capacity)
        }

        for vertexIndex in indices.indices {
            let index = Int(indices[vertexIndex])
            let start3 = index * 3
            let start2 = index * 2

            for uvIndex in 0 ..< uvSets.count {
                let uvSet = uvSets[uvIndex]
                uvs[uvIndex].append(Position2(uvSet[start2], uvSet[start2 + 1]))
            }

            positions.append(
                Position3(
                    self.positions[start3],
                    self.positions[start3 + 1],
                    self.positions[start3 + 2]
                )
            )
        }

        func attributeUVs(forTiangle index: Int) -> CollisionAttributeUVs {
            var triangleUVs: [CollisionAttributeUVs.TriangleUVs] = []
            for uvIndex in 0 ..< uvSets.count {
                triangleUVs.append(
                    CollisionAttributeUVs.TriangleUVs(
                        uv1: unsafeBitCast(uvs[uvIndex][index], to: TextureCoordinate.self),
                        uv2: unsafeBitCast(uvs[uvIndex][index + 1], to: TextureCoordinate.self),
                        uv3: unsafeBitCast(uvs[uvIndex][index + 2], to: TextureCoordinate.self)
                    )
                )
            }
            return CollisionAttributeUVs(uvSets: triangleUVs)
        }

        let stride = stride(from: 0, to: positions.count, by: 3)
        return stride.map({
            CollisionTriangle(
                p1: positions[$0 + 0],
                p2: positions[$0 + 1],
                p3: positions[$0 + 2],
                normal: nil,
                using: attributesType,
                with: attributeUVs(forTiangle: $0)
            )
        })
    }
}
