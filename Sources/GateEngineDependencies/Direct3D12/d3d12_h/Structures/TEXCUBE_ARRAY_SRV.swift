/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresources from an array of cube textures to use in a shader-resource view.
public struct D3DTextureCubeArrayShaderResourceView {
    public typealias RawValue = WinSDK.D3D12_TEXCUBE_ARRAY_SRV
    internal var rawValue: RawValue

    /// Index of the most detailed mipmap level to use; this number is between 0 and MipLevels (from the original Texture2D for which ID3D12Device::CreateShaderResourceView creates a view) -1.
    @inlinable @inline(__always)
    public var maxMipLevel: UInt32 {
        get {
            return rawValue.MostDetailedMip
        }
        set {
            rawValue.MostDetailedMip = newValue
        }
    }

    /// The maximum number of mipmap levels for the view of the texture. See the remarks in D3D12_TEX1D_SRV. Set to -1 to indicate all the mipmap levels from MostDetailedMip on down to least detailed.
    @inlinable @inline(__always)
    public var mipLevels: UInt32 {
        get {
            return rawValue.MipLevels
        }
        set {
            rawValue.MipLevels = newValue
        }
    }

    /// Index of the first 2D texture to use.
    @inlinable @inline(__always)
    public var first2DArrayFace: UInt32 {
        get {
            return rawValue.First2DArrayFace
        }
        set {
            rawValue.First2DArrayFace = newValue
        }
    }

    /// Number of cube textures in the array.
    @inlinable @inline(__always)
    public var cubeTextureCount: UInt32 {
        get {
            return rawValue.NumCubes
        }
        set {
            rawValue.NumCubes = newValue
        }
    }

    /// A value to clamp sample LOD values to. For example, if you specify 2.0f for the clamp value, you ensure that no individual sample accesses a mip level less than 2.0f.
    @inlinable @inline(__always)
    public var minLODClamp: Float {
        get {
            return rawValue.ResourceMinLODClamp
        }
        set {
            rawValue.ResourceMinLODClamp = newValue
        }
    }

    /** Describes the subresources from an array of cube textures to use in a shader-resource view.
    - parameter maxMipLevel: Index of the most detailed mipmap level to use; this number is between 0 and MipLevels (from the original Texture3D for which ID3D12Device::CreateShaderResourceView creates a view) -1.
    - parameter mipLevels: The maximum number of mipmap levels for the view of the texture. See the remarks in D3D12_TEX1D_SRV. Set to -1 to indicate all the mipmap levels from MostDetailedMip on down to least detailed.
    - parameter first2dArrayFace: Index of the first 2D texture to use.
    - parameter cubeTextureCount: Number of cube textures in the array.
    - parameter minLODClamp: A value to clamp sample LOD values to. For example, if you specify 2.0f for the clamp value, you ensure that no individual sample accesses a mip level less than 2.0f.
    */
    @inlinable @inline(__always)
    public init(maxMipLevel: UInt32, mipLevels: UInt32, first2DArrayFace: UInt32, cubeTextureCount: UInt32, minLODClamp: Float) {
        self.rawValue = RawValue(MostDetailedMip: maxMipLevel,
                                 MipLevels: mipLevels,
                                 First2DArrayFace: first2DArrayFace,
                                 NumCubes: cubeTextureCount,
                                 ResourceMinLODClamp: minLODClamp)
    }
    
    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTextureCubeArrayShaderResourceView")
public typealias D3D12_TEXCUBE_ARRAY_SRV = D3DTextureCubeArrayShaderResourceView

#endif
