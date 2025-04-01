/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresource from a cube texture to use in a shader-resource view.
public struct D3DTextureCubeShaderResourceView {
    public typealias RawValue = WinSDK.D3D12_TEXCUBE_SRV
    @usableFromInline
    internal var rawValue: RawValue

    /// Index of the most detailed mipmap level to use; this number is between 0 and MipLevels (from the original Texture2D for which ID3D12Device::CreateShaderResourceView creates a view) -1.
    @inlinable
    public var maxMipLevel: UInt32 {
        get {
            return rawValue.MostDetailedMip
        }
        set {
            rawValue.MostDetailedMip = newValue
        }
    }

    /// The maximum number of mipmap levels for the view of the texture. See the remarks in D3D12_TEX1D_SRV. Set to -1 to indicate all the mipmap levels from MostDetailedMip on down to least detailed.
    @inlinable
    public var mipLevels: UInt32 {
        get {
            return rawValue.MipLevels
        }
        set {
            rawValue.MipLevels = newValue
        }
    }

    /// A value to clamp sample LOD values to. For example, if you specify 2.0f for the clamp value, you ensure that no individual sample accesses a mip level less than 2.0f.
    @inlinable
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
    - parameter minLODClamp: A value to clamp sample LOD values to. For example, if you specify 2.0f for the clamp value, you ensure that no individual sample accesses a mip level less than 2.0f.
    */
    @inlinable
    public init(maxMipLevel: UInt32, mipLevels: UInt32, minLODClamp: Float) {
        self.rawValue = RawValue(MostDetailedMip: maxMipLevel,
                                 MipLevels: mipLevels,
                                 ResourceMinLODClamp: minLODClamp)
    }

    @inlinable
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTextureCubeShaderResourceView")
public typealias D3D12_TEXCUBE_SRV = D3DTextureCubeShaderResourceView

#endif
