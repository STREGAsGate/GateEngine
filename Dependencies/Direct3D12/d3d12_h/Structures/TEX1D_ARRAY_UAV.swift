/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes an array of unordered-access 1D texture resources.
public struct D3DTexture1DArrayUnorderedAccessView {
    public typealias RawValue = WinSDK.D3D12_TEX1D_ARRAY_UAV
    @usableFromInline
    internal var rawValue: RawValue

    /// The index of the first mipmap level to use.
    @inlinable @inline(__always)
    public var mipIndex: UInt32 {
        get {
            return rawValue.MipSlice
        }
        set {
            rawValue.MipSlice = newValue
        }
    }

    /// The index of the first texture to use in an array of textures.
    @inlinable @inline(__always)
    public var textureIndex: UInt32 {
        get {
            return rawValue.FirstArraySlice
        }
        set {
            rawValue.FirstArraySlice = newValue
        }
    }

    /// Number of textures to use.
    @inlinable @inline(__always)
    public var textureCount: UInt32 {
        get {
            return rawValue.ArraySize
        }
        set {
            rawValue.ArraySize = newValue
        }
    }

    /** Describes an array of unordered-access 1D texture resources.
    - parameter mipIndex: The index of the first mipmap level to use.
    - parameter textureIndex: The index of the first texture to use in an array of textures.
    - parameter textureCount: Number of textures to use.
    */
    @inlinable @inline(__always)
    public init(mipIndex: UInt32, textureIndex: UInt32, textureCount: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex,
                                 FirstArraySlice: textureIndex,
                                 ArraySize: textureCount)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture1DArrayUnorderedAccessView")
public typealias D3D12_TEX1D_ARRAY_UAV = D3DTexture1DArrayUnorderedAccessView

#endif
