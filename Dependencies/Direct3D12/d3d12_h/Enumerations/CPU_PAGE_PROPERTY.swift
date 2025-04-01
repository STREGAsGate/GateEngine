/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the CPU-page properties for the heap.
public enum D3DCPUPageProperty {
    public typealias RawValue = WinSDK.D3D12_CPU_PAGE_PROPERTY
    ///	The CPU-page property is unknown.
    case unknown
    ///	The CPU cannot access the heap, therefore no page properties are available.
    case notAvailable
    ///	The CPU-page property is write-combined.
    case writeCombine
    ///	The CPU-page property is write-back.
    case writeBack

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .unknown:
            return WinSDK.D3D12_CPU_PAGE_PROPERTY_UNKNOWN
        case .notAvailable:
            return WinSDK.D3D12_CPU_PAGE_PROPERTY_NOT_AVAILABLE
        case .writeCombine:
            return WinSDK.D3D12_CPU_PAGE_PROPERTY_WRITE_COMBINE
        case .writeBack:
            return WinSDK.D3D12_CPU_PAGE_PROPERTY_WRITE_BACK
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_CPU_PAGE_PROPERTY_UNKNOWN:
            self = .unknown
        case WinSDK.D3D12_CPU_PAGE_PROPERTY_NOT_AVAILABLE:
            self = .notAvailable
        case WinSDK.D3D12_CPU_PAGE_PROPERTY_WRITE_COMBINE:
            self = .writeCombine
        case WinSDK.D3D12_CPU_PAGE_PROPERTY_WRITE_BACK:
            self = .writeBack
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCPUPageProperty")
public typealias D3D12_CPU_PAGE_PROPERTY = D3DCPUPageProperty


@available(*, deprecated, renamed: "D3DCPUPageProperty.unknown")
public let D3D12_CPU_PAGE_PROPERTY_UNKNOWN = D3DCPUPageProperty.unknown

@available(*, deprecated, renamed: "D3DCPUPageProperty.notAvailable")
public let D3D12_CPU_PAGE_PROPERTY_NOT_AVAILABLE = D3DCPUPageProperty.notAvailable

@available(*, deprecated, renamed: "D3DCPUPageProperty.writeCombine")
public let D3D12_CPU_PAGE_PROPERTY_WRITE_COMBINE = D3DCPUPageProperty.writeCombine

@available(*, deprecated, renamed: "D3DCPUPageProperty.writeBack")
public let D3D12_CPU_PAGE_PROPERTY_WRITE_BACK = D3DCPUPageProperty.writeBack

#endif
