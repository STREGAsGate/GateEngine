/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import DOM
import WebAPIBase
import JavaScriptKit
import typealias WebGL1.GLsizei
import class WebGL1.WebGLBuffer
import WebGL2

class WebGL2Geometry: GeometryBackend, SkinnedGeometryBackend {
    let primitive: DrawFlags.Primitive
    let attributes: ContiguousArray<GeometryAttribute>
    let buffers: ContiguousArray<WebGLBuffer>
    let indicesCount: GLsizei
    
    required init(lines: RawLines) {
        let gl = WebGL2Renderer.context
        
        self.primitive = .line
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        var buffers: ContiguousArray<WebGLBuffer> = []
        buffers.reserveCapacity(3)
        
        buffers.append(gl.createBuffer()!)
        let positions: AllowSharedBufferSource = .arrayBuffer(Float32Array(lines.positions).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[0])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: positions, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let colors: AllowSharedBufferSource = .arrayBuffer(Float32Array(lines.colors).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[1])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: colors, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let indicies: AllowSharedBufferSource = .arrayBuffer(Uint16Array(lines.indicies).arrayBuffer)
        gl.bindBuffer(target: GL.ELEMENT_ARRAY_BUFFER, buffer: buffers[2])
        gl.bufferData(target: GL.ELEMENT_ARRAY_BUFFER, srcData: indices, usage: GL.STATIC_DRAW)
        
        self.buffers = buffers
        self.indicesCount = GLsizei(lines.indices.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.checkError()
#endif
    }
    
    required init(points: RawPoints) {
        let gl = WebGL2Renderer.context
        
        self.primitive = .point
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        var buffers: ContiguousArray<WebGLBuffer> = []
        buffers.reserveCapacity(3)
        
        buffers.append(gl.createBuffer()!)
        let positions: AllowSharedBufferSource = .arrayBuffer(Float32Array(points.positions).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[0])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: positions, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let colors: AllowSharedBufferSource = .arrayBuffer(Float32Array(points.colors).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[1])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: colors, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let indicies: AllowSharedBufferSource = .arrayBuffer(Uint16Array(points.indicies).arrayBuffer)
        gl.bindBuffer(target: GL.ELEMENT_ARRAY_BUFFER, buffer: buffers[2])
        gl.bufferData(target: GL.ELEMENT_ARRAY_BUFFER, srcData: indices, usage: GL.STATIC_DRAW)
        
        self.buffers = buffers
        self.indicesCount = GLsizei(points.indices.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.checkError()
#endif
    }
    
    required init(geometry: RawGeometry) {
        let gl = WebGL2Renderer.context
        
        self.primitive = .triangle
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord0),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord1),
            .init(type: .float, componentLength: 3, shaderAttribute: .tangent),
            .init(type: .float, componentLength: 3, shaderAttribute: .normal),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        var buffers: ContiguousArray<WebGLBuffer> = []
        buffers.reserveCapacity(7)
        
        buffers.append(gl.createBuffer()!)
        let positions: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.positions).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[0])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: positions, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let uvs1: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.uvSet1).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[1])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: uvs1, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let uvs2: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.uvSet2).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[2])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: uvs2, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let tangents: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.tangents).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[3])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: tangents, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let normals: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.normals).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[4])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: normals, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let colors: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.colors).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[5])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: colors, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let indicies: AllowSharedBufferSource = .arrayBuffer(Uint16Array(geometry.indicies).arrayBuffer)
        gl.bindBuffer(target: GL.ELEMENT_ARRAY_BUFFER, buffer: buffers[6])
        gl.bufferData(target: GL.ELEMENT_ARRAY_BUFFER, srcData: indices, usage: GL.STATIC_DRAW)
        
        self.buffers = buffers
        self.indicesCount = GLsizei(geometry.indices.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.checkError()
#endif
    }
    
    required init(geometry: RawGeometry, skin: Skin) {
        let gl = WebGL2Renderer.context
        
        self.primitive = .triangle
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord0),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord1),
            .init(type: .float, componentLength: 3, shaderAttribute: .tangent),
            .init(type: .float, componentLength: 3, shaderAttribute: .normal),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
            .init(type: .uInt32, componentLength: 4, shaderAttribute: .jointIndices),
            .init(type: .float, componentLength: 4, shaderAttribute: .jointWeights),
        ]
        
        var buffers: ContiguousArray<WebGLBuffer> = []
        buffers.reserveCapacity(9)
        
        buffers.append(gl.createBuffer()!)
        let positions: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.positions).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[0])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: positions, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let uvs1: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.uvSet1).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[1])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: uvs1, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let uvs2: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.uvSet2).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[2])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: uvs2, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let tangents: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.tangents).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[3])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: tangents, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let normals: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.normals).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[4])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: normals, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let colors: AllowSharedBufferSource = .arrayBuffer(Float32Array(geometry.colors).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[5])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: colors, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let jointIndicies: AllowSharedBufferSource = .arrayBuffer(Uint32Array(skin.jointIndicies).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[6])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: jointIndices, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let jointWeights: AllowSharedBufferSource = .arrayBuffer(Float32Array(skin.jointWeights).arrayBuffer)
        gl.bindBuffer(target: GL.ARRAY_BUFFER, buffer: buffers[7])
        gl.bufferData(target: GL.ARRAY_BUFFER, srcData: jointWeights, usage: GL.STATIC_DRAW)
        
        buffers.append(gl.createBuffer()!)
        let indicies: AllowSharedBufferSource = .arrayBuffer(Uint16Array(geometry.indicies).arrayBuffer)
        gl.bindBuffer(target: GL.ELEMENT_ARRAY_BUFFER, buffer: buffers[8])
        gl.bufferData(target: GL.ELEMENT_ARRAY_BUFFER, srcData: indices, usage: GL.STATIC_DRAW)
        
        self.buffers = buffers
        self.indicesCount = GLsizei(geometry.indices.count)
        
#if GATEENGINE_DEBUG_RENDERING
        Game.shared.renderer.checkError()
#endif
    }
    
#if GATEENGINE_DEBUG_RENDERING || DEBUG
    func isDrawCommandValid(sharedWith backend: GeometryBackend) -> Bool {
        let backend = backend as! Self
        if indicesCount != backend.indicesCount {
            return false
        }
        if self.primitive != backend.primitive {
            return false
        }
        return true
    }
#endif
    
    deinit {
        let gl = WebGL2Renderer.context
        for buffer in buffers {
            gl.deleteBuffer(buffer: buffer)
        }
    }
}

#endif
