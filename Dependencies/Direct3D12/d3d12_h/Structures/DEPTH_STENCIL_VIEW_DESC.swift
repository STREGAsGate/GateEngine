/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresources of a texture that are accessible from a depth-stencil view.
public struct D3DDepthStencilViewDescription {
    public typealias RawValue = WinSDK.D3D12_DEPTH_STENCIL_VIEW_DESC
    @usableFromInline
    internal var rawValue: RawValue

    /// A DXGI_FORMAT-typed value that specifies the viewing format. For allowable formats, see Remarks.
    @inlinable @inline(__always)
    public var format: DGIFormat {
        get {
            return DGIFormat(rawValue.Format)
        }
        set {
            rawValue.Format = newValue.rawValue
        }
    }

    /// A D3D12_DSV_DIMENSION-typed value that specifies how the depth-stencil resource will be accessed. This member also determines which _DSV to use in the following union.
    @inlinable @inline(__always)
    public var dimension: D3DDSVDimension {
        get {
            return D3DDSVDimension(rawValue.ViewDimension)
        }
        set {
            rawValue.ViewDimension = newValue.rawValue
        }
    }

    /// A combination of D3D12_DSV_FLAGS enumeration constants that are combined by using a bitwise OR operation. The resulting value specifies whether the texture is read only. Pass 0 to specify that it isn't read only; otherwise, pass one or more of the members of the D3D12_DSV_FLAGS enumerated type.
    @inlinable @inline(__always)
    public var flags: D3DDepthStencilViewFlags {
        get {
            return D3DDepthStencilViewFlags(rawValue.Flags)
        }
        set {
            rawValue.Flags = D3DDepthStencilViewFlags.RawType(newValue.rawValue)
        }
    }

    /// A D3D12_TEX1D_DSV structure that specifies a 1D texture subresource.
    @inlinable @inline(__always)
    public var texture1D: D3DTexture1DDepthStencilView {
        get {
            return D3DTexture1DDepthStencilView(rawValue.Texture1D)
        }
        set {
            rawValue.Texture1D = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_ARRAY_DSV structure that specifies an array of 1D texture subresources.
    @inlinable @inline(__always)
    public var texture1DArray: D3DTexture1DArrayDepthStencilView {
        get {
            return D3DTexture1DArrayDepthStencilView(rawValue.Texture1DArray)
        }
        set {
            rawValue.Texture1DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_DSV structure that specifies a 2D texture subresource.
    @inlinable @inline(__always)
    public var texture2D: D3DTexture2DDepthStencilView {
        get {
            return D3DTexture2DDepthStencilView(rawValue.Texture2D)
        }
        set {
            rawValue.Texture2D = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_ARRAY_DSV structure that specifies an array of 2D texture subresources.
    @inlinable @inline(__always)
    public var texture2DArray: D3DTexture2DArrayDepthStencilView {
        get {
            return D3DTexture2DArrayDepthStencilView(rawValue.Texture2DArray)
        }
        set {
            rawValue.Texture2DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2DMS_DSV structure that specifies a multisampled 2D texture.
    @inlinable @inline(__always)
    public var texture2DMultiSampled: D3DTexture2DMultiSampledDepthStencilView {
        get {
            return D3DTexture2DMultiSampledDepthStencilView(rawValue.Texture2DMS)
        }
        set {
            rawValue.Texture2DMS = newValue.rawValue
        }
    }

    /// A D3D12_TEX2DMS_ARRAY_DSV structure that specifies an array of multisampled 2D textures.
    @inlinable @inline(__always)
    public var texture2DMultiSampledArray: D3DTexture2DMultiSampledArrayDepthStencilView {
        get {
            return D3DTexture2DMultiSampledArrayDepthStencilView(rawValue.Texture2DMSArray)
        }
        set {
            rawValue.Texture2DMSArray = newValue.rawValue
        }
    }

    /** Describes the subresources of a texture that are accessible from a depth-stencil view.
    - parameter format: A DXGI_FORMAT-typed value that specifies the viewing format. For allowable formats, see Remarks.
    - parameter dimension: A D3D12_DSV_DIMENSION-typed value that specifies how the depth-stencil resource will be accessed. This member also determines which _DSV to use in the following union.
    - parameter flags: A combination of D3D12_DSV_FLAGS enumeration constants that are combined by using a bitwise OR operation. The resulting value specifies whether the texture is read only. Pass 0 to specify that it isn't read only; otherwise, pass one or more of the members of the D3D12_DSV_FLAGS enumerated type.
    - parameter texture1D: A D3D12_TEX1D_DSV structure that specifies a 1D texture subresource.
    - parameter texture1DArray: A D3D12_TEX1D_ARRAY_DSV structure that specifies an array of 1D texture subresources.
    - parameter texture2D: A D3D12_TEX2D_DSV structure that specifies a 2D texture subresource.
    - parameter texture2DArray: A D3D12_TEX2D_ARRAY_DSV structure that specifies an array of 2D texture subresources.
    - parameter texture2DMultiSampled: A D3D12_TEX2DMS_DSV structure that specifies a multisampled 2D texture.
    - parameter texture2DMultiSampledArray: A D3D12_TEX2DMS_ARRAY_DSV structure that specifies an array of multisampled 2D textures.
    */
    @inlinable @inline(__always)
    public init(format: DGIFormat,
                dimension: D3DDSVDimension, 
                flags: D3DDepthStencilViewFlags,
                texture1D: D3DTexture1DDepthStencilView,
                texture1DArray: D3DTexture1DArrayDepthStencilView,
                texture2D: D3DTexture2DDepthStencilView,
                texture2DArray: D3DTexture2DArrayDepthStencilView,
                texture2DMultiSampled: D3DTexture2DMultiSampledDepthStencilView,
                texture2DMultiSampledArray: D3DTexture2DMultiSampledArrayDepthStencilView) {
        self.rawValue = RawValue()
        self.format = format
        self.dimension = dimension
        self.flags = flags
        self.texture1D = texture1D
        self.texture1DArray = texture1DArray
        self.texture2D = texture2D
        self.texture2DArray = texture2DArray
        self.texture2DMultiSampled = texture2DMultiSampled
        self.texture2DMultiSampledArray = texture2DMultiSampledArray
    }

    /// Describes the subresources of a texture that are accessible from a depth-stencil view.
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

@available(*, deprecated, renamed: "D3DDepthStencilViewDescription")
public typealias D3D12_DEPTH_STENCIL_VIEW_DESC = D3DDepthStencilViewDescription

#endif
