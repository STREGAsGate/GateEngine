/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a unordered-access 2D texture resource.
public struct D3DTexture2DUnorderedAccessView {
    public typealias RawValue = WinSDK.D3D12_TEX2D_UAV
    @usableFromInline
    internal var rawValue: RawValue

    /// The index of the mipmap level to use.
    @inlinable @inline(__always)
    public var mipIndex: UInt32 {
        get {
            return rawValue.MipSlice
        }
        set {
            rawValue.MipSlice = newValue
        }
    }

    /// The index (plane slice number) of the plane to use in the texture.
    @inlinable @inline(__always)
    public var planeSlice: UInt32 {
        get {
            return rawValue.PlaneSlice
        }
        set {
            rawValue.PlaneSlice = newValue
        }
    }

    /** Describes a unordered-access 2D texture resource.
    - parameter mipIndex: The mipmap slice index.
    - parameter planeSlice: The index (plane slice number) of the plane to use in the texture.
    */
    @inlinable @inline(__always)
    public init(mipIndex: UInt32, planeSlice: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex, PlaneSlice: planeSlice)
    }
    
    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture2DUnorderedAccessView")
public typealias D3D12_TEX2D_UAV = D3DTexture2DUnorderedAccessView

#endif
