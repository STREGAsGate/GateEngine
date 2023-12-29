/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the transition of subresources between different usages.
public struct D3DResourceTransitionBarrier {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_TRANSITION_BARRIER
    @usableFromInline
    internal var rawValue: RawValue

    /// A pointer to the ID3D12Resource object that represents the resource used in the transition.
    @inlinable @inline(__always)
    public var resource: D3DResource? {
        get {
            return D3DResource(winSDKPointer: rawValue.pResource)
        }
        set {
            rawValue.pResource = newValue?.performFatally(as: D3DResource.RawValue.self) {$0}
        }
    }

    /// The index of the subresource for the transition. Use the D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES flag ( 0xffffffff ), nil in swift, to transition all subresources in a resource at the same time.
    @inlinable @inline(__always)
    public var subresourceIndex: UInt32? {
        get {
            return rawValue.Subresource == WinSDK.D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES ? nil : rawValue.Subresource
        }
        set {
            if let newValue = newValue {
                rawValue.Subresource = newValue
            }else{
                rawValue.Subresource = WinSDK.D3D12_RESOURCE_BARRIER_ALL_SUBRESOURCES
            }
        }
    }

    /// The "before" usages of the subresources, as a bitwise-OR'd combination of D3D12_RESOURCE_STATES enumeration constants.
    @inlinable @inline(__always)
    public var stateBefore: D3DResourceStates {
        get {
            return D3DResourceStates(rawValue.StateBefore)
        }
        set {
            rawValue.StateBefore = newValue.rawType
        }
    }

    /// The "after" usages of the subresources, as a bitwise-OR'd combination of D3D12_RESOURCE_STATES enumeration constants.
    @inlinable @inline(__always)
    public var stateAfter: D3DResourceStates {
        get {
            return D3DResourceStates(rawValue.StateAfter)
        }
        set {
            rawValue.StateAfter = newValue.rawType
        }
    }

    /// Describes the transition of subresources between different usages.
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

@available(*, deprecated, renamed: "D3DResourceTransitionBarrier")
public typealias D3D12_RESOURCE_TRANSITION_BARRIER = D3DResourceTransitionBarrier

#endif
