/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the type of root signature slot.
public enum D3DRootParameterType {
    public typealias RawValue = WinSDK.D3D12_ROOT_PARAMETER_TYPE

    ///	The slot is for a descriptor table.
    case descriptorTable
    ///	The slot is for root constants.
    case constants
    ///	The slot is for a constant-buffer view (CBV).
    case constantBufferView
    ///	The slot is for a shader-resource view (SRV).
    case shaderResourceView
    ///	The slot is for a unordered-access view (UAV).
    case unorderedAccessView

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .descriptorTable:
            return WinSDK.D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE
        case .constants:
            return WinSDK.D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS
        case .constantBufferView:
            return WinSDK.D3D12_ROOT_PARAMETER_TYPE_CBV
        case .shaderResourceView:
            return WinSDK.D3D12_ROOT_PARAMETER_TYPE_SRV
        case .unorderedAccessView:
            return WinSDK.D3D12_ROOT_PARAMETER_TYPE_UAV
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE:
            self = .descriptorTable
        case WinSDK.D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS:
            self = .constants
        case WinSDK.D3D12_ROOT_PARAMETER_TYPE_CBV:
            self = .constantBufferView
        case WinSDK.D3D12_ROOT_PARAMETER_TYPE_SRV:
            self = .shaderResourceView
        case WinSDK.D3D12_ROOT_PARAMETER_TYPE_UAV:
            self = .unorderedAccessView
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootParameterType")
public typealias D3D12_ROOT_PARAMETER_TYPE = D3DRootParameterType


@available(*, deprecated, renamed: "D3DRootParameterType.descriptorTable")
public let D3D12_ROOT_PARAMETER_TYPE_DESCRIPTOR_TABLE = D3DRootParameterType.descriptorTable

@available(*, deprecated, renamed: "D3DRootParameterType.constants")
public let D3D12_ROOT_PARAMETER_TYPE_32BIT_CONSTANTS = D3DRootParameterType.constants

@available(*, deprecated, renamed: "D3DRootParameterType.constantBufferView")
public let D3D12_ROOT_PARAMETER_TYPE_CBV = D3DRootParameterType.constantBufferView

@available(*, deprecated, renamed: "D3DRootParameterType.shaderResourceView")
public let D3D12_ROOT_PARAMETER_TYPE_SRV = D3DRootParameterType.shaderResourceView

@available(*, deprecated, renamed: "D3DRootParameterType.unorderedAccessView")
public let D3D12_ROOT_PARAMETER_TYPE_UAV = D3DRootParameterType.unorderedAccessView

#endif
