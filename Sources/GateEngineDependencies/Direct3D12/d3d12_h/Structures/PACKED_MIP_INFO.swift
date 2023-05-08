/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the tile structure of a tiled resource with mipmaps.
public struct D3DPackedMipInfo {
    public typealias RawValue = WinSDK.D3D12_PACKED_MIP_INFO
    internal var rawValue: RawValue

    public var numStandardMips: UInt8 {
        get {
            return rawValue.NumStandardMips
        }
        set {
            rawValue.NumStandardMips = newValue
        }
    }

    /** 
        The number of packed mipmaps in the tiled resource.

        This number starts from the least detailed mipmap (either sharing tiles or using non standard tile layout). This number is 0 if no such packing is in the resource. For array surfaces, this value is the number of mipmaps that are packed for a given array slice where each array slice repeats the same packing.

        On Tier_2 tiled resources hardware, mipmaps that fill at least one standard shaped tile in all dimensions are not allowed to be included in the set of packed mipmaps. On Tier_1 hardware, mipmaps that are an integer multiple of one standard shaped tile in all dimensions are not allowed to be included in the set of packed mipmaps. Mipmaps with at least one dimension less than the standard tile shape may or may not be packed. When a given mipmap needs to be packed, all coarser mipmaps for a given array slice are considered packed as well.
    */
    public var numPackedMips: UInt8 {
        get {
            return rawValue.NumPackedMips
        }
        set {
            rawValue.NumPackedMips = newValue
        }
    }

    /**
        The number of tiles for the packed mipmaps in the tiled resource.

        If there is no packing, this value is meaningless and is set to 0. Otherwise, it is set to the number of tiles that are needed to represent the set of packed mipmaps. The pixel layout within the packed mipmaps is hardware specific. If apps define only partial mappings for the set of tiles in packed mipmaps, read and write behavior is vendor specific and undefined. For arrays, this value is only the count of packed mipmaps within the subresources for each array slice.
    */
    public var numTilesForPackedMips: UInt32 {
        get {
            return rawValue.NumTilesForPackedMips
        }
        set {
            rawValue.NumTilesForPackedMips = newValue
        }
    }

    /// The offset of the first packed tile for the resource in the overall range of tiles. If NumPackedMips is 0, this value is meaningless and is 0. Otherwise, it is the offset of the first packed tile for the resource in the overall range of tiles for the resource. A value of 0 for StartTileIndexInOverallResource means the entire resource is packed. For array surfaces, this is the offset for the tiles that contain the packed mipmaps for the first array slice. Packed mipmaps for each array slice in arrayed surfaces are at this offset past the beginning of the tiles for each array slice.
    public var startTileIndexInOverallResource: UInt32 {
        get {
            return rawValue.StartTileIndexInOverallResource
        }
        set {
            rawValue.StartTileIndexInOverallResource = newValue
        }
    }

    /** Describes the tile structure of a tiled resource with mipmaps.
    - parameter numStandardMips: The number of standard mipmaps in the tiled resource.
    - parameter numPackedMips: The number of packed mipmaps in the tiled resource.
    - parameter numTilesForPackedMips: The number of tiles for the packed mipmaps in the tiled resource.
    - parameter startTileIndexInOverallResource: The offset of the first packed tile for the resource in the overall range of tiles. If NumPackedMips is 0, this value is meaningless and is 0. Otherwise, it is the offset of the first packed tile for the resource in the overall range of tiles for the resource. A value of 0 for StartTileIndexInOverallResource means the entire resource is packed. For array surfaces, this is the offset for the tiles that contain the packed mipmaps for the first array slice. Packed mipmaps for each array slice in arrayed surfaces are at this offset past the beginning of the tiles for each array slice.
    */
    public init(numStandardMips: UInt8, numPackedMips: UInt8, numTilesForPackedMips: UInt32, startTileIndexInOverallResource: UInt32) {
        self.rawValue = RawValue()
        self.numStandardMips = numStandardMips
        self.numPackedMips = numPackedMips
        self.numTilesForPackedMips = numTilesForPackedMips
        self.startTileIndexInOverallResource = startTileIndexInOverallResource
    }

    /// Describes the tile structure of a tiled resource with mipmaps.
    public init() {
        self.rawValue = RawValue()
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DPackedMipInfo")
public typealias D3D12_PACKED_MIP_INFO = D3DPackedMipInfo

#endif
