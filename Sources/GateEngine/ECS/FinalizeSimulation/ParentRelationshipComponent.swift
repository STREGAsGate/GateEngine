/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class ParentRelationshipComponent: Component {
    public var parent: ObjectIdentifier? = nil
    public var relativeTransform: Transform3? = nil
    public var options: Options = [.relativePosition, .relativeRotation, .relativeScale]
    
    public struct Options: OptionSet, Sendable {
        public typealias RawValue = UInt
        public let rawValue: RawValue
        
        public static let relativePosition = Options(rawValue: 1 << 1)
        public static let relativeRotation = Options(rawValue: 1 << 2)
        public static let relativeScale = Options(rawValue: 1 << 3)
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
    
    public init(_ entity: Entity) {
        self.parent = entity.id
    }
    public init() {}
    public static let componentID: ComponentID = ComponentID()
}
