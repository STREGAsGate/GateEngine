/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the fill mode to use when rendering triangles.
public enum D3DFillMode {
    public typealias RawValue = WinSDK.D3D12_FILL_MODE

    ///	Draw lines connecting the vertices. Adjacent vertices are not drawn.
    case wireframe
    ///	Fill the triangles formed by the vertices. Adjacent vertices are not drawn.
    case solid

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .wireframe:
            return WinSDK.D3D12_FILL_MODE_WIREFRAME
        case .solid:
            return WinSDK.D3D12_FILL_MODE_SOLID
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_FILL_MODE_WIREFRAME:
            self = .wireframe
        case WinSDK.D3D12_FILL_MODE_SOLID:
            self = .solid
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DFillMode")
public typealias D3D12_FILL_MODE = D3DFillMode


@available(*, deprecated, renamed: "D3DFillMode.wireframe")
public let D3D12_FILL_MODE_WIREFRAME = D3DFillMode.wireframe

@available(*, deprecated, renamed: "D3DFillMode.solid")
public let D3D12_FILL_MODE_SOLID = D3DFillMode.solid

#endif
