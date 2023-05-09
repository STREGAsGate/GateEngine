/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK
import Direct3D12
import GameMath
import Shaders

final class DX12Renderer: RendererBackend {
    let factory: DGIFactory
    let device: D3DDevice

    let commandQueue: D3DCommandQueue
    let backgroundCommandQueue: D3DCommandQueue

    let rtvIncermentSize: UInt32
    let dsvIncrementSize: UInt32
    let cbvIncrementSize: UInt32

    private var pipelineStates: [DrawFlags:D3DPipelineState] = [:]

    func draw(_ drawCommand: DrawCommand, camera: Camera?, matrices: Matrices, renderTarget: RenderTarget) {
        let renderTarget: DX12RenderTarget = renderTarget.backend as! DX12RenderTarget
        let geometries: ContiguousArray<DX12Geometry> = ContiguousArray(drawCommand.geometries.map({$0 as! DX12Geometry}))
        let encoder: D3DGraphicsCommandList = renderTarget.commandList
        let data = createUniforms(drawCommand.material, camera, matrices)
    
#if GATEENGINE_DEBUG_RENDERING
        for geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
#endif


    }

    init() {
        do {
            #if GATEENGINE_DEBUG_RENDERING
            try D3DDebug().enableDebugLayer()
            print("D3DDebug: Debug layer enabled.")
            #endif
            let factory: DGIFactory = try DGIFactory()
            let device: D3DDevice = try factory.createDefaultDevice()
            self.factory = factory
            self.device = device
            self.commandQueue = try device.createCommandQueue(type: .direct, priority: .high)
            self.backgroundCommandQueue = try device.createCommandQueue(type: .direct, priority: .normal)

            self.rtvIncermentSize = device.descriptorHandleIncrementSize(for: .renderTargetView)
            self.dsvIncrementSize = device.descriptorHandleIncrementSize(for: .depthStencilView)
            self.cbvIncrementSize = device.descriptorHandleIncrementSize(for: .constantBufferShaderResourceAndUnordererAccess)
        }catch{
            DX12Renderer.checkError(error)
        }
    }

    private var fence: D3DFence! = nil
    private var fenceValue: UInt64 = 0
    func wait() throws {
        if fence == nil {
            fence = try device.createFence()
        }
        fenceValue += 1
        try commandQueue.signal(fence: fence, value: fenceValue)
        if fence.value < fenceValue {
            let h: HANDLE? = WinSDK.CreateEventW(nil, false, false, nil)
            defer {_ = CloseHandle(h)}
            try fence.setCompletionEvent(h, whenValueIs: fenceValue)
            _ = WinSDK.WaitForSingleObject(h, INFINITE)
        }
    }
}

extension DX12Renderer {
    struct InstancedUniforms {
        let modelMatrix: SIMD16<Float>
        let inverseModelMatrix: SIMD16<Float>
        init(modelMatrix: Matrix4x4, inverseModelMatrix: Matrix4x4) {
            self.modelMatrix = modelMatrix.transposedSIMD
            self.inverseModelMatrix = inverseModelMatrix.transposedSIMD
        }
    }
    
    struct ShaderMaterial {
        enum SampleFilter: UInt32 {
            case linear = 1
            case nearest = 2
        }
        
        let scale: SIMD2<Float>
        let offset: SIMD2<Float>
        let color: SIMD4<Float>
        let sampleFilter: SampleFilter.RawValue
        
        init(scale: Size2, offset: Position2, color: Color, sampleFilter: SampleFilter) {
            self.scale = scale.simd
            self.offset = offset.simd
            self.color = color.simd
            self.sampleFilter = sampleFilter.rawValue
        }
    }

    @inline(__always)
    private func createUniforms(_ material: Material, _ camera: Camera?, _ matricies: Matrices) -> (uniforms: ContiguousArray<UInt8>, materials: ContiguousArray<ShaderMaterial>, textures: ContiguousArray<D3DResource?>) {
        var uniforms: ContiguousArray<UInt8> = []
        uniforms.reserveCapacity(16 * 2)
        withUnsafeBytes(of: matricies.projection.transposedSIMD) { pointer in
            uniforms.append(contentsOf: pointer)
        }
        withUnsafeBytes(of: matricies.view.transposedSIMD) { pointer in
            uniforms.append(contentsOf: pointer)
        }
        let customValues: [CustomUniformType] = material.sortedCustomUniforms()
        if customValues.isEmpty == false {
            for value: CustomUniformType in customValues {
                switch value {
                case let value as Bool:
                    withUnsafeBytes(of: value) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Int:
                    withUnsafeBytes(of: value) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Float:
                    withUnsafeBytes(of: value) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as any Vector2:
                    withUnsafeBytes(of: value) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as any Vector3:
                    withUnsafeBytes(of: value) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Matrix3x3:
                    value.transposedArray().withUnsafeBytes { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Matrix4x4:
                    value.transposedArray().withUnsafeBytes { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Array<Matrix4x4>:
                    var floats: [Float] = []
                    floats.reserveCapacity(value.count * 16 * 60)
                    for mtx in value {
                        floats.append(contentsOf: mtx.transposedArray())
                    }
                    while floats.count < 16 * 60 {
                        floats.append(0)
                    }
                    floats.withUnsafeBytes { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                default:
                    fatalError()
                }
            }
        }
        //Add padding
        for _ in 0 ..< MemoryLayout<SIMD16<Float>>.alignment - (uniforms.count % MemoryLayout<SIMD16<Float>>.alignment) {
            uniforms.append(0)
        }
    
        var materials: ContiguousArray<ShaderMaterial> = []
        var textures: ContiguousArray<D3DResource?> = []
        for index in material.channels.indices {
            let channel = material.channels[index]
            
            let sampleFilter: ShaderMaterial.SampleFilter
            switch channel.sampleFilter {
            case .linear:
                sampleFilter = .linear
            case .nearest:
                sampleFilter = .nearest
            }
            
            materials.append(ShaderMaterial(scale: channel.scale,
                                            offset: channel.offset,
                                            color: channel.color,
                                            sampleFilter: sampleFilter))
            
            textures.append((channel.texture?.textureBackend as? DX12Texture)?.dxTexture)
        }

        return (uniforms, materials, textures)
    }
}

extension DX12Renderer {
    final func pipelineState(vsh: VertexShader, fsh: FragmentShader, flags: DrawFlags, geometries: ContiguousArray<GeometryBackend>) -> D3DPipelineState {
        if let existing: D3DPipelineState = pipelineStates[flags] {
            return existing
        }
        let new: D3DPipelineState = self.createPipelineState(vsh: vsh, fsh: fsh, flags: flags, geometries: geometries)
        pipelineStates[flags] = new
        return new
    }
    
    private func createPipelineState(vsh: VertexShader, fsh: FragmentShader, flags: DrawFlags, geometries: ContiguousArray<GeometryBackend>) -> D3DPipelineState {
        do {
            @_transparent
            var primitive: D3DPrimitiveTopologyType {
                switch flags.primitive {
                case .point:
                    return .point
                case .line:
                    return .line
                case .triangle:
                    return .triangle
                case .lineStrip, .triangleStrip:
                    fatalError()
                }
            }

            @_transparent
            var inputLayoutDescription: D3DInputLayoutDesription {
                let append: UInt32 = WinSDK.D3D11_APPEND_ALIGNED_ELEMENT
                var elementDescriptions: [D3DInputElementDescription] = []
                var index: UInt32 = 0
                for geometry: GeometryBackend in geometries {
                    for attribute: GeometryAttribute in geometry.attributes {
                        let format: Direct3D12.DGIFormat
                        switch attribute.type {
                        case .float:
                            switch attribute.componentLength {
                            case 1:
                                format = .r32Float
                            case 2:
                                format = .r32g32Float
                            case 3:
                                format = .r32g32b32Float
                            case 4:
                                format = .r32g32b32a32Float
                            default:
                                fatalError()
                            }
                        case .uInt16:
                            switch attribute.componentLength {
                            case 1:
                                format = .r16UInt
                            case 2:
                                format = .r16g16UInt
                            case 3:
                                fatalError()
                            case 4:
                                format = .r16g16b16a16UInt
                            default:
                                fatalError()
                            }
                        case .uInt32:
                            switch attribute.componentLength {
                            case 1:
                                format = .r32UInt
                            case 2:
                                format = .r32g32UInt
                            case 3:
                                format = .r32g32b32UInt
                            case 4:
                                format = .r32g32b32a32UInt
                            default:
                                fatalError()
                            }
                        }

                        let sematic: String
                        switch attribute.shaderAttribute {
                        case .position:
                            sematic = "POSITION"
                        case .texCoord0, .texCoord1:
                            sematic = "TEXCOORD"
                        case .normal:
                            sematic = "NORMAL"
                        case .tangent:
                            sematic = "TANGENT"
                        case .color:
                            sematic = "COLOR"
                        case .jointIndicies:
                            sematic = "BONEINDEX"
                        case .jointWeights:
                            sematic = "BONEWEIGHT"
                        }
                        let element: D3DInputElementDescription = D3DInputElementDescription(semanticName: sematic, format: format, inputSlot: index, alignedByteOffset: 0, inputSlotClassification: .perVertexData)
                        elementDescriptions.append(element)
                        index += 1
                    }
                }

                elementDescriptions.append(contentsOf: [
                    D3DInputElementDescription(semanticName: "ModelMatrixA", format: .r32g32b32a32Float, inputSlot: index, alignedByteOffset: append, inputSlotClassification: .perInstanceData, instanceDataStepRate: 1),
                    D3DInputElementDescription(semanticName: "ModelMatrixB", format: .r32g32b32a32Float, inputSlot: index, alignedByteOffset: append, inputSlotClassification: .perInstanceData, instanceDataStepRate: 1),
                    D3DInputElementDescription(semanticName: "ModelMatrixC", format: .r32g32b32a32Float, inputSlot: index, alignedByteOffset: append, inputSlotClassification: .perInstanceData, instanceDataStepRate: 1),
                    D3DInputElementDescription(semanticName: "ModelMatrixD", format: .r32g32b32a32Float, inputSlot: index, alignedByteOffset: append, inputSlotClassification: .perInstanceData, instanceDataStepRate: 1),
                ])
                
                return D3DInputLayoutDesription(elementDescriptions: elementDescriptions)
            }

            let generator: HLSLCodeGenerator = HLSLCodeGenerator()
            let shaders: (vsh: String, fsh: String) = try generator.generateShaderCode(vertexShader: vsh, fragmentShader: fsh, attributes: geometries.shaderAttributes)

            #if GATEENGINE_DEBUG_RENDERING
            let debug: Bool = true
            #else
            let debug: Bool = false
            #endif

            var description: D3DGraphicsPipelineStateDescription = D3DGraphicsPipelineStateDescription(
                rootSignature: self.rootSignature(cbvCount: 1, srvCount: 1),
                vertexShader: D3DShaderBytecode(byteCodeBlob: try Direct3D12.compileFromSource(shaders.vsh, functionName: "VSMain", target: "vs_5_0", forDebug: debug)),
                pixelShader: D3DShaderBytecode(byteCodeBlob: try Direct3D12.compileFromSource(shaders.fsh, functionName: "PSMain", target: "ps_5_0", forDebug: debug)),
                blendState: .additive,
                inputLayout: inputLayoutDescription,
                primitiveTopologyType: primitive,
                renderTargetFormats: [.r8g8b8a8Unorm],
                depthStencilFormat: .d32Float
            )
            
            switch flags.winding {
            case .clockwise:
                description.rasterizerState.windingDirection = .clockwise
            case .counterClockwise:
                description.rasterizerState.windingDirection = .counterClockwise
            }
            
            description.depthStencilState.stencilTestingEnabled = false

            switch flags.cull {
            case .disabled:
                description.rasterizerState.cullMode = .disabled
            case .back:
                description.rasterizerState.cullMode = .back
            case .front:
                description.rasterizerState.cullMode = .front
            }

            description.depthStencilState.depthTestingEnabled = false
            switch flags.depthTest {
            case .always:
                description.depthStencilState.depthFunction = .alwaysSucceed
            case .greaterThan:
                description.depthStencilState.depthFunction = .greaterThan
            case .lessThan:
                description.depthStencilState.depthFunction = .lessThan
            case .never:
                description.depthStencilState.depthFunction = .neverSucceed
            }

            switch flags.depthWrite {
            case .disabled:
                description.depthStencilState.depthWriteMask = .zero
            case .enabled:
                description.depthStencilState.depthWriteMask = .all
            }
        
            let pipelineState = try device.createGraphicsPipelineState(description: description)
#if GATEENGINE_DEBUG_RENDERING
            try pipelineState.setDebugName("\(type(of: self)).\(#function)")
#endif
            return pipelineState
        }catch{
            DX12Renderer.checkError(error)
        }
    }

    @inline(__always)
    func rootSignature(cbvCount: UInt32, srvCount: UInt32) -> D3DRootSignature {
        do {
            let table1: D3DRootDescriptorTable = D3DRootDescriptorTable(descriptorRanges: [D3DDescriptorRange(type: .constantBufferView, descriptorCount: cbvCount, baseShaderRegister: 0)])
            let table2: D3DRootDescriptorTable = D3DRootDescriptorTable(descriptorRanges: [D3DDescriptorRange(type: .shaderResourceView, descriptorCount: srvCount, baseShaderRegister: 0)])
            let parameters: [D3DRootParameter] = [D3DRootParameter(type: .descriptorTable, descriptorTable: table1, shaderVisibility: .all),
                              D3DRootParameter(type: .descriptorTable, descriptorTable: table2, shaderVisibility: .all)]
            let staticSamplers: [D3DStaticSamplerDescription] = [D3DStaticSamplerDescription(filter: .minMagMipLinear, shaderRegister: 0),
                                  D3DStaticSamplerDescription(filter: .minMagPointMipLinear, shaderRegister: 1)]
            let description: D3DRootSignatureDescription = D3DRootSignatureDescription(parameters: parameters, staticSamplers: staticSamplers, flags: [.allowInputAssemblerInputLayout,
                                                                                                                          .denyDomainShaderRootAccess,
                                                                                                                          .denyGeometryShaderRootAccess,
                                                                                                                          .denyHullShaderRootAccess])
            let rootSignature: D3DRootSignature = try device.createRootSignature(description: description, version: .v1_0)
            return rootSignature
        }catch{
            DX12Renderer.checkError(error)
        }
    }
}

extension DX12Renderer {
    static func createBuffer<T>(withData data: [T], heapProperties: D3DHeapProperties, state: D3DResourceStates) -> D3DResource {
        var resourceDesciption: D3DResourceDescription = D3DResourceDescription()
        resourceDesciption.dimension = .buffer
        resourceDesciption.format = .unknown
        resourceDesciption.layout = .rowMajor
        resourceDesciption.width = UInt64(((MemoryLayout<T>.stride * data.count) + 255) & ~255)
        resourceDesciption.height = 1
        resourceDesciption.depthOrArraySize = 1
        resourceDesciption.mipLevels = 1
        resourceDesciption.sampleDescription.count = 1

        do {
            let resource: D3DResource = try Game.shared.renderer.device.createCommittedResource(description: resourceDesciption, properties: heapProperties, state: state)
            #if GATEENGINE_DEBUG_RENDERING
            try resource.setDebugName("\(type(of: self)).\(#function)")
            #endif
            try data.withUnsafeBytes {
                let buffer: UnsafeMutableRawPointer? = try resource.map()
                _ = memcpy(buffer, $0.baseAddress, $0.count)
                resource.unmap()
            }
            return resource
        }catch{
            DX12Renderer.checkError(error)
        }
    }

    static func checkError(_ error: Swift.Error, function: String = #function, line: Int = #line) -> Never {
        print("[GateEngine] Error: \(Self.self).\(#function)\n", error)
        do {
            try Game.shared.renderer.device.checkDeviceRemovedReason()
        }catch{
            print("[GateEngine] Device Removed Reason:\n", error)
        }
        fatalError()
    }
}

extension Renderer {
    @_transparent
    var backend: DX12Renderer {
        return self._backend as! DX12Renderer
    }
    @_transparent
    var device: D3DDevice {
        return backend.device
    }
    @_transparent
    var backgroundCommandQueue: D3DCommandQueue {
        return backend.backgroundCommandQueue
    }
}
#endif
