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
    static let idGenerator = IDGenerator<UInt>()
    let value: UInt
    public init() {
        self.value = Self.idGenerator.generateID()
    }
}
