/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies a type of descriptor heap.
public enum D3DDescriptorRangeType {
    public typealias RawValue = WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE

    ///	Specifies a range of SRVs.
    case shaderResourceView
    ///	Specifies a range of unordered-access views (UAVs).
    case unorderedAccessView
    ///	Specifies a range of constant-buffer views (CBVs).
    case constantBufferView
    ///	Specifies a range of samplers.
    case sampler

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .shaderResourceView:
            return WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_SRV
        case .unorderedAccessView:
            return WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_UAV
        case .constantBufferView:
            return WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_CBV
        case .sampler:
            return WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_SRV:
            self = .shaderResourceView
        case WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_UAV:
            self = .unorderedAccessView
        case WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_CBV:
            self = .constantBufferView
        case WinSDK.D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER:
            self = .sampler
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDescriptorRangeType")
public typealias D3D12_DESCRIPTOR_RANGE_TYPE  = D3DDescriptorRangeType


@available(*, deprecated, renamed: "D3DDescriptorRangeType.srv")
public let D3D12_DESCRIPTOR_RANGE_TYPE_SRV = D3DDescriptorRangeType.shaderResourceView

@available(*, deprecated, renamed: "D3DDescriptorRangeType.unorderedAccessView")
public let D3D12_DESCRIPTOR_RANGE_TYPE_UAV = D3DDescriptorRangeType.unorderedAccessView

@available(*, deprecated, renamed: "D3DDescriptorRangeType.constantBufferView")
public let D3D12_DESCRIPTOR_RANGE_TYPE_CBV = D3DDescriptorRangeType.constantBufferView

@available(*, deprecated, renamed: "D3DDescriptorRangeType.sampler")
public let D3D12_DESCRIPTOR_RANGE_TYPE_SAMPLER = D3DDescriptorRangeType.sampler

#endif
