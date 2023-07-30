/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies how to copy a tile.
public struct D3DTileCopyFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_TILE_COPY_FLAGS
    public typealias RawValue = WinSDK.D3D12_TILE_COPY_FLAGS.RawValue
    public let rawValue: RawValue
    //Use an empty collection `[]` to represent none in Swift.
    ///// No tile-copy flags are specified.
    //public static let none = D3DTileCopyFlags(rawValue: WinSDK.D3D12_TILE_COPY_FLAG_NONE.rawValue)

    ///	Indicates that the GPU isn't currently referencing any of the
    /// portions of destination memory being written.
    public static let noHazard = D3DTileCopyFlags(rawValue: WinSDK.D3D12_TILE_COPY_FLAG_NO_HAZARD.rawValue)
    ///	Indicates that the ID3D12GraphicsCommandList::CopyTiles operation involves copying a linear buffer to a swizzled tiled resource. This means to copy tile data from the
    /// specified buffer location, reading tiles sequentially,
    /// to the specified tile region (in x,y,z order if the region is a box), swizzling to optimal hardware memory layout as needed.
    /// In this ID3D12GraphicsCommandList::CopyTiles call, you specify the source data with the pBuffer parameter and the destination with the pTiledResource parameter.
    public static let linearBufferToSwizzledTiledResource = D3DTileCopyFlags(rawValue: WinSDK.D3D12_TILE_COPY_FLAG_LINEAR_BUFFER_TO_SWIZZLED_TILED_RESOURCE.rawValue)
    ///	Indicates that the ID3D12GraphicsCommandList::CopyTiles operation involves copying a swizzled tiled resource to a linear buffer. This means to copy tile data from the tile region, reading tiles sequentially (in x,y,z order if the region is a box),
    /// to the specified buffer location, deswizzling to linear memory layout as needed.
    /// In this ID3D12GraphicsCommandList::CopyTiles call, you specify the source data with the pTiledResource parameter and the destination with the pBuffer parameter.
    public static let swizzledTiledResourceToLinearBuffer = D3DTileCopyFlags(rawValue: WinSDK.D3D12_TILE_COPY_FLAG_SWIZZLED_TILED_RESOURCE_TO_LINEAR_BUFFER.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTileCopyFlags")
public typealias D3D12_TILE_COPY_FLAGS = D3DTileCopyFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_TILE_COPY_FLAG_NONE: D3DTileCopyFlags = []

@available(*, deprecated, renamed: "D3DTileCopyFlags.noHazard")
public let D3D12_TILE_COPY_FLAG_NO_HAZARD = D3DTileCopyFlags.noHazard

@available(*, deprecated, renamed: "D3DTileCopyFlags.linearBufferToSwizzledTiledResource")
public let D3D12_TILE_COPY_FLAG_LINEAR_BUFFER_TO_SWIZZLED_TILED_RESOURCE = D3DTileCopyFlags.linearBufferToSwizzledTiledResource

@available(*, deprecated, renamed: "D3DTileCopyFlags.swizzledTiledResourceToLinearBuffer")
public let D3D12_TILE_COPY_FLAG_SWIZZLED_TILED_RESOURCE_TO_LINEAR_BUFFER = D3DTileCopyFlags.swizzledTiledResourceToLinearBuffer

#endif
