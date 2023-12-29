/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies whether conservative rasterization is on or off.
public enum D3DConservativeRasterizationMode {
    public typealias RawValue = WinSDK.D3D12_CONSERVATIVE_RASTERIZATION_MODE

    ///	Conservative rasterization is off.
    case off
    ///	Conservative rasterization is on.
    case on

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .off:
            return WinSDK.D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF
        case .on:
            return WinSDK.D3D12_CONSERVATIVE_RASTERIZATION_MODE_ON
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF:
            self = .off
        case WinSDK.D3D12_CONSERVATIVE_RASTERIZATION_MODE_ON:
            self = .on
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DConservativeRasterizationMode")
public typealias D3D12_CONSERVATIVE_RASTERIZATION_MODE = D3DConservativeRasterizationMode


@available(*, deprecated, renamed: "D3DConservativeRasterizationMode.off")
public let D3D12_CONSERVATIVE_RASTERIZATION_MODE_OFF = D3DConservativeRasterizationMode.off

@available(*, deprecated, renamed: "D3DConservativeRasterizationMode.on")
public let D3D12_CONSERVATIVE_RASTERIZATION_MODE_ON = D3DConservativeRasterizationMode.on

#endif
