/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class TimedDeathComponent: Component {
    /// The duration until the entitiy with this component is removed (in seconds)
    public var timeRemaining: Float = 1
    
    public init() {}
    public static let componentID: ComponentID = ComponentID()
}
