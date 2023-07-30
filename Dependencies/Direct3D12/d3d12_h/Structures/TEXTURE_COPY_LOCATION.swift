/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a portion of a texture for the purpose of texture copies.
public struct D3DTextureCopyLocation {
    public typealias RawValue = WinSDK.D3D12_TEXTURE_COPY_LOCATION
    @usableFromInline
    internal var rawValue: RawValue

    /** Specifies the resource which will be used for the copy operation.
    When Type is `D3D12_TEXTURE_COPY_TYPE_PLACED_FOOTPRINT`, pResource must point to a buffer resource.
    When Type is `D3D12_TEXTURE_COPY_TYPE_SUBRESOURCE_INDEX`, pResource must point to a texture resource.
    */
    @inlinable @inline(__always)
    public var resource: D3DResource? {
        get {
            return D3DResource(winSDKPointer: rawValue.pResource)
        }
        set {
            rawValue.pResource = newValue?.performFatally(as: D3DResource.RawValue.self) {$0}
        }
    }

    /// Specifies which type of resource location this is: a subresource of a texture, or a description of a texture layout which can be applied to a buffer. This D3D12_TEXTURE_COPY_TYPE enum indicates which union member to use.
    @inlinable @inline(__always)
    public var `type`: D3DTextureCopyType {
        get {
            return D3DTextureCopyType(rawValue.Type)
        }
        set {
            rawValue.Type = newValue.rawValue
        }
    }

    /// Specifies a texture layout, with offset, dimensions, and pitches, for the hardware to understand how to treat a section of a buffer resource as a multi-dimensional texture. To fill-in the correct data for a CopyTextureRegion call, see D3D12_PLACED_SUBRESOURCE_FOOTPRINT.
    @inlinable @inline(__always)
    public var placedFootprint: D3DPlacedSubresourceFootprint {
        get {
            return D3DPlacedSubresourceFootprint(rawValue.PlacedFootprint)
        }
        set {
            rawValue.PlacedFootprint = newValue.rawValue
        }
    }

    /// Specifies the index of the subresource of an arrayed, mip-mapped, or planar texture should be used for the copy operation.
    @inlinable @inline(__always)
    public var subresourceIndex: UInt32 {
        get {
            return rawValue.SubresourceIndex
        }
        set {
            rawValue.SubresourceIndex = newValue
        }
    }

    /** Describes a portion of a texture for the purpose of texture copies.
    - parameter resource: Specifies the resource which will be used for the copy operation.
    - parameter type: Specifies which type of resource location this is: a subresource of a texture, or a description of a texture layout which can be applied to a buffer. This D3D12_TEXTURE_COPY_TYPE enum indicates which union member to use.
    - parameter placedFootprint: Specifies a texture layout, with offset, dimensions, and pitches, for the hardware to understand how to treat a section of a buffer resource as a multi-dimensional texture. To fill-in the correct data for a CopyTextureRegion call, see D3D12_PLACED_SUBRESOURCE_FOOTPRINT.
    - parameter subresourceIndex: Specifies the index of the subresource of an arrayed, mip-mapped, or planar texture should be used for the copy operation.
    */
    @inlinable @inline(__always)
    public init(resource: D3DResource?, type: D3DTextureCopyType, placedFootprint: D3DPlacedSubresourceFootprint, subresourceIndex: UInt32) {
        self.rawValue = RawValue()
        self.resource = resource
        self.type = type
        self.placedFootprint = placedFootprint
        self.subresourceIndex = subresourceIndex
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTextureCopyLocation")
public typealias D3D12_TEXTURE_COPY_LOCATION = D3DTextureCopyLocation

#endif
