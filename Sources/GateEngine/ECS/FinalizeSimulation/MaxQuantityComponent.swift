/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class MaxQuantityComponent: Component {
    /** Used to decide which entities to remove when over the max quantity.
     
     The oldest entities are removed first ensuring newnly created entities are not 
     immediatley removed.
     */
    let creationDate: Date = Date()
    
    /// An identifier used to match this, and other instances of this id, to a qunatity.
    public var quantityMatchID: Int = 0
    
    /**
     The maximum number of the quantityMatchID to allow.
     
     - note: Different maxQuantity values for the same quantityMatchID (from other entities) will result in only 
             one being chosen. You must keep all instances the same for consistent behavior.
     */
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
