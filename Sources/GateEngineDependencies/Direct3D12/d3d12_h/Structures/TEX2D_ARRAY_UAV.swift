/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes an array of unordered-access 2D texture resources.
public struct D3DTexture2DArrayUnorderedAccessView {
    public typealias RawValue = WinSDK.D3D12_TEX2D_ARRAY_UAV
    internal var rawValue: RawValue

    /// The index of the first mipmap level to use.
    public var mipIndex: UInt32 {
        get {
            return rawValue.MipSlice
        }
        set {
            rawValue.MipSlice = newValue
        }
    }

    /// The index of the first texture to use in an array of textures.
    public var textureIndex: UInt32 {
        get {
            return rawValue.FirstArraySlice
        }
        set {
            rawValue.FirstArraySlice = newValue
        }
    }

    /// Number of textures to use.
    public var textureCount: UInt32 {
        get {
            return rawValue.ArraySize
        }
        set {
            rawValue.ArraySize = newValue
        }
    }

    /// The index (plane slice number) of the plane to use in an array of textures.
    public var planeSlice: UInt32 {
        get {
            return rawValue.PlaneSlice
        }
        set {
            rawValue.PlaneSlice = newValue
        }
    }

    /** Describes an array of unordered-access 2D texture resources.
    - parameter maxMipLevel: Index of the most detailed mipmap level to use; this number is between 0 and MipLevels (from the original Texture1D for which ID3D12Device::CreateShaderResourceView creates a view) -1.
    - parameter textureIndex: The index of the first texture to use in an array of textures.
    - parameter textureCount: Number of textures to use.
    - parameter minLODClamp: A value to clamp sample LOD values to. For example, if you specify 2.0f for the clamp value, you ensure that no individual sample accesses a mip level less than 2.0f.
    */
    public init(mipIndex: UInt32, textureIndex: UInt32, textureCount: UInt32, planeSlice: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex,
                                 FirstArraySlice: textureIndex,
                                 ArraySize: textureCount,
                                 PlaneSlice: planeSlice)
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture2DArrayUnorderedAccessView")
public typealias D3D12_TEX2D_ARRAY_UAV = D3DTexture2DArrayUnorderedAccessView

#endif
