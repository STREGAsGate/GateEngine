/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class Collider2DComponent: Component {
    public var primitive: AxisAlignedBoundingBox2D! = nil
    public var complex: Collider2D? = nil
    
    public init() {}

    public static let componentID: ComponentID = ComponentID()
}
