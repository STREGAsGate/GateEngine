/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies depth-stencil view options.
public struct D3DDepthStencilViewFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_DSV_FLAGS
    public typealias RawValue = WinSDK.D3D12_DSV_FLAGS.RawValue
    public let rawValue: RawValue

    //Use an empty collection `[]` to represent none in Swift.
    ///// Indicates a default view.
    //public static let none = D3DDepthStencilViewFlags(rawValue: WinSDK.D3D12_DSV_FLAG_NONE.rawValue)

    ///	Indicates that depth values are read only.
    public static let readOnlyDepth = D3DDepthStencilViewFlags(rawValue: WinSDK.D3D12_DSV_FLAG_READ_ONLY_DEPTH.rawValue)

    ///	Indicates that stencil values are read only.
    public static let readOnlyStencil = D3DDepthStencilViewFlags(rawValue: WinSDK.D3D12_DSV_FLAG_READ_ONLY_STENCIL.rawValue)

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

@available(*, deprecated, renamed: "D3DDepthStencilViewFlags")
public typealias D3D12_DSV_FLAGS = D3DDepthStencilViewFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_DSV_FLAG_NONE: D3DDepthStencilViewFlags = []

@available(*, deprecated, renamed: "D3DDepthStencilViewFlags.readOnlyDepth")
public let D3D12_DSV_FLAG_READ_ONLY_DEPTH = D3DDepthStencilViewFlags.readOnlyDepth

@available(*, deprecated, renamed: "D3DDepthStencilViewFlags.readOnlyStencil")
public let D3D12_DSV_FLAG_READ_ONLY_STENCIL = D3DDepthStencilViewFlags.readOnlyStencil

#endif
