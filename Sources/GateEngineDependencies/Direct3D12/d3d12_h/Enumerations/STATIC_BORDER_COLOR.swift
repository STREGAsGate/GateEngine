/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the border color for a static sampler.
public enum D3DStaticBorderColor {
    public typealias RawValue = WinSDK.D3D12_STATIC_BORDER_COLOR

    ///	Indicates black, with the alpha component as fully transparent.
    case transparentBlack
    ///	Indicates black, with the alpha component as fully opaque.
    case opaqueBlack
    ///	Indicates white, with the alpha component as fully opaque.
    case opaqueWhite

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .transparentBlack:
            return WinSDK.D3D12_STATIC_BORDER_COLOR_TRANSPARENT_BLACK
        case .opaqueBlack:
            return WinSDK.D3D12_STATIC_BORDER_COLOR_OPAQUE_BLACK
        case .opaqueWhite:
            return WinSDK.D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_STATIC_BORDER_COLOR_TRANSPARENT_BLACK:
            self = .transparentBlack
        case WinSDK.D3D12_STATIC_BORDER_COLOR_OPAQUE_BLACK:
            self = .opaqueBlack
        case WinSDK.D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE:
            self = .opaqueWhite
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DStaticBorderColor")
public typealias D3D12_STATIC_BORDER_COLOR = D3DStaticBorderColor


@available(*, deprecated, renamed: "D3DStaticBorderColor.transparentBlack")
public let D3D12_STATIC_BORDER_COLOR_TRANSPARENT_BLACK = D3DStaticBorderColor.transparentBlack

@available(*, deprecated, renamed: "D3DStaticBorderColor.opaqueBlack")
public let D3D12_STATIC_BORDER_COLOR_OPAQUE_BLACK = D3DStaticBorderColor.opaqueBlack

@available(*, deprecated, renamed: "D3DStaticBorderColor.opaqueWhite")
public let D3D12_STATIC_BORDER_COLOR_OPAQUE_WHITE = D3DStaticBorderColor.opaqueWhite

#endif
