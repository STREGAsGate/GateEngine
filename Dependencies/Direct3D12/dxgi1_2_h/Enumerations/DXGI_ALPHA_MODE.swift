/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK


/// Identifies the alpha value, transparency behavior, of a surface.
public enum DGIAlphaMode {
    public typealias RawValue = WinSDK.DXGI_ALPHA_MODE  
    
    /// Indicates that the transparency behavior is not specified.
    case unspecified
    /// Indicates that the transparency behavior is premultiplied. Each color is first scaled by the alpha value. The alpha value itself is the same in both straight and premultiplied alpha. Typically, no color channel value is greater than the alpha channel value. If a color channel value in a premultiplied format is greater than the alpha channel, the standard source-over blending math results in an additive blend.
    case premultiplied
    /// Indicates that the transparency behavior is not premultiplied. The alpha channel indicates the transparency of the color.
    case straight
    /// Indicates to ignore the transparency behavior.
    case ignore

    case _unimplemented(RawValue)
    
    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unspecified:
            return WinSDK.DXGI_ALPHA_MODE_UNSPECIFIED
        case .premultiplied:
            return WinSDK.DXGI_ALPHA_MODE_PREMULTIPLIED
        case .straight:
            return WinSDK.DXGI_ALPHA_MODE_STRAIGHT
        case .ignore:
            return WinSDK.DXGI_ALPHA_MODE_IGNORE
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.DXGI_ALPHA_MODE_UNSPECIFIED:
            self = .unspecified
        case WinSDK.DXGI_ALPHA_MODE_PREMULTIPLIED:
            self = .premultiplied
        case WinSDK.DXGI_ALPHA_MODE_STRAIGHT:
            self = .straight
        case WinSDK.DXGI_ALPHA_MODE_IGNORE:
            self = .ignore
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIAlphaMode")
public typealias DXGI_ALPHA_MODE = DGIAlphaMode

@available(*, deprecated, renamed: "DGIAlphaMode.unspecified")
public let DXGI_ALPHA_MODE_UNSPECIFIED = DGIAlphaMode.unspecified

@available(*, deprecated, renamed: "DGIAlphaMode.premultiplied")
public let DXGI_ALPHA_MODE_PREMULTIPLIED = DGIAlphaMode.premultiplied

@available(*, deprecated, renamed: "DGIAlphaMode.straight")
public let DXGI_ALPHA_MODE_STRAIGHT = DGIAlphaMode.straight

@available(*, deprecated, renamed: "DGIAlphaMode.ignore")
public let DXGI_ALPHA_MODE_IGNORE = DGIAlphaMode.ignore

@available(*, unavailable, message: "Not supported.")
public let DXGI_ALPHA_MODE_FORCE_DWORD = DGIAlphaMode.ignore

#endif
