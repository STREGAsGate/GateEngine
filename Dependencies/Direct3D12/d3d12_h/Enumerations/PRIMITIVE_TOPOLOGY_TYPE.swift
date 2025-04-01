/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies how the pipeline interprets geometry or hull shader input primitives.
public enum D3DPrimitiveTopologyType {
    public typealias RawValue = WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE

    ///	The shader has not been initialized with an input primitive type.
    case undefined
    ///	Interpret the input primitive as a point.
    case point
    ///	Interpret the input primitive as a line.
    case line
    ///	Interpret the input primitive as a triangle.
    case triangle
    ///	Interpret the input primitive as a control point patch.
    case patch

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .undefined:
            return WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_UNDEFINED
        case .point:
            return WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_POINT
        case .line:
            return WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_LINE
        case .triangle:
            return WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE
        case .patch:
            return WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_PATCH
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_UNDEFINED:
            self = .undefined
        case WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_POINT:
            self = .point
        case WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_LINE:
            self = .line
        case WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE:
            self = .triangle
        case WinSDK.D3D12_PRIMITIVE_TOPOLOGY_TYPE_PATCH:
            self = .patch
        default:
            self = ._unimplemented(rawValue)
        }
    }
} 
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DPrimitiveTopologyType")
public typealias D3D12_PRIMITIVE_TOPOLOGY_TYPE = D3DPrimitiveTopologyType


@available(*, deprecated, renamed: "D3DPrimitiveTopologyType.undefined")
public let D3D12_PRIMITIVE_TOPOLOGY_TYPE_UNDEFINED = D3DPrimitiveTopologyType.undefined

@available(*, deprecated, renamed: "D3DPrimitiveTopologyType.point")
public let D3D12_PRIMITIVE_TOPOLOGY_TYPE_POINT = D3DPrimitiveTopologyType.point

@available(*, deprecated, renamed: "D3DPrimitiveTopologyType.line")
public let D3D12_PRIMITIVE_TOPOLOGY_TYPE_LINE = D3DPrimitiveTopologyType.line

@available(*, deprecated, renamed: "D3DPrimitiveTopologyType.triangle")
public let D3D12_PRIMITIVE_TOPOLOGY_TYPE_TRIANGLE = D3DPrimitiveTopologyType.triangle

@available(*, deprecated, renamed: "D3DPrimitiveTopologyType.patch")
public let D3D12_PRIMITIVE_TOPOLOGY_TYPE_PATCH = D3DPrimitiveTopologyType.patch

#endif
