/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct TimeScaleComponent: Component {
    public var scale: Float = 1

    public init() {}
    public static let componentID: ComponentID = ComponentID()
}
