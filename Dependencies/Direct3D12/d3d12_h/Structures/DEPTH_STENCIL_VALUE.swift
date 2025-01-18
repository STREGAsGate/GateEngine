/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies a depth and stencil value.
public struct D3DDepthStencilValue {
    public typealias RawValue = WinSDK.D3D12_DEPTH_STENCIL_VALUE
    @usableFromInline
    internal var rawValue: RawValue

    /// Specifies the depth value.
    @inlinable @inline(__always)
    public var depth: Float {
        get {
            return rawValue.Depth
        }
        set {
            rawValue.Depth = newValue
        }
    }

    /// Specifies the stencil value.
    @inlinable @inline(__always)
    public var stencil: UInt8 {
        get {
            return rawValue.Stencil
        }
        set {
            rawValue.Stencil = newValue
        }
    }

    /** Specifies a depth and stencil value.
    - parameter depth: Specifies the depth value. 
    - parameter stencil: Specifies the stencil value.
    */
    @inlinable @inline(__always)
    public init(depth: Float, stencil: UInt8) {
        self.rawValue = RawValue()
        self.depth = depth
        self.stencil = stencil
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDepthStencilValue")
public typealias D3D12_DEPTH_STENCIL_VALUE = D3DDepthStencilValue

#endif
