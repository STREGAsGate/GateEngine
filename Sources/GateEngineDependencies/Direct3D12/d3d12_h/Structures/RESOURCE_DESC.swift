/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

// @available(Windows, deprecated: 10.0.19041, renamed: "ResourceDescription1")
/// Describes a resource, such as a texture. This structure is used extensively.
public struct D3DResourceDescription {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_DESC
    internal var rawValue: RawValue

    /// One member of D3D12_RESOURCE_DIMENSION, specifying the dimensions of the resource (for example, D3D12_RESOURCE_DIMENSION_TEXTURE1D), or whether it is a buffer ((D3D12_RESOURCE_DIMENSION_BUFFER).
    @inlinable @inline(__always)
    public var dimension: D3DResourceDimension {
        get {
            return D3DResourceDimension(rawValue.Dimension)
        }
        set {
            rawValue.Dimension = newValue.rawValue
        }
    }

    /// Specifies the alignment.
    @inlinable @inline(__always)
    public var alignment: UInt64 {
        get {
            return rawValue.Alignment
        }
        set {
            rawValue.Alignment = newValue
        }
    }

    /// Specifies the width of the resource.
    @inlinable @inline(__always)
    public var width: UInt64 {
        get {
            return rawValue.Width
        }
        set {
            rawValue.Width = newValue
        }
    }

    /// Specifies the height of the resource.
    @inlinable @inline(__always)
    public var height: UInt32 {
        get {
            return rawValue.Height
        }
        set {
            rawValue.Height = newValue
        }
    }

    /// Specifies the depth of the resource, if it is 3D, or the array size if it is an array of 1D or 2D resources.
    @inlinable @inline(__always)
    public var depthOrArraySize: UInt16 {
        get {
            return rawValue.DepthOrArraySize
        }
        set {
            rawValue.DepthOrArraySize = newValue
        }
    }

    /// Specifies the number of MIP levels.
    @inlinable @inline(__always)
    public var mipLevels: UInt16 {
        get {
            return rawValue.MipLevels
        }
        set {
            rawValue.MipLevels = newValue
        }
    }

    /// Specifies one member of DXGI_FORMAT.
    @inlinable @inline(__always)
    public var format: DGIFormat {
        get {
            return DGIFormat(rawValue.Format)
        }
        set {
            rawValue.Format = newValue.rawValue
        }
    }

    /// Specifies a DXGI_SAMPLE_DESC structure.
    @inlinable @inline(__always)
    public var sampleDescription: DGISampleDescription {
        get {
            return DGISampleDescription(rawValue.SampleDesc)
        }
        set {
            rawValue.SampleDesc = newValue.rawValue
        }
    }

    /// Specifies one member of D3D12_TEXTURE_LAYOUT.
    @inlinable @inline(__always)
    public var layout: D3DTextureLayout {
        get {
            return D3DTextureLayout(rawValue.Layout)
        }
        set {
            rawValue.Layout = newValue.rawValue
        }
    }

    /// Bitwise-OR'd flags, as D3D12_RESOURCE_FLAGS enumeration constants.
    @inlinable @inline(__always)
    public var flags: D3DResourceFlags {
        get {
            return D3DResourceFlags(rawValue.Flags)
        }
        set {
            rawValue.Flags = newValue.rawType
        }
    }

    /// Describes a resource, such as a texture. This structure is used extensively.
    @inlinable @inline(__always)
    public init() {
        self.rawValue = RawValue()
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceDescription")
public typealias D3D12_RESOURCE_DESC = D3DResourceDescription

#endif
