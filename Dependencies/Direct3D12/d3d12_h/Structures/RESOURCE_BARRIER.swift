/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a resource barrier (transition in resource use).
public struct D3DResourceBarrier {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_BARRIER
    @usableFromInline
    internal var rawValue: RawValue

    /// A D3D12_RESOURCE_BARRIER_TYPE-typed value that specifies the type of resource barrier. This member determines which type to use in the union below.
    @inlinable @inline(__always)
    public var `type`: D3DResourceBarrierType {
        get {
            return D3DResourceBarrierType(rawValue.Type)
        }
        set {
            rawValue.Type = newValue.rawValue
        }
    }

    /// Specifies a D3D12_RESOURCE_BARRIER_FLAGS enumeration constant such as for "begin only" or "end only".
    @inlinable @inline(__always)
    public var flags: D3DResourceBarrierFlags {
        get {
            return D3DResourceBarrierFlags(rawValue.Flags)
        }
        set {
            rawValue.Flags = newValue.rawType
        }
    }

    /// A D3D12_RESOURCE_TRANSITION_BARRIER structure that describes the transition of subresources between different usages. Members specify the before and after usages of the subresources.
    @inlinable @inline(__always)
    public var transition: D3DResourceTransitionBarrier {
        get {
            return D3DResourceTransitionBarrier(rawValue.Transition)
        }
        set {
            rawValue.Transition = newValue.rawValue
        }
    }

    /// A D3D12_RESOURCE_ALIASING_BARRIERstructure that describes the transition between usages of two different resources that have mappings into the same heap.
    @inlinable @inline(__always)
    public var aliasing: D3DResourceAliasingBarrier {
        get {
            return D3DResourceAliasingBarrier(rawValue.Aliasing)
        }
        set {
            rawValue.Aliasing = newValue.rawValue
        }
    }

    /// A D3D12_RESOURCE_UAV_BARRIERstructure that describes a resource in which all UAV accesses (reads or writes) must complete before any future UAV accesses (read or write) can begin.
    @inlinable @inline(__always)
    public var unorderedAccessView: D3DResourceUnorderedAccessViewBarrier {
        get {
            return D3DResourceUnorderedAccessViewBarrier(rawValue.UAV)
        }
        set {
            rawValue.UAV = newValue.rawValue
        }
    }

    /** Describes a resource barrier (transition in resource use).
    - parameter type: A D3D12_RESOURCE_BARRIER_TYPE-typed value that specifies the type of resource barrier. This member determines which type to use in the union below.
    - parameter flags: Specifies a D3D12_RESOURCE_BARRIER_FLAGS enumeration constant such as for "begin only" or "end only".
    - parameter transition: A D3D12_RESOURCE_TRANSITION_BARRIER structure that describes the transition of subresources between different usages. Members specify the before and after usages of the subresources.
    - parameter aliasing: A D3D12_RESOURCE_ALIASING_BARRIERstructure that describes the transition between usages of two different resources that have mappings into the same heap.
    - parameter unorderedAccessView: A D3D12_RESOURCE_UAV_BARRIERstructure that describes a resource in which all UAV accesses (reads or writes) must complete before any future UAV accesses (read or write) can begin.
    */
    @inlinable @inline(__always)
    public init(type: D3DResourceBarrierType,
                flags: D3DResourceBarrierFlags,
                transition: D3DResourceTransitionBarrier,
                aliasing: D3DResourceAliasingBarrier,
                unorderedAccessView: D3DResourceUnorderedAccessViewBarrier) {
        self.rawValue = RawValue()
        self.type = type
        self.flags = flags
        self.transition = transition
        self.aliasing = aliasing
        self.unorderedAccessView = unorderedAccessView
    }

    /// Describes a resource barrier (transition in resource use).
    @inlinable @inline(__always)
    public init() {
        self.rawValue = RawValue()
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceBarrier")
public typealias D3D12_RESOURCE_BARRIER = D3DResourceBarrier

#endif
