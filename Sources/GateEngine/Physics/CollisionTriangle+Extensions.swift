//
//  CollisionTriangle+Extensions.swift
//  GateEngine
//
//  Created by Dustin Collins on 4/8/25.
//

extension CollisionTriangle {
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
        self.init(
            p1: triangle.v1.position,
            p2: triangle.v2.position,
            p3: triangle.v3.position,
            normal: triangle.faceNormal,
            attributes: Attributes(parsingUVs: triangle.collisionAttributeUVs)
        )
    }
}

extension Triangle {
    var collisionAttributeUVs: CollisionAttributeUVs {
        return CollisionAttributeUVs(uvSets: [
            .init(uv1: v1.uv1, uv2: v2.uv1, uv3: v3.uv1),
            .init(uv1: v1.uv2, uv2: v2.uv2, uv3: v3.uv2),
        ])
    }
}
