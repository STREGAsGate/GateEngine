/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the shape of a tile by specifying its dimensions.
public struct D3DTileShape {
    public typealias RawValue = WinSDK.D3D12_TILE_SHAPE
    @usableFromInline
    internal var rawValue: RawValue

    /// The width in texels of the tile.
    @inlinable @inline(__always)
    public var width: UInt32 {
        get {
            return rawValue.WidthInTexels
        }
        set {
            rawValue.WidthInTexels = newValue
        }
    }

    /// The height in texels of the tile.
    @inlinable @inline(__always)
    public var height: UInt32 {
        get {
            return rawValue.HeightInTexels
        }
        set {
            rawValue.HeightInTexels = newValue
        }
    }

    /// The depth in texels of the tile.
    @inlinable @inline(__always)
    public var depth: UInt32 {
        get {
            return rawValue.DepthInTexels
        }
        set {
            rawValue.DepthInTexels = newValue
        }
    }

    /** Describes the shape of a tile by specifying its dimensions.
    - parameter width: The width in texels of the tile.
    - parameter height: The height in texels of the tile.
    - parameter depth: The depth in texels of the tile.
    */
    @inlinable @inline(__always)
    public init(width: UInt32, height: UInt32, depth: UInt32) {
        self.rawValue = RawValue(WidthInTexels: width, HeightInTexels: height, DepthInTexels: depth)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTileShape")
public typealias D3D12_TILE_SHAPE = D3DTileShape

#endif
