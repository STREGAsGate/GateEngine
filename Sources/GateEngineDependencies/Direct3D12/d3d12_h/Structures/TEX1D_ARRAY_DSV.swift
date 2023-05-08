/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresources from an array of 1D textures to use in a depth-stencil view.
public struct D3DTexture1DArrayDepthStencilView {
    public typealias RawValue = WinSDK.D3D12_TEX1D_ARRAY_DSV
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

    /** Describes the subresources from an array of 1D textures to use in a depth-stencil view.
    - parameter mipIndex: The index of the first mipmap level to use.
    - parameter textureIndex: The index of the first texture to use in an array of textures.
    - parameter textureCount: Number of textures to use.
    */
    public init(mipIndex: UInt32, textureIndex: UInt32, textureCount: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex,
                                 FirstArraySlice: textureIndex,
                                 ArraySize: textureCount)
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture1DArrayDepthStencilView")
public typealias D3D12_TEX1D_ARRAY_DSV = D3DTexture1DArrayDepthStencilView

#endif
