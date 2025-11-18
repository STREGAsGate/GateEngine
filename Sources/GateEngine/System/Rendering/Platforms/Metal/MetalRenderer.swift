/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(MetalKit)
#if os(macOS)
// Make sure CoreGraphics gets linked on macOS for MTLCreateSystemDefaultDevice()
import CoreGraphics
#endif
import MetalKit
import GameMath
import Shaders

extension Renderer {
    var device: any MTLDevice {
        get {
            return unsafeDowncast(self, to: MetalRenderer.self).device
        }
        set {
            let renderer = unsafeDowncast(self, to: MetalRenderer.self)
            renderer.device = newValue
        }
    }
    var commandQueue: any MTLCommandQueue {
        return unsafeDowncast(self, to: MetalRenderer.self).commandQueue
    }
}

final class MetalRenderer: Renderer {
    static let api: RenderingAPI = .metal
    static let isSupported: Bool = (MTLCreateSystemDefaultDevice() != nil)
    var device: any MTLDevice {
        didSet {
            self.commandQueue = device.makeCommandQueue()!
        }
    }
    var commandQueue: any MTLCommandQueue
    
    required init() {
        let device = MTLCreateSystemDefaultDevice()!
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
    }

    private var _shaders: [ShaderKey: MetalShader] = [:]
    struct ShaderKey: Hashable {
        let vshID: VertexShader.ID
        let fshID: FragmentShader.ID
        let attributes: ContiguousArray<CodeGenerator.InputAttribute>
        let blendMode: DrawCommand.Flags.BlendMode
        init(vsh: VertexShader, fsh: FragmentShader, attributes: ContiguousArray<CodeGenerator.InputAttribute>, blendMode: DrawCommand.Flags.BlendMode) {
            self.vshID = vsh.id
            self.fshID = fsh.id
            self.attributes = attributes
            self.blendMode = blendMode
        }
    }
    struct MetalShader {
        let library: any MTLLibrary
        let renderPipelineState: any MTLRenderPipelineState
        let vertexShader: VertexShader
        let fragmentShader: FragmentShader
    }

    func draw(
        _ drawCommand: DrawCommand,
        camera: Camera?,
        matrices: Matrices,
        renderTarget: some _RenderTargetProtocol
    ) {
        guard let _geometries = drawCommand.geometries else {return}
        #if GATEENGINE_DEBUG_RENDERING
        let renderTarget = renderTarget.renderTargetBackend as! MetalRenderTarget
        let geometries = _geometries as! Array<MetalGeometry>
        for geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
        assert(geometries.isEmpty == false)
        #else
        let renderTarget = unsafeDowncast(renderTarget.renderTargetBackend, to: MetalRenderTarget.self)
        let geometries = unsafeBitCast(_geometries, to: Array<MetalGeometry>.self)
        #endif
        
        let encoder = renderTarget.commandEncoder!
        let data = createUniforms(drawCommand, camera, matrices)

        self.setWinding(drawCommand.flags.winding, encoder: encoder)
        self.setFlags(drawCommand, geometries: geometries, encoder: encoder)

        var vertexIndex: Int = 0
        var fragmentIndex: Int = 0

        self.setGeometries(geometries, on: encoder, at: &vertexIndex)
        self.setUniforms(
            data.uniforms,
            encoder: encoder,
            vertexIndex: &vertexIndex,
            fragmentIndex: &fragmentIndex
        )
        self.setTransforms(drawCommand.transforms, on: encoder, at: &vertexIndex)
        self.setMaterials(
            data.materials,
            on: encoder,
            vertexIndex: &vertexIndex,
            fragmentIndex: &fragmentIndex
        )
        self.setTextures(data.textures, encoder: encoder)

        encoder.setVertexSamplerState(linearSamplerState, index: 0)
        encoder.setVertexSamplerState(nearestSamplerState, index: 1)
        encoder.setVertexSamplerState(linearMinNearestMaxSamplerState, index: 2)
        encoder.setFragmentSamplerState(linearSamplerState, index: 0)
        encoder.setFragmentSamplerState(nearestSamplerState, index: 1)
        encoder.setFragmentSamplerState(linearMinNearestMaxSamplerState, index: 2)

        let firstGeometry = geometries[0]
        let indicesCount: Int = firstGeometry.indicesCount
        encoder.drawIndexedPrimitives(
            type: primitive(from: drawCommand.flags.primitive),
            indexCount: indicesCount,
            indexType: .uint16,
            indexBuffer: firstGeometry.buffer,
            indexBufferOffset: firstGeometry.bufferOffsets[firstGeometry.attributes.count],
            instanceCount: drawCommand.transforms.count
        )
    }

    lazy private(set) var linearSamplerState: any MTLSamplerState = {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge

        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear

        return device.makeSamplerState(descriptor: samplerDescriptor).unsafelyUnwrapped
    }()

    lazy private(set) var nearestSamplerState: any MTLSamplerState = {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge

        samplerDescriptor.mipFilter = .nearest
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest

        return device.makeSamplerState(descriptor: samplerDescriptor).unsafelyUnwrapped
    }()
    
    lazy private(set) var linearMinNearestMaxSamplerState: any MTLSamplerState = {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge

        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .nearest

        return device.makeSamplerState(descriptor: samplerDescriptor).unsafelyUnwrapped
    }()

    struct DepthStencilStateKey: Hashable {
        let depthTest: DrawCommand.Flags.DepthTest
        let depthWrite: DrawCommand.Flags.DepthWrite
    }
    var _storedDepthStencilStates: [DepthStencilStateKey: any MTLDepthStencilState] = [:]

    func getDepthStencilState(flags: DrawCommand.Flags) -> any MTLDepthStencilState {
        let key = DepthStencilStateKey(depthTest: flags.depthTest, depthWrite: flags.depthWrite)
        if let existing = _storedDepthStencilStates[key] {
            return existing
        }
        let new = build()
        _storedDepthStencilStates[key] = new
        return new

        func build() -> some MTLDepthStencilState {
            let depthStencilDescriptor = MTLDepthStencilDescriptor()

            switch flags.depthTest {
            case .always:
                depthStencilDescriptor.depthCompareFunction = .always
            case .equal:
                depthStencilDescriptor.depthCompareFunction = .equal
            case .greater:
                depthStencilDescriptor.depthCompareFunction = .greater
            case .greaterEqual:
                depthStencilDescriptor.depthCompareFunction = .greaterEqual
            case .less:
                depthStencilDescriptor.depthCompareFunction = .less
            case .lessEqual:
                depthStencilDescriptor.depthCompareFunction = .lessEqual
            case .never:
                depthStencilDescriptor.depthCompareFunction = .never
            }

            switch flags.depthWrite {
            case .enabled:
                depthStencilDescriptor.isDepthWriteEnabled = true
            case .disabled:
                depthStencilDescriptor.isDepthWriteEnabled = false
            }
            
            let stencil = MTLStencilDescriptor()
//            stencil.writeMask = 0xFFFFFFFF
//            stencil.readMask = 0xFFFFFFFF
            
            switch flags.stencilTest {
            case .always:
                stencil.stencilCompareFunction = .always
            case .equal:
                stencil.stencilCompareFunction = .equal
            case .greater:
                stencil.stencilCompareFunction = .greater
            case .greaterEqual:
                stencil.stencilCompareFunction = .greaterEqual
            case .less:
                stencil.stencilCompareFunction = .less
            case .lessEqual:
                stencil.stencilCompareFunction = .lessEqual
            case .never:
                stencil.stencilCompareFunction = .never
            }
            
            stencil.stencilFailureOperation = .keep
            stencil.depthFailureOperation = .keep
            
            switch flags.stencilWrite {
            case .enabled:
                stencil.depthStencilPassOperation = .replace
            case .disabled:
                stencil.depthStencilPassOperation = .keep
            }
            
            depthStencilDescriptor.frontFaceStencil = stencil
            depthStencilDescriptor.backFaceStencil = stencil
            
            return device.makeDepthStencilState(descriptor: depthStencilDescriptor).unsafelyUnwrapped
        }
    }

    struct RenderPipelineStateKey: Hashable {
        let vertexShader: VertexShader.ID
        let fragmentShader: FragmentShader.ID
        let attributes: ContiguousArray<CodeGenerator.InputAttribute>
        let blendMode: DrawCommand.Flags.BlendMode
    }
    var _storedRenderPipelineStates: [RenderPipelineStateKey: any MTLRenderPipelineState] = [:]
    func getRenderPipelineState(
        _ drawCommand: DrawCommand,
        geometries: [MetalGeometry],
        attributes: ContiguousArray<CodeGenerator.InputAttribute>,
        library: some MTLLibrary
    ) -> any MTLRenderPipelineState {
        let key = RenderPipelineStateKey(
            vertexShader: drawCommand.vsh.id,
            fragmentShader: drawCommand.fsh.id,
            attributes: attributes,
            blendMode: drawCommand.flags.blendMode
        )
        if let existing = _storedRenderPipelineStates[key] {
            return existing
        }
        let new = buildRenderPipeline()
        _storedRenderPipelineStates[key] = new
        return new

        func buildRenderPipeline() -> some MTLRenderPipelineState {
            let pipelineDescriptor = MTLRenderPipelineDescriptor()

            let vertexDescriptor = MTLVertexDescriptor()

            var index: Int = 0
            for geometry in geometries {
                for attribute in geometry.attributes {
                    vertexDescriptor.attributes[index].bufferIndex = index
                    switch attribute.type {
                    case .float:
                        switch attribute.componentLength {
                        case 1:
                            vertexDescriptor.attributes[index].format = .float
                        case 2:
                            vertexDescriptor.attributes[index].format = .float2
                        case 3:
                            vertexDescriptor.attributes[index].format = .float3
                        case 4:
                            vertexDescriptor.attributes[index].format = .float4
                        default:
                            fatalError()
                        }
                        vertexDescriptor.layouts[index].stride =
                            MemoryLayout<Float>.size * attribute.componentLength
                    case .uInt16:
                        switch attribute.componentLength {
                        case 1:
                            vertexDescriptor.attributes[index].format = .ushort
                        case 2:
                            vertexDescriptor.attributes[index].format = .ushort2
                        case 3:
                            vertexDescriptor.attributes[index].format = .ushort3
                        case 4:
                            vertexDescriptor.attributes[index].format = .ushort4
                        default:
                            fatalError()
                        }
                        vertexDescriptor.layouts[index].stride =
                            MemoryLayout<UInt16>.size * attribute.componentLength
                    case .uInt32:
                        switch attribute.componentLength {
                        case 1:
                            vertexDescriptor.attributes[index].format = .uint
                        case 2:
                            vertexDescriptor.attributes[index].format = .uint2
                        case 3:
                            vertexDescriptor.attributes[index].format = .uint3
                        case 4:
                            vertexDescriptor.attributes[index].format = .uint4
                        default:
                            fatalError()
                        }
                        vertexDescriptor.layouts[index].stride =
                            MemoryLayout<UInt32>.size * attribute.componentLength
                    }
                    index += 1
                }
            }

            pipelineDescriptor.vertexDescriptor = vertexDescriptor

            pipelineDescriptor.vertexFunction = library.makeFunction(
                name: "vertex\(UInt(bitPattern: drawCommand.vsh.id.hashValue))"
            )
            pipelineDescriptor.fragmentFunction = library.makeFunction(
                name: "fragment\(UInt(bitPattern: drawCommand.fsh.id.hashValue))"
            )

            pipelineDescriptor.colorAttachments[0] = {
                let descriptor = MTLRenderPipelineColorAttachmentDescriptor()
                descriptor.pixelFormat = .bgra8Unorm

                switch drawCommand.flags.blendMode {
                case .none:
                    break
                case .normal:
                    descriptor.isBlendingEnabled = true
                    descriptor.rgbBlendOperation = .add
                    descriptor.alphaBlendOperation = .add
                    descriptor.sourceRGBBlendFactor = .sourceAlpha
                    descriptor.sourceAlphaBlendFactor = .one
                    descriptor.destinationRGBBlendFactor = .oneMinusSourceAlpha
                    descriptor.destinationAlphaBlendFactor = .oneMinusSourceAlpha
                case .add:
                    descriptor.isBlendingEnabled = true
                    descriptor.rgbBlendOperation = .add
                    descriptor.alphaBlendOperation = .add
                    descriptor.sourceRGBBlendFactor = .sourceAlpha
                    descriptor.sourceAlphaBlendFactor = .one
                    descriptor.destinationRGBBlendFactor = .one
                    descriptor.destinationAlphaBlendFactor = .one
                case .subtract:
                    descriptor.isBlendingEnabled = true
                    descriptor.rgbBlendOperation = .add
                    descriptor.alphaBlendOperation = .add
                    descriptor.sourceRGBBlendFactor = .zero
                    descriptor.sourceAlphaBlendFactor = .zero
                    descriptor.destinationRGBBlendFactor = .oneMinusSourceColor
                    descriptor.destinationAlphaBlendFactor = .one
                }

                return descriptor
            }()

            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
            pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8

            do {
                return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                Log.fatalError("\(error)")
            }
        }
    }
}

extension MetalRenderer {
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
            case minLinearMaxNearest = 3
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
}

extension MetalRenderer {
    func metalShader(_ drawCommand: DrawCommand,
        geometries: [MetalGeometry],
        flags: DrawCommand.Flags
    ) -> MetalShader {
        let attributes = MetalGeometry.shaderAttributes(from: geometries)
        let key = ShaderKey(vsh: drawCommand.vsh, fsh: drawCommand.fsh, attributes: attributes, blendMode: flags.blendMode)
        if let existing = _shaders[key] {
            return existing
        }
        do {
            let generator = MSLCodeGenerator()
            let source = try generator.generateShaderCode(
                vertexShader: drawCommand.vsh,
                fragmentShader: drawCommand.fsh,
                attributes: attributes
            )
            #if GATEENGINE_LOG_SHADERS
            Log.info("Generated Metal Shaders vsh:\(drawCommand.vsh) fsh:\(drawCommand.fsh) \n\n\(source)\n")
            #endif
            let library = try self.device.makeLibrary(source: source, options: nil)
            let pipelineState = self.getRenderPipelineState(
                drawCommand,
                geometries: geometries,
                attributes: attributes,
                library: library
            )
            let shader = MetalShader(
                library: library,
                renderPipelineState: pipelineState,
                vertexShader: drawCommand.vsh,
                fragmentShader: drawCommand.fsh
            )
            _shaders[key] = shader
            return shader
        } catch {
            Log.fatalError("\(error)")
        }
    }

    private func setFlags(_ drawCommand: DrawCommand,
        geometries: [MetalGeometry],
        encoder: some MTLRenderCommandEncoder
    ) {
        switch drawCommand.flags.cull {
        case .disabled:
            encoder.setCullMode(.none)
        case .back:
            encoder.setCullMode(.back)
        case .front:
            encoder.setCullMode(.front)
        }

        let shader = metalShader(drawCommand, geometries: geometries, flags: drawCommand.flags)
        encoder.setDepthStencilState(getDepthStencilState(flags: drawCommand.flags))
        encoder.setRenderPipelineState(shader.renderPipelineState)
    }

    private func setWinding(_ winding: DrawCommand.Flags.Winding, encoder: some MTLRenderCommandEncoder) {
        switch winding {
        case .clockwise:
            encoder.setFrontFacing(.clockwise)
        case .counterClockwise:
            encoder.setFrontFacing(.counterClockwise)
        }
    }

    private func setUniforms(
        _ uniforms: ContiguousArray<UInt8>,
        encoder: some MTLRenderCommandEncoder,
        vertexIndex: inout Int,
        fragmentIndex: inout Int
    ) {
        let length = MemoryLayout<UInt8>.stride * uniforms.count
        uniforms.withUnsafeBytes { uniforms in
            let uniforms = uniforms.baseAddress!
            if length < 4096 {  // Let Metal manage our data if it's small
                encoder.setVertexBytes(uniforms, length: length, index: vertexIndex)
                encoder.setFragmentBytes(uniforms, length: length, index: fragmentIndex)
            } else if let instancedBuffer = device.makeBuffer(
                bytes: uniforms,
                length: length,
                options: .storageModeShared
            ) {
                encoder.setVertexBuffer(instancedBuffer, offset: 0, index: vertexIndex)
                encoder.setFragmentBuffer(instancedBuffer, offset: 0, index: fragmentIndex)
            } else {
                Log.error("\(type(of: self)) Failed to attach uniforms to shader.")
            }
            vertexIndex += 1
            fragmentIndex += 1
        }
    }
    
    private func primitive(from primitive: DrawCommand.Flags.Primitive) -> MTLPrimitiveType {
        switch primitive {
        case .point:
            return .point
        case .line:
            return .line
        case .lineStrip:
            return .lineStrip
        case .triangle:
            return .triangle
        case .triangleStrip:
            return .triangleStrip
        }
    }

    private func setTextures(
        _ textures: ContiguousArray<(some MTLTexture)?>,
        encoder: some MTLRenderCommandEncoder
    ) {
        for index in textures.indices {
            encoder.setFragmentTexture(textures[index], index: index)
        }
    }

    private func createUniforms(_ drawCommand: DrawCommand, _ camera: Camera?, _ matricies: Matrices) -> (
        uniforms: ContiguousArray<UInt8>, materials: ContiguousArray<ShaderMaterial>,
        textures: ContiguousArray<(some MTLTexture)?>
    ) {
        var uniforms: ContiguousArray<UInt8> = []
        uniforms.reserveCapacity(MemoryLayout<SIMD16<CFloat>>.size * 2)
        withUnsafeBytes(of: matricies.projection.transposedSIMD) { pointer in
            uniforms.append(contentsOf: pointer)
        }
        withUnsafeBytes(of: matricies.view.transposedSIMD) { pointer in
            uniforms.append(contentsOf: pointer)
        }
        
        var largestAlignment: Int = MemoryLayout<SIMD16<CFloat>>.alignment
        func padIfNeeded(alignment: Int) {
            if alignment > largestAlignment {
                largestAlignment = alignment
            }
            while uniforms.count % alignment != 0 {
                uniforms.append(0)
            }
        }
        
        let customValues = drawCommand.material.sortedCustomUniforms()
        if customValues.isEmpty == false {
            for pair in customValues {
                let value = pair.value
                let name = pair.key
                switch value {
                case let value as Bool:
                    padIfNeeded(alignment: MemoryLayout<CBool>.alignment)
                    withUnsafeBytes(of: CBool(value)) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Int:
                    padIfNeeded(alignment: MemoryLayout<CInt>.alignment)
                    withUnsafeBytes(of: CInt(value)) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Float:
                    padIfNeeded(alignment: MemoryLayout<CFloat>.alignment)
                    withUnsafeBytes(of: CFloat(value)) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as any Vector2:
                    padIfNeeded(alignment: MemoryLayout<SIMD2<CFloat>>.alignment)
                    withUnsafeBytes(of: value.simd) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as any Vector3:
                    padIfNeeded(alignment: MemoryLayout<SIMD3<CFloat>>.alignment)
                    withUnsafeBytes(of: value.simd) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Matrix3x3:
                    padIfNeeded(alignment: MemoryLayout<simd_float3x3>.alignment)
                    value.transposedArray().withUnsafeBytes { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as Matrix4x4:
                    padIfNeeded(alignment: MemoryLayout<SIMD16<CFloat>>.alignment)
                    withUnsafeBytes(of: value.transposedSIMD) { pointer in
                        uniforms.append(contentsOf: pointer)
                    }
                case let value as [Matrix4x4]:
                    padIfNeeded(alignment: MemoryLayout<SIMD16<CFloat>>.alignment)
                    let capacity = drawCommand.vsh.uniforms.arrayCapacityForUniform(named: name) ?? drawCommand.fsh.uniforms.arrayCapacityForUniform(named: name)!
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
        
        padIfNeeded(alignment: largestAlignment)// Align the shaders struct

        var materials: ContiguousArray<ShaderMaterial> = []
        var textures: ContiguousArray<(any MTLTexture)?> = []
        for index in drawCommand.material.channels.indices {
            let channel = drawCommand.material.channels[index]

            let sampleFilter: ShaderMaterial.SampleFilter
            switch channel.sampleFilter {
            case .linear:
                sampleFilter = .linear
            case .nearest:
                sampleFilter = .nearest
            case .minLinearMaxNearest:
                sampleFilter = .minLinearMaxNearest
            }

            materials.append(
                ShaderMaterial(
                    scale: channel.scale,
                    offset: channel.offset,
                    color: channel.color,
                    sampleFilter: sampleFilter
                )
            )

            textures.append((channel.texture?.textureBackend as? MetalTexture)?.mtlTexture)
        }

        return (uniforms, materials, textures)
    }

    private func setTransforms(
        _ transforms: [Transform3],
        on encoder: some MTLRenderCommandEncoder,
        at vertexIndex: inout Int
    ) {
        var instancedUniforms: ContiguousArray<InstancedUniforms> = []
        instancedUniforms.reserveCapacity(transforms.count)
        for transform in transforms {
            let matrix = transform.createMatrix()
            let uniforms = InstancedUniforms(
                modelMatrix: matrix,
                inverseModelMatrix: matrix.inverse
            )
            instancedUniforms.append(uniforms)
        }

        let instanceUniformsSize = MemoryLayout<InstancedUniforms>.size * instancedUniforms.count
        instancedUniforms.withUnsafeBufferPointer { instancedUniforms in
            if instanceUniformsSize < 4096 {  // Let Metal manage our data if it's small
                encoder.setVertexBytes(
                    instancedUniforms.baseAddress!,
                    length: instanceUniformsSize,
                    index: vertexIndex
                )
            } else if let instancedBuffer = device.makeBuffer(
                bytes: instancedUniforms.baseAddress!,
                length: instanceUniformsSize,
                options: .storageModeShared
            ) {
                encoder.setVertexBuffer(instancedBuffer, offset: 0, index: vertexIndex)
            } else {
                Log.error("\(type(of: self)) Failed to attach modelMatrix(s) to shader.")
            }
        }
        vertexIndex += 1
    }

    private func setMaterials(
        _ materials: ContiguousArray<ShaderMaterial>,
        on encoder: some MTLRenderCommandEncoder,
        vertexIndex: inout Int,
        fragmentIndex: inout Int
    ) {
        let materialsSize = MemoryLayout<ShaderMaterial>.stride * materials.count
        materials.withUnsafeBufferPointer { materials in
            let materials = materials.baseAddress!
            if materialsSize < 4096 {  // Let Metal manage our data if it's small
                encoder.setVertexBytes(materials, length: materialsSize, index: vertexIndex)
                encoder.setFragmentBytes(materials, length: materialsSize, index: fragmentIndex)
            } else if let instancedBuffer = device.makeBuffer(
                bytes: materials,
                length: materialsSize,
                options: .storageModeShared
            ) {
                encoder.setVertexBuffer(instancedBuffer, offset: 0, index: vertexIndex)
                encoder.setFragmentBuffer(instancedBuffer, offset: 0, index: fragmentIndex)
            } else {
                Log.error("\(type(of: self)) Failed to attach materials(s) to shader.")
            }
        }
        vertexIndex += 1
        fragmentIndex += 1
    }

    private func setGeometries(
        _ geometries: [MetalGeometry],
        on encoder: some MTLRenderCommandEncoder,
        at index: inout Int
    ) {
        for geometry in geometries {
            for attributeIndex in geometry.attributes.indices {
                encoder.setVertexBuffer(geometry.buffer, offset: geometry.bufferOffsets[attributeIndex], index: index)
                index += 1
            }
        }
    }
}

#endif
