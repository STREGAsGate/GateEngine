/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Component {
    init()
    nonisolated static var componentID: ComponentID { get }
}

public struct ComponentID: Equatable, Hashable {
    static let idGenerator = IDGenerator<Int>(startValue: 0)
    @usableFromInline
    internal let value: Int
    public init() {
        self.value = Self.idGenerator.generateID()
    }
}
