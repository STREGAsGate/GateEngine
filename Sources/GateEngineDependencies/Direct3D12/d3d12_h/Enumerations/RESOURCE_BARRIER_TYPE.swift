/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies a type of resource barrier (transition in resource use) description.
public enum D3DResourceBarrierType {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_BARRIER_TYPE

    ///	A transition barrier that indicates a transition of a set of subresources between different usages. The caller must specify the before and after usages of the subresources.
    case transition
    ///	An aliasing barrier that indicates a transition between usages of 2 different resources that have mappings into the same tile pool. The caller can specify both the before and the after resource. Note that one or both resources can be NULL, which indicates that any tiled resource could cause aliasing.
    case aliasing
    ///	An unordered access view (UAV) barrier that indicates all UAV accesses (reads or writes) to a particular resource must complete before any future UAV accesses (read or write) can begin.
    case unorderedAccessView

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .transition:
            return WinSDK.D3D12_RESOURCE_BARRIER_TYPE_TRANSITION
        case .aliasing:
            return WinSDK.D3D12_RESOURCE_BARRIER_TYPE_ALIASING
        case .unorderedAccessView:
            return WinSDK.D3D12_RESOURCE_BARRIER_TYPE_UAV
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_RESOURCE_BARRIER_TYPE_TRANSITION:
            self = .transition
        case WinSDK.D3D12_RESOURCE_BARRIER_TYPE_ALIASING:
            self = .aliasing
        case WinSDK.D3D12_RESOURCE_BARRIER_TYPE_UAV:
            self = .unorderedAccessView
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceBarrierType")
public typealias D3D12_RESOURCE_BARRIER_TYPE = D3DResourceBarrierType


@available(*, deprecated, renamed: "D3DResourceBarrierType.transition")
public let D3D12_RESOURCE_BARRIER_TYPE_TRANSITION = D3DResourceBarrierType.transition

@available(*, deprecated, renamed: "D3DResourceBarrierType.aliasing")
public let D3D12_RESOURCE_BARRIER_TYPE_ALIASING = D3DResourceBarrierType.aliasing

@available(*, deprecated, renamed: "D3DResourceBarrierType.unorderedAccessView")
public let D3D12_RESOURCE_BARRIER_TYPE_UAV = D3DResourceBarrierType.unorderedAccessView

#endif
