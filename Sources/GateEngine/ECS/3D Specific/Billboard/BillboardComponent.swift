/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct BillboardComponent: Component {
    public enum Style {
        /// Rotates to align with the plane on the camera
        case align
        /// Rotates to face toward the camera
        case lookAt(constraint: Quaternion.LookAtConstraint)
    }
    public var style: Style = .align
    
    public init() {}
    public static let componentID = ComponentID()
}
