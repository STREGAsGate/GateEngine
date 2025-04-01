/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

///Identifies the type of resource to view as a render target.
public enum D3DRenderTargetViewDiemension {
    public typealias RawValue = WinSDK.D3D12_RTV_DIMENSION

    ///	Do not use this value, as it will cause ID3D12Device::CreateRenderTargetView to fail.
    case unknown
    ///	The resource will be accessed as a buffer.
    case buffer
    ///	The resource will be accessed as a 1D texture.
    case texture1D
    ///	The resource will be accessed as an array of 1D textures.
    case texture1dArray
    ///	The resource will be accessed as a 2D texture.
    case texture2D
    ///	The resource will be accessed as an array of 2D textures.
    case texture2dArray
    ///	The resource will be accessed as a 2D texture with multisampling.
    case texture2dMultisampling
    ///	The resource will be accessed as an array of 2D textures with multisampling.
    case texture2dArrayMultisampling
    ///	The resource will be accessed as a 3D texture.
    case texture3D

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_RTV_DIMENSION_UNKNOWN
        case .buffer:
            return WinSDK.D3D12_RTV_DIMENSION_BUFFER
        case .texture1D:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE1D
        case .texture1dArray:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE1DARRAY
        case .texture2D:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE2D
        case .texture2dArray:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE2DARRAY
        case .texture2dMultisampling:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE2DMS
        case .texture2dArrayMultisampling:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE2DMSARRAY
        case .texture3D:
            return WinSDK.D3D12_RTV_DIMENSION_TEXTURE3D
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_RTV_DIMENSION_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_RTV_DIMENSION_BUFFER:
            self = .buffer
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE1D:
            self = .texture1D
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE1DARRAY:
            self = .texture1dArray
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE2D:
            self = .texture2D
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE2DARRAY:
            self = .texture2dArray
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE2DMS:
            self = .texture2dMultisampling
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE2DMSARRAY:
            self = .texture2dArrayMultisampling
        case WinSDK.D3D12_RTV_DIMENSION_TEXTURE3D:
            self = .texture3D
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension")
public typealias D3D12_RTV_DIMENSION = D3DRenderTargetViewDiemension


@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.unknown")
public let D3D12_RTV_DIMENSION_UNKNOWN = D3DRenderTargetViewDiemension.unknown

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.buffer")
public let D3D12_RTV_DIMENSION_BUFFER = D3DRenderTargetViewDiemension.buffer

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture1D")
public let D3D12_RTV_DIMENSION_TEXTURE1D = D3DRenderTargetViewDiemension.texture1D

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture1dArray")
public let D3D12_RTV_DIMENSION_TEXTURE1DARRAY = D3DRenderTargetViewDiemension.texture1dArray

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture2D")
public let D3D12_RTV_DIMENSION_TEXTURE2D = D3DRenderTargetViewDiemension.texture2D

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture2dArray")
public let D3D12_RTV_DIMENSION_TEXTURE2DARRAY = D3DRenderTargetViewDiemension.texture2dArray

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture2dMultisampling")
public let D3D12_RTV_DIMENSION_TEXTURE2DMS = D3DRenderTargetViewDiemension.texture2dMultisampling

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture2dArrayMultisampling")
public let D3D12_RTV_DIMENSION_TEXTURE2DMSARRAY = D3DRenderTargetViewDiemension.texture2dArrayMultisampling

@available(*, deprecated, renamed: "D3DRenderTargetViewDiemension.texture3D")
public let D3D12_RTV_DIMENSION_TEXTURE3D = D3DRenderTargetViewDiemension.texture3D

#endif
