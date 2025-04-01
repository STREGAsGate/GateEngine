/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a graphics pipeline state object.
public struct D3DGraphicsPipelineStateDescription {
    public typealias RawValue = WinSDK.D3D12_GRAPHICS_PIPELINE_STATE_DESC

    /// A pointer to the ID3D12RootSignature object.
    public var rootSignature: D3DRootSignature?

    /// A D3D12_SHADER_BYTECODE structure that describes the vertex shader.
    public var vertexShader: D3DShaderBytecode

    /// A D3D12_SHADER_BYTECODE structure that describes the pixel shader.
    public var pixelShader: D3DShaderBytecode

    /// A D3D12_SHADER_BYTECODE structure that describes the domain shader.
    public var domainShader: D3DShaderBytecode

    /// A D3D12_SHADER_BYTECODE structure that describes the hull shader.
    public var hullShader: D3DShaderBytecode

    /// A D3D12_SHADER_BYTECODE structure that describes the geometry shader.
    public var geometryShader: D3DShaderBytecode

    /// A D3D12_STREAM_OUTPUT_DESC structure that describes a streaming output buffer.
    public var streamOutput: D3DStreamOutputDescription

    /// A D3D12_BLEND_DESC structure that describes the blend state.
    public var blendState: D3DBlendDescription

    /// The sample mask for the blend state.
    public var sampleMask: UInt32

    /// A D3D12_RASTERIZER_DESC structure that describes the rasterizer state.
    public var rasterizerState: D3DRasterizerDescription

    /// A D3D12_DEPTH_STENCIL_DESC structure that describes the depth-stencil state.
    public var depthStencilState: D3DDepthStencilDescription

    /// A D3D12_INPUT_LAYOUT_DESC structure that describes the input-buffer data for the input-assembler stage.
    public var inputLayout: D3DInputLayoutDescription

    /// Specifies the properties of the index buffer in a D3D12_INDEX_BUFFER_STRIP_CUT_VALUE structure.
    public var indexBufferStripCutValue: D3DIndexBufferStripCutValue

    /// A D3D12_PRIMITIVE_TOPOLOGY_TYPE-typed value for the type of primitive, and ordering of the primitive data.
    public var primitiveTopologyType: D3DPrimitiveTopologyType

    /// An array of DXGI_FORMAT-typed values for the render target formats.
    public var renderTargetFormats: [DGIFormat]

    /// A DXGI_FORMAT-typed value for the depth-stencil format.
    public var depthStencilFormat: DGIFormat

    /// A DXGI_SAMPLE_DESC structure that specifies multisampling parameters.
    public var sampleDescription: DGISampleDescription

    /// For single GPU operation, set this to zero. If there are multiple GPU nodes, set a bit to identify the node (the device's physical adapter) to which the command queue applies. Each bit in the mask corresponds to a single node. Only 1 bit must be set. Refer to Multi-adapter systems.
    public var multipleAdapterNodeMask: UInt32

    /// A cached pipeline state object, as a D3D12_CACHED_PIPELINE_STATE structure. pCachedBlob and CachedBlobSizeInBytes may be set to NULL and 0 respectively.
    public var cachedPipelineState: D3DCachedPipelineState

    /// A D3D12_PIPELINE_STATE_FLAGS enumeration constant such as for "tool debug".
    public var flags: D3DPipelineStateFlags

    /** Describes a graphics pipeline state object.
    - parameter rootSignature: A pointer to the ID3D12RootSignature object.
    - parameter vertexShader: A D3D12_SHADER_BYTECODE structure that describes the vertex shader.
    - parameter pixelShader: A D3D12_SHADER_BYTECODE structure that describes the pixel shader.
    - parameter domainShader: A D3D12_SHADER_BYTECODE structure that describes the domain shader.
    - parameter hullShader: A D3D12_SHADER_BYTECODE structure that describes the hull shader.
    - parameter geometryShader: A D3D12_SHADER_BYTECODE structure that describes the geometry shader.
    - parameter streamOutput: A D3D12_STREAM_OUTPUT_DESC structure that describes a streaming output buffer.
    - parameter blendState: A D3D12_BLEND_DESC structure that describes the blend state.
    - parameter sampleMask: The sample mask for the blend state.
    - parameter rasterizerState: A D3D12_RASTERIZER_DESC structure that describes the rasterizer state.
    - parameter depthStencilState: A D3D12_DEPTH_STENCIL_DESC structure that describes the depth-stencil state.
    - parameter inputLayout: A D3D12_INPUT_LAYOUT_DESC structure that describes the input-buffer data for the input-assembler stage.
    - parameter indexBufferStripCutValue: Specifies the properties of the index buffer in a D3D12_INDEX_BUFFER_STRIP_CUT_VALUE structure.
    - parameter primitiveTopologyType: A D3D12_PRIMITIVE_TOPOLOGY_TYPE-typed value for the type of primitive, and ordering of the primitive data.
    - parameter renderTargetFormats: An array of DXGI_FORMAT-typed values for the render target formats.
    - parameter depthStencilFormat: A DXGI_FORMAT-typed value for the depth-stencil format.
    - parameter sampleDescription: A DXGI_SAMPLE_DESC structure that specifies multisampling parameters.
    - parameter multipleAdapterNodeMask: For single GPU operation, set this to zero. If there are multiple GPU nodes, set bits to identify the nodes (the device's physical adapters) for which the graphics pipeline state is to apply. Each bit in the mask corresponds to a single node. Refer to Multi-adapter systems.
    - parameter cachedPipelineState: A cached pipeline state object, as a D3D12_CACHED_PIPELINE_STATE structure. pCachedBlob and CachedBlobSizeInBytes may be set to NULL and 0 respectively.
    - parameter flags: A D3D12_PIPELINE_STATE_FLAGS enumeration constant such as for "tool debug".
    */
    @inlinable
    public init(rootSignature: D3DRootSignature,
                vertexShader: D3DShaderBytecode,
                pixelShader: D3DShaderBytecode,
                domainShader: D3DShaderBytecode = D3DShaderBytecode(byteCodeBlob: nil),
                hullShader: D3DShaderBytecode = D3DShaderBytecode(byteCodeBlob: nil),
                geometryShader: D3DShaderBytecode = D3DShaderBytecode(byteCodeBlob: nil),
                streamOutput: D3DStreamOutputDescription = D3DStreamOutputDescription(),
                blendState: D3DBlendDescription = .normal,
                sampleMask: UInt32 = .max,
                rasterizerState: D3DRasterizerDescription = D3DRasterizerDescription(),
                depthStencilState: D3DDepthStencilDescription = D3DDepthStencilDescription(),
                inputLayout: D3DInputLayoutDescription,
                indexBufferStripCutValue: D3DIndexBufferStripCutValue = .disabled,
                primitiveTopologyType: D3DPrimitiveTopologyType,
                renderTargetFormats: [DGIFormat],
                depthStencilFormat: DGIFormat,
                sampleDescription: DGISampleDescription = DGISampleDescription(count: 1, quality: 0),
                multipleAdapterNodeMask: UInt32 = 0,
                cachedPipelineState: D3DCachedPipelineState = D3DCachedPipelineState(),
                flags: D3DPipelineStateFlags = []) {
        self.rootSignature = rootSignature
        self.vertexShader = vertexShader
        self.pixelShader = pixelShader
        self.domainShader = domainShader
        self.hullShader = hullShader
        self.geometryShader = geometryShader
        self.streamOutput = streamOutput
        self.blendState = blendState
        self.sampleMask = sampleMask
        self.rasterizerState = rasterizerState
        self.depthStencilState = depthStencilState
        self.inputLayout = inputLayout
        self.indexBufferStripCutValue = indexBufferStripCutValue
        self.primitiveTopologyType = primitiveTopologyType
        self.renderTargetFormats = renderTargetFormats
        self.depthStencilFormat = depthStencilFormat
        self.sampleDescription = sampleDescription
        self.multipleAdapterNodeMask = multipleAdapterNodeMask
        self.cachedPipelineState = cachedPipelineState
        self.flags = flags
    }

    @inlinable
    internal func withUnsafeRawValue<ResultType>(_ body: (RawValue) throws -> ResultType) rethrows -> ResultType {
        let pRootSignature = rootSignature?.performFatally(as: D3DRootSignature.RawValue.self){$0}
        return try vertexShader.withUnsafeRawValue {VS in
            return try pixelShader.withUnsafeRawValue {PS in
                return try domainShader.withUnsafeRawValue {DS in
                    return try hullShader.withUnsafeRawValue {HS in
                        return try geometryShader.withUnsafeRawValue {GS in
                            return try streamOutput.withUnsafeRawValue {StreamOutput in
                                let BlendState = blendState.rawValue
                                let SampleMask = sampleMask
                                let RasterizerState = rasterizerState.rawValue
                                let DepthStencilState = depthStencilState.rawValue
                                return try inputLayout.withUnsafeRawValue {InputLayout in
                                    let IBStripCutValue = indexBufferStripCutValue.rawValue
                                    let PrimitiveTopologyType = primitiveTopologyType.rawValue
                                    let NumRenderTargets = UInt32(renderTargetFormats.count)

                                    var renderTargetFormatsTuple = (DGIFormat.unknown.rawValue, DGIFormat.unknown.rawValue,
                                                                    DGIFormat.unknown.rawValue, DGIFormat.unknown.rawValue,
                                                                    DGIFormat.unknown.rawValue, DGIFormat.unknown.rawValue,
                                                                    DGIFormat.unknown.rawValue, DGIFormat.unknown.rawValue)
                                    for index in renderTargetFormats.indices {
                                        switch index {
                                        case 0:
                                            renderTargetFormatsTuple.0 = renderTargetFormats[index].rawValue
                                        case 1:
                                            renderTargetFormatsTuple.1 = renderTargetFormats[index].rawValue
                                        case 2:
                                            renderTargetFormatsTuple.2 = renderTargetFormats[index].rawValue
                                        case 3:
                                            renderTargetFormatsTuple.3 = renderTargetFormats[index].rawValue
                                        case 4:
                                            renderTargetFormatsTuple.4 = renderTargetFormats[index].rawValue
                                        case 5:
                                            renderTargetFormatsTuple.5 = renderTargetFormats[index].rawValue
                                        case 6:
                                            renderTargetFormatsTuple.6 = renderTargetFormats[index].rawValue
                                        case 7:
                                            renderTargetFormatsTuple.7 = renderTargetFormats[index].rawValue
                                        default:
                                            fatalError("renderTargetFormats must have 8 or fewer elements.")
                                        }
                                    }
                                    let RTVFormats = renderTargetFormatsTuple
                                    
                                    let DSVFormat = depthStencilFormat.rawValue
                                    let SampleDesc = sampleDescription.rawValue
                                    let NodeMask = multipleAdapterNodeMask
                                    let CachedPSO = cachedPipelineState.rawValue
                                    let Flags = flags.rawType

                                    let rawValue = RawValue(pRootSignature: pRootSignature,
                                                            VS: VS, PS: PS, DS: DS, HS: HS, GS: GS,
                                                            StreamOutput: StreamOutput,
                                                            BlendState: BlendState,
                                                            SampleMask: SampleMask,
                                                            RasterizerState: RasterizerState,
                                                            DepthStencilState: DepthStencilState,
                                                            InputLayout: InputLayout,
                                                            IBStripCutValue: IBStripCutValue,
                                                            PrimitiveTopologyType: PrimitiveTopologyType,
                                                            NumRenderTargets: NumRenderTargets,
                                                            RTVFormats: RTVFormats,
                                                            DSVFormat: DSVFormat,
                                                            SampleDesc: SampleDesc,
                                                            NodeMask: NodeMask,
                                                            CachedPSO: CachedPSO,
                                                            Flags: Flags)

                                    return try body(rawValue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DGraphicsPipelineStateDescription")
public typealias D3D12_GRAPHICS_PIPELINE_STATE_DESC = D3DGraphicsPipelineStateDescription

#endif
