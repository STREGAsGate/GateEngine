/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the type of the indirect parameter.
public enum D3DIndirectArgumentType {
    public typealias RawValue = WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE

    ///	Indicates the type is a Draw call.
    case draw
    ///	Indicates the type is a DrawIndexed call.
    case drawIndexed
    ///	Indicates the type is a Dispatch call.
    case dispatch
    ///	Indicates the type is a vertex buffer view.
    case vertexBufferView
    ///	Indicates the type is an index buffer view.
    case indexBufferView
    ///	Indicates the type is a constant.
    case constant
    ///	Indicates the type is a constant buffer view (CBV).
    case constantBufferView
    ///	Indicates the type is a shader resource view (SRV).
    case shaderResourceView
    ///	Indicates the type is an unordered access view (UAV).
    case unorderedAccessView
    case dispatchRays
    case dispatchMesh

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .draw:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DRAW
        case .drawIndexed:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DRAW_INDEXED
        case .dispatch:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH
        case .vertexBufferView:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_VERTEX_BUFFER_VIEW
        case .indexBufferView:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_INDEX_BUFFER_VIEW
        case .constant:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_CONSTANT
        case .constantBufferView:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_CONSTANT_BUFFER_VIEW
        case .shaderResourceView:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_SHADER_RESOURCE_VIEW
        case .unorderedAccessView:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_UNORDERED_ACCESS_VIEW
        case .dispatchRays:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH_RAYS
        case .dispatchMesh:
            return WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH_MESH
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DRAW:
            self =  .draw
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DRAW_INDEXED:
            self = .drawIndexed
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH:
            self = .dispatch
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_VERTEX_BUFFER_VIEW:
            self = .vertexBufferView
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_INDEX_BUFFER_VIEW:
            self = .indexBufferView
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_CONSTANT:
            self = .constant
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_CONSTANT_BUFFER_VIEW:
            self = .constantBufferView
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_SHADER_RESOURCE_VIEW:
            self = .shaderResourceView
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_UNORDERED_ACCESS_VIEW:
            self = .unorderedAccessView
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH_RAYS:
            self = .dispatchRays
        case WinSDK.D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH_MESH:
            self = .dispatchMesh
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DIndirectArgumentType")
public typealias D3D12_INDIRECT_ARGUMENT_TYPE = D3DIndirectArgumentType


@available(*, deprecated, renamed: "D3DIndirectArgumentType.draw")
public let D3D12_INDIRECT_ARGUMENT_TYPE_DRAW = D3DIndirectArgumentType.draw

@available(*, deprecated, renamed: "D3DIndirectArgumentType.drawIndexed")
public let D3D12_INDIRECT_ARGUMENT_TYPE_DRAW_INDEXED = D3DIndirectArgumentType.drawIndexed

@available(*, deprecated, renamed: "D3DIndirectArgumentType.dispatch")
public let D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH = D3DIndirectArgumentType.dispatch

@available(*, deprecated, renamed: "D3DIndirectArgumentType.vertexBufferView")
public let D3D12_INDIRECT_ARGUMENT_TYPE_VERTEX_BUFFER_VIEW = D3DIndirectArgumentType.vertexBufferView

@available(*, deprecated, renamed: "D3DIndirectArgumentType.indexBufferView")
public let D3D12_INDIRECT_ARGUMENT_TYPE_INDEX_BUFFER_VIEW = D3DIndirectArgumentType.indexBufferView

@available(*, deprecated, renamed: "D3DIndirectArgumentType.constant")
public let D3D12_INDIRECT_ARGUMENT_TYPE_CONSTANT = D3DIndirectArgumentType.constant

@available(*, deprecated, renamed: "D3DIndirectArgumentType.constantBufferView")
public let D3D12_INDIRECT_ARGUMENT_TYPE_CONSTANT_BUFFER_VIEW = D3DIndirectArgumentType.constantBufferView

@available(*, deprecated, renamed: "D3DIndirectArgumentType.shaderResourceView")
public let D3D12_INDIRECT_ARGUMENT_TYPE_SHADER_RESOURCE_VIEW = D3DIndirectArgumentType.shaderResourceView

@available(*, deprecated, renamed: "D3DIndirectArgumentType.unorderedAccessView")
public let D3D12_INDIRECT_ARGUMENT_TYPE_UNORDERED_ACCESS_VIEW = D3DIndirectArgumentType.unorderedAccessView

@available(*, deprecated, renamed: "D3DIndirectArgumentType.dispatchRays")
public let D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH_RAYS = D3DIndirectArgumentType.dispatchRays

@available(*, deprecated, renamed: "D3DIndirectArgumentType.dispatchMesh")
public let D3D12_INDIRECT_ARGUMENT_TYPE_DISPATCH_MESH = D3DIndirectArgumentType.dispatchMesh

#endif
