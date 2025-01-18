/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies unordered-access view options.
public enum D3DUnorderedAccessViewDimension {
    public typealias RawValue = WinSDK.D3D12_UAV_DIMENSION

    ///	The view type is unknown.
    case unknown
    ///	View the resource as a buffer.
    case buffer
    ///	View the resource as a 1D texture.
    case texture1D
    ///	View the resource as a 1D texture array.
    case texture1dArray
    ///	View the resource as a 2D texture.
    case texture2D
    ///	View the resource as a 2D texture array.
    case texture2dArray
    ///	View the resource as a 3D texture array.
    case texture3D

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_UAV_DIMENSION_UNKNOWN
        case .buffer:
            return WinSDK.D3D12_UAV_DIMENSION_BUFFER
        case .texture1D:
            return WinSDK.D3D12_UAV_DIMENSION_TEXTURE1D
        case .texture1dArray:
            return WinSDK.D3D12_UAV_DIMENSION_TEXTURE1DARRAY
        case .texture2D:
            return WinSDK.D3D12_UAV_DIMENSION_TEXTURE2D
        case .texture2dArray:
            return WinSDK.D3D12_UAV_DIMENSION_TEXTURE2DARRAY
        case .texture3D:
            return WinSDK.D3D12_UAV_DIMENSION_TEXTURE3D
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_UAV_DIMENSION_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_UAV_DIMENSION_BUFFER:
            self = .buffer
        case WinSDK.D3D12_UAV_DIMENSION_TEXTURE1D:
            self = .texture1D
        case WinSDK.D3D12_UAV_DIMENSION_TEXTURE1DARRAY:
            self = .texture1dArray
        case WinSDK.D3D12_UAV_DIMENSION_TEXTURE2D:
            self = .texture2D
        case WinSDK.D3D12_UAV_DIMENSION_TEXTURE2DARRAY:
            self = .texture2dArray
        case WinSDK.D3D12_UAV_DIMENSION_TEXTURE3D:
            self = .texture3D
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension")
public typealias D3D12_UAV_DIMENSION = D3DUnorderedAccessViewDimension


@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.unknown")
public let D3D12_UAV_DIMENSION_UNKNOWN = D3DUnorderedAccessViewDimension.unknown

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.buffer")
public let D3D12_UAV_DIMENSION_BUFFER = D3DUnorderedAccessViewDimension.buffer

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.texture1D")
public let D3D12_UAV_DIMENSION_TEXTURE1D = D3DUnorderedAccessViewDimension.texture1D

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.texture1dArray")
public let D3D12_UAV_DIMENSION_TEXTURE1DARRAY = D3DUnorderedAccessViewDimension.texture1dArray

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.texture2D")
public let D3D12_UAV_DIMENSION_TEXTURE2D = D3DUnorderedAccessViewDimension.texture2D

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.texture2dArray")
public let D3D12_UAV_DIMENSION_TEXTURE2DARRAY = D3DUnorderedAccessViewDimension.texture2dArray

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDimension.texture3D")
public let D3D12_UAV_DIMENSION_TEXTURE3D = D3DUnorderedAccessViewDimension.texture3D

#endif
