/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresource from a 1D texture to use in a render-target view.
public struct D3DTexture1DRenderTargetView {
    public typealias RawValue = WinSDK.D3D12_TEX1D_RTV
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

    /** Describes the subresource from a 1D texture to use in a render-target view.
    - parameter mipIndex: The index of the first mipmap level to use.
    */
    @inlinable @inline(__always)
    public init(mipIndex: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex)
    }
    
    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture1DRenderTargetView")
public typealias D3D12_TEX1D_RTV = D3DTexture1DRenderTargetView

#endif
