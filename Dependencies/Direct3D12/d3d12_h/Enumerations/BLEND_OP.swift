/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies RGB or alpha blending operations.
public enum D3DBlendOperation {
    public typealias RawValue = WinSDK.D3D12_BLEND_OP

    ///	Add source 1 and source 2.
    case add
    ///	Subtract source 1 from source 2.
    case subtract
    ///	Subtract source 2 from source 1.
    case reverseSubtract
    ///	Find the minimum of source 1 and source 2.
    case minimum
    ///	Find the maximum of source 1 and source 2.
    case maximum

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .add:
            return WinSDK.D3D12_BLEND_OP_ADD
        case .subtract:
            return WinSDK.D3D12_BLEND_OP_SUBTRACT
        case .reverseSubtract:
            return WinSDK.D3D12_BLEND_OP_REV_SUBTRACT
        case .minimum:
            return WinSDK.D3D12_BLEND_OP_MIN
        case .maximum:
            return WinSDK.D3D12_BLEND_OP_MAX
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_BLEND_OP_ADD:
            self = .add
        case WinSDK.D3D12_BLEND_OP_SUBTRACT:
            self = .subtract
        case WinSDK.D3D12_BLEND_OP_REV_SUBTRACT:
            self = .reverseSubtract
        case WinSDK.D3D12_BLEND_OP_MIN:
            self = .minimum
        case WinSDK.D3D12_BLEND_OP_MAX:
            self = .maximum
        default:
            self = ._unimplemented(rawValue)
        }
    }
} 


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DBlendOperation")
public typealias D3D12_BLEND_OP = D3DBlendOperation


@available(*, deprecated, renamed: "D3DBlendOperation.add")
public let D3D12_BLEND_OP_ADD = D3DBlendOperation.add

@available(*, deprecated, renamed: "D3DBlendOperation.subtract")
public let D3D12_BLEND_OP_SUBTRACT = D3DBlendOperation.subtract

@available(*, deprecated, renamed: "D3DBlendOperation.reverseSubtract")
public let D3D12_BLEND_OP_REV_SUBTRACT = D3DBlendOperation.reverseSubtract

@available(*, deprecated, renamed: "D3DBlendOperation.minimum")
public let D3D12_BLEND_OP_MIN = D3DBlendOperation.minimum

@available(*, deprecated, renamed: "D3DBlendOperation.maximum")
public let D3D12_BLEND_OP_MAX = D3DBlendOperation.maximum

#endif
