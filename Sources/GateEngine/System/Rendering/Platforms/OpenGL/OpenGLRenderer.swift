/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenGL_GateEngine)
import Foundation
import OpenGL_GateEngine
import Shaders

class OpenGLRenderer: RendererBackend {
    init() {
        self.setup()
    }
    
#if GATEENGINE_DEBUG_RENDERING
    var singleWarnings: Set<String> = []
    func printOnce(_ string: String) {
        guard singleWarnings.contains(string) == false else {return}
        singleWarnings.insert(string)
        print(string)
    }
#endif
    
    lazy private var instanceMatriciesVBO: GLuint = glGenBuffer()
    let generator = GLSLCodeGenerator(version: .v330core)
    
    var _shaders: [ShaderKey:OpenGLShader] = [:]
    struct ShaderKey: Hashable {
        let vshID: ObjectIdentifier
        let fshID: ObjectIdentifier
        let attributes: ContiguousArray<CodeGenerator.InputAttribute>
        init(vsh: VertexShader, fsh: FragmentShader, attributes: ContiguousArray<CodeGenerator.InputAttribute>) {
            self.vshID = ObjectIdentifier(vsh)
            self.fshID = ObjectIdentifier(fsh)
            self.attributes = attributes
        }
    }
    struct OpenGLShader {
        let program: GLuint
        let vertexShader: VertexShader
        let fragmentShader: FragmentShader
    }
    @inline(__always)
    func openGLShader(vsh: VertexShader, fsh: FragmentShader, attributes: ContiguousArray<CodeGenerator.InputAttribute>) -> OpenGLShader {
        let key = ShaderKey(vsh: vsh, fsh: fsh, attributes: attributes)
        if let existing = _shaders[key] {
            return existing
        }
        let program = program(vsh: vsh, fsh: fsh, attributes: attributes)
        let shader = OpenGLShader(program: program, vertexShader: vsh, fragmentShader: fsh)
        _shaders[key] = shader
        return shader
    }
    
    func program(vsh: VertexShader, fsh: FragmentShader, attributes: ContiguousArray<CodeGenerator.InputAttribute>) -> GLuint {
        do {
            let sources = try generator.generateShaderCode(vertexShader: vsh, fragmentShader: fsh, attributes: attributes)
            

            let vsh = compileShader(sources.vertexSource, shared: "", withType: .vertex)!
#if GATEENGINE_LOG_SHADERS
            print("[GateEngine] Generated OpenGL Vertex Shader:\n\n\(GLSLCodeGenerator.addingLineNumbers(sources.vertexSource))\n")
#endif
#if GATEENGINE_DEBUG_RENDERING
            if let error = try glGetShaderInfoLog(shader: vsh), error.isEmpty == false {
                print("[GateEngine] Error \(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
            }
#endif
            let fsh = compileShader(sources.fragmentSource, shared: "", withType: .fragment)!
#if GATEENGINE_LOG_SHADERS
            print("[GateEngine] Generated OpenGL Fragment Shader:\n\n\(GLSLCodeGenerator.addingLineNumbers(sources.fragmentSource))\n")
#endif
#if GATEENGINE_DEBUG_RENDERING
            if let error = try glGetShaderInfoLog(shader: fsh), error.isEmpty == false {
                print("[GateEngine] Error \(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
            }
#endif
            
            let program = glCreateProgram()
            glAttachShader(vsh, toProgram: program)
            glAttachShader(fsh, toProgram: program)
            glLinkProgram(program)
            glValidateProgram(program)
#if GATEENGINE_DEBUG_RENDERING
            let status: Int = glGetProgramiv(program: program, property: .validateStatus)
            if status == 0 {
                let error = glGetProgramInfoLog(forProgram: program)
                if error.isEmpty == false {
                    print("[GateEngine] Shader Program Error \(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
                }else{
                    print("[GateEngine] GL Error: Link Failed")
                }
            }
            checkError()
#endif
            return program
        }catch{
            fatalError("\(error)")
        }
    }
    
    func draw(_ drawCommand: DrawCommand, camera: Camera?, matrices: Matrices, renderTarget: any _RenderTargetProtocol) {
        let geometries = ContiguousArray(drawCommand.geometries.map({$0 as! OpenGLGeometry}))
        
#if GATEENGINE_DEBUG_RENDERING
        for geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
#endif
      
        let vao = glGenVertexArrays(count: 1)[0]
        glBindVertexArray(vao)
        
        let attributes = OpenGLGeometry.shaderAttributes(from: geometries)
        let program = openGLShader(vsh: drawCommand.material.vertexShader, fsh: drawCommand.material.fragmentShader, attributes: attributes).program
        
        glUseProgram(program)
        
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
        
        setFlags(drawCommand.flags)
        setWinding(drawCommand.flags.winding)
        setUniforms(matrices, program: program, generator: generator)
        setMaterial(drawCommand.material, generator: generator, program: program)
        
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
        
        
        var vertexIndex: Int = 0
        setGeometries(geometries, at: &vertexIndex)
        setTransforms(drawCommand.transforms, at: &vertexIndex)
        
        glBindBuffer(geometries[0].buffers.last!, as: .elementArray)
        
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
        
        do {
            try glDrawElementsInstanced(mode: primitive(from: drawCommand.flags.primitive),
                                        count: geometries[0].indiciesCount,
                                        type: .uint16,
                                        instanceCount: GLsizei(drawCommand.transforms.count))
        }catch{
            
        }
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
        
        glDeleteVertexArrays([vao])
        
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
    }
    
    final class OpenGLSizeOnlyRenderTarget: _RenderTargetProtocol {
        var texture: Texture {get {fatalError()}set{}}
        var renderTargetBackend: RenderTargetBackend {get{fatalError()}set{}}
        var drawables: [Any] {get{fatalError()}set{}}
        func reshapeIfNeeded() {}
        var size: Size2 = .zero
        init() {}
    }
    let sizeOnlyRenderTarget = OpenGLSizeOnlyRenderTarget()
}

extension OpenGLRenderer {
    @inline(__always)
    private func setFlags(_ flags: DrawFlags) {
        switch flags.cull {
        case .disabled:
            glDisable(capability: .cullFace)
        case .back:
            glEnable(capability: .cullFace)
            glCullFace(.back)
        case .front:
            glEnable(capability: .cullFace)
            glCullFace(.front)
        }
        glFrontFacing(OpenGL.FaceWinding.clockwise)
        
        glEnable(capability: .depthTest)
        switch flags.depthTest {
        case .always:
            glDepthFunc(.alwaysSucceeed)
        case .greaterThan:
            glDepthFunc(.greaterThan)
        case .lessThan:
            glDepthFunc(.lessThan)
        case .never:
            glDepthFunc(.neverSucceeed)
        }
        
        switch flags.depthWrite {
        case .enabled:
            glDepthMask(true)
        case .disabled:
            glDepthMask(false)
        }
        
        switch flags.blendMode {
        case .none:
            glDisable(capability: .blend)
        case .normal:
            glEnable(capability: .blend)
            glBlendEquation(.add)
            glBlendFuncSeparate(sourceRGB: .sourceAlpha, destinationRGB: .oneMinusSourceAlpha, sourceAlpha: .one, destinationAlpha: .oneMinusSourceAlpha)
        }
    }
    
    @inline(__always)
    private func setWinding(_ winding: DrawFlags.Winding) {
        switch winding {
        case .clockwise:
            glFrontFacing(.clockwise)
        case .counterClockwise:
            glFrontFacing(.counterClockwise)
        }
    }
    
    @inline(__always)
    private func setUniforms(_ matrices: Matrices, program: GLuint, generator: GLSLCodeGenerator) {
        if let vMatrixLocation = try? glGetUniformLocation(inProgram: program, named: generator.variable(for: .uniformViewMatrix)) {
            glUniformMatrix4fv(location: vMatrixLocation, transpose: false, values: matrices.view.transposedArray())

#if GATEENGINE_DEBUG_RENDERING
            checkError()
#endif
        }
        
        if let pMatrixLocation = try? glGetUniformLocation(inProgram: program, named: generator.variable(for: .uniformProjectionMatrix)) {
            glUniformMatrix4fv(location: pMatrixLocation, transpose: false, values: matrices.projection.transposedArray())
#if GATEENGINE_DEBUG_RENDERING
            checkError()
#endif
        }
    }
    
    @inline(__always)
    private func primitive(from primitive: DrawFlags.Primitive) -> OpenGL_GateEngine.OpenGL.Elements.Mode {
        switch primitive {
        case .point:
            return .points
        case .line:
            return .lines
        case .lineStrip:
            return .lineStrip
        case .triangle:
            return .triangles
        case .triangleStrip:
            return .triangleStrip
        }
    }
    
    @inline(__always)
    private func setTransforms(_ transforms: ContiguousArray<Transform3>, at index: inout Int) {
        var data: [Float] = []
        data.reserveCapacity(16 * transforms.count)
        for transform in transforms {
            data.append(contentsOf: transform.createMatrix().transposedArray())
        }
        
        glBindBuffer(instanceMatriciesVBO, as: .array)
        glBufferData(data, withUsage: .static, as: .array)
        
        let atributeLocation = index
        for index in 0 ..< 4 {
            let atrributeLocation = GLuint(atributeLocation + index)
            glEnableVertexAttribArray(attributeIndex: atrributeLocation)
            let stride = MemoryLayout<SIMD16<Float>>.stride
            let offset = UnsafeMutableRawPointer(bitPattern: MemoryLayout<SIMD4<Float>>.stride * index)
            glVertexAttribPointer(attributeIndex: atrributeLocation, unitsPerComponent: 4, unitType: .float, stride: GLsizei(stride), pointer: offset)
            glVertexAttribDivisor(atrributeLocation, divisor: 1)
        }
        index += 4
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
    }
    
    @inline(__always)
    private func setMaterial(_ material: Material, generator: GLSLCodeGenerator, program: GLuint) {
        do {
            for index in material.channels.indices {
                let channel = material.channels[index]
                if let texture = channel.texture?.textureBackend as? OpenGLTexture {
                    let textureName = generator.variable(for: .channelAttachment(UInt8(index)))
                    if let location = try? glGetUniformLocation(inProgram: program, named: textureName) {
                        glActiveTexture(unit: .texture(index))
                        glBindTexture(texture.textureId, as: .texture2D)
                        try glUniform(location: location, values: GLint(index))
                    }else{
#if GATEENGINE_DEBUG_RENDERING
                        printOnce("[GateEngine] Warning: OpenGL attribute [\(textureName)] not found.")
#endif
                    }
                }
                
                let scaleName = generator.variable(for: .channelScale(UInt8(index)))
                if let location = try? glGetUniformLocation(inProgram: program, named: scaleName) {
                    try glUniform(location: location, values: channel.scale.x, channel.scale.y)
                }else{
#if GATEENGINE_DEBUG_RENDERING
                    printOnce("[GateEngine] Warning: OpenGL attribute [\(scaleName)] not found.")
#endif
                }
                let offsetName = generator.variable(for: .channelOffset(UInt8(index)))
                if let location = try? glGetUniformLocation(inProgram: program, named: offsetName) {
                    try glUniform(location: location, values: channel.offset.x, channel.offset.y)
                }else{
#if GATEENGINE_DEBUG_RENDERING
                    printOnce("[GateEngine] Warning: OpenGL attribute [\(offsetName)] not found.")
#endif
                }
                let colorName = generator.variable(for: .channelColor(UInt8(index)))
                if let location = try? glGetUniformLocation(inProgram: program, named: colorName) {
                    try glUniform(location: location, values: channel.color.red, channel.color.green, channel.color.blue, channel.color.alpha)
                }else{
#if GATEENGINE_DEBUG_RENDERING
                    printOnce("[GateEngine] Warning: OpenGL attribute [\(colorName)] not found.")
#endif
                }
            }
            let customValues = material.sortedCustomUniforms()
            if customValues.isEmpty == false {
                for index in customValues.indices {
                    let value = customValues[index]
                    let name = generator.variable(for: .uniformCustom(UInt8(index), type: .bool))
                    switch value {
                    case let value as Bool:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            try glUniform(location: location, values: value ? 1 : 0)
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as Int:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            try glUniform(location: location, values: GLint(value))
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as Float:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            try glUniform(location: location, values: value)
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as any Vector2:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            try glUniform(location: location, values: value.x, value.y)
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as any Vector3:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            try glUniform(location: location, values: value.x, value.y, value.z)
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as Matrix3x3:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            glUniformMatrix3fv(location: location, transpose: false, values: value.transposedArray())
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as Matrix4x4:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            glUniformMatrix4fv(location: location, transpose: false, values: value.transposedArray())
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    case let value as Array<Matrix4x4>:
                        if let location = try? glGetUniformLocation(inProgram: program, named: name) {
                            var floats: [Float] = []
                            floats.reserveCapacity(value.count * 16 * 24)
                            for mtx in value {
                                floats.append(contentsOf: mtx.transposedArray())
                            }
                            while floats.count < 16 * 24 {
                                floats.append(0)
                            }
                            glUniformMatrix4fv(location: location, transpose: false, values: floats)
                        }else{
#if GATEENGINE_DEBUG_RENDERING
                            printOnce("[GateEngine] Warning: OpenGL attribute [\(name)] not found.")
#endif
                        }
                    default:
                        fatalError()
                    }
                }
            }
        }catch{
#if GATEENGINE_DEBUG_RENDERING
            printOnce("[GateEngine] Error: \(error).")
#endif
        }
        
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
    }
    
    @inline(__always)
    private func setGeometries(_ geometries: ContiguousArray<OpenGLGeometry>, at index: inout Int) {
        for geometry in geometries {
            for attributeIndex in geometry.attributes.indices {
                let glIndex = GLuint(index)
                
                let attribute = geometry.attributes[attributeIndex]
                glBindBuffer(geometry.buffers[attributeIndex], as: .array)
                glEnableVertexAttribArray(attributeIndex: glIndex)
                
                switch attribute.type {
                case .float:
                    glVertexAttribPointer(attributeIndex: glIndex, unitsPerComponent: GLint(attribute.componentLength), unitType: .float)
                case .uInt16:
                    glVertexAttribPointer(attributeIndex: glIndex, unitsPerComponent: GLint(attribute.componentLength), unitType: .uint16)
                case .uInt32:
                    glVertexAttribPointer(attributeIndex: glIndex, unitsPerComponent: GLint(attribute.componentLength), unitType: .float)
                }
                
                index += 1
            }
        }
#if GATEENGINE_DEBUG_RENDERING
        checkError()
#endif
    }
}

extension OpenGLRenderer {
#if GATEENGINE_DEBUG_RENDERING
    @_transparent
    func checkError(_ function: String = #function, _ line: Int = #line) {
        assert(glCheckFramebufferStatus(target: .draw) == .complete)
        assert({let error = glGetError(); if error != .none {print(error)}; return error == .none}())
    }
#endif
}

#if GATEENGINE_DEBUG_RENDERING
extension Renderer {
    @_transparent
    func openGLCheckError(_ function: String = #function, _ line: Int = #line) {
        (self._backend as! OpenGLRenderer).checkError(function, line)
    }
}
#endif


extension OpenGLRenderer {
    private func compileShader(_ source: String, shared: String?, withType type: OpenGL_GateEngine.OpenGL.Shader.Kind, function: StaticString = #function, line: Int = #line) -> GLuint? {
        var source = source
        if let shared {
            source = shared + source
        }

        // Compile the shader.
        let shader = glCreateShader(ofType: type)
        do {
            try glShaderSource(shader: shader, source: source)
            glCompileShader(shader)
        }catch{
            assertionFailure("\(error)")
        }
        
        #if GATEENGINE_DEBUG_RENDERING
        func printableError() throws -> String {
            guard let glError = try glGetShaderInfoLog(shader: shader) else {return ""}
            var error = ""
            let lines = glError.components(separatedBy: "\n").map({$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}).filter({$0.isEmpty == false})
            #if os(macOS) || os(iOS) || os(tvOS)
            for lineLower in lines {
                let glComponenets = lineLower.components(separatedBy: ":")
                
                let filePath = ""
                let lineLower = Int(glComponenets[2].trimmingCharacters(in: CharacterSet.whitespaces))! - 1
                error += filePath + ":\(lineLower):\(glComponenets[1].trimmingCharacters(in: CharacterSet.whitespaces)):"
                error += " \(glComponenets[0].trimmingCharacters(in: CharacterSet.whitespaces).lowercased()):"
                for comp in glComponenets[3 ..< glComponenets.indices.endIndex] {
                    error +=  " \(comp.trimmingCharacters(in: CharacterSet.whitespaces))"
                }
                error += "\n"
            }
            print("[GateEngine] Error \(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
            #else
            print("[GateEngine] Error \(self.self).\(#function):\(#line), OpenGL Error")
            #endif
            return "Shader compiler error."
        }
        #endif
        // Make sure the compilation was successful.
        do {
            let success = try glGetShaderCompileStatus(shader: shader)
            #if GATEENGINE_DEBUG_RENDERING
            if !success {
                let error = try printableError()
                assert(success, error)
            }
            #endif
        }catch{
            fatalError("\(error)")
        }
        return shader
    }
}

extension Renderer {
    @_transparent
    var openGLBackend: OpenGLRenderer {
        return _backend as! OpenGLRenderer
    }
}

#endif
