/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension CollisionTriangle {
    init<Attributes: CollisionAttributesGroup>(
        p1: Position3, p2: Position3, p3: Position3, normal: Direction3?,
        using attributesType: Attributes.Type = BasicCollisionAttributes.self,
        with attributeUVs: CollisionAttributeUVs
    ) {
        self.init(
            p1: p1,
            p2: p2,
            p3: p3,
            normal: normal,
            attributes: Attributes(parsingUVs: attributeUVs)
        )
    }
    
    init<Attributes: CollisionAttributesGroup>(_ triangle: Triangle, using attributesType: Attributes.Type = BasicCollisionAttributes.self) {
        let collisionAttributeUVs = CollisionAttributeUVs(uvSets: [
            .init(uv1: triangle.v1.uv1, uv2: triangle.v2.uv1, uv3: triangle.v3.uv1),
            .init(uv1: triangle.v1.uv2, uv2: triangle.v2.uv2, uv3: triangle.v3.uv2),
        ])
        self.init(
            p1: triangle.v1.position,
            p2: triangle.v2.position,
            p3: triangle.v3.position,
            normal: triangle.faceNormal,
            attributes: Attributes(parsingUVs: collisionAttributeUVs)
        )
    }
}
