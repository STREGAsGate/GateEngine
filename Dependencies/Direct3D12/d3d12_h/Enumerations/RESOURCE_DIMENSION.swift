/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies the type of resource being used.
public enum D3DResourceDimension {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_DIMENSION

    ///	Resource is of unknown type.
    case unknown
    ///	Resource is a buffer.
    case buffer
    ///	Resource is a 1D texture.
    case texture1D
    ///	Resource is a 2D texture.
    case texture2D
    ///	Resource is a 3D texture.
    case texture3D

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_RESOURCE_DIMENSION_UNKNOWN
        case .buffer:
            return WinSDK.D3D12_RESOURCE_DIMENSION_BUFFER
        case .texture1D:
            return WinSDK.D3D12_RESOURCE_DIMENSION_TEXTURE1D
        case .texture2D:
            return WinSDK.D3D12_RESOURCE_DIMENSION_TEXTURE2D
        case .texture3D:
            return WinSDK.D3D12_RESOURCE_DIMENSION_TEXTURE3D
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_RESOURCE_DIMENSION_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_RESOURCE_DIMENSION_BUFFER:
            self = .buffer
        case WinSDK.D3D12_RESOURCE_DIMENSION_TEXTURE1D:
            self = .texture1D
        case WinSDK.D3D12_RESOURCE_DIMENSION_TEXTURE2D:
            self = .texture2D
        case WinSDK.D3D12_RESOURCE_DIMENSION_TEXTURE3D:
            self = .texture3D
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceDimension")
public typealias D3D12_RESOURCE_DIMENSION = D3DResourceDimension


@available(*, deprecated, renamed: "D3DResourceDimension.unknown")
public let D3D12_RESOURCE_DIMENSION_UNKNOWN = D3DResourceDimension.unknown

@available(*, deprecated, renamed: "D3DResourceDimension.buffer")
public let D3D12_RESOURCE_DIMENSION_BUFFER = D3DResourceDimension.buffer

@available(*, deprecated, renamed: "D3DResourceDimension.texture1D")
public let D3D12_RESOURCE_DIMENSION_TEXTURE1D = D3DResourceDimension.texture1D

@available(*, deprecated, renamed: "D3DResourceDimension.texture2D")
public let D3D12_RESOURCE_DIMENSION_TEXTURE2D = D3DResourceDimension.texture2D

@available(*, deprecated, renamed: "D3DResourceDimension.texture3D")
public let D3D12_RESOURCE_DIMENSION_TEXTURE3D = D3DResourceDimension.texture3D

#endif
