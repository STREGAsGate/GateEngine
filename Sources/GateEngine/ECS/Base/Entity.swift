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
    internal var components: [ComponentID : Component]

    public init(name: String? = nil, priority: Priority = .normal, components: [Component]? = nil) {
        self.name = name
        self.priority = priority
        self.components = Dictionary(minimumCapacity: components?.count ?? 5)
        if let components = components {
            for component in components {
                self.insert(component)
            }
        }
    }
    
    public convenience init(name: String? = nil, priority: Priority = .normal, components: [Component.Type]) {
        self.init(name: name, priority: priority, components: components.map({$0.init()}))
    }
}

//MARK: Component Management
public extension Entity {
    /// - returns true if the entity has the component
    @inlinable @inline(__always)
    func hasComponent(_ type: Component.Type) -> Bool {
        return components.keys.contains(type.componentID)
    }

    /// - returns The component, addind it to the entity if necessary
    @inlinable @inline(__always)
    subscript<T: Component>(_ type: T.Type) -> T {
        get {
            if self.hasComponent(type) == false {
                self.insert(type.init(), replacingExisting: true)
            }
            return components[type.componentID] as! T
        }
        set {
            self.insert(newValue)
        }
    }

    /// Obtain an existing component by it's ID.
    /// - returns The existing component or nil if it's not present.
    @inlinable @inline(__always)
    func component<T: Component>(ofType type: T.Type) -> T? {
        if let existing = components[type.componentID] as? T {
            return existing
        }
        return nil
    }
    
    /// Obtain a component by type. Useful for Component subclasses.
    @inlinable @inline(__always)
    func component<T>(as type: T.Type) -> T? where T: AnyObject {
        if let existing: T = components.first(where: {$0.value is T})?.value as? T {
            return existing
        }
        return nil
    }
    
    /// - returns true if an existing component was replaced
    @inlinable @inline(__always)
    @discardableResult
    func insert(_ component: Component, replacingExisting: Bool = true) -> Bool {
        let key = type(of: component).componentID
        let exists = components.keys.contains(key)
        guard (replacingExisting && exists) || exists == false else {return false}
        components[key] = component
        return true
    }
    
    ///Adds or replaces a component with option configuration closure
    @inlinable @inline(__always)
    func insert<T: Component>(_ type: T.Type, replaceExisting: Bool = false, _ config: ((_ component: inout T)->())? = nil) {
        if self.hasComponent(type) == false || replaceExisting {
            self.insert(type.init(), replacingExisting: true)
        }
        config?(&self[T.self])
    }
    
    /// Allows changing a component, addind it first if needed.
    @inlinable @inline(__always)
    func configure<T: Component, ResultType>(_ type: T.Type, _ config: (_ component: inout T) -> ResultType) -> ResultType {
        return config(&self[T.self])
    }
    
    /// Allows changing a component with async, creating the component if needed.
    /// The component is added to the Entity after the async operation is complete.
    @inlinable @inline(__always)
    func configure<T: Component>(_ type: T.Type, _ config: @escaping (_ component: inout T) async throws -> Void) {
        Task(priority: .medium) {
            var component = self.component(ofType: type) ?? T.init()
            
            try await config(&component)
            
            let immutableComponent = component
            Task {@MainActor in
                self[T.self] = immutableComponent
            }
        }
    }
    
    /// - returns The removed componen or nil if no component was found.
    @inlinable @inline(__always)
    @discardableResult
    func remove<T: Component>(_ type: T.Type) -> T? {
        return components.removeValue(forKey: type.componentID) as? T
    }
}

public extension Entity {
    enum Priority: Int {
        case high = 100
        case normal = 0
        case low = -100
    }
}

extension Entity: Hashable {
    @_transparent
    public static func ==(lhs: Entity, rhs: Entity) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
