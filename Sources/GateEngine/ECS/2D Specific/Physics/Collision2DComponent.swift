/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class Collision2DComponent: Component {
    public var primitive: AxisAlignedBoundingBox2D! = nil
    public var complex: Collider2D? = nil
    
    public init() {}

    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    var collision2DComponent: Collision2DComponent {
        return self[Collision2DComponent.self]
    }
}
