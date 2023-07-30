/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies the type of resource that will be viewed as a shader resource.
public enum D3DShaderResourceViewDimension {
    public typealias RawValue = WinSDK.D3D12_SRV_DIMENSION

    ///	The type is unknown.
    case unknown
    ///	The resource is a buffer.
    case buffer
    ///	The resource is a 1D texture.
    case texture1D
    ///	The resource is an array of 1D textures.
    case texture1dArray
    ///	The resource is a 2D texture.
    case texture2D
    ///	The resource is an array of 2D textures.
    case texture2dArray
    ///	The resource is a multisampling 2D texture.
    case texture2dMultisampling
    ///	The resource is an array of multisampling 2D textures.
    case texture2dArrayMultisampling
    ///	The resource is a 3D texture.
    case texture3D
    ///	The resource is a cube texture.
    case textureCube
    ///	The resource is an array of cube textures.
    case textureCubeArray
    ///	The resource is a raytracing acceleration structure.
    case raytracingAccelerationStructure

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_SRV_DIMENSION_UNKNOWN
        case .buffer:
            return WinSDK.D3D12_SRV_DIMENSION_BUFFER
        case .texture1D:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE1D
        case .texture1dArray:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE1DARRAY
        case .texture2D:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE2D
        case .texture2dArray:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE2DARRAY
        case .texture2dMultisampling:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE2DMS
        case .texture2dArrayMultisampling:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE2DMSARRAY
        case .texture3D:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURE3D
        case .textureCube:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURECUBE
        case .textureCubeArray:
            return WinSDK.D3D12_SRV_DIMENSION_TEXTURECUBEARRAY
        case .raytracingAccelerationStructure:
            return WinSDK.D3D12_SRV_DIMENSION_RAYTRACING_ACCELERATION_STRUCTURE
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_SRV_DIMENSION_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_SRV_DIMENSION_BUFFER:
            self = .buffer
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE1D:
            self = .texture1D
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE1DARRAY:
            self = .texture1dArray
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE2D:
            self = .texture2D
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE2DARRAY:
            self = .texture2dArray
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE2DMS:
            self = .texture2dMultisampling
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE2DMSARRAY:
            self = .texture2dArrayMultisampling
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURE3D:
            self = .texture3D
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURECUBE:
            self = .textureCube
        case WinSDK.D3D12_SRV_DIMENSION_TEXTURECUBEARRAY:
            self = .textureCubeArray
        case WinSDK.D3D12_SRV_DIMENSION_RAYTRACING_ACCELERATION_STRUCTURE:
            self = .raytracingAccelerationStructure
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension")
public typealias D3D12_SRV_DIMENSION = D3DShaderResourceViewDimension


@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.unknown")
public let D3D12_SRV_DIMENSION_UNKNOWN = D3DShaderResourceViewDimension.unknown

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.buffer")
public let D3D12_SRV_DIMENSION_BUFFER = D3DShaderResourceViewDimension.buffer

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture1D")
public let D3D12_SRV_DIMENSION_TEXTURE1D = D3DShaderResourceViewDimension.texture1D

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture1dArray")
public let D3D12_SRV_DIMENSION_TEXTURE1DARRAY = D3DShaderResourceViewDimension.texture1dArray

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture2D")
public let D3D12_SRV_DIMENSION_TEXTURE2D = D3DShaderResourceViewDimension.texture2D

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture2dArray")
public let D3D12_SRV_DIMENSION_TEXTURE2DARRAY = D3DShaderResourceViewDimension.texture2dArray

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture2dMultisampling")
public let D3D12_SRV_DIMENSION_TEXTURE2DMS = D3DShaderResourceViewDimension.texture2dMultisampling

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture2dArrayMultisampling")
public let D3D12_SRV_DIMENSION_TEXTURE2DMSARRAY = D3DShaderResourceViewDimension.texture2dArrayMultisampling

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.texture3D")
public let D3D12_SRV_DIMENSION_TEXTURE3D = D3DShaderResourceViewDimension.texture3D

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.textureCube")
public let D3D12_SRV_DIMENSION_TEXTURECUBE = D3DShaderResourceViewDimension.textureCube

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.textureCubeArray")
public let D3D12_SRV_DIMENSION_TEXTURECUBEARRAY = D3DShaderResourceViewDimension.textureCubeArray

@available(*, deprecated, renamed: "D3DShaderResourceViewDimension.raytracingAccelerationStructure")
public let D3D12_SRV_DIMENSION_RAYTRACING_ACCELERATION_STRUCTURE = D3DShaderResourceViewDimension.raytracingAccelerationStructure

#endif
