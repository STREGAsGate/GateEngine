/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a tiled subresource volume.
public struct D3DSubresourceTiling {
    public typealias RawValue = WinSDK.D3D12_SUBRESOURCE_TILING
    @usableFromInline
    internal var rawValue: RawValue

    /// The width in tiles of the subresource.
    @inlinable @inline(__always)
    public var horizontalTileCount: UInt32 {
        get {
            return rawValue.WidthInTiles
        }
        set {
            rawValue.WidthInTiles = newValue
        }
    }

    /// The height in tiles of the subresource.
    @inlinable @inline(__always)
    public var verticalTileCount: UInt16 {
        get {
            return rawValue.HeightInTiles
        }
        set {
            rawValue.HeightInTiles = newValue
        }
    }

    /// The depth in tiles of the subresource.
    @inlinable @inline(__always)
    public var depthTileCount: UInt16 {
        get {
            return rawValue.DepthInTiles
        }
        set {
            rawValue.DepthInTiles = newValue
        }
    }

    /// The index of the tile in the overall tiled subresource to start with.
    @inlinable @inline(__always)
    public var startIndex: UInt32 {
        get {
            return rawValue.StartTileIndexInOverallResource
        }
        set {
            rawValue.StartTileIndexInOverallResource = newValue
        }
    }

    /** Describes a tiled subresource volume.
    - parameter horizontalTileCount: The width in tiles of the subresource.
    - parameter verticalTileCount: The height in tiles of the subresource.
    - parameter depthTileCount: The depth in tiles of the subresource.
    - parameter startIndex: The index of the tile in the overall tiled subresource to start with.
    */
    @inlinable @inline(__always)
    public init(horizontalTileCount: UInt32,
                verticalTileCount: UInt16,
                depthTileCount: UInt16,
                startIndex: UInt32) {
        self.rawValue = RawValue(WidthInTiles: horizontalTileCount, 
                                 HeightInTiles: verticalTileCount, 
                                 DepthInTiles: depthTileCount, 
                                 StartTileIndexInOverallResource: startIndex)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DSubresourceTiling")
public typealias D3D12_SUBRESOURCE_TILING = D3DSubresourceTiling

#endif
