/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the transition between usages of two different resources that have mappings into the same heap.
public struct D3DResourceAliasingBarrier {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_ALIASING_BARRIER
    @usableFromInline
    internal var rawValue: RawValue

    /// A pointer to the ID3D12Resource object that represents the before resource used in the transition.
    @inlinable @inline(__always)
    public var before: D3DResource? {
        get {
            return D3DResource(winSDKPointer: rawValue.pResourceBefore)
        }
        set {
            rawValue.pResourceBefore = newValue?.performFatally(as: D3DResource.RawValue.self) {$0}
        }
    }

    /// A pointer to the ID3D12Resource object that represents the after resource used in the transition.
    @inlinable @inline(__always)
    public var after: D3DResource? {
        get {
            return D3DResource(winSDKPointer: rawValue.pResourceAfter)
        }
        set {
            rawValue.pResourceAfter = newValue?.performFatally(as: D3DResource.RawValue.self) {$0}
        }
    }

    @inlinable @inline(__always)
    public init(before: D3DResource?, after: D3DResource?) {
        let before = before?.performFatally(as: D3DResource.RawValue.self) {$0}
        let after = after?.performFatally(as: D3DResource.RawValue.self) {$0}
        self.rawValue = RawValue(pResourceBefore: before, pResourceAfter: after)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceAliasingBarrier")
public typealias D3D12_RESOURCE_ALIASING_BARRIER = D3DResourceAliasingBarrier

#endif
