/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a unordered-access 1D texture resource.
public struct D3DTexture1DUnorderedAccessView {
    public typealias RawValue = WinSDK.D3D12_TEX1D_UAV
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

    /** Describes a unordered-access 1D texture resource.
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

@available(*, deprecated, renamed: "D3DTexture1DUnorderedAccessView")
public typealias D3D12_TEX1D_UAV = D3DTexture1DUnorderedAccessView

#endif
