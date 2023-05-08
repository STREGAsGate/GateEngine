/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the size of a tiled region.
public struct D3DTileRegionSize {
    public typealias RawValue = WinSDK.D3D12_TILE_REGION_SIZE
    var rawValue: RawValue

    /// The number of tiles in the tiled region.
    public var tileCount: UInt32 {
        get {
            return rawValue.NumTiles
        }
        set {
            rawValue.NumTiles = newValue
        }
    }

    /** Specifies whether the runtime uses the Width, Height, and Depth members to define the region.
    If TRUE, the runtime uses the Width, Height, and Depth members to define the region. In this case, NumTiles should be equal to Width * Height * Depth.
    If FALSE, the runtime ignores the Width, Height, and Depth members and uses the NumTiles member to traverse tiles in the resource linearly across x, then y, then z (as applicable) and then spills over mipmaps/arrays in subresource order. For example, use this technique to map an entire resource at once.

    Regardless of whether you specify TRUE or FALSE for UseBox, you use a D3D12_TILED_RESOURCE_COORDINATE structure to specify the starting location for the region within the resource as a separate parameter outside of this structure by using x, y, and z coordinates.

    When the region includes mipmaps that are packed with nonstandard tiling, UseBox must be FALSE because tile dimensions are not standard and the app only knows a count of how many tiles are consumed by the packed area, which is per array slice. The corresponding (separate) starting location parameter uses x to offset into the flat range of tiles in this case, and y and z coordinates must each be 0.
    */
    public var useBox: Bool {
        get {
            return rawValue.UseBox.boolValue
        }
        set {
            rawValue.UseBox = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// The width of the tiled region, in tiles. Used for buffer and 1D, 2D, and 3D textures.
    public var width: UInt32 {
        get {
            return rawValue.Width
        }
        set {
            rawValue.Width = newValue
        }
    }

    /// The height of the tiled region, in tiles. Used for 2D and 3D textures.
    public var height: UInt16 {
        get {
            return rawValue.Height
        }
        set {
            rawValue.Height = newValue
        }
    }

    /// The depth of the tiled region, in tiles. Used for 3D textures or arrays. For arrays, used for advancing in depth jumps to next slice of same mipmap size, which isn't contiguous in the subresource counting space if there are multiple mipmaps.
    public var depth: UInt16 {
        get {
            return rawValue.Depth
        }
        set {
            rawValue.Depth = newValue
        }
    }

    /** Describes the size of a tiled region.
    - parameter tileCount: The number of tiles in the tiled region.
    - parameter useBoxes: Specifies whether the runtime uses the Width, Height, and Depth members to define the region.
    - parameter width: The width of the tiled region, in tiles. Used for buffer and 1D, 2D, and 3D textures.
    - parameter height: The height of the tiled region, in tiles. Used for 2D and 3D textures.
    - parameter depth: The depth of the tiled region, in tiles. Used for 3D textures or arrays. For arrays, used for advancing in depth jumps to next slice of same mipmap size, which isn't contiguous in the subresource counting space if there are multiple mipmaps.
    */
    public init(tileCount: UInt32,
                useBox: Bool,
                width: UInt32,
                height: UInt16,
                depth: UInt16) {
        self.rawValue = RawValue(NumTiles: tileCount,
                                 UseBox: WindowsBool(booleanLiteral: useBox),
                                 Width: width,
                                 Height: height,
                                 Depth: depth)
    }

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTileRegionSize")
public typealias D3D12_TILE_REGION_SIZE = D3DTileRegionSize

#endif
