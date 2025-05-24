/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Entity: Identifiable {
    /// A string to identify this Entity for the purpose of convenience and debugging.
    ///
    /// It is more performant and much safer to store the `entity.id`
    ///- warning: `name` is not required to be unique. Giving many entites the same name will result in undefined look up behavior. It is strongly recommended to find entites based on their components or the `id` value.
    public var name: String? = nil
    public let priority: Priority

    @usableFromInline
    internal var componentIDs: Set<Int> = []
    @usableFromInline
    internal var componentBank: ContiguousArray<(any Component)?> = []

    public init(
        name: String? = nil,
        priority: Priority = .normal,
        components: [any Component]? = nil
    ) {
        self.name = name
        self.priority = priority
        
        let minimumCapacity = Swift.max(components?.count ?? 8, 8)
        self.componentIDs.reserveCapacity(minimumCapacity)
        self.componentBank.reserveCapacity(minimumCapacity)
        
        if let components = components {
            for component in components {
                self.insert(component)
            }
        }
    }
}

extension Entity {
    @inlinable
    public convenience init(
        name: String? = nil,
        priority: Priority = .normal,
        components: [any Component.Type]
    ) {
        self.init(name: name, priority: priority, components: components.map({ $0.init() }))
    }
}

//MARK: Component Management
extension Entity {
    @usableFromInline
    func getComponent(at index: Int) -> (any Component)? {
        return self.componentBank[index]
    }
    
    @usableFromInline
    internal func hasComponent(at index: Int) -> Bool {
        return self.componentIDs.contains(index)
    }
    
    /// - returns true if the entity has the component
    @inlinable
    public func hasComponent(_ type: any Component.Type) -> Bool {
        return self.hasComponent(at: type.componentID.value)
    }

    /// - returns The component, addind it to the entity if necessary
    @inlinable
    public subscript<T: Component>(_ type: T.Type) -> T {
        get {
            let componentID = type.componentID.value
            #if DEBUG
            Log.assert(hasComponent(at: componentID), "Component \"\(type)\" is not a member of this entity.")
            #endif
            return self.getComponent(at: componentID) as! T
        }
        set {
            self.insert(newValue)
        }
    }

    /// Obtain an existing component by it's ID.
    /// - returns The existing component or nil if it's not present.
    @inlinable
    public func component<T: Component>(ofType type: T.Type) -> T? {
        let componentID = type.componentID.value
        guard self.hasComponent(at: componentID) else {return nil}
        return self.getComponent(at: componentID) as? T
    }
    
    /// Obtain an existing component by it's ID.
    /// - returns The existing component or nil if it's not present.
    @MainActor
    @inlinable
    public func component<T: ResourceConstrainedComponent>(ofType type: T.Type) -> T? {
        let componentID = type.componentID.value
        guard self.hasComponent(at: componentID) else {return nil}
        guard let component = self.getComponent(at: componentID) as? T else {return nil}
        switch component.resourcesState {
        case .pending:
            if let notReady = component.resources.first(where: {$0.state != .ready}) {
                self[T.self].resourcesState = notReady.state
                return nil
            }
            self[T.self].resourcesState = .ready
            return component
        case .ready:
            return component
        case .failed(error: _):
            return nil
        }
    }
    
    @inlinable
    public func insert<T: Component>(_ component: T) {
        let index = T.self.componentID.value
        
        // expand component bank if needed
        if self.componentBank.count - 1 < index {
            self.componentBank.reserveCapacity(index)
            while componentBank.count - 1 < index {
                componentBank.append(nil)
            }
        }
        
        self.componentBank[index] = component
        self.componentIDs.insert(index)
    }

    /// - returns true if an existing component was replaced
    @inlinable
    @discardableResult
    public func insert<T: Component>(_ component: T, replacingExisting: Bool) -> Bool {
        let componentID = T.self.componentID.value
        let exists = self.hasComponent(at: componentID)
        guard (replacingExisting && exists) || exists == false else { return false }
        self.insert(component)
        return true
    }

    ///Adds or replaces a component with option configuration closure
    @inlinable
    public func insert<T: Component>(
        _ type: T.Type,
        replaceExisting: Bool = false,
        _ config: ((_ component: inout T) -> Void)? = nil
    ) {
        if self.hasComponent(type) == false || replaceExisting {
            self.insert(type.init())
        }
        config?(&self[T.self])
    }
    
    /// Allows changing an existing component
    @inlinable
    @discardableResult
    public func modify<T: Component, ResultType>(
        _ type: T.Type,
        _ config: @escaping (_ component: inout T) -> ResultType
    ) -> ResultType {
        return config(&self[T.self])
    }

    /// Allows changing a component, addind it first if needed.
    @discardableResult
    @inlinable
    public func configure<T: Component, ResultType>(
        _ type: T.Type,
        _ config: (_ component: inout T) async -> ResultType
    ) async -> ResultType {
        if self.hasComponent(type) == false {
            self.insert(type.init())
        }
        return await config(&self[T.self])
    }
    
    /// Allows changing a component, addind it first if needed.
    @discardableResult
    @inlinable
    public func configure<T: Component, ResultType>(
        _ type: T.Type,
        _ config: (_ component: inout T) -> ResultType
    ) -> ResultType {
        if self.hasComponent(type) == false {
            self.insert(type.init())
        }
        return config(&self[T.self])
    }

    /// - returns The removed component or nil if no component was found.
    @inlinable
    @discardableResult
    public func remove<T: Component>(_ type: T.Type) -> T? {
        if let value = component(ofType: type) {
            let index = type.componentID.value
            self.componentBank[index] = nil
            self.componentIDs.remove(index)
            return value
        }
        return nil
    }
}

extension Entity {
    public enum Priority: Int {
        case high = 100
        case normal = 0
        case low = -100
    }
}

extension Entity: Hashable {
    @inlinable
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
    }
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
