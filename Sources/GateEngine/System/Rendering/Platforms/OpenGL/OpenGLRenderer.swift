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
    @inline(__always)
    var renderingAPI: RenderingAPI {
        #if os(macOS) || os(Windows) || (os(Linux) && !os(Android))
        return .openGL
        #elseif os(iOS) || os(tvOS) || os(Android)
        return .openGLES
        #else
        #error("Unhandled Platform")
        #endif
    }

    init() {
        self.setup()
    }

    let generator = GLSLCodeGenerator(version: .v330core)

    var _shaders: [ShaderKey: OpenGLShader] = [:]
    struct ShaderKey: Hashable {
        let vshID: ObjectIdentifier
        let fshID: ObjectIdentifier
        let attributes: ContiguousArray<CodeGenerator.InputAttribute>
        init(
            vsh: VertexShader,
            fsh: FragmentShader,
            attributes: ContiguousArray<CodeGenerator.InputAttribute>
        ) {
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
    func openGLShader(
        vsh: VertexShader,
        fsh: FragmentShader,
        attributes: ContiguousArray<CodeGenerator.InputAttribute>
    ) -> OpenGLShader {
        let key = ShaderKey(vsh: vsh, fsh: fsh, attributes: attributes)
        if let existing = _shaders[key] {
            return existing
        }
        let program = program(vsh: vsh, fsh: fsh, attributes: attributes)
        let shader = OpenGLShader(program: program, vertexShader: vsh, fragmentShader: fsh)
        _shaders[key] = shader
        return shader
    }

    func program(
        vsh: VertexShader,
        fsh: FragmentShader,
        attributes: ContiguousArray<CodeGenerator.InputAttribute>
    ) -> GLuint {
        do {
            let sources = try generator.generateShaderCode(
                vertexShader: vsh,
                fragmentShader: fsh,
                attributes: attributes
            )

            #if GATEENGINE_LOG_SHADERS
            Log.info(
                "Generated OpenGL Vertex Shader:\n\n\(GLSLCodeGenerator.addingLineNumbers(sources.vertexSource))\n"
            )
            #endif
            let vsh = compileShader(sources.vertexSource, shared: "", withType: .vertex)!
            #if GATEENGINE_DEBUG_RENDERING
            if let error = try glGetShaderInfoLog(shader: vsh), error.isEmpty == false {
                Log.error("\(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
            }
            #endif
            #if GATEENGINE_LOG_SHADERS
            Log.info(
                "Generated OpenGL Fragment Shader:\n\n\(GLSLCodeGenerator.addingLineNumbers(sources.fragmentSource))\n"
            )
            #endif
            let fsh = compileShader(sources.fragmentSource, shared: "", withType: .fragment)!
   
            #if GATEENGINE_DEBUG_RENDERING
            if let error = try glGetShaderInfoLog(shader: fsh), error.isEmpty == false {
                Log.error("\(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
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
                    Log.error(
                        "Shader Program Error \(self.self).\(#function):\(#line), OpenGL Error:\n\(error)"
                    )
                } else {
                    Log.error("OpenGL Link Failed")
                }
            }
            checkError()
            #endif
            return program
        } catch {
            Log.fatalError("\(error)")
        }
    }

    func draw(
        _ drawCommand: DrawCommand,
        camera: Camera?,
        matrices: Matrices,
        renderTarget: some _RenderTargetProtocol
    ) {
        let geometries = drawCommand.geometries.map({ $0 as! OpenGLGeometry })

        #if GATEENGINE_DEBUG_RENDERING
        for geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
        #endif
        let instanceMatriciesVBO: GLuint = glGenBuffer()
        let vao = glGenVertexArrays(count: 1)[0]
        glBindVertexArray(vao)

        let attributes = OpenGLGeometry.shaderAttributes(from: geometries)
        let program = openGLShader(
            vsh: drawCommand.material.vertexShader,
            fsh: drawCommand.material.fragmentShader,
            attributes: attributes
        ).program

        glUseProgram(program)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        setFlags(drawCommand.flags)
        setUniforms(matrices, program: program, generator: generator)
        setMaterial(drawCommand.material, generator: generator, program: program)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        var vertexIndex: Int = 0
        setGeometries(geometries, at: &vertexIndex)
        setTransforms(drawCommand.transforms, vbo: instanceMatriciesVBO, at: &vertexIndex)

        glBindBuffer(geometries[0].buffers.last!, as: .elementArray)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        do {
            try glDrawElementsInstanced(
                mode: primitive(from: drawCommand.flags.primitive),
                count: geometries[0].indicesCount,
                type: .uint16,
                instanceCount: GLsizei(drawCommand.transforms.count)
            )
        } catch {

        }
        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        glDeleteVertexArrays([vao])
        glDeleteBuffers([instanceMatriciesVBO])

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }

    final class OpenGLSizeOnlyRenderTarget: _RenderTargetProtocol {
        var lastDrawnFrame: UInt = .max
        var texture: Texture {
            get { fatalError() }
            set {}
        }
        var renderTargetBackend: any RenderTargetBackend {
            get { fatalError() }
            set {}
        }
        var drawables: [Any] {
            get { fatalError() }
            set {}
        }
        func reshapeIfNeeded() {}
        var size: Size2 = .zero
        init() {}
    }
    let sizeOnlyRenderTarget = OpenGLSizeOnlyRenderTarget()
}

extension OpenGLRenderer {
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
        
        switch flags.winding {
        case .clockwise:
            glFrontFacing(.clockwise)
        case .counterClockwise:
            glFrontFacing(.counterClockwise)
        }

        glEnable(capability: .depthTest)
        switch flags.depthTest {
        case .always:
            glDepthFunc(.alwaysSucceed)
        case .greater:
            glDepthFunc(.greaterThan)
        case .greaterEqual:
            glDepthFunc(.greaterThanOrEqualTo)
        case .less:
            glDepthFunc(.lessThan)
        case .lessEqual:
            glDepthFunc(.lessThanOrEqualTo)
        case .never:
            glDepthFunc(.neverSucceed)
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
            glBlendFuncSeparate(
                sourceRGB: .sourceAlpha,
                destinationRGB: .oneMinusSourceAlpha,
                sourceAlpha: .one,
                destinationAlpha: .oneMinusSourceAlpha
            )
        }
    }

    private func setUniforms(_ matrices: Matrices, program: GLuint, generator: GLSLCodeGenerator) {
        if let vMatrixLocation = try? glGetUniformLocation(
            inProgram: program,
            named: generator.variable(for: .uniformViewMatrix)
        ) {
            glUniformMatrix4fv(
                location: vMatrixLocation,
                transpose: false,
                values: matrices.view.transposedArray()
            )

            #if GATEENGINE_DEBUG_RENDERING
            checkError()
            #endif
        }

        if let pMatrixLocation = try? glGetUniformLocation(
            inProgram: program,
            named: generator.variable(for: .uniformProjectionMatrix)
        ) {
            glUniformMatrix4fv(
                location: pMatrixLocation,
                transpose: false,
                values: matrices.projection.transposedArray()
            )
            #if GATEENGINE_DEBUG_RENDERING
            checkError()
            #endif
        }
    }

    private func primitive(from primitive: DrawFlags.Primitive)
        -> OpenGL_GateEngine.OpenGL.Elements.Mode
    {
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

    private func setTransforms(
        _ transforms: [Transform3],
        vbo: GLuint,
        at index: inout Int
    ) {
        var data: [Float] = []
        data.reserveCapacity(16 * transforms.count)
        for transform in transforms {
            data.append(contentsOf: transform.createMatrix().transposedArray())
        }

        glBindBuffer(vbo, as: .array)
        glBufferData(data, withUsage: .static, as: .array)

        let attributeLocation = index
        for index in 0 ..< 4 {
            let attributeLocation = GLuint(attributeLocation + index)
            glEnableVertexAttribArray(attributeIndex: attributeLocation)
            let stride = MemoryLayout<SIMD16<Float>>.stride
            let offset = UnsafeMutableRawPointer(
                bitPattern: MemoryLayout<SIMD4<Float>>.stride * index
            )
            glVertexAttribPointer(
                attributeIndex: attributeLocation,
                unitsPerComponent: 4,
                unitType: .float,
                stride: GLsizei(stride),
                pointer: offset
            )
            glVertexAttribDivisor(attributeLocation, divisor: 1)
        }
        index += 4
        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }

    private func setMaterial(_ material: Material, generator: GLSLCodeGenerator, program: GLuint) {
        do {
            for index in material.channels.indices {
                let channel = material.channels[index]
                if let texture = channel.texture?.textureBackend as? OpenGLTexture {
                    let textureName = generator.variable(for: .channelAttachment(UInt8(index)))
                    if let location = try? glGetUniformLocation(
                        inProgram: program,
                        named: textureName
                    ) {
                        glActiveTexture(unit: .texture(index))
                        glBindTexture(texture.textureId, as: .texture2D)
                        try glUniform(location: location, values: GLint(index))
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(textureName)] not found.")
                        #endif
                    }
                }

                let scaleName = generator.variable(for: .channelScale(UInt8(index)))
                if let location = try? glGetUniformLocation(inProgram: program, named: scaleName) {
                    try glUniform(location: location, values: channel.scale.x, channel.scale.y)
                } else {
                    #if GATEENGINE_DEBUG_RENDERING
                    Log.warnOnce("OpenGL attribute [\(scaleName)] not found.")
                    #endif
                }
                let offsetName = generator.variable(for: .channelOffset(UInt8(index)))
                if let location = try? glGetUniformLocation(inProgram: program, named: offsetName) {
                    try glUniform(location: location, values: channel.offset.x, channel.offset.y)
                } else {
                    #if GATEENGINE_DEBUG_RENDERING
                    Log.warnOnce("OpenGL attribute [\(offsetName)] not found.")
                    #endif
                }
                let colorName = generator.variable(for: .channelColor(UInt8(index)))
                if let location = try? glGetUniformLocation(inProgram: program, named: colorName) {
                    try glUniform(
                        location: location,
                        values: channel.color.red,
                        channel.color.green,
                        channel.color.blue,
                        channel.color.alpha
                    )
                } else {
                    #if GATEENGINE_DEBUG_RENDERING
                    Log.warnOnce("OpenGL attribute [\(colorName)] not found.")
                    #endif
                }
            }
            let customValues = material.sortedCustomUniforms()
            if customValues.isEmpty == false {
                for index in customValues.indices {
                    let pair = customValues[index]
                    let value = pair.value
                    let name = pair.key
                    let variable = generator.variable(
                        for: .uniformCustom(name, type: .bool)
                    )
                    switch value {
                    case let value as Bool:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            try glUniform(location: location, values: value ? 1 : 0)
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as Int:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            try glUniform(location: location, values: GLint(value))
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as Float:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            try glUniform(location: location, values: value)
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as any Vector2:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            try glUniform(location: location, values: value.x, value.y)
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as any Vector3:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            try glUniform(location: location, values: value.x, value.y, value.z)
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as Matrix3x3:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            glUniformMatrix3fv(
                                location: location,
                                transpose: false,
                                values: value.transposedArray()
                            )
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as Matrix4x4:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            glUniformMatrix4fv(
                                location: location,
                                transpose: false,
                                values: value.transposedArray()
                            )
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    case let value as [Matrix4x4]:
                        if let location = try? glGetUniformLocation(
                            inProgram: program,
                            named: variable
                        ) {
                            var floats: [Float] = []
                            let capacity =
                            material.vertexShader.uniforms.arrayCapacityForUniform(named: name)
                            ?? material.fragmentShader.uniforms.arrayCapacityForUniform(named: name)!
                            floats.reserveCapacity(value.count * 16)
                            for mtx in value {
                                floats.append(contentsOf: mtx.transposedArray())
                            }

                            if floats.count > capacity * 16 {
                                floats = Array(floats[..<capacity])
                                Log.warnOnce(
                                    "Custom uniform \(name) exceeded max array capacity \(capacity) and was truncated."
                                )
                            }
                            glUniformMatrix4fv(location: location, transpose: false, values: floats)
                        } else {
                            #if GATEENGINE_DEBUG_RENDERING
                            Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                            #endif
                        }
                    default:
                        fatalError()
                    }
                }
            }
        } catch {
            #if GATEENGINE_DEBUG_RENDERING
            Log.errorOnce(error)
            #endif
        }

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }

    private func setGeometries(_ geometries: [OpenGLGeometry], at index: inout Int) {
        for geometry in geometries {
            for attributeIndex in geometry.attributes.indices {
                let glIndex = GLuint(index)

                let attribute = geometry.attributes[attributeIndex]
                glBindBuffer(geometry.buffers[attributeIndex], as: .array)
                glEnableVertexAttribArray(attributeIndex: glIndex)

                #if os(iOS) || os(tvOS) || os(macOS)
                if MetalRenderer.isSupported {
                    //Apples Metal wrapper appears to require actual correct types
                    switch attribute.type {
                    case .float:
                        glVertexAttribPointer(
                            attributeIndex: glIndex,
                            unitsPerComponent: GLint(attribute.componentLength),
                            unitType: .float
                        )
                    case .uInt16:
                        glVertexAttribPointer(
                            attributeIndex: glIndex,
                            unitsPerComponent: GLint(attribute.componentLength),
                            unitType: .uint16
                        )
                    case .uInt32:
                        glVertexAttribPointer(
                            attributeIndex: glIndex,
                            unitsPerComponent: GLint(attribute.componentLength),
                            unitType: .uint32
                        )
                    }
                } else {
                    // Standard OpenGL requires only float be used here
                    glVertexAttribPointer(
                        attributeIndex: glIndex,
                        unitsPerComponent: GLint(attribute.componentLength),
                        unitType: .float
                    )
                }
                #else
                glVertexAttribPointer(
                    attributeIndex: glIndex,
                    unitsPerComponent: GLint(attribute.componentLength),
                    unitType: .float
                )
                #endif

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
        assert(
            {
                let error = glGetError()
                if error != .none { Log.error(error) }
                return error == .none
            }()
        )
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
    private func compileShader(
        _ source: String,
        shared: String?,
        withType type: OpenGL_GateEngine.OpenGL.Shader.Kind,
        function: StaticString = #function,
        line: Int = #line
    ) -> GLuint? {
        var source = source
        if let shared {
            source = shared + source
        }

        // Compile the shader.
        let shader = glCreateShader(ofType: type)
        do {
            try glShaderSource(shader: shader, source: source)
            glCompileShader(shader)
        } catch {
            Log.fatalError("\(error)")
        }

        #if GATEENGINE_DEBUG_RENDERING
        func printableError() throws -> String {
            guard let glError = try glGetShaderInfoLog(shader: shader) else { return "" }
            var error = ""
            let lines = glError.components(separatedBy: "\n").map({
                $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }).filter({ $0.isEmpty == false })
            #if os(macOS) || os(iOS) || os(tvOS)
            for lineLower in lines {
                let glComponents = lineLower.components(separatedBy: ":")

                let filePath = ""
                let lineLower =
                    Int(glComponents[2].trimmingCharacters(in: CharacterSet.whitespaces))! - 1
                error +=
                    filePath
                    + ":\(lineLower):\(glComponents[1].trimmingCharacters(in: CharacterSet.whitespaces)):"
                error +=
                    " \(glComponents[0].trimmingCharacters(in: CharacterSet.whitespaces).lowercased()):"
                for comp in glComponents[3 ..< glComponents.indices.endIndex] {
                    error += " \(comp.trimmingCharacters(in: CharacterSet.whitespaces))"
                }
                error += "\n"
            }
            Log.error("\(self.self).\(#function):\(#line), OpenGL Error:\n\(error)")
            #else
            Log.error("\(self.self).\(#function):\(#line), OpenGL Error")
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
        } catch {
            Log.fatalError("\(error)")
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
