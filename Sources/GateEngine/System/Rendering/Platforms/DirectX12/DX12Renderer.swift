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
    @inline(__always)
    var renderingAPI: RenderingAPI { .d3d12 }
    let factory: DGIFactory
    let device: D3DDevice

    let commandQueue: D3DCommandQueue
    let backgroundCommandQueue: D3DCommandQueue

    let rtvIncermentSize: UInt32
    let dsvIncrementSize: UInt32
    let cbvIncrementSize: UInt32

    var cachedContent: [Any] = []

    private var _shaders: [ShaderKey: DXShader] = [:]
    struct ShaderKey: Hashable {
        let vshID: VertexShader.ID
        let fshID: FragmentShader.ID
        let flags: DrawFlags
        let attributes: ContiguousArray<CodeGenerator.InputAttribute>
        init(
            vsh: VertexShader,
            fsh: FragmentShader,
            flags: DrawFlags,
            attributes: ContiguousArray<CodeGenerator.InputAttribute>
        ) {
            self.vshID = vsh.id
            self.fshID = fsh.id
            self.flags = flags
            self.attributes = attributes
        }
    }
    struct DXShader {
        let rootSignature: D3DRootSignature
        let pipelineState: D3DPipelineState
        let descriptorHeap: D3DDescriptorHeap
        let vertexShader: VertexShader
        let fragmentShader: FragmentShader
    }

    func draw(
        _ drawCommand: DrawCommand,
        camera: Camera?,
        matrices: Matrices,
        renderTarget: some _RenderTargetProtocol
    ) {
        let renderTarget: DX12RenderTarget = renderTarget.renderTargetBackend as! DX12RenderTarget
        let geometries = drawCommand.geometries.map({ $0 as! DX12Geometry })
        let commandList: D3DGraphicsCommandList = renderTarget.commandList
        let data = createUniforms(drawCommand.material, camera, matrices)
        let shader: DX12Renderer.DXShader = getShader(
            vsh: drawCommand.material.vertexShader,
            fsh: drawCommand.material.fragmentShader,
            flags: drawCommand.flags,
            geometries: geometries,
            textureCount: UInt32(data.textures.count)
        )

        #if GATEENGINE_DEBUG_RENDERING
        for geometry: DX12Geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
        #endif

        commandList.setGraphicsRootSignature(shader.rootSignature)
        commandList.setPipelineState(shader.pipelineState)
        commandList.setDescriptorHeaps([shader.descriptorHeap])

        var uniformsIndex: UInt32 = 0
        self.setUniforms(
            data.uniforms,
            commandList: commandList,
            at: &uniformsIndex,
            heap: shader.descriptorHeap
        )
        self.setMaterials(
            data.materials,
            commandList: commandList,
            at: &uniformsIndex,
            heap: shader.descriptorHeap
        )
        self.setTextures(
            data.textures,
            commandList: commandList,
            at: &uniformsIndex,
            heap: shader.descriptorHeap
        )

        var vertexIndex: UInt32 = 0
        self.setGeometries(geometries, on: commandList, at: &vertexIndex)
        self.setTransforms(drawCommand.transforms, on: commandList, at: &vertexIndex)

        var location: D3DGPUDescriptorHandle = shader.descriptorHeap.gpuDescriptorHandleForHeapStart
        commandList.setGraphicsRootDescriptorTable(parameterIndex: 0, baseDescriptor: location)
        location.pointer += UInt64(cbvIncrementSize * (uniformsIndex - 1))
        commandList.setGraphicsRootDescriptorTable(parameterIndex: 1, baseDescriptor: location)

        switch drawCommand.flags.primitive {
        case .point:
            commandList.setPrimitiveTopology(.pointList)
        case .line:
            commandList.setPrimitiveTopology(.lineList)
        case .lineStrip:
            commandList.setPrimitiveTopology(.lineStrip)
        case .triangle:
            commandList.setPrimitiveTopology(.triangleList)
        case .triangleStrip:
            commandList.setPrimitiveTopology(.triangleStrip)
        }

        let indexBufferView: D3DIndexBufferView = D3DIndexBufferView(
            bufferLocation: geometries[0].indexBuffer.gpuVirtualAddress,
            byteCount: UInt32(MemoryLayout<UInt16>.stride * geometries[0].indicesCount),
            format: .r16UInt
        )
        commandList.setIndexBuffer(indexBufferView)
        commandList.drawIndexedInstanced(
            indexCountPerInstance: UInt32(geometries[0].indicesCount),
            instanceCount: UInt32(drawCommand.transforms.count),
            startIndexLocation: 0,
            baseVertexLocation: 0,
            startInstanceLocation: 0
        )
    }

    init() {
        do {
            #if GATEENGINE_DEBUG_RENDERING
            try D3DDebug().enableDebugLayer()
            Log.info("D3DDebug: Debug layer enabled.")
            #endif
            let factory: DGIFactory = try DGIFactory()
            let device: D3DDevice = try factory.createDefaultDevice()
            self.factory = factory
            self.device = device
            self.commandQueue = try device.createCommandQueue(type: .direct, priority: .high)
            self.backgroundCommandQueue = try device.createCommandQueue(
                type: .direct,
                priority: .normal
            )

            self.rtvIncermentSize = device.descriptorHandleIncrementSize(for: .renderTargetView)
            self.dsvIncrementSize = device.descriptorHandleIncrementSize(for: .depthStencilView)
            self.cbvIncrementSize = device.descriptorHandleIncrementSize(
                for: .constantBufferShaderResourceAndUnordererAccess
            )
        } catch {
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
            defer { _ = CloseHandle(h) }
            try fence.setCompletionEvent(h, whenValueIs: fenceValue)
            _ = WinSDK.WaitForSingleObject(h, INFINITE)
        }
    }
}

extension DX12Renderer {
    @inline(__always)
    private func setGeometries(
        _ geometries: [DX12Geometry],
        on commandList: D3DGraphicsCommandList,
        at index: inout UInt32
    ) {
        var bufferViews: [D3DVertexBufferView] = []
        bufferViews.reserveCapacity(geometries[0].attributes.count * geometries.count)
        for geometry: DX12Geometry in geometries {
            for attributeIndex: Range<ContiguousArray<GeometryAttribute>.Index>.Element in geometry
                .attributes.indices
            {
                let attribute: GeometryAttribute = geometry.attributes[attributeIndex]
                let stride: Int
                switch attribute.type {
                case .float:
                    stride = MemoryLayout<Float>.stride
                case .uInt32:
                    stride = MemoryLayout<UInt32>.stride
                case .uInt16:
                    stride = MemoryLayout<UInt16>.stride
                }
                let bufferView: D3DVertexBufferView = D3DVertexBufferView(
                    bufferLocation: geometry.buffers[attributeIndex].gpuVirtualAddress,
                    byteCount: UInt32(stride * attribute.componentLength * geometry.indicesCount),
                    byteStride: UInt32(stride * attribute.componentLength)
                )
                bufferViews.append(bufferView)
            }
        }
        commandList.setVertexBuffers(bufferViews, startingAt: index)
        index += UInt32(bufferViews.count)
    }

    @inline(__always)
    private func setTransforms(
        _ transforms: ContiguousArray<Transform3>,
        on commandList: D3DGraphicsCommandList,
        at index: inout UInt32
    ) {
        var instancedUniforms: ContiguousArray<InstancedUniforms> = []
        instancedUniforms.reserveCapacity(transforms.count)
        for transform: Transform3 in transforms {
            let matrix: Matrix4x4 = transform.createMatrix()
            let uniforms: DX12Renderer.InstancedUniforms = InstancedUniforms(
                modelMatrix: matrix,
                inverseModelMatrix: matrix.inverse
            )
            instancedUniforms.append(uniforms)
        }

        let buffer: D3DResource = DX12Renderer.createBuffer(
            withData: instancedUniforms,
            heapProperties: .forBuffer,
            state: .genericRead
        )
        #if GATEENGINE_DEBUG_RENDERING
        do {
            try buffer.setDebugName("\(type(of: self)).\(#function)")
        } catch {
            DX12Renderer.checkError(error)
        }
        #endif

        let bufferView: D3DVertexBufferView = D3DVertexBufferView(
            bufferLocation: buffer.gpuVirtualAddress,
            byteCount: UInt32(MemoryLayout<Float>.stride * 16 * transforms.count),
            byteStride: UInt32(MemoryLayout<Float>.stride * 16)
        )
        commandList.setVertexBuffers([bufferView], startingAt: index)

        self.cachedContent.append(buffer)
        self.cachedContent.append(bufferView)
        index += 1
    }

    @inline(__always)
    private func setUniforms(
        _ uniforms: ContiguousArray<UInt8>,
        commandList: D3DGraphicsCommandList,
        at index: inout UInt32,
        heap: D3DDescriptorHeap
    ) {
        do {
            let buffer: D3DResource = DX12Renderer.createBuffer(
                withData: uniforms,
                heapProperties: .forBuffer,
                state: .genericRead
            )

            let value: UnsafeMutableRawPointer? = try buffer.map()
            let location: UInt64 = buffer.gpuVirtualAddress
            let description: D3DConstantBufferViewDescription = D3DConstantBufferViewDescription(
                location: location,
                size: UInt32((uniforms.count + 255) & ~255)
            )
            var blockDestination: D3DCPUDescriptorHandle = heap.cpuDescriptorHandleForHeapStart
            blockDestination.pointer += UInt64(cbvIncrementSize * index)
            device.createConstantBufferView(description: description, destination: blockDestination)

            self.cachedContent.append(buffer as Any)
            self.cachedContent.append(value as Any)
            index += 1
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    @inline(__always)
    private func setMaterials(
        _ materials: ContiguousArray<ShaderMaterial>,
        commandList: D3DGraphicsCommandList,
        at index: inout UInt32,
        heap: D3DDescriptorHeap
    ) {
        do {
            let buffer: D3DResource = DX12Renderer.createBuffer(
                withData: materials,
                heapProperties: .forBuffer,
                state: .genericRead
            )

            let value: UnsafeMutableRawPointer? = try buffer.map()
            let location: UInt64 = buffer.gpuVirtualAddress
            let description: D3DConstantBufferViewDescription = D3DConstantBufferViewDescription(
                location: location,
                size: UInt32((MemoryLayout<ShaderMaterial>.size * materials.count + 255) & ~255)
            )
            var blockDestination: D3DCPUDescriptorHandle = heap.cpuDescriptorHandleForHeapStart
            blockDestination.pointer += UInt64(cbvIncrementSize * index)
            device.createConstantBufferView(description: description, destination: blockDestination)

            self.cachedContent.append(buffer as Any)
            self.cachedContent.append(value as Any)
            index += 1
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    @inline(__always)
    private func setTextures(
        _ textures: ContiguousArray<D3DResource?>,
        commandList: D3DGraphicsCommandList,
        at index: inout UInt32,
        heap: D3DDescriptorHeap
    ) {
        var blockDestination: D3DCPUDescriptorHandle = heap.cpuDescriptorHandleForHeapStart
        blockDestination.pointer += UInt64(cbvIncrementSize * index)

        for dxTexture: D3DResource? in textures {
            if let dxTexture: D3DResource = dxTexture {
                var srvDesc: D3DShaderResourceViewDescription = D3DShaderResourceViewDescription()
                srvDesc.componentMapping = .default
                srvDesc.format = .r8g8b8a8Unorm
                srvDesc.dimension = .texture2D
                srvDesc.texture2D.mipLevels = 1
                device.createShaderResourceView(
                    resource: dxTexture,
                    description: srvDesc,
                    destination: blockDestination
                )
            }
            blockDestination.pointer += UInt64(cbvIncrementSize)
            index += 1
        }
    }
}

extension DX12Renderer {
    struct InstancedUniforms {
        let modelMatrix: SIMD16<Float>
        // let inverseModelMatrix: SIMD16<Float>
        init(modelMatrix: Matrix4x4, inverseModelMatrix: Matrix4x4) {
            self.modelMatrix = modelMatrix.simd
            // self.inverseModelMatrix = inverseModelMatrix.transposedSIMD
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
    private func createUniforms(_ material: Material, _ camera: Camera?, _ matricies: Matrices) -> (
        uniforms: ContiguousArray<UInt8>, materials: ContiguousArray<ShaderMaterial>,
        textures: ContiguousArray<D3DResource?>
    ) {
        var uniforms: ContiguousArray<UInt8> = []
        uniforms.reserveCapacity(16 * 2)
        withUnsafeBytes(of: matricies.projection.transposedSIMD) { pointer in
            uniforms.append(contentsOf: pointer)
        }
        withUnsafeBytes(of: matricies.view.transposedSIMD) { pointer in
            uniforms.append(contentsOf: pointer)
        }
        let customValues = material.sortedCustomUniforms()
        if customValues.isEmpty == false {
            for pair in customValues {
                let value = pair.value
                let name = pair.key
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
                case let value as [Matrix4x4]:
                    let capacity =
                        material.vertexShader.arrayCapacityForUniform(named: name) ?? material
                        .fragmentShader.arrayCapacityForUniform(named: name)!
                    var floats: [Float] = []
                    floats.reserveCapacity(value.count * 16 * capacity)
                    for mtx in value {
                        floats.append(contentsOf: mtx.transposedArray())
                    }
                    while floats.count < 16 * capacity {
                        floats.append(0)
                    }
                    if floats.count > capacity * 16 {
                        floats = Array(floats[..<capacity])
                        Log.warnOnce(
                            "Custom uniform \(name) exceeded max array capacity \(capacity) and was truncated."
                        )
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
        for _ in 0 ..< MemoryLayout<SIMD16<Float>>.alignment
            - (uniforms.count % MemoryLayout<SIMD16<Float>>.alignment)
        {
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

            materials.append(
                ShaderMaterial(
                    scale: channel.scale,
                    offset: channel.offset,
                    color: channel.color,
                    sampleFilter: sampleFilter
                )
            )

            textures.append((channel.texture?.textureBackend as? DX12Texture)?.dxTexture)
        }

        return (uniforms, materials, textures)
    }
}

extension DX12Renderer {
    func getShader(
        vsh: VertexShader,
        fsh: FragmentShader,
        flags: DrawFlags,
        geometries: [DX12Geometry],
        textureCount srvCount: UInt32
    ) -> DXShader {
        let key: DX12Renderer.ShaderKey = ShaderKey(
            vsh: vsh,
            fsh: fsh,
            flags: flags,
            attributes: DX12Geometry.shaderAttributes(from: geometries)
        )
        if let existing: DX12Renderer.DXShader = _shaders[key] {
            return existing
        }

        do {
            let cbvCount: UInt32 = 2
            let rootSignature: D3DRootSignature = rootSignature(
                cbvCount: cbvCount,
                srvCount: srvCount
            )
            let pipelineState: D3DPipelineState = createPipelineState(
                vsh: vsh,
                fsh: fsh,
                flags: flags,
                geometries: geometries,
                rootSignature: rootSignature
            )

            let descriptorHeapDesc: D3DDescriptorHeapDescription = D3DDescriptorHeapDescription(
                type: .constantBufferShaderResourceAndUnordererAccess,
                count: cbvCount + srvCount,
                flags: .shaderVisible
            )
            let descriptorHeap: D3DDescriptorHeap = try device.createDescriptorHeap(
                description: descriptorHeapDesc
            )

            let shader: DX12Renderer.DXShader = DXShader(
                rootSignature: rootSignature,
                pipelineState: pipelineState,
                descriptorHeap: descriptorHeap,
                vertexShader: vsh,
                fragmentShader: fsh
            )
            _shaders[key] = shader
            return shader
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    private func createPipelineState(
        vsh: VertexShader,
        fsh: FragmentShader,
        flags: DrawFlags,
        geometries: [DX12Geometry],
        rootSignature: D3DRootSignature
    ) -> D3DPipelineState {
        do {
            @_transparent
            var primitive: D3DPrimitiveTopologyType {
                switch flags.primitive {
                case .point:
                    return .point
                case .line, .lineStrip:
                    return .line
                case .triangle, .triangleStrip:
                    return .triangle
                }
            }

            @_transparent
            var inputLayoutDescription: D3DInputLayoutDescription {
                let append: UInt32 = WinSDK.D3D11_APPEND_ALIGNED_ELEMENT
                var elementDescriptions: [D3DInputElementDescription] = []
                var index: UInt32 = 0

                for geometry: DX12Geometry in geometries {
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

                        let semantic: String
                        let semanticIndex: UInt32
                        switch attribute.shaderAttribute {
                        case .position:
                            semantic = "POSITION"
                            semanticIndex = 0
                        case .texCoord0:
                            semantic = "TEXCOORD"
                            semanticIndex = 0
                        case .texCoord1:
                            semantic = "TEXCOORD"
                            semanticIndex = 1
                        case .normal:
                            semantic = "NORMAL"
                            semanticIndex = 0
                        case .tangent:
                            semantic = "TANGENT"
                            semanticIndex = 0
                        case .color:
                            semantic = "COLOR"
                            semanticIndex = 0
                        case .jointIndices:
                            semantic = "BONEINDEX"
                            semanticIndex = 0
                        case .jointWeights:
                            semantic = "BONEWEIGHT"
                            semanticIndex = 0
                        }
                        let element: D3DInputElementDescription = D3DInputElementDescription(
                            semanticName: semantic,
                            semanticIndex: semanticIndex,
                            format: format,
                            inputSlot: index,
                            alignedByteOffset: 0,
                            inputSlotClassification: .perVertexData
                        )
                        elementDescriptions.append(element)
                        index += 1
                    }
                }

                elementDescriptions.append(contentsOf: [
                    D3DInputElementDescription(
                        semanticName: "ModelMatrixA",
                        format: .r32g32b32a32Float,
                        inputSlot: index,
                        alignedByteOffset: append,
                        inputSlotClassification: .perInstanceData,
                        instanceDataStepRate: 1
                    ),
                    D3DInputElementDescription(
                        semanticName: "ModelMatrixB",
                        format: .r32g32b32a32Float,
                        inputSlot: index,
                        alignedByteOffset: append,
                        inputSlotClassification: .perInstanceData,
                        instanceDataStepRate: 1
                    ),
                    D3DInputElementDescription(
                        semanticName: "ModelMatrixC",
                        format: .r32g32b32a32Float,
                        inputSlot: index,
                        alignedByteOffset: append,
                        inputSlotClassification: .perInstanceData,
                        instanceDataStepRate: 1
                    ),
                    D3DInputElementDescription(
                        semanticName: "ModelMatrixD",
                        format: .r32g32b32a32Float,
                        inputSlot: index,
                        alignedByteOffset: append,
                        inputSlotClassification: .perInstanceData,
                        instanceDataStepRate: 1
                    ),
                ])

                return D3DInputLayoutDescription(elementDescriptions: elementDescriptions)
            }

            let generator: HLSLCodeGenerator = HLSLCodeGenerator()
            let shaderAttributes: ContiguousArray<CodeGenerator.InputAttribute> =
                DX12Geometry.shaderAttributes(from: geometries)
            let shaders: (vsh: String, fsh: String) = try generator.generateShaderCode(
                vertexShader: vsh,
                fragmentShader: fsh,
                attributes: shaderAttributes
            )
            #if GATEENGINE_LOG_SHADERS
            Log.info(
                "Generated DirectX Vertex Shader:\n\n\(HLSLCodeGenerator.addingLineNumbers(shaders.vsh))\n"
            )
            Log.info(
                "Generated DirectX Fragment Shader:\n\n\(HLSLCodeGenerator.addingLineNumbers(shaders.fsh))\n"
            )
            #endif
            #if GATEENGINE_DEBUG_RENDERING
            let debug: Bool = true
            #else
            let debug: Bool = false
            #endif

            var description: D3DGraphicsPipelineStateDescription =
                D3DGraphicsPipelineStateDescription(
                    rootSignature: rootSignature,
                    vertexShader: D3DShaderBytecode(
                        byteCodeBlob: try Direct3D12.compileFromSource(
                            shaders.vsh,
                            functionName: "VSMain",
                            target: "vs_5_0",
                            forDebug: debug
                        )
                    ),
                    pixelShader: D3DShaderBytecode(
                        byteCodeBlob: try Direct3D12.compileFromSource(
                            shaders.fsh,
                            functionName: "PSMain",
                            target: "ps_5_0",
                            forDebug: debug
                        )
                    ),
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

            switch flags.cull {
            case .disabled:
                description.rasterizerState.cullMode = .disabled
            case .back:
                description.rasterizerState.cullMode = .back
            case .front:
                description.rasterizerState.cullMode = .front
            }

            description.depthStencilState.stencilTestingEnabled = false
            description.depthStencilState.depthTestingEnabled = true
            switch flags.depthTest {
            case .always:
                description.depthStencilState.depthFunction = .alwaysSucceed
            case .greater:
                description.depthStencilState.depthFunction = .greaterThan
            case .greaterEqual:
                description.depthStencilState.depthFunction = .greaterThanOrEqualTo
            case .less:
                description.depthStencilState.depthFunction = .lessThan
            case .lessEqual:
                description.depthStencilState.depthFunction = .lessThanOrEqualTo
            case .never:
                description.depthStencilState.depthFunction = .neverSucceed
            }

            switch flags.depthWrite {
            case .disabled:
                description.depthStencilState.depthWriteMask = .zero
            case .enabled:
                description.depthStencilState.depthWriteMask = .all
            }

            let pipelineState: D3DPipelineState = try device.createGraphicsPipelineState(
                description: description
            )
            #if GATEENGINE_DEBUG_RENDERING
            try pipelineState.setDebugName("\(type(of: self)).\(#function)")
            #endif
            return pipelineState
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    @inline(__always)
    func rootSignature(cbvCount: UInt32, srvCount: UInt32) -> D3DRootSignature {
        do {
            let table1: D3DRootDescriptorTable = D3DRootDescriptorTable(descriptorRanges: [
                D3DDescriptorRange(
                    type: .constantBufferView,
                    descriptorCount: cbvCount,
                    baseShaderRegister: 0
                )
            ])
            let table2: D3DRootDescriptorTable = D3DRootDescriptorTable(descriptorRanges: [
                D3DDescriptorRange(
                    type: .shaderResourceView,
                    descriptorCount: srvCount,
                    baseShaderRegister: 0
                )
            ])
            let parameters: [D3DRootParameter] = [
                D3DRootParameter(
                    type: .descriptorTable,
                    descriptorTable: table1,
                    shaderVisibility: .all
                ),
                D3DRootParameter(
                    type: .descriptorTable,
                    descriptorTable: table2,
                    shaderVisibility: .all
                ),
            ]
            let staticSamplers: [D3DStaticSamplerDescription] = [
                D3DStaticSamplerDescription(filter: .minMagMipLinear, shaderRegister: 0),
                D3DStaticSamplerDescription(filter: .minMagPointMipLinear, shaderRegister: 1),
            ]
            let description: D3DRootSignatureDescription = D3DRootSignatureDescription(
                parameters: parameters,
                staticSamplers: staticSamplers,
                flags: [
                    .allowInputAssemblerInputLayout,
                    .denyDomainShaderRootAccess,
                    .denyGeometryShaderRootAccess,
                    .denyHullShaderRootAccess,
                ]
            )
            let rootSignature: D3DRootSignature = try device.createRootSignature(
                description: description,
                version: .v1_0
            )
            return rootSignature
        } catch {
            DX12Renderer.checkError(error)
        }
    }
}

extension DX12Renderer {
    @inline(__always)
    static func createBuffer<T>(
        withData data: [T],
        heapProperties: D3DHeapProperties,
        state: D3DResourceStates,
        function: String = #function
    ) -> D3DResource {
        return data.withUnsafeBytes {
            createBuffer(
                withStart: $0.baseAddress!,
                count: $0.count,
                heapProperties: heapProperties,
                state: state,
                function: function
            )
        }
    }

    @inline(__always)
    static func createBuffer<T>(
        withData data: ContiguousArray<T>,
        heapProperties: D3DHeapProperties,
        state: D3DResourceStates,
        function: String = #function
    ) -> D3DResource {
        return data.withUnsafeBytes {
            createBuffer(
                withStart: $0.baseAddress!,
                count: $0.count,
                heapProperties: heapProperties,
                state: state,
                function: function
            )
        }
    }

    @_transparent
    static func createBuffer<T>(
        withData data: UnsafeBufferPointer<T>,
        heapProperties: D3DHeapProperties,
        state: D3DResourceStates,
        function: String = #function
    ) -> D3DResource {
        createBuffer(
            withStart: data.baseAddress!,
            count: data.count,
            heapProperties: heapProperties,
            state: state,
            function: function
        )
    }

    static func createBuffer(
        withStart start: UnsafeRawPointer,
        count: Int,
        heapProperties: D3DHeapProperties,
        state: D3DResourceStates,
        function: String = #function
    ) -> D3DResource {
        var resourceDescription: D3DResourceDescription = D3DResourceDescription()
        resourceDescription.dimension = .buffer
        resourceDescription.format = .unknown
        resourceDescription.layout = .rowMajor
        resourceDescription.width = UInt64(((MemoryLayout<UInt8>.size * count) + 255) & ~255)
        resourceDescription.height = 1
        resourceDescription.depthOrArraySize = 1
        resourceDescription.mipLevels = 1
        resourceDescription.sampleDescription.count = 1

        do {
            let resource: D3DResource = try Game.shared.renderer.device.createCommittedResource(
                description: resourceDescription,
                properties: heapProperties,
                state: state
            )
            #if GATEENGINE_DEBUG_RENDERING
            try resource.setDebugName("\(type(of: self)).\(function)")
            #endif

            let buffer: UnsafeMutableRawPointer? = try resource.map()
            _ = memcpy(buffer, start, count)
            resource.unmap()

            return resource
        } catch {
            DX12Renderer.checkError(error)
        }
    }

    func createTextureShaderResourceView(
        for resource: D3DResource,
        withFormat format: DGIFormat,
        at blockDestination: D3DCPUDescriptorHandle
    ) {
        var srvDesc: D3DShaderResourceViewDescription = D3DShaderResourceViewDescription()
        srvDesc.componentMapping = .default
        srvDesc.format = format
        srvDesc.dimension = .texture2D
        srvDesc.texture2D.mipLevels = 2
        device.createShaderResourceView(
            resource: resource,
            description: srvDesc,
            destination: blockDestination
        )
    }

    @_optimize(none)  // Prevent compiler crash on release builds
    static func checkError(_ error: any Swift.Error, function: String = #function, line: Int = #line)
        -> Never
    {
        Log.error(error)

        #if GATEENGINE_DEBUG_RENDERING
        if let infoQueue: D3DInfoQueue = Game.shared.renderer.device.queryInterface(
            D3DInfoQueue.self
        ) {
            for index: UInt64 in 0 ..< infoQueue.storedMessageCount {
                infoQueue.getMessage(messageIndex: index) { message in
                    if let message {
                        print(message)
                    } else {
                        print("---failed to load error message---")
                    }
                }
            }
        }
        #endif

        do {
            try Game.shared.renderer.device.checkDeviceRemovedReason()
        } catch {
            Log.error("Device Removed Reason ->", error)
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
