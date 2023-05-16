/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresources from a resource that are accessible by using a render-target view.
public struct D3DRenderTargetViewDescription {
    public typealias RawValue = WinSDK.D3D12_RENDER_TARGET_VIEW_DESC
    @usableFromInline
    internal var rawValue: RawValue

    /// A DXGI_FORMAT-typed value that specifies the viewing format.
    @inlinable @inline(__always)
    public var format: DGIFormat {
        get {
            return DGIFormat(rawValue.Format)
        }
        set {
            rawValue.Format = newValue.rawValue
        }
    }

    /// A D3D12_RTV_DIMENSION-typed value that specifies how the render-target resource will be accessed. This type specifies how the resource will be accessed. This member also determines which _RTV to use in the following union.
    @inlinable @inline(__always)
    public var dimension: D3DRenderTargetViewDiemension {
        get {
            return D3DRenderTargetViewDiemension(rawValue.ViewDimension)
        }
        set {
            rawValue.ViewDimension = newValue.rawValue
        }
    }

    /// A D3D12_BUFFER_RTV structure that specifies which buffer elements can be accessed.
    @inlinable @inline(__always)
    public var buffer: D3DRenderTargetViewBuffer {
        get {
            return D3DRenderTargetViewBuffer(rawValue.Buffer)
        }
        set {
            rawValue.Buffer = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_RTV structure that specifies the subresources in a 1D texture that can be accessed.
    @inlinable @inline(__always)
    public var texture1D: D3DTexture1DRenderTargetView {
        get {
            return D3DTexture1DRenderTargetView(rawValue.Texture1D)
        }
        set {
            rawValue.Texture1D = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_ARRAY_RTV structure that specifies the subresources in a 1D texture array that can be accessed.
    @inlinable @inline(__always)
    public var texture1DArray: D3DTexture1DArrayRenderTargetView {
        get {
            return D3DTexture1DArrayRenderTargetView(rawValue.Texture1DArray)
        }
        set {
            rawValue.Texture1DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_RTV structure that specifies the subresources in a 2D texture that can be accessed.
    @inlinable @inline(__always)
    public var texture2D: D3DTexture2DRenderTargetView {
        get {
            return D3DTexture2DRenderTargetView(rawValue.Texture2D)
        }
        set {
            rawValue.Texture2D = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_ARRAY_RTV structure that specifies the subresources in a 2D texture array that can be accessed.
    @inlinable @inline(__always)
    public var texture2DArray: D3DTexture2DArrayRenderTargetView {
        get {
            return D3DTexture2DArrayRenderTargetView(rawValue.Texture2DArray)
        }
        set {
            rawValue.Texture2DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2DMS_RTV structure that specifies a single subresource because a multisampled 2D texture only contains one subresource.
    @inlinable @inline(__always)
    public var texture2DMultiSampled: D3DTexture2DMultiSampledRenderTargetView {
        get {
            return D3DTexture2DMultiSampledRenderTargetView(rawValue.Texture2DMS)
        }
        set {
            rawValue.Texture2DMS = newValue.rawValue
        }
    }

    /// A D3D12_TEX2DMS_ARRAY_RTV structure that specifies the subresources in a multisampled 2D texture array that can be accessed.
    @inlinable @inline(__always)
    public var texture2DMultiSampledArray: D3DTexture2DMultiSampledArrayRenderTargetView {
        get {
            return D3DTexture2DMultiSampledArrayRenderTargetView(rawValue.Texture2DMSArray)
        }
        set {
            rawValue.Texture2DMSArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX3D_RTV structure that specifies subresources in a 3D texture that can be accessed.
    @inlinable @inline(__always)
    public var texture3D: D3DTexture3DRenderTargetView {
        get {
            return D3DTexture3DRenderTargetView(rawValue.Texture3D)
        }
        set {
            rawValue.Texture3D = newValue.rawValue
        }
    }

    /** Describes the subresources from a resource that are accessible by using a render-target view.
    - parameter format: A DXGI_FORMAT-typed value that specifies the viewing format.
    - parameter dimension: A D3D12_RTV_DIMENSION-typed value that specifies how the render-target resource will be accessed. This type specifies how the resource will be accessed. This member also determines which _RTV to use in the following union.
    - parameter buffer: A D3D12_BUFFER_RTV structure that specifies which buffer elements can be accessed.
    - parameter texture1D: A D3D12_TEX1D_RTV structure that specifies the subresources in a 1D texture that can be accessed.
    - parameter texture1DArray: A D3D12_TEX1D_ARRAY_RTV structure that specifies the subresources in a 1D texture array that can be accessed.
    - parameter texture2D: A D3D12_TEX2D_RTV structure that specifies the subresources in a 2D texture that can be accessed.
    - parameter texture2DArray: A D3D12_TEX2D_ARRAY_RTV structure that specifies the subresources in a 2D texture array that can be accessed.
    - parameter texture2DMultiSampled: A D3D12_TEX2DMS_RTV structure that specifies a single subresource because a multisampled 2D texture only contains one subresource.
    - parameter texture2DMiltiSampledArray: A D3D12_TEX2DMS_ARRAY_RTV structure that specifies the subresources in a multisampled 2D texture array that can be accessed.
    - parameter texture3D: A D3D12_TEX3D_RTV structure that specifies subresources in a 3D texture that can be accessed.
    */
    @inlinable @inline(__always)
    public init(format: DGIFormat,
                dimension: D3DRenderTargetViewDiemension,
                buffer: D3DRenderTargetViewBuffer,
                texture1D: D3DTexture1DRenderTargetView,
                texture1DArray: D3DTexture1DArrayRenderTargetView,
                texture2D: D3DTexture2DRenderTargetView,
                texture2DArray: D3DTexture2DArrayRenderTargetView,
                texture2DMultiSampled: D3DTexture2DMultiSampledRenderTargetView,
                texture2DMultiSampledArray: D3DTexture2DMultiSampledArrayRenderTargetView,
                texture3D: D3DTexture3DRenderTargetView) {
        self.rawValue = RawValue()
        self.format = format
        self.dimension = dimension
        self.buffer = buffer
        self.texture1D = texture1D
        self.texture1DArray = texture1DArray
        self.texture2D = texture2D
        self.texture2DArray = texture2DArray
        self.texture2DMultiSampled = texture2DMultiSampled
        self.texture2DMultiSampledArray = texture2DMultiSampledArray
        self.texture3D = texture3D
    }

    /// Describes the subresources from a resource that are accessible by using a render-target view.
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

@available(*, deprecated, renamed: "D3DRenderTargetViewDescription")
public typealias D3D12_RENDER_TARGET_VIEW_DESC = D3DRenderTargetViewDescription

#endif
