/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies what type of texture copy is to take place.
public enum D3DTextureCopyType {
    public typealias RawValue = WinSDK.D3D12_TEXTURE_COPY_TYPE

    ///	Indicates a subresource, identified by an index, is to be copied.
    case subresourceIndex
    ///	Indicates a place footprint, identified by a D3D12_PLACED_SUBRESOURCE_FOOTPRINT structure, is to be copied.
    case placedFootprint

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .subresourceIndex:
            return WinSDK.D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX
        case .placedFootprint:
            return WinSDK.D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX:
            self = .subresourceIndex
        case WinSDK.D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT:
            self = .placedFootprint
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTextureCopyType")
public typealias D3D12_TEXTURE_COPY_TYPE = D3DTextureCopyType


@available(*, deprecated, renamed: "D3DTextureCopyType.subresourceIndex")
public let D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX = D3DTextureCopyType.subresourceIndex

@available(*, deprecated, renamed: "D3DTextureCopyType.placedFootprint")
public let D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT = D3DTextureCopyType.placedFootprint

#endif
