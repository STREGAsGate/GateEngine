/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import WebAPIBase
import DOM
import WebGL1
import WebGL2
import GameMath
import Shaders

public typealias GL = WebGL2RenderingContext

class WebGL2Renderer: RendererBackend {
    @inline(__always)
    var renderingAPI: RenderingAPI { .webGL2 }

    lazy private var instanceMatriciesVBO: WebGLBuffer = WebGL2Renderer.context.createBuffer()!
    let generator = GLSLCodeGenerator(version: .v300es)

    var _shaders: [ShaderKey: WebGLShader] = [:]
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
    struct WebGLShader {
        let program: WebGLProgram
        let vertexShader: VertexShader
        let fragmentShader: FragmentShader
    }
    @inline(__always)
    func webGLShader(
        vsh: VertexShader,
        fsh: FragmentShader,
        attributes: ContiguousArray<CodeGenerator.InputAttribute>
    ) -> WebGLShader {
        let key = ShaderKey(vsh: vsh, fsh: fsh, attributes: attributes)
        if let existing = _shaders[key] {
            return existing
        }
        let program = program(vsh: vsh, fsh: fsh, attributes: attributes)
        let shader = WebGLShader(program: program, vertexShader: vsh, fragmentShader: fsh)
        _shaders[key] = shader
        return shader
    }

    func program(
        vsh: VertexShader,
        fsh: FragmentShader,
        attributes: ContiguousArray<CodeGenerator.InputAttribute>
    ) -> WebGLProgram {
        do {
            let gl = WebGL2Renderer.context

            let sources = try generator.generateShaderCode(
                vertexShader: vsh,
                fragmentShader: fsh,
                attributes: attributes
            )

            #if GATEENGINE_LOG_SHADERS
            Log.info(
                "Generated OpenGL ES Vertex Shader:\n\n\(GLSLCodeGenerator.addingLineNumbers(sources.vertexSource))\n"
            )
            #endif
            let _vsh = gl.createShader(type: WebGL2RenderingContext.VERTEX_SHADER)!
            gl.shaderSource(shader: _vsh, source: sources.vertexSource)
            gl.compileShader(shader: _vsh)
            if let error = Self.context.getShaderInfoLog(shader: _vsh), error.isEmpty == false {
                Log.error("\(self.self).\(#function):\(#line), WebGL Error:\n\(error)")
            }

            #if GATEENGINE_LOG_SHADERS
            Log.info(
                "Generated OpenGL ES Fragment Shader:\n\n\(GLSLCodeGenerator.addingLineNumbers(sources.fragmentSource))\n"
            )
            #endif
            let _fsh = gl.createShader(type: WebGL2RenderingContext.FRAGMENT_SHADER)!
            gl.shaderSource(shader: _fsh, source: sources.fragmentSource)
            gl.compileShader(shader: _fsh)
            #if GATEENGINE_DEBUG_RENDERING
            if let error = Self.context.getShaderInfoLog(shader: _fsh), error.isEmpty == false {
                Log.error("\(self.self).\(#function):\(#line), WebGL Error:\n\(error)")
            }
            #endif

            let program = gl.createProgram()!
            gl.attachShader(program: program, shader: _vsh)
            gl.attachShader(program: program, shader: _fsh)
            gl.linkProgram(program: program)
            gl.validateProgram(program: program)
            #if GATEENGINE_DEBUG_RENDERING
            if gl.getProgramParameter(program: program, pname: GL.VALIDATE_STATUS).boolean == false
            {
                if let error = gl.getProgramInfoLog(program: program), error.isEmpty == false {
                    Log.error("\(self.self).\(#function):\(#line), WebGL Error:\n\(error)")
                } else {
                    Log.error("WebGL2 Shader Linking Failed: Reason Unknown")
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
        let gl = WebGL2Renderer.context
        let geometries = ContiguousArray(drawCommand.geometries.map({ $0 as! WebGL2Geometry }))

        #if GATEENGINE_DEBUG_RENDERING
        for geometry in geometries {
            assert(drawCommand.flags.primitive == geometry.primitive)
        }
        #endif

        let attributes = WebGL2Geometry.shaderAttributes(from: geometries)
        let program = webGLShader(
            vsh: drawCommand.material.vertexShader,
            fsh: drawCommand.material.fragmentShader,
            attributes: attributes
        ).program

        gl.useProgram(program: program)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        setFlags(drawCommand.flags, in: gl)
        setWinding(drawCommand.flags.winding, in: gl)
        setUniforms(matrices, program: program, generator: generator, in: gl)
        setMaterial(drawCommand.material, generator: generator, program: program, in: gl)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        let vao: WebGLVertexArrayObject! = gl.createVertexArray()
        gl.bindVertexArray(array: vao)
        var vertexIndex: Int = 0
        setGeometries(geometries, at: &vertexIndex, in: gl)
        setTransforms(drawCommand.transforms, at: &vertexIndex, in: gl)

        gl.bindBuffer(target: GL.ELEMENT_ARRAY_BUFFER, buffer: geometries[0].buffers.last!)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        gl.drawElementsInstanced(
            mode: primitive(from: drawCommand.flags.primitive),
            count: geometries[0].indicesCount,
            type: GL.UNSIGNED_SHORT,
            offset: 0,
            instanceCount: GLsizei(drawCommand.transforms.count)
        )
        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif

        gl.deleteVertexArray(vertexArray: vao)

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }
}

extension WebGL2Renderer {
    @inline(__always)
    private func setFlags(_ flags: DrawFlags, in gl: WebGL2RenderingContext) {
        switch flags.cull {
        case .disabled:
            gl.disable(cap: GL.CULL_FACE)
        case .back:
            gl.enable(cap: GL.CULL_FACE)
            gl.cullFace(mode: GL.BACK)
        case .front:
            gl.enable(cap: GL.CULL_FACE)
            gl.cullFace(mode: GL.FRONT)
        }

        gl.enable(cap: GL.DEPTH_TEST)
        switch flags.depthTest {
        case .always:
            gl.depthFunc(func: GL.ALWAYS)
        case .greater:
            gl.depthFunc(func: GL.GREATER)
        case .greaterEqual:
            gl.depthFunc(func: GL.GEQUAL)
        case .less:
            gl.depthFunc(func: GL.LESS)
        case .lessEqual:
            gl.depthFunc(func: GL.LEQUAL)
        case .never:
            gl.depthFunc(func: GL.NEVER)
        }

        switch flags.depthWrite {
        case .enabled:
            gl.depthMask(flag: true)
        case .disabled:
            gl.depthMask(flag: false)
        }

        switch flags.blendMode {
        case .none:
            gl.disable(cap: GL.BLEND)
        case .normal:
            gl.enable(cap: GL.BLEND)
            gl.blendEquation(mode: GL.FUNC_ADD)
            gl.blendFuncSeparate(
                srcRGB: GL.SRC_ALPHA,
                dstRGB: GL.ONE_MINUS_SRC_ALPHA,
                srcAlpha: GL.ONE,
                dstAlpha: GL.ONE_MINUS_SRC_ALPHA
            )
        }
    }

    @inline(__always)
    private func setWinding(_ winding: DrawFlags.Winding, in gl: WebGL2RenderingContext) {
        switch winding {
        case .clockwise:
            gl.frontFace(mode: GL.CW)
        case .counterClockwise:
            gl.frontFace(mode: GL.CCW)
        }
    }

    @inline(__always)
    private func setUniforms(
        _ matrices: Matrices,
        program: WebGLProgram,
        generator: GLSLCodeGenerator,
        in gl: WebGL2RenderingContext
    ) {
        if let vMatrixLocation = gl.getUniformLocation(
            program: program,
            name: generator.variable(for: .uniformViewMatrix)
        ) {
            let vMtx = Float32List.float32Array(Float32Array(matrices.view.transposedArray()))
            gl.uniformMatrix4fv(location: vMatrixLocation, transpose: false, data: vMtx)
            #if GATEENGINE_DEBUG_RENDERING
            checkError()
            #endif
        }

        if let pMatrixLocation = gl.getUniformLocation(
            program: program,
            name: generator.variable(for: .uniformProjectionMatrix)
        ) {
            let pMtx = Float32List.float32Array(Float32Array(matrices.projection.transposedArray()))
            gl.uniformMatrix4fv(location: pMatrixLocation, transpose: false, data: pMtx)
            #if GATEENGINE_DEBUG_RENDERING
            checkError()
            #endif
        }
    }

    @inline(__always)
    private func primitive(from primitive: DrawFlags.Primitive) -> GLenum {
        switch primitive {
        case .point:
            return GL.POINTS
        case .line:
            return GL.LINES
        case .lineStrip:
            return GL.LINE_STRIP
        case .triangle:
            return GL.TRIANGLES
        case .triangleStrip:
            return GL.TRIANGLE_STRIP
        }
    }

    @inline(__always)
    private func setTransforms(
        _ transforms: ContiguousArray<Transform3>,
        at index: inout Int,
        in gl: WebGL2RenderingContext
    ) {
        var data: [Float] = []
        data.reserveCapacity(16 * transforms.count)
        for transform in transforms {
            data.append(contentsOf: transform.createMatrix().transposedArray())
        }
        let floats: AllowSharedBufferSource = .arrayBuffer(Float32Array(data).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: instanceMatriciesVBO)
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: floats, usage: GL.STATIC_DRAW)

        let attributeLocation = index
        for index in 0 ..< 4 {
            let attributeLocation = GLuint(attributeLocation + index)
            gl.enableVertexAttribArray(index: attributeLocation)
            let stride = MemoryLayout<SIMD16<Float>>.stride
            let offset = MemoryLayout<SIMD4<Float>>.stride * index
            gl.vertexAttribPointer(
                index: attributeLocation,
                size: 4,
                type: GL.FLOAT,
                normalized: false,
                stride: GLsizei(stride),
                offset: GLintptr(offset)
            )
            gl.vertexAttribDivisor(index: attributeLocation, divisor: 1)
        }
        index += 4
        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }

    @inline(__always)
    private func setMaterial(
        _ material: Material,
        generator: GLSLCodeGenerator,
        program: WebGLProgram,
        in gl: WebGL2RenderingContext
    ) {
        for index in material.channels.indices {
            let channel = material.channels[index]
            if let texture = channel.texture?.textureBackend as? WebGL2Texture {
                let textureName = generator.variable(for: .channelAttachment(UInt8(index)))
                if let location = gl.getUniformLocation(program: program, name: textureName) {
                    gl.activeTexture(texture: GL.TEXTURE0 + UInt32(index))
                    gl.bindTexture(target: GL.TEXTURE_2D, texture: texture.textureId)
                    gl.uniform1i(location: location, x: GLint(index))
                } else {
                    #if GATEENGINE_DEBUG_RENDERING
                    Log.warnOnce("OpenGL attribute [\(textureName)] not found.")
                    #endif
                }
            }

            let scaleName = generator.variable(for: .channelScale(UInt8(index)))
            if let location = gl.getUniformLocation(program: program, name: scaleName) {
                gl.uniform2f(location: location, x: channel.scale.x, y: channel.scale.y)
            } else {
                #if GATEENGINE_DEBUG_RENDERING
                Log.warnOnce("OpenGL attribute [\(scaleName)] not found.")
                #endif
            }
            let offsetName = generator.variable(for: .channelOffset(UInt8(index)))
            if let location = gl.getUniformLocation(program: program, name: offsetName) {
                gl.uniform2f(location: location, x: channel.offset.x, y: channel.offset.y)
            } else {
                #if GATEENGINE_DEBUG_RENDERING
                Log.warnOnce("OpenGL attribute [\(offsetName)] not found.")
                #endif
            }
            let colorName = generator.variable(for: .channelColor(UInt8(index)))
            if let location = gl.getUniformLocation(program: program, name: colorName) {
                gl.uniform4f(
                    location: location,
                    x: channel.color.red,
                    y: channel.color.green,
                    z: channel.color.blue,
                    w: channel.color.alpha
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
                let variable = generator.variable(for: .uniformCustom(UInt8(index), type: .bool))
                switch value {
                case let value as Bool:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        gl.uniform1i(location: location, x: value ? 1 : 0)
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as Int:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        gl.uniform1i(location: location, x: GLint(value))
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as Float:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        gl.uniform1f(location: location, x: value)
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as any Vector2:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        gl.uniform2f(location: location, x: value.x, y: value.y)
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as any Vector3:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        gl.uniform3f(location: location, x: value.x, y: value.y, z: value.z)
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as Matrix3x3:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        let data = Float32List.float32Array(Float32Array(value.transposedArray()))
                        gl.uniformMatrix3fv(location: location, transpose: false, data: data)
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as Matrix4x4:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        let data = Float32List.float32Array(Float32Array(value.transposedArray()))
                        gl.uniformMatrix4fv(location: location, transpose: false, data: data)
                    } else {
                        #if GATEENGINE_DEBUG_RENDERING
                        Log.warnOnce("OpenGL attribute [\(variable)] not found.")
                        #endif
                    }
                case let value as [Matrix4x4]:
                    if let location = gl.getUniformLocation(program: program, name: variable) {
                        let capacity =
                            material.vertexShader.arrayCapacityForUniform(named: name) ?? material
                            .fragmentShader.arrayCapacityForUniform(named: name)!
                        var floats: [Float] = []
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
                        let data = Float32List.float32Array(Float32Array(floats))
                        gl.uniformMatrix4fv(location: location, transpose: false, data: data)
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

        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }

    @inline(__always)
    private func setGeometries(
        _ geometries: ContiguousArray<WebGL2Geometry>,
        at index: inout Int,
        in gl: WebGL2RenderingContext
    ) {
        for geometry in geometries {
            for attributeIndex in geometry.attributes.indices {
                let glIndex = GLuint(index)

                let attribute = geometry.attributes[attributeIndex]
                gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: geometry.buffers[attributeIndex])
                gl.enableVertexAttribArray(index: glIndex)

                switch attribute.type {
                case .float:
                    gl.vertexAttribPointer(
                        index: glIndex,
                        size: GLint(attribute.componentLength),
                        type: GL.FLOAT,
                        normalized: false,
                        stride: 0,
                        offset: 0
                    )
                case .uInt16:
                    gl.vertexAttribIPointer(
                        index: glIndex,
                        size: GLint(attribute.componentLength),
                        type: GL.UNSIGNED_SHORT,
                        stride: 0,
                        offset: 0
                    )
                case .uInt32:
                    gl.vertexAttribIPointer(
                        index: glIndex,
                        size: GLint(attribute.componentLength),
                        type: GL.UNSIGNED_INT,
                        stride: 0,
                        offset: 0
                    )
                }

                index += 1
            }
        }
        #if GATEENGINE_DEBUG_RENDERING
        checkError()
        #endif
    }
}

extension WebGL2Renderer {
    @_transparent
    var context: WebGL2RenderingContext {
        return Self.context
    }
    static let context: WebGL2RenderingContext = {
        let element = globalThis.document.getElementById(elementId: "mainCanvas")!
        let canvas = HTMLCanvasElement(from: element)!
        let options = [
            "powerPreference": "high-performance",
            "preserveDrawingBuffer": true,
            "desynchronized": true,
            "antialias": false,
            "failIfMajorPerformanceCaveat": false,
            "premultipliedAlpha": false,
        ].jsValue
        let context = canvas.getContext(WebGL2RenderingContext.self, options: options)!
        return context
    }()

    #if GATEENGINE_DEBUG_RENDERING
    @_transparent
    func checkError(_ function: String = #function, _ line: Int = #line) {
        var error = Self.context.checkFramebufferStatus(target: GL.FRAMEBUFFER)
        if error == GL.FRAMEBUFFER_COMPLETE {
            error = Self.context.checkFramebufferStatus(target: GL.DRAW_FRAMEBUFFER)
            if error == GL.FRAMEBUFFER_COMPLETE {
                error = Self.context.checkFramebufferStatus(target: GL.READ_FRAMEBUFFER)
                if error == GL.FRAMEBUFFER_COMPLETE {
                    error = Self.context.getError()
                }
            }
        }

        switch error {
        case GL.FRAMEBUFFER_COMPLETE:
            return
        case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
            Log.errorOnce("WebGL2: FRAMEBUFFER_INCOMPLETE_ATTACHMENT")
        case GL.FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            Log.errorOnce("WebGL2: FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT")
        case GL.FRAMEBUFFER_UNSUPPORTED:
            Log.errorOnce("WebGL2: FRAMEBUFFER_UNSUPPORTED")
        case GL.INVALID_OPERATION:
            Log.errorOnce("WebGL2: INVALID_OPERATION")
        case GL.INVALID_VALUE:
            Log.errorOnce("WebGL2: INVALID_VALUE")
        case GL.INVALID_ENUM:
            Log.errorOnce("WebGL2: INVALID_ENUM")
        case GL.OUT_OF_MEMORY:
            Log.errorOnce("WebGL2: OUT_OF_MEMORY")
        case GL.NO_ERROR:
            return
        default:
            Log.errorOnce("\(error)")
        }
    }
    #endif
}

#if GATEENGINE_DEBUG_RENDERING
extension Renderer {
    @_transparent
    func checkError(_ function: String = #function, _ line: Int = #line) {
        (self._backend as! WebGL2Renderer).checkError(function, line)
    }
}
#endif

#endif
