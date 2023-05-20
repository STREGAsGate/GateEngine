/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

public final class Physics2DComponent: Component {

    public var velocity: Direction2 = .zero

    public init() {}

    public static let componentID: ComponentID = ComponentID()
}
