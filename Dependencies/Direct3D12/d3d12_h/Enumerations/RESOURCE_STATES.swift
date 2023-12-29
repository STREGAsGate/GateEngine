/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Defines constants that specify the state of a resource regarding how the resource is being used.
public struct D3DResourceStates: OptionSet {
    public typealias RawType = WinSDK.D3D12_RESOURCE_STATES
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_RESOURCE_STATES.RawValue
    public let rawValue: RawValue

    /**
    Your application should transition to this state only for accessing a resource across different graphics engine types.

    Specifically, a resource must be in the COMMON state before being used on a COPY queue (when previous used on DIRECT/COMPUTE), and before being used on DIRECT/COMPUTE (when previously used on COPY). This restriction does not exist when accessing data between DIRECT and COMPUTE queues.

    The COMMON state can be used for all usages on a Copy queue using the implicit state transitions. For more info, in Multi-engine synchronization, find "common".

    Additionally, textures must be in the COMMON state for CPU access to be legal, assuming the texture was created in a CPU-visible heap in the first place.
    */
    public static let common = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_COMMON.rawValue)
    ///	A subresource must be in this state when it is accessed by the GPU as a vertex buffer or constant buffer. This is a read-only state.
    public static let vertexAndConstantBuffer = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER.rawValue)
    ///	A subresource must be in this state when it is accessed by the 3D pipeline as an index buffer. This is a read-only state.
    public static let indexBuffer = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_INDEX_BUFFER.rawValue)
    /// The resource is used as a render target. A subresource must be in this state when it is rendered to or when it is cleared with ID3D12GraphicsCommandList::ClearRenderTargetView.
    /// This is a write-only state. To read from a render target as a shader resource the resource must be in either D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE or D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE.
    public static let renderTarget = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_RENDER_TARGET.rawValue)
    ///	The resource is used for unordered access. A subresource must be in this state when it is accessed by the GPU via an unordered access view. A subresource must also be in this state when it is cleared with ID3D12GraphicsCommandList::ClearUnorderedAccessViewInt or ID3D12GraphicsCommandList::ClearUnorderedAccessViewFloat. This is a read/write state.
    public static let unorderedAccess = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_UNORDERED_ACCESS.rawValue)
    ///	D3D12_RESOURCE_STATE_DEPTH_WRITE is a state that is mutually exclusive with other states. You should use it for ID3D12GraphicsCommandList::ClearDepthStencilView when the flags (see D3D12_CLEAR_FLAGS) indicate a given subresource should be cleared (otherwise the subresource state doesn't matter), or when using it in a writable depth stencil view (see D3D12_DSV_FLAGS) when the PSO has depth write enabled (see D3D12_DEPTH_STENCIL_DESC).
    public static let depthWrite = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_DEPTH_WRITE.rawValue)
    ///	DEPTH_READ is a state which can be combined with other states. It should be used when the subresource is in a read-only depth stencil view, or when the DepthEnable parameter of D3D12_DEPTH_STENCIL_DESC is false. It can be combined with other read states (for example, D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE), such that the resource can be used for the depth or stencil test, and accessed by a shader within the same draw call. Using it when depth will be written by a draw call or clear command is invalid.
    public static let depthRead = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_DEPTH_READ.rawValue)
    ///	The resource is used with a shader other than the pixel shader. A subresource must be in this state before being read by any stage (except for the pixel shader stage) via a shader resource view. You can still use the resource in a pixel shader with this flag as long as it also has the flag D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE set. This is a read-only state.
    public static let nonPixelShaderResource = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE.rawValue)
    ///	The resource is used with a pixel shader. A subresource must be in this state before being read by the pixel shader via a shader resource view. This is a read-only state.
    public static let pixelShaderResource = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE.rawValue)
    ///	The resource is used with stream output. A subresource must be in this state when it is accessed by the 3D pipeline as a stream-out target. This is a write-only state.
    public static let streamOut = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_STREAM_OUT.rawValue)
    /// The resource is used as an indirect argument.
    /// Subresources must be in this state when they are used as the argument buffer passed to the indirect drawing method ID3D12GraphicsCommandList::ExecuteIndirect.
    /// This is a read-only state.
    public static let indirectArgument = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_INDIRECT_ARGUMENT.rawValue)
    ///	The resource is used as the destination in a copy operation.
    /// Subresources must be in this state when they are used as the destination of copy operation, or a blt operation.
    /// This is a write-only state.
    public static let copyDestination = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_COPY_DEST.rawValue)
    ///	The resource is used as the source in a copy operation.
    /// Subresources must be in this state when they are used as the source of copy operation, or a blt operation.
    /// This is a read-only state.
    public static let copySource = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_COPY_SOURCE.rawValue)
    ///	The resource is used as the destination in a resolve operation.
    public static let resolveOperationDestination = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_RESOLVE_DEST.rawValue)
    ///	The resource is used as the source in a resolve operation.
    public static let resolveOperationSource = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_RESOLVE_SOURCE.rawValue)
    ///	When a buffer is created with this as its initial state, it indicates that the resource is a raytracing acceleration structure, for use in ID3D12GraphicsCommandList4::BuildRaytracingAccelerationStructure, ID3D12GraphicsCommandList4::CopyRaytracingAccelerationStructure, or ID3D12Device::CreateShaderResourceView for the D3D12_SRV_DIMENSION_RAYTRACING_ACCELERATION_STRUCTURE dimension.
    public static let raytracingAccelerationStructure = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE.rawValue)
    ///	Starting with Windows 10, version 1903 (10.0; Build 18362), indicates that the resource is a screen-space shading-rate image for variable-rate shading (VRS). For more info, see Variable-rate shading (VRS).
    public static let shadingRateSource = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_SHADING_RATE_SOURCE.rawValue)
    ///	D3D12_RESOURCE_STATE_GENERIC_READ is a logically OR'd combination of other read-state bits. This is the required starting state for an upload heap. Your application should generally avoid transitioning to D3D12_RESOURCE_STATE_GENERIC_READ when possible, since that can result in premature cache flushes, or resource layout changes (for example, compress/decompress), causing unnecessary pipeline stalls. You should instead transition resources only to the actually-used states.
    public static let genericRead = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_GENERIC_READ.rawValue)
    ///	Synonymous with D3D12_RESOURCE_STATE_COMMON.
    public static let present = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_PRESENT.rawValue)
    ///	The resource is used for Predication.
    public static let predication = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_PREDICATION.rawValue)
    ///	The resource is used as a source in a decode operation. Examples include reading the compressed bitstream and reading from decode references,
    public static let videoDecodeRead = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VIDEO_DECODE_READ.rawValue)
    ///	The resource is used as a destination in the decode operation. This state is used for decode output and histograms.
    public static let videoDecodeWrite = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VIDEO_DECODE_WRITE.rawValue)
    ///	The resource is used to read video data during video processing; that is, the resource is used as the source in a processing operation such as video encoding (compression).
    public static let videoProcessRead = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VIDEO_PROCESS_READ.rawValue)
    ///	The resource is used to write video data during video processing; that is, the resource is used as the destination in a processing operation such as video encoding (compression).
    public static let videoProcessWrite = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VIDEO_PROCESS_WRITE.rawValue)
    ///	The resource is used as the source in an encode operation. This state is used for the input and reference of motion estimation.
    public static let videoEncodeRead = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VIDEO_ENCODE_READ.rawValue)
    ///	This resource is used as the destination in an encode operation. This state is used for the destination texture of a resolve motion vector heap operation.
    public static let videoEncodeWrite = D3DResourceStates(rawValue: WinSDK.D3D12_RESOURCE_STATE_VIDEO_ENCODE_WRITE.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init(_ rawType: RawType) {
        self.rawValue = rawType.rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceStates")
public typealias D3D12_RESOURCE_STATES = D3DResourceStates


@available(*, deprecated, renamed: "D3DResourceStates.common")
public let D3D12_RESOURCE_STATE_COMMON = D3DResourceStates.common

@available(*, deprecated, renamed: "D3DResourceStates.vertexAndConstantBuffer")
public let D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER = D3DResourceStates.vertexAndConstantBuffer

@available(*, deprecated, renamed: "D3DResourceStates.indexBuffer")
public let D3D12_RESOURCE_STATE_INDEX_BUFFER = D3DResourceStates.indexBuffer

@available(*, deprecated, renamed: "D3DResourceStates.renderTarget")
public let D3D12_RESOURCE_STATE_RENDER_TARGET = D3DResourceStates.renderTarget

@available(*, deprecated, renamed: "D3DResourceStates.unorderedAccess")
public let D3D12_RESOURCE_STATE_UNORDERED_ACCESS = D3DResourceStates.unorderedAccess

@available(*, deprecated, renamed: "D3DResourceStates.depthWrite")
public let D3D12_RESOURCE_STATE_DEPTH_WRITE = D3DResourceStates.depthWrite

@available(*, deprecated, renamed: "D3DResourceStates.depthRead")
public let D3D12_RESOURCE_STATE_DEPTH_READ = D3DResourceStates.depthRead

@available(*, deprecated, renamed: "D3DResourceStates.nonPixelShaderResource")
public let D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE = D3DResourceStates.nonPixelShaderResource

@available(*, deprecated, renamed: "D3DResourceStates.pixelShaderResource")
public let D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE = D3DResourceStates.pixelShaderResource

@available(*, deprecated, renamed: "D3DResourceStates.streamOut")
public let D3D12_RESOURCE_STATE_STREAM_OUT = D3DResourceStates.streamOut

@available(*, deprecated, renamed: "D3DResourceStates.indirectArgument")
public let D3D12_RESOURCE_STATE_INDIRECT_ARGUMENT = D3DResourceStates.indirectArgument

@available(*, deprecated, renamed: "D3DResourceStates.copyDestination")
public let D3D12_RESOURCE_STATE_COPY_DEST = D3DResourceStates.copyDestination

@available(*, deprecated, renamed: "D3DResourceStates.copySource")
public let D3D12_RESOURCE_STATE_COPY_SOURCE = D3DResourceStates.copySource

@available(*, deprecated, renamed: "D3DResourceStates.resolveOperationDestination")
public let D3D12_RESOURCE_STATE_RESOLVE_DEST = D3DResourceStates.resolveOperationDestination

@available(*, deprecated, renamed: "D3DResourceStates.resolveOperationSource")
public let D3D12_RESOURCE_STATE_RESOLVE_SOURCE = D3DResourceStates.resolveOperationSource

@available(*, deprecated, renamed: "D3DResourceStates.raytracingAccelerationStructure")
public let D3D12_RESOURCE_STATE_RAYTRACING_ACCELERATION_STRUCTURE = D3DResourceStates.raytracingAccelerationStructure

@available(*, deprecated, renamed: "D3DResourceStates.shadingRateSource")
public let D3D12_RESOURCE_STATE_SHADING_RATE_SOURCE = D3DResourceStates.shadingRateSource

@available(*, deprecated, renamed: "D3DResourceStates.genericRead")
public let D3D12_RESOURCE_STATE_GENERIC_READ = D3DResourceStates.genericRead

@available(*, deprecated, renamed: "D3DResourceStates.present")
public let D3D12_RESOURCE_STATE_PRESENT = D3DResourceStates.present

@available(*, deprecated, renamed: "D3DResourceStates.predication")
public let D3D12_RESOURCE_STATE_PREDICATION = D3DResourceStates.predication

@available(*, deprecated, renamed: "D3DResourceStates.videoDecodeRead")
public let D3D12_RESOURCE_STATE_VIDEO_DECODE_READ = D3DResourceStates.videoDecodeRead

@available(*, deprecated, renamed: "D3DResourceStates.videoDecodeWrite")
public let D3D12_RESOURCE_STATE_VIDEO_DECODE_WRITE = D3DResourceStates.videoDecodeWrite

@available(*, deprecated, renamed: "D3DResourceStates.videoProcessRead")
public let D3D12_RESOURCE_STATE_VIDEO_PROCESS_READ = D3DResourceStates.videoProcessRead

@available(*, deprecated, renamed: "D3DResourceStates.videoProcessWrite")
public let D3D12_RESOURCE_STATE_VIDEO_PROCESS_WRITE = D3DResourceStates.videoProcessWrite

@available(*, deprecated, renamed: "D3DResourceStates.videoEncodeRead")
public let D3D12_RESOURCE_STATE_VIDEO_ENCODE_READ = D3DResourceStates.videoEncodeRead

@available(*, deprecated, renamed: "D3DResourceStates.videoEncodeWrite")
public let D3D12_RESOURCE_STATE_VIDEO_ENCODE_WRITE = D3DResourceStates.videoEncodeWrite

#endif
