/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class TimedDeathComponent: Component {
    public var timeRemaining: Float = 1
    
    public init() {}
    public static let componentID: ComponentID = ComponentID()
}
