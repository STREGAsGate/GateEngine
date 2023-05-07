/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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

class MetalRenderer: RendererBackend {
    var device: MTLDevice = MTLCreateSystemDefaultDevice()!
    lazy var commandQueue: MTLCommandQueue = self.device.makeCommandQueue()!
    
    private var _shaders: [ShaderKey:MetalShader] = [:]
    struct ShaderKey: Hashable {
        let vshID: VertexShader.ID
        let fshID: FragmentShader.ID
        init(vsh: VertexShader, fsh: FragmentShader) {
            self.vshID = vsh.id
            self.fshID = fsh.id
        }
    }
    struct MetalShader {
        let library: MTLLibrary
        let renderPipelineState: MTLRenderPipelineState
        let vertexShader: VertexShader
        let fragmentShader: FragmentShader
    }
    
    func draw(_ drawCommand: DrawCommand, camera: Camera?, matrices: Matrices, renderTarget: RenderTarget) {
        let renderTarget = renderTarget.backend as! MetalRenderTarget
        let encoder = renderTarget.commandEncoder!
        let geometries = ContiguousArray(drawCommand.geometries.map({$0 as! MetalGeometry}))
        let data = createUniforms(drawCommand.material, camera, matrices)
        
#if GATEENGINE_DEBUG_RENDERING
        for geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
#endif
        
        self.setWinding(drawCommand.flags.winding, encoder: encoder)
        self.setFlags(drawCommand.flags, vsh: drawCommand.material.vertexShader, fsh: drawCommand.material.fragmentShader, geometries: drawCommand.geometries, encoder: encoder)

        var vertexIndex: Int = 0
        var fragmentIndex: Int = 0
        
        self.setGeometries(geometries, on: encoder, at: &vertexIndex)
        self.setUniforms(data.uniforms, encoder: encoder, vertexIndex: &vertexIndex, fragmentIndex: &fragmentIndex)
        self.setTransforms(drawCommand.transforms, on: encoder, at: &vertexIndex)
        self.setMaterials(data.materials, on: encoder, vertexIndex: &vertexIndex, fragmentIndex: &fragmentIndex)
        self.setTextures(data.textures, encoder: encoder)
        
        encoder.setVertexSamplerState(linearSamplerState, index: 0)
        encoder.setVertexSamplerState(nearestSamplerState, index: 1)
        encoder.setFragmentSamplerState(linearSamplerState, index: 0)
        encoder.setFragmentSamplerState(nearestSamplerState, index: 1)

        let firstGeometry = geometries[0]
        let indiciesCount: Int = firstGeometry.indiciesCount
        let indexBuffer: MTLBuffer = firstGeometry.indexBuffer
        encoder.drawIndexedPrimitives(type: primitive(from: drawCommand.flags.primitive),
                                      indexCount: indiciesCount,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0,
                                      instanceCount: drawCommand.transforms.count)
    }
    
    lazy private(set) var linearSamplerState: MTLSamplerState = {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }()
    
    lazy private(set) var nearestSamplerState: MTLSamplerState = {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        
        samplerDescriptor.mipFilter = .linear
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }()
   
    struct DepthStencilStateKey: Hashable {
        let depthTest: DrawFlags.DepthTest
        let depthWrite: DrawFlags.DepthWrite
    }
    var _storedDepthStencilStates: [DepthStencilStateKey:MTLDepthStencilState] = [:]
    @inline(__always)
    func getDepthStencilState(flags: DrawFlags) -> MTLDepthStencilState {
        let key = DepthStencilStateKey(depthTest: flags.depthTest, depthWrite: flags.depthWrite)
        if let existing = _storedDepthStencilStates[key] {
            return existing
        }
        let new = build()
        _storedDepthStencilStates[key] = new
        return new
        
        @_transparent
        func build() -> MTLDepthStencilState {
            let depthStencilDescriptor = MTLDepthStencilDescriptor()
            
            switch flags.depthTest {
            case .always:
                depthStencilDescriptor.depthCompareFunction = .always
            case .greaterThan:
                depthStencilDescriptor.depthCompareFunction = .greater
            case .lessThan:
                depthStencilDescriptor.depthCompareFunction = .less
            case .never:
                depthStencilDescriptor.depthCompareFunction = .never
            }
            
            switch flags.depthWrite {
            case .enabled:
                depthStencilDescriptor.isDepthWriteEnabled = true
            case .disabled:
                depthStencilDescriptor.isDepthWriteEnabled = false
            }
            
            return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
        }
    }
    
    struct RenderPipelineStateKey: Hashable {
        let vertexShader: VertexShader.ID
        let fragmentShader: FragmentShader.ID
        let blendMode: DrawFlags.BlendMode
    }
    var _storedRenderPipelineStates: [RenderPipelineStateKey:MTLRenderPipelineState] = [:]
    @inline(__always)
    func getRenderPipelineState(vsh: VertexShader, fsh: FragmentShader, flags: DrawFlags, geometries: ContiguousArray<GeometryBackend>, library: MTLLibrary) -> MTLRenderPipelineState {
        let key = RenderPipelineStateKey(vertexShader: vsh.id, fragmentShader: fsh.id, blendMode: flags.blendMode)
        if let existing = _storedRenderPipelineStates[key] {
            return existing
        }
        let new = buildRenderPipeline()
        _storedRenderPipelineStates[key] = new
        return new
        
        @inline(__always)
        func buildRenderPipeline() -> MTLRenderPipelineState {
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
                        vertexDescriptor.layouts[index].stride = MemoryLayout<Float>.stride * attribute.componentLength
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
                        vertexDescriptor.layouts[index].stride = MemoryLayout<UInt16>.stride * attribute.componentLength
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
                        vertexDescriptor.layouts[index].stride = MemoryLayout<UInt32>.stride * attribute.componentLength
                    }
                    index += 1
                }
            }

            pipelineDescriptor.vertexDescriptor = vertexDescriptor
            
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex\(UInt(bitPattern: vsh.id.hashValue))")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment\(UInt(bitPattern: fsh.id.hashValue))")
            
            pipelineDescriptor.colorAttachments[0] = {
                let descriptor = MTLRenderPipelineColorAttachmentDescriptor()
                descriptor.pixelFormat = .bgra8Unorm
                
                switch flags.blendMode {
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
                }
                
                return descriptor
            }()
            
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            do {
                return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            }catch{
                print(error)
                fatalError()
            }
        }
    }
}

extension MetalRenderer {
    struct ShaderUniforms {
        let projectionMatrix: SIMD16<Float>
        let viewMatrix: SIMD16<Float>
        let u0: Float = 0
        init(projectionMatrix: Matrix4x4, viewMatrix: Matrix4x4) {
            self.projectionMatrix = projectionMatrix.transposedSIMD
            self.viewMatrix = viewMatrix.transposedSIMD
        }
    }
    
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
}

extension MetalRenderer {
    @inline(__always)
    func metalShader(vsh: VertexShader, fsh: FragmentShader, geometries: ContiguousArray<GeometryBackend>, flags: DrawFlags) -> MetalShader {
        let key = ShaderKey(vsh: vsh, fsh: fsh)
        if let existing = _shaders[key] {
            return existing
        }
        do {
            let generator = MSLCodeGenerator()
            let attributes = geometries.shaderAttributes
            let source = try generator.generateShaderCode(vertexShader: vsh, fragmentShader: fsh, attributes: attributes)
            #if GATEENGINE_LOG_SHADERS
            print("Generated Metal Shaders:\n\n\(source)\n")
            #endif
            let library = try self.device.makeLibrary(source: source, options: nil)
            let pipelineState = self.getRenderPipelineState(vsh: vsh, fsh: fsh, flags: flags, geometries: geometries, library: library)
            let shader = MetalShader(library: library, renderPipelineState: pipelineState, vertexShader: vsh, fragmentShader: fsh)
            _shaders[key] = shader
            return shader
        }catch{
            print(error)
            fatalError()
        }
    }
    
    @inline(__always)
    private func setFlags(_ flags: DrawFlags, vsh: VertexShader, fsh: FragmentShader, geometries: ContiguousArray<GeometryBackend>, encoder: MTLRenderCommandEncoder) {
        switch flags.cull {
        case .disabled:
            encoder.setCullMode(.none)
        case .back:
            encoder.setCullMode(.back)
        case .front:
            encoder.setCullMode(.front)
        }
        
        let shader = metalShader(vsh: vsh, fsh: fsh, geometries: geometries, flags: flags)
        encoder.setDepthStencilState(getDepthStencilState(flags: flags))
        encoder.setRenderPipelineState(shader.renderPipelineState)
    }
    
    @inline(__always)
    private func setWinding(_ winding: DrawFlags.Winding, encoder: MTLRenderCommandEncoder) {
        switch winding {
        case .clockwise:
            encoder.setFrontFacing(.clockwise)
        case .counterClockwise:
            encoder.setFrontFacing(.counterClockwise)
        }
    }
    
    @inline(__always)
    private func setUniforms(_ uniforms: ContiguousArray<UInt8>, encoder: MTLRenderCommandEncoder, vertexIndex: inout Int, fragmentIndex: inout Int) {
        let length = MemoryLayout<UInt8>.stride * uniforms.count
        uniforms.withUnsafeBytes { uniforms in
            let uniforms = uniforms.baseAddress!
            if length < 4096 {// Let Metal manage our data if it's small
                encoder.setVertexBytes(uniforms, length: length, index: vertexIndex)
                encoder.setFragmentBytes(uniforms, length: length, index: fragmentIndex)
            }else if let instancedBuffer = device.makeBuffer(bytes: uniforms, length: length, options: .storageModeShared) {
                encoder.setVertexBuffer(instancedBuffer, offset: 0, index: vertexIndex)
                encoder.setFragmentBuffer(instancedBuffer, offset: 0, index: fragmentIndex)
            }else{
                print("[GateEngine]: \(type(of: self)) Failed to attach uniforms to shader.")
            }
            vertexIndex += 1
            fragmentIndex += 1
        }
    }
    
    @inline(__always)
    private func primitive(from primitive: DrawFlags.Primitive) -> MTLPrimitiveType {
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
    
    @inline(__always)
    private func setTextures(_ textures: ContiguousArray<MTLTexture?>, encoder: MTLRenderCommandEncoder) {
        for index in textures.indices {
            encoder.setFragmentTexture(textures[index], index: index)
        }
    }
    
    @inline(__always)
    private func createUniforms(_ material: Material, _ camera: Camera?, _ matricies: Matrices) -> (uniforms: ContiguousArray<UInt8>, materials: ContiguousArray<ShaderMaterial>, textures: ContiguousArray<MTLTexture?>) {
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
            for value in customValues {
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
        var textures: ContiguousArray<MTLTexture?> = []
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
            
            textures.append((channel.texture?.textureBackend as? MetalTexture)?.mtlTexture)
        }

        return (uniforms, materials, textures)
    }
    
    @inline(__always)
    private func setTransforms(_ transforms: ContiguousArray<Transform3>, on encoder: MTLRenderCommandEncoder, at vertexIndex: inout Int) {
        var instancedUniforms: ContiguousArray<InstancedUniforms> = []
        instancedUniforms.reserveCapacity(transforms.count)
        for transform in transforms {
            let matrix = transform.createMatrix()
            let uniforms = InstancedUniforms(modelMatrix: matrix, inverseModelMatrix: matrix.inverse)
            instancedUniforms.append(uniforms)
        }
        
        let instanceUniformsSize = MemoryLayout<InstancedUniforms>.stride * instancedUniforms.count
        instancedUniforms.withUnsafeBufferPointer { instancedUniforms in
            if instanceUniformsSize < 4096 {// Let Metal manage our data if it's small
                encoder.setVertexBytes(instancedUniforms.baseAddress!, length: instanceUniformsSize, index: vertexIndex)
            }else if let instancedBuffer = device.makeBuffer(bytes: instancedUniforms.baseAddress!, length: instanceUniformsSize, options: .storageModeShared) {
                encoder.setVertexBuffer(instancedBuffer, offset: 0, index: vertexIndex)
            }else{
                print("GateEngine: \(type(of: self)) Failed to attach modelMatrix(s) to shader.")
            }
        }
        vertexIndex += 1
    }
    
    @inline(__always)
    private func setMaterials(_ materials: ContiguousArray<ShaderMaterial>, on encoder: MTLRenderCommandEncoder, vertexIndex: inout Int, fragmentIndex: inout Int) {
        let materialsSize = MemoryLayout<ShaderMaterial>.stride * materials.count
        materials.withUnsafeBufferPointer { materials in
            let materials = materials.baseAddress!
            if materialsSize < 4096 {// Let Metal manage our data if it's small
                encoder.setVertexBytes(materials, length: materialsSize, index: vertexIndex)
                encoder.setFragmentBytes(materials, length: materialsSize, index: fragmentIndex)
            }else if let instancedBuffer = device.makeBuffer(bytes: materials, length: materialsSize, options: .storageModeShared) {
                encoder.setVertexBuffer(instancedBuffer, offset: 0, index: vertexIndex)
                encoder.setFragmentBuffer(instancedBuffer, offset: 0, index: fragmentIndex)
            }else{
                print("GateEngine: \(type(of: self)) Failed to attach materials(s) to shader.")
            }
        }
        vertexIndex += 1
        fragmentIndex += 1
    }
    
    @inline(__always)
    private func setGeometries(_ geometries: ContiguousArray<MetalGeometry>, on encoder: MTLRenderCommandEncoder, at index: inout Int) {
        for geometry in geometries {
            for attributeIndex in geometry.attributes.indices {
                encoder.setVertexBuffer(geometry.buffers[attributeIndex], offset: 0, index: index)
                index += 1
            }
        }
    }
}

extension Renderer {
    @_transparent
    var device: MTLDevice {
        get {
            let renderer = backend as! MetalRenderer
            return renderer.device
        }
        set {
            let renderer = backend as! MetalRenderer
            renderer.device = newValue
            renderer.commandQueue = newValue.makeCommandQueue()!
        }
    }
    @_transparent
    var commandQueue: MTLCommandQueue {
        let renderer = backend as! MetalRenderer
        return renderer.commandQueue
    }
}
#endif
