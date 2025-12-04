/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension RawGeometry {
    public func generateCollisionTriangles<Attributes: CollisionAttributesGroup>(using attributesType: Attributes.Type = BasicCollisionAttributes.self) -> [CollisionTriangle] {
        return self.map({CollisionTriangle($0, using: attributesType)})
    }
}
