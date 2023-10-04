/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class MaxQuantityComponent: Component {
    let creationDate: Date = Date()
    
    public var quantityMatchID: Int = 0
    
    public var maxQuantity: Int = 10
    
    public init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension MaxQuantityComponent: Equatable {
    public static func ==(lhs: MaxQuantityComponent, rhs: MaxQuantityComponent) -> Bool {
        return lhs.quantityMatchID == rhs.quantityMatchID
    }
}

extension MaxQuantityComponent: Comparable {
    public static func <(lhs: MaxQuantityComponent, rhs: MaxQuantityComponent) -> Bool {
        return lhs.creationDate.timeIntervalSinceNow > rhs.creationDate.timeIntervalSinceNow
    }
}
