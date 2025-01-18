/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DTexture1DArrayShaderResourceView {
    public typealias RawValue = WinSDK.D3D12_TEX1D_ARRAY_SRV
    @usableFromInline
    internal var rawValue: RawValue

    /// Index of the most detailed mipmap level to use; this number is between 0 and MipLevels (from the original Texture1D for which ID3D12Device::CreateShaderResourceView creates a view) -1.
    @inlinable @inline(__always)
    public var maxMipLevel: UInt32 {
        get {
            return rawValue.MostDetailedMip
        }
        set {
            rawValue.MostDetailedMip = newValue
        }
    }

    /**
    The maximum number of mipmap levels for the view of the texture. See the remarks in D3D12_TEX1D_SRV.

    Set to -1 to indicate all the mipmap levels from MostDetailedMip on down to least detailed.
    */
    @inlinable @inline(__always)
    public var mipLevels: UInt32 {
        get {
            return rawValue.MipLevels
        }
        set {
            rawValue.MipLevels = newValue
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

    /** Describes the subresources from an array of 1D textures to use in a depth-stencil view.
    - parameter maxMipLevel: Index of the most detailed mipmap level to use; this number is between 0 and MipLevels (from the original Texture1D for which ID3D12Device::CreateShaderResourceView creates a view) -1.
    - parameter mipLevels: The maximum number of mipmap levels for the view of the texture. See the remarks in D3D12_TEX1D_SRV. Set to -1 to indicate all the mipmap levels from MostDetailedMip on down to least detailed.
    - parameter textureIndex: The index of the first texture to use in an array of textures.
    - parameter textureCount: Number of textures to use.
    - parameter minLODClamp: A value to clamp sample LOD values to. For example, if you specify 2.0f for the clamp value, you ensure that no individual sample accesses a mip level less than 2.0f.
    */
    @inlinable @inline(__always)
    public init(maxMipLevel: UInt32, mipLevels: UInt32, textureIndex: UInt32, textureCount: UInt32, minLODClamp: Float) {
        self.rawValue = RawValue(MostDetailedMip: maxMipLevel,
                                 MipLevels: mipLevels,
                                 FirstArraySlice: textureIndex,
                                 ArraySize: textureCount,
                                 ResourceMinLODClamp: minLODClamp)
    }
    
    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture1DArrayShaderResourceView")
public typealias D3D12_TEX1D_ARRAY_SRV = D3DTexture1DArrayShaderResourceView

#endif
