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
    internal var components: [ComponentID: any Component]

    public init(
        name: String? = nil,
        priority: Priority = .normal,
        components: [any Component]? = nil
    ) {
        self.name = name
        self.priority = priority
        self.components = Dictionary(minimumCapacity: components?.count ?? 5)
        if let components = components {
            for component in components {
                self.insert(component)
            }
        }
    }

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
    /// - returns true if the entity has the component
    @inlinable @inline(__always)
    public func hasComponent(_ type: any Component.Type) -> Bool {
        return components.keys.contains(type.componentID)
    }

    /// - returns The component, addind it to the entity if necessary
    @inlinable @inline(__always)
    public subscript<T: Component>(_ type: T.Type) -> T {
        get {
            assert(self.hasComponent(type), "Component \"\(type)\" is not a member of this entity.")
            return components[type.componentID] as! T
        }
        set {
            self.insert(newValue)
        }
    }

    /// Obtain an existing component by it's ID.
    /// - returns The existing component or nil if it's not present.
    @inlinable @inline(__always)
    public func component<T: Component>(ofType type: T.Type) -> T? {
        return components[type.componentID] as? T
    }

    /// Obtain a component by type. Useful for Component subclasses.
    @inlinable @inline(__always)
    public func component<T>(as type: T.Type) -> T? where T: AnyObject {
        return components.first(where: { $0.value is T })?.value as? T
    }

    /// - returns true if an existing component was replaced
    @discardableResult @inlinable @inline(__always)
    public func insert<T: Component>(_ component: T, replacingExisting: Bool = true) -> Bool {
        let key = type(of: component).componentID
        let exists = components.keys.contains(key)
        guard (replacingExisting && exists) || exists == false else { return false }
        components[key] = component
        return true
    }

    ///Adds or replaces a component with option configuration closure
    @inlinable @inline(__always)
    public func insert<T: Component>(
        _ type: T.Type,
        replaceExisting: Bool = false,
        _ config: ((_ component: inout T) -> Void)? = nil
    ) {
        if self.hasComponent(type) == false || replaceExisting {
            self.insert(type.init(), replacingExisting: true)
        }
        config?(&self[T.self])
    }
    
    /// Allows changing an existing component
    @inlinable @inline(__always)
    public func modify<T: Component, ResultType>(
        _ type: T.Type,
        _ config: @escaping (_ component: inout T) -> ResultType
    ) -> ResultType {
        return config(&self[T.self])
    }

    /// Allows changing a component, addind it first if needed.
    @inlinable @inline(__always)
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
    @inlinable @inline(__always)
    @discardableResult
    public func remove<T: Component>(_ type: T.Type) -> T? {
        return components.removeValue(forKey: type.componentID) as? T
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
