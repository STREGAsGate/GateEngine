/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DTexture3DUnorderedAccessView {
    public typealias RawValue = WinSDK.D3D12_TEX3D_UAV
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

    /// First depth level to use.
    @inlinable @inline(__always)
    public var depthIndex: UInt32 {
        get {
            return rawValue.FirstWSlice
        }
        set {
            rawValue.FirstWSlice = newValue
        }
    }

    /// Number of depth levels to use in the render-target view, starting from FirstWSlice. A value of -1 indicates all of the slices along the w axis, starting from FirstWSlice.
    @inlinable @inline(__always)
    public var depthCount: UInt32 {
        get {
            return rawValue.WSize
        }
        set {
            rawValue.WSize = newValue
        }
    }

    /** Describes the subresources from a 3D texture to use in a render-target view.
    - parameter mipIndex: The index of the mipmap level to use mip slice.
    - parameter depthIndex: First depth level to use.
    - parameter depthCount: Number of depth levels to use in the render-target view, starting from FirstWSlice. A value of -1 indicates all of the slices along the w axis, starting from FirstWSlice.
    */
    @inlinable @inline(__always)
    public init(mipIndex: UInt32, depthIndex: UInt32, depthCount: UInt32) {
        self.rawValue = RawValue(MipSlice: mipIndex, FirstWSlice: depthIndex, WSize: depthCount)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture3DUnorderedAccessView")
public typealias D3D12_TEX3D_UAV = D3DTexture3DUnorderedAccessView

#endif
