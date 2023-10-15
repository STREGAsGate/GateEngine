/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Component {
    init()
    nonisolated static var componentID: ComponentID { get }
    
    nonisolated static func systemThatProcessesThisComponent() -> System.Type?
}

public protocol ResourceConstrainedComponent: Component {
    @MainActor var resourcesState: ResourceState {get set}
    @MainActor var resources: [any Resource] {get}
}

extension Component {
    public nonisolated static func systemThatProcessesThisComponent() -> System.Type? {
        return nil
    }
}

public struct ComponentID: Equatable, Hashable {
    static let idGenerator = IDGenerator<Int>(startValue: 0)
    @usableFromInline
    internal let value: Int
    public init() {
        self.value = Self.idGenerator.generateID()
    }
}
