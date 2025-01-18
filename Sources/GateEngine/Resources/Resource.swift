/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
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
            assert(
                owner!.state == state,
                "The state must be \(state) before accessing this property"
            )
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

public protocol Resource: AnyObject, Equatable, Hashable {
    /** The current state of the resource.
    It is a programming error to use a resource or access it's properties while it's state is anything other then `ready`.
    */
    @MainActor var state: ResourceState { get }
    @MainActor var isReady: Bool {get}
    
    @MainActor var cacheHint: CacheHint {get set}
}

extension Resource {
    @MainActor
    @_transparent
    public var isReady: Bool { self.state == .ready }
}

internal protocol _Resource: Resource {
    @MainActor var cache: any ResourceCache {get}
        
    @MainActor var defaultCacheHint: CacheHint {get set}
    @MainActor var cachHintIsDefault: Bool {get}
}

extension _Resource {
    @MainActor
    public var state: ResourceState {
        @_transparent get { self.cache.state }
        set { self.cache.state = newValue }
    }
    
    @MainActor
    public var cacheHint: CacheHint {
        get {
            let cache = self.cache
            return cache.cacheHint ?? cache.defaultCacheHint
        }
        set {
            self.cache.cacheHint = newValue
        }
    }
    
    @MainActor
    var defaultCacheHint: CacheHint {
        get {
            let cache = self.cache
            return cache.defaultCacheHint
        }
        set {
            self.cache.defaultCacheHint = newValue
        }
    }
    
    @MainActor
    @_transparent
    var cachHintIsDefault: Bool {
        return cache.cacheHint == nil
    }
}

public enum ResourceState: Equatable {
    /// The resource isn't ready for use but may eventually become `ready` or `failed`.
    case pending
    /// The resource can be used and it's properties accessed.
    case ready
    /** The resource had an issue becoming `ready` and will never be usable. It should be discarded.
     The provided failure reason exists for debugging and does not guaranteed the same string for the same failure. Do not compare against it.
    - parameter error: The error thrown that caused the resource state to be `failed`.
    */
    case failed(error: GateEngineError)
}

public class OldResource: Equatable, Hashable, Identifiable {
    /** The current state of the resource.
    It is a programming error to use a resource or access it's properties while it's state is anything other then `ready`.
    */
    public var state: ResourceState = .pending
}

extension OldResource {
    public static func == (lhs: OldResource, rhs: OldResource) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
