/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class QuadtreeComponent: Component {
    public var quadtree: Quadtree! = nil
    
    public init() {}

    public static let componentID: ComponentID = ComponentID()
}
