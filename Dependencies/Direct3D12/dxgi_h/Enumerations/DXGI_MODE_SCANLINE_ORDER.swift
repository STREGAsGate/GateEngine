/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK


/// Flags indicating the method the raster uses to create an image on a surface.
public enum DGIModeScanlineOrder {
    public typealias RawValue = WinSDK.DXGI_MODE_SCANLINE_ORDER 
    
    /// Scanline order is unspecified.
    case unspecified
    /// The image is created from the first scanline to the last without skipping any.
    case progressive
    /// The image is created beginning with the upper field.
    case upperFieldFirst
    /// The image is created beginning with the lower field.
    case lowerFieldFirst

    case _unimplemented(RawValue)
    
    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unspecified:
            return WinSDK.DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED
        case .progressive:
            return WinSDK.DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE
        case .upperFieldFirst:
            return WinSDK.DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST
        case .lowerFieldFirst:
            return WinSDK.DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED:
            self = .unspecified
        case WinSDK.DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE:
            self = .progressive
        case WinSDK.DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST:
            self = .upperFieldFirst
        case WinSDK.DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST:
            self = .lowerFieldFirst
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIModeScanlineOrder")
public typealias DXGI_MODE_SCANLINE_ORDER = DGIModeScanlineOrder


@available(*, deprecated, renamed: "DGIModeScanlineOrder.unspecified")
public let DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED = DGIModeScanlineOrder.unspecified

@available(*, deprecated, renamed: "DGIModeScanlineOrder.progressive")
public let DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE = DGIModeScanlineOrder.progressive

@available(*, deprecated, renamed: "DGIModeScanlineOrder.upperFieldFirst")
public let DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST = DGIModeScanlineOrder.upperFieldFirst

@available(*, deprecated, renamed: "DGIModeScanlineOrder.lowerFieldFirst")
public let DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST = DGIModeScanlineOrder.lowerFieldFirst

#endif
