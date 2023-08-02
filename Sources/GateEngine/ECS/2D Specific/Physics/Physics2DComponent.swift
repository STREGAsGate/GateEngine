/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Physics2DComponent: Component {

    public var velocity: Direction2 = .zero

    public init() {}

    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    var physics2DComponent: Physics2DComponent {
        return self[Physics2DComponent.self]
    }
}
