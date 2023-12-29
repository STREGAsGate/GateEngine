/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies what to clear from the depth stencil view.
public struct D3DClearFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_CLEAR_FLAGS
    public typealias RawValue = WinSDK.D3D12_CLEAR_FLAGS.RawValue
    public let rawValue: RawValue

    /// Indicates the depth buffer should be cleared.
    public static let depth = D3DClearFlags(rawValue: WinSDK.D3D12_CLEAR_FLAG_DEPTH.rawValue)

    /// Indicates the stencil buffer should be cleared.
    public static let stencil = D3DClearFlags(rawValue: WinSDK.D3D12_CLEAR_FLAG_STENCIL.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DClearFlags")
public typealias D3D12_CLEAR_FLAGS = D3DClearFlags


@available(*, deprecated, renamed: "D3DClearFlags.depth")
public let D3D12_CLEAR_FLAG_DEPTH = D3DClearFlags.depth

@available(*, deprecated, renamed: "D3DClearFlags.stencil")
public let D3D12_CLEAR_FLAG_STENCIL = D3DClearFlags.stencil

#endif
