/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@propertyWrapper public struct RequiresState<Value> {
    #if DEBUG
    let state: ResourceState
    var _wrappedValue: Value
    var owner: OldResource! = nil

    public var wrappedValue: Value {
        get {
            assert(owner != nil, "Not configured!")
            assert(owner!.state == state, "The state must be \(state) before accessing this property")
            return _wrappedValue
        }
        set {
            _wrappedValue = newValue
        }
    }
    public init(wrappedValue: Value, _ state: ResourceState) {
        self.state = state
        self._wrappedValue = wrappedValue
    }
    mutating func configure(withOwner owner: OldResource) {
        self.owner = owner
    }
    #else

    public var wrappedValue: Value
    public init(wrappedValue: Value, _ state: ResourceState) {
        self.wrappedValue = wrappedValue
    }
    #endif
}

public protocol Resource: AnyObject, Identifiable, Equatable, Hashable {
    /** The current state of the resource. 
    It is a programming error to use a resource or access it's properties while it's state is anything other then `ready`.
    */
     @MainActor var state: ResourceState {get}
}



public enum ResourceState: Equatable {
    /// The resource isn't ready for use but may eventually become `ready` or `failed`.
    case pending
    /// The resource can be used and it's properties accessed.
    case ready
    /** The resource had an issue becoming `ready` and will never be usable. It should be discarded.
     The provided failure reason exists for debugging and does not guaranteed the same string for the same failure. Do not compare against it.
    - parameter reason: The rason the resource state is `failed`.
    */
    case failed(reason: String)
}

extension Resource {
    public static func ==(lhs: any Resource, rhs: any Resource) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

public class OldResource: Equatable, Hashable, Identifiable {
    /** The current state of the resource.
    It is a programming error to use a resource or access it's properties while it's state is anything other then `ready`.
    */
    public var state: ResourceState = .pending
}

extension OldResource {
    public static func ==(lhs: OldResource, rhs: OldResource) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
