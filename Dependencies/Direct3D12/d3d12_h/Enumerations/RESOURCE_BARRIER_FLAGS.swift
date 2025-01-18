/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Flags for setting split resource barriers
public struct D3DResourceBarrierFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_RESOURCE_BARRIER_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_RESOURCE_BARRIER_FLAGS.RawValue
    public let rawValue: RawValue 
    //Use an empty collection `[]` to represent none in Swift.
    ///// No flags.
    //public static let none = D3DResourceBarrierFlags(rawValue: WinSDK.D3D12_RESOURCE_BARRIER_FLAG_NONE.rawValue)

    /// This starts a barrier transition in a new state, putting a resource in a temporary no-access condition.
    public static let beginOnly = D3DResourceBarrierFlags(rawValue: WinSDK.D3D12_RESOURCE_BARRIER_FLAG_BEGIN_ONLY.rawValue)

    /// This barrier completes a transition, setting a new state and restoring active access to a resource.
    public static let endOnly = D3DResourceBarrierFlags(rawValue: WinSDK.D3D12_RESOURCE_BARRIER_FLAG_END_ONLY.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init(_ rawType: RawType) {
        self.rawValue = rawType.rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceBarrierFlags")
public typealias D3D12_RESOURCE_BARRIER_FLAGS = D3DResourceBarrierFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_RESOURCE_BARRIER_FLAG_NONE: D3DResourceBarrierFlags = []

@available(*, deprecated, renamed: "D3DResourceBarrierFlags.beginOnly")
public let D3D12_RESOURCE_BARRIER_FLAG_BEGIN_ONLY = D3DResourceBarrierFlags.beginOnly

@available(*, deprecated, renamed: "D3DResourceBarrierFlags.endOnly")
public let D3D12_RESOURCE_BARRIER_FLAG_END_ONLY = D3DResourceBarrierFlags.endOnly

#endif
