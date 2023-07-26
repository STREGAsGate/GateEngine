/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies how to access a resource used in a depth-stencil view.
public enum D3DDSVDimension {
    public typealias RawValue = WinSDK.D3D12_DSV_DIMENSION
    
    ///	D3D12_DSV_DIMENSION_UNKNOWN is not a valid value for D3D12_DEPTH_STENCIL_VIEW_DESC and is not used.
    case unknown
    ///	The resource will be accessed as a 1D texture.
    case texture1D
    ///	The resource will be accessed as an array of 1D textures.
    case texture1DArray
    ///	The resource will be accessed as a 2D texture.
    case texture2D
    ///	The resource will be accessed as an array of 2D textures.
    case texture2DArray
    ///	The resource will be accessed as a 2D texture with multi sampling.
    case texture2DMuiliSampling
    ///	The resource will be accessed as an array of 2D textures with multi sampling.
    case texture2DMuiliSamplingArray

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_DSV_DIMENSION_UNKNOWN
        case .texture1D:
            return WinSDK.D3D12_DSV_DIMENSION_TEXTURE1D
        case .texture1DArray:
            return WinSDK.D3D12_DSV_DIMENSION_TEXTURE1DARRAY
        case .texture2D:
            return WinSDK.D3D12_DSV_DIMENSION_TEXTURE2D
        case .texture2DArray:
            return WinSDK.D3D12_DSV_DIMENSION_TEXTURE2DARRAY
        case .texture2DMuiliSampling:
            return WinSDK.D3D12_DSV_DIMENSION_TEXTURE2DMS
        case .texture2DMuiliSamplingArray:
            return WinSDK.D3D12_DSV_DIMENSION_TEXTURE2DMSARRAY
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_DSV_DIMENSION_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_DSV_DIMENSION_TEXTURE1D:
            self = .texture1D
        case WinSDK.D3D12_DSV_DIMENSION_TEXTURE1DARRAY:
            self = .texture1DArray
        case WinSDK.D3D12_DSV_DIMENSION_TEXTURE2D:
            self = .texture2D
        case WinSDK.D3D12_DSV_DIMENSION_TEXTURE2DARRAY:
            self = .texture2DArray
        case WinSDK.D3D12_DSV_DIMENSION_TEXTURE2DMS:
            self = .texture2DMuiliSampling
        case WinSDK.D3D12_DSV_DIMENSION_TEXTURE2DMSARRAY:
            self = .texture2DMuiliSamplingArray
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDSVDimension")
public typealias D3D12_DSV_DIMENSION  = D3DDSVDimension


@available(*, deprecated, renamed: "D3DDSVDimension.unknown")
public let D3D12_DSV_DIMENSION_UNKNOWN = D3DDSVDimension.unknown

@available(*, deprecated, renamed: "D3DDSVDimension.texture1D")
public let D3D12_DSV_DIMENSION_TEXTURE1D = D3DDSVDimension.texture1D

@available(*, deprecated, renamed: "D3DDSVDimension.texture1DArray")
public let D3D12_DSV_DIMENSION_TEXTURE1DARRAY = D3DDSVDimension.texture1DArray

@available(*, deprecated, renamed: "D3DDSVDimension.texture2D")
public let D3D12_DSV_DIMENSION_TEXTURE2D = D3DDSVDimension.texture2D

@available(*, deprecated, renamed: "D3DDSVDimension.texture2DArray")
public let D3D12_DSV_DIMENSION_TEXTURE2DARRAY = D3DDSVDimension.texture2DArray

@available(*, deprecated, renamed: "D3DDSVDimension.texture2DMuiliSampling")
public let D3D12_DSV_DIMENSION_TEXTURE2DMS = D3DDSVDimension.texture2DMuiliSampling

@available(*, deprecated, renamed: "D3DDSVDimension.texture2DMuiliSamplingArray")
public let D3D12_DSV_DIMENSION_TEXTURE2DMSARRAY = D3DDSVDimension.texture2DMuiliSamplingArray

#endif
