/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the shaders that can access the contents of a given root signature slot.
public enum D3DShaderVisibility {
    public typealias RawValue = WinSDK.D3D12_SHADER_VISIBILITY

    ///	Specifies that all shader stages can access whatever is bound at the root signature slot.
    case all
    ///	Specifies that the vertex shader stage can access whatever is bound at the root signature slot.
    case vertex
    ///	Specifies that the hull shader stage can access whatever is bound at the root signature slot.
    case hull
    ///	Specifies that the domain shader stage can access whatever is bound at the root signature slot.
    case domain
    ///	Specifies that the geometry shader stage can access whatever is bound at the root signature slot.
    case geometry
    ///	Specifies that the pixel shader stage can access whatever is bound at the root signature slot.
    case pixel
    ///	Specifies that the amplification shader stage can access whatever is bound at the root signature slot.
    case amplification
    ///	Specifies that the mesh shader stage can access whatever is bound at the root signature slot.
    case mesh

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)
    
    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .all:
            return WinSDK.D3D12_SHADER_VISIBILITY_ALL
        case .vertex:
            return WinSDK.D3D12_SHADER_VISIBILITY_VERTEX
        case .hull:
            return WinSDK.D3D12_SHADER_VISIBILITY_HULL
        case .domain:
            return WinSDK.D3D12_SHADER_VISIBILITY_DOMAIN
        case .geometry:
            return WinSDK.D3D12_SHADER_VISIBILITY_GEOMETRY
        case .pixel:
            return WinSDK.D3D12_SHADER_VISIBILITY_PIXEL
        case .amplification:
            return WinSDK.D3D12_SHADER_VISIBILITY_AMPLIFICATION
        case .mesh:
            return WinSDK.D3D12_SHADER_VISIBILITY_MESH
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_SHADER_VISIBILITY_ALL:
            self = .all
        case WinSDK.D3D12_SHADER_VISIBILITY_VERTEX:
            self = .vertex
        case WinSDK.D3D12_SHADER_VISIBILITY_HULL:
            self = .hull
        case WinSDK.D3D12_SHADER_VISIBILITY_DOMAIN:
            self = .domain
        case WinSDK.D3D12_SHADER_VISIBILITY_GEOMETRY:
            self = .geometry
        case WinSDK.D3D12_SHADER_VISIBILITY_PIXEL:
            self = .pixel
        case WinSDK.D3D12_SHADER_VISIBILITY_AMPLIFICATION:
            self = .amplification
        case WinSDK.D3D12_SHADER_VISIBILITY_MESH:
            self = .mesh
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DShaderVisibility")
public typealias D3D12_SHADER_VISIBILITY = D3DShaderVisibility


@available(*, deprecated, renamed: "D3DShaderVisibility.all")
public let D3D12_SHADER_VISIBILITY_ALL = D3DShaderVisibility.all

@available(*, deprecated, renamed: "D3DShaderVisibility.vertex")
public let D3D12_SHADER_VISIBILITY_VERTEX = D3DShaderVisibility.vertex

@available(*, deprecated, renamed: "D3DShaderVisibility.hull")
public let D3D12_SHADER_VISIBILITY_HULL = D3DShaderVisibility.hull

@available(*, deprecated, renamed: "D3DShaderVisibility.domain")
public let D3D12_SHADER_VISIBILITY_DOMAIN = D3DShaderVisibility.domain

@available(*, deprecated, renamed: "D3DShaderVisibility.geometry")
public let D3D12_SHADER_VISIBILITY_GEOMETRY = D3DShaderVisibility.geometry

@available(*, deprecated, renamed: "D3DShaderVisibility.pixel")
public let D3D12_SHADER_VISIBILITY_PIXEL = D3DShaderVisibility.pixel

@available(*, deprecated, renamed: "D3DShaderVisibility.amplification")
public let D3D12_SHADER_VISIBILITY_AMPLIFICATION = D3DShaderVisibility.amplification

@available(*, deprecated, renamed: "D3DShaderVisibility.mesh")
public let D3D12_SHADER_VISIBILITY_MESH = D3DShaderVisibility.mesh

#endif
