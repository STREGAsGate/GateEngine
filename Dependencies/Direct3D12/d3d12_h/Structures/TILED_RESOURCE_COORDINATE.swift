/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the coordinates of a tiled resource.
public struct D3DTiledResourceCoordinate {
    public typealias RawValue = WinSDK.D3D12_TILED_RESOURCE_COORDINATE
    @usableFromInline
    var rawValue: RawValue

    /// The x-coordinate of the tiled resource.
    @inlinable @inline(__always)
    public var x: UInt32 {
        get {
            return rawValue.X
        }
        set {
            rawValue.X = newValue
        }
    }

    /// The y-coordinate of the tiled resource.
    @inlinable @inline(__always)
    public var y: UInt32 {
        get {
            return rawValue.Y
        }
        set {
            rawValue.Y = newValue
        }
    }

    /// The z-coordinate of the tiled resource.
    @inlinable @inline(__always)
    public var z: UInt32 {
        get {
            return rawValue.Z
        }
        set {
            rawValue.Z = newValue
        }
    }

    /**The index of the subresource for the tiled resource.
    For mipmaps that use nonstandard tiling, or are packed, or both use nonstandard tiling and are packed, any subresource value that indicates any of the packed mipmaps all refer to the same tile. Additionally, the X coordinate is used to indicate a tile within the packed mip region, rather than a logical region of a single subresource. The Y and Z coordinates must be zero.
    */
    @inlinable @inline(__always)
    public var subresourceIndex: UInt32 {
        get {
            return rawValue.Subresource
        }
        set {
            rawValue.Subresource = newValue
        }
    }

    /** Describes the coordinates of a tiled resource.
    - parameter x: The x-coordinate of the tiled resource.
    - parameter y: The y-coordinate of the tiled resource.
    - parameter z: The z-coordinate of the tiled resource.
    - parameter subresourceIndex: The index of the subresource for the tiled resource.
    */
    @inlinable @inline(__always)
    public init(x: UInt32, y: UInt32, z: UInt32, subresourceIndex: UInt32) {
        self.rawValue = RawValue(X: x, Y: y, Z: z, Subresource: subresourceIndex)
    }

    @inlinable @inline(__always)
    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTiledResourceCoordinate")
public typealias D3D12_TILED_RESOURCE_COORDINATE = D3DTiledResourceCoordinate

#endif
