/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies the stencil operations that can be performed during depth-stencil testing.
public enum D3DStencilOperation {
    public typealias RawValue = WinSDK.D3D12_STENCIL_OP
    ///	Keep the existing stencil data.
    case keep
    ///	Set the stencil data to 0.
    case zero
    ///	Set the stencil data to the reference value set by calling ID3D12GraphicsCommandList::OMSetStencilRef.
    case replace
    ///	Increment the stencil value by 1, and clamp the result.
    case incrementClamp
    ///	Decrement the stencil value by 1, and clamp the result.
    case decrementClamp
    ///	Invert the stencil data.
    case invert
    ///	Increment the stencil value by 1, and wrap the result if necessary.
    case incrementWrap
    ///	Decrement the stencil value by 1, and wrap the result if necessary.
    case decrementWrap

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .keep:
            return WinSDK.D3D12_STENCIL_OP_KEEP
        case .zero:
            return WinSDK.D3D12_STENCIL_OP_ZERO
        case .replace:
            return WinSDK.D3D12_STENCIL_OP_REPLACE
        case .incrementClamp:
            return WinSDK.D3D12_STENCIL_OP_INCR_SAT
        case .decrementClamp:
            return WinSDK.D3D12_STENCIL_OP_DECR_SAT
        case .invert:
            return WinSDK.D3D12_STENCIL_OP_INVERT
        case .incrementWrap:
            return WinSDK.D3D12_STENCIL_OP_INCR
        case .decrementWrap:
            return WinSDK.D3D12_STENCIL_OP_DECR
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_STENCIL_OP_KEEP:
            self = .keep
        case WinSDK.D3D12_STENCIL_OP_ZERO:
            self = .zero
        case WinSDK.D3D12_STENCIL_OP_REPLACE:
            self = .replace
        case WinSDK.D3D12_STENCIL_OP_INCR_SAT:
            self = .incrementClamp
        case WinSDK.D3D12_STENCIL_OP_DECR_SAT:
            self = .decrementClamp
        case WinSDK.D3D12_STENCIL_OP_INVERT:
            self = .invert
        case WinSDK.D3D12_STENCIL_OP_INCR:
            self = .incrementWrap
        case WinSDK.D3D12_STENCIL_OP_DECR:
            self = .decrementWrap
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DStencilOperation.")
public typealias D3D12_STENCIL_OP = D3DStencilOperation


@available(*, deprecated, renamed: "D3DStencilOperation.keep")
public let D3D12_STENCIL_OP_KEEP = D3DStencilOperation.keep

@available(*, deprecated, renamed: "D3DStencilOperation.zero")
public let D3D12_STENCIL_OP_ZERO = D3DStencilOperation.zero

@available(*, deprecated, renamed: "D3DStencilOperation.replace")
public let D3D12_STENCIL_OP_REPLACE = D3DStencilOperation.replace

@available(*, deprecated, renamed: "D3DStencilOperation.incrementClamp")
public let D3D12_STENCIL_OP_INCR_SAT = D3DStencilOperation.incrementClamp

@available(*, deprecated, renamed: "D3DStencilOperation.decrementClamp")
public let D3D12_STENCIL_OP_DECR_SAT = D3DStencilOperation.decrementClamp

@available(*, deprecated, renamed: "D3DStencilOperation.invert")
public let D3D12_STENCIL_OP_INVERT = D3DStencilOperation.invert

@available(*, deprecated, renamed: "D3DStencilOperation.incrementWrap")
public let D3D12_STENCIL_OP_INCR = D3DStencilOperation.incrementWrap

@available(*, deprecated, renamed: "D3DStencilOperation.decrementWrap")
public let D3D12_STENCIL_OP_DECR = D3DStencilOperation.decrementWrap

#endif
