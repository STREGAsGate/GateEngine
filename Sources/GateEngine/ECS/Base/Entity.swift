/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Entity: Identifiable {
    public var name: String? = nil
    public let priority: Priority

    @usableFromInline
    internal var componentIDs: Set<Int> = .init(minimumCapacity: 8)
    @usableFromInline
    internal var componentBank: ContiguousArray<(any Component)?> = .init(repeating: nil, count: 8)

    public init(
        name: String? = nil,
        priority: Priority = .normal,
        components: [any Component]? = nil
    ) {
        self.name = name
        self.priority = priority
        if let components = components {
            for component in components {
                self.insert(component)
            }
        }
    }
}

extension Entity {
    @_transparent
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
    @usableFromInline @_transparent
    func getComponent(at index: Int) -> (any Component)? {
        return componentBank[index]
    }
    
    @usableFromInline @_transparent
    internal func hasComponent(at index: Int) -> Bool {
        return componentIDs.contains(index)
    }
    
    @usableFromInline @_transparent
    internal func expandComponentBankIfNeeded(forIndex index: Int) {
        if componentBank.count - 1 < index {
            componentBank.reserveCapacity(index)
            while componentBank.count - 1 < index {
                componentBank.append(nil)
            }
        }
    }
    
    /// - returns true if the entity has the component
    @_transparent
    public func hasComponent(_ type: any Component.Type) -> Bool {
        return hasComponent(at: type.componentID.value)
    }

    /// - returns The component, addind it to the entity if necessary
    public subscript<T: Component>(_ type: T.Type) -> T {
        @_transparent get {
            let componentID = type.componentID.value
            #if DEBUG
            Log.assert(hasComponent(at: componentID), "Component \"\(type)\" is not a member of this entity.")
            #endif
            return getComponent(at: componentID) as! T
        }
        @_transparent set {
            self.insert(newValue)
        }
    }

    /// Obtain an existing component by it's ID.
    /// - returns The existing component or nil if it's not present.
    @_transparent
    public func component<T: Component>(ofType type: T.Type) -> T? {
        let componentID = type.componentID.value
        guard hasComponent(at: componentID) else {return nil}
        return getComponent(at: componentID) as? T
    }
    
    @inline(__always)
    public func insert<T: Component>(_ component: T) {
        let index = T.self.componentID.value
        self.expandComponentBankIfNeeded(forIndex: index)
        self.componentBank[index] = component
        self.componentIDs.insert(index)
    }

    /// - returns true if an existing component was replaced
    @discardableResult
    public func insert<T: Component>(_ component: T, replacingExisting: Bool) -> Bool {
        let componentID = T.self.componentID.value
        let exists = hasComponent(at: componentID)
        guard (replacingExisting && exists) || exists == false else { return false }
        self.insert(component)
        return true
    }

    ///Adds or replaces a component with option configuration closure
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
    @_transparent
    public func modify<T: Component, ResultType>(
        _ type: T.Type,
        _ config: @escaping (_ component: inout T) -> ResultType
    ) -> ResultType {
        return config(&self[T.self])
    }

    /// Allows changing a component, addind it first if needed.
    public func configure<T: Component, ResultType>(
        _ type: T.Type,
        _ config: @escaping (_ component: inout T) async -> ResultType
    ) async -> ResultType {
        if self.hasComponent(type) == false {
            self.insert(type.init())
        }
        return await config(&self[T.self])
    }

    /// - returns The removed component or nil if no component was found.
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
    @_transparent
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
