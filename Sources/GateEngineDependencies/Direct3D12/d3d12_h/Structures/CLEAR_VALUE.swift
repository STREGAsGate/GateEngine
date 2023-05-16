/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a value used to optimize clear operations for a particular resource.
public struct D3DClearValue {
    public typealias RawValue = WinSDK.D3D12_CLEAR_VALUE
    internal var rawValue: RawValue

    /// Specifies one member of the DXGI_FORMAT enum. The format of the commonly cleared color follows the same validation rules as a view/ descriptor creation. In general, the format of the clear color can be any format in the same typeless group that the resource format belongs to. This Format must match the format of the view used during the clear operation. It indicates whether the Color or the DepthStencil member is valid and how to convert the values for usage with the resource.
    @inlinable @inline(__always)
    public var format: DGIFormat {
        get {
            return DGIFormat(self.rawValue.Format)
        }
        set {
            self.rawValue.Format = newValue.rawValue
        }
    }

    /// Specifies a 4-entry array of float values, determining the RGBA value. The order of RGBA matches the order used with ClearRenderTargetView.
    @inlinable @inline(__always)
    public var color: D3DColor {
        get {
            return D3DColor(rawValue.Color)
        }
        set {
            self.rawValue.Color = newValue.tuple
        }
    }

    /// Specifies one member of D3D12_DEPTH_STENCIL_VALUE. These values match the semantics of Depth and Stencil in ClearDepthStencilView.
    @inlinable @inline(__always)
    public var depthStencil: D3DDepthStencilValue {
        get {
            return D3DDepthStencilValue(self.rawValue.DepthStencil)
        }
        set {
            self.rawValue.DepthStencil = newValue.rawValue
        }
    }

    /** Describes a value used to optimize clear operations for a particular resource.
    - parameter format: Specifies one member of the DXGI_FORMAT enum. The format of the commonly cleared color follows the same validation rules as a view/ descriptor creation. In general, the format of the clear color can be any format in the same typeless group that the resource format belongs to. This Format must match the format of the view used during the clear operation. It indicates whether the Color or the DepthStencil member is valid and how to convert the values for usage with the resource.
    - parameter color: Specifies a 4-entry array of float values, determining the RGBA value. The order of RGBA matches the order used with ClearRenderTargetView.
    - parameter depthStencil: Specifies one member of D3D12_DEPTH_STENCIL_VALUE. These values match the semantics of Depth and Stencil in ClearDepthStencilView.
    */
    @inlinable @inline(__always)
    public init(format: DGIFormat, color: D3DColor, depthStencil: D3DDepthStencilValue = .init(depth: 1, stencil: 0)) {
        self.rawValue = RawValue(format.rawValue, color.rawValue, depthStencil.rawValue)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DClearValue")
public typealias D3D12_CLEAR_VALUE = D3DClearValue 

#endif
