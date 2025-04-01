/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresource from a 2D texture that is accessible to a depth-stencil view.
public struct D3DTexture2DDepthStencilView {
    public typealias RawValue = WinSDK.D3D12_TEX2D_DSV
    @usableFromInline
    internal var rawValue: RawValue

    /// The index of the first mipmap level to use.
    @inlinable
    public var mipIndex: UInt32 {
        get {
            return rawValue.MipSlice
        }
        set {
            rawValue.MipSlice = newValue
        }
    }

    /** Describes the subresource from a 2D texture that is accessible to a depth-stencil view.
    - parameter mipIndex: The index of the first mipmap level to use.
    */
    @inlinable
    public init(mipIndex: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex)
    }

    @inlinable
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture2DDepthStencilView")
public typealias D3D12_TEX2D_DSV = D3DTexture2DDepthStencilView

#endif
