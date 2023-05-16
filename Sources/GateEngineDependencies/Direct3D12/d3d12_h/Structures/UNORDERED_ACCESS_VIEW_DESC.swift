/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the subresources from a resource that are accessible by using an unordered-access view.
public struct D3DUnorderedAccessViewDescription {
    public typealias RawValue = WinSDK.D3D12_UNORDERED_ACCESS_VIEW_DESC
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

    /// A D3D12_UAV_DIMENSION-typed value that specifies the resource type of the view. This type specifies how the resource will be accessed. This member also determines which _UAV to use in the union below.
    @inlinable @inline(__always)
    public var dimension: D3DUnorderedAccessViewDimension {
        get {
            return D3DUnorderedAccessViewDimension(rawValue.ViewDimension)
        }
        set {
            rawValue.ViewDimension = newValue.rawValue
        }
    }

    /// A D3D12_BUFFER_UAV structure that specifies which buffer elements can be accessed.
    @inlinable @inline(__always)
    public var buffer: D3DUnorderedAccessViewBuffer {
        get {
            return D3DUnorderedAccessViewBuffer(rawValue.Buffer)
        }
        set {
            rawValue.Buffer = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_UAV structure that specifies the subresources in a 1D texture that can be accessed.
    @inlinable @inline(__always)
    public var texture1D: D3DTexture1DUnorderedAccessView {
        get {
            return D3DTexture1DUnorderedAccessView(rawValue.Texture1D)
        }
        set {
            rawValue.Texture1D = newValue.rawValue
        }
    }

    /// A D3D12_TEX1D_ARRAY_UAV structure that specifies the subresources in a 1D texture array that can be accessed.
    @inlinable @inline(__always)
    public var texture1DArray: D3DTexture1DArrayUnorderedAccessView {
        get {
            return D3DTexture1DArrayUnorderedAccessView(rawValue.Texture1DArray)
        }
        set {
            rawValue.Texture1DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_UAV structure that specifies the subresources in a 2D texture that can be accessed.
    @inlinable @inline(__always)
    public var texture2D: D3DTexture2DUnorderedAccessView {
        get {
            return D3DTexture2DUnorderedAccessView(rawValue.Texture2D)
        }
        set {
            rawValue.Texture2D = newValue.rawValue
        }
    }

    /// A D3D12_TEX2D_ARRAY_UAV structure that specifies the subresources in a 2D texture array that can be accessed.
    @inlinable @inline(__always)
    public var texture2DArray: D3DTexture2DArrayUnorderedAccessView {
        get {
            return D3DTexture2DArrayUnorderedAccessView(rawValue.Texture2DArray)
        }
        set {
            rawValue.Texture2DArray = newValue.rawValue
        }
    }

    /// A D3D12_TEX3D_UAV structure that specifies subresources in a 3D texture that can be accessed.
    @inlinable @inline(__always)
    public var texture3D: D3DTexture3DUnorderedAccessView {
        get {
            return D3DTexture3DUnorderedAccessView(rawValue.Texture3D)
        }
        set {
            rawValue.Texture3D = newValue.rawValue
        }
    }

    /** Describes the subresources from a resource that are accessible by using an unordered-access view.
    - parameter format: A DXGI_FORMAT-typed value that specifies the viewing format.
    - parameter dimension: A D3D12_UAV_DIMENSION-typed value that specifies the resource type of the view. This type specifies how the resource will be accessed. This member also determines which _UAV to use in the union below.
    - parameter buffer: A D3D12_BUFFER_UAV structure that specifies which buffer elements can be accessed.
    - parameter texture1D: A D3D12_TEX1D_UAV structure that specifies the subresources in a 1D texture that can be accessed.
    - parameter texture1DArray: A D3D12_TEX1D_ARRAY_UAV structure that specifies the subresources in a 1D texture array that can be accessed.
    - parameter texture2D: A D3D12_TEX2D_UAV structure that specifies the subresources in a 2D texture that can be accessed.
    - parameter texture2DArray: A D3D12_TEX2D_ARRAY_UAV structure that specifies the subresources in a 2D texture array that can be accessed.
    - parameter texture3D: A D3D12_TEX3D_UAV structure that specifies subresources in a 3D texture that can be accessed.
    */
    @inlinable @inline(__always)
    public init(format: DGIFormat,
                dimension: D3DUnorderedAccessViewDimension,
                buffer: D3DUnorderedAccessViewBuffer,
                texture1D: D3DTexture1DUnorderedAccessView,
                texture1DArray: D3DTexture1DArrayUnorderedAccessView,
                texture2D: D3DTexture2DUnorderedAccessView,
                texture2DArray: D3DTexture2DArrayUnorderedAccessView,
                texture3D: D3DTexture3DUnorderedAccessView) {
        self.rawValue = RawValue()
        self.format = format
        self.dimension = dimension
        self.buffer = buffer
        self.texture1D = texture1D
        self.texture1DArray = texture1DArray
        self.texture2D = texture2D
        self.texture2DArray = texture2DArray
        self.texture3D = texture3D
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DUnorderedAccessViewDescription")
public typealias D3D12_UNORDERED_ACCESS_VIEW_DESC = D3DUnorderedAccessViewDescription

#endif
