/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenGL_GateEngine)
import OpenGL_GateEngine

class OpenGLRenderTarget: RenderTargetBackend {
    let framebuffer: GLuint
    
    let colorTexture: GLuint
    let depthTexture: GLuint
    
    var size: Size2 = Size2(2, 2)
    
    var clearColor: Color = .clear
    
    func reshape() {
        let width = Int(size.width)
        let height = Int(size.height)
        
        glBindTexture(colorTexture)
        glTexImage2D(internalFormat: .rgba, width: width, height: height, format: .rgba, type: .uint8)
 
        glBindTexture(depthTexture)
        glTexImage2D(internalFormat: .depth, width: width, height: height, format: .depth, type: .float)
    }
    
    let isWindow: Bool
    init(isWindow: Bool) {
        self.isWindow = isWindow
        
        self.framebuffer = glGenFramebuffers(count: 1)[0]
        self.colorTexture = glGenTextures(count: 1)[0]
        self.depthTexture = glGenTextures(count: 1)[0]
        
        glBindFramebuffer(framebuffer)
        
        glBindTexture(colorTexture)
        glTexParameter(filtering: .magnify, by: .nearest)
        glTexParameter(filtering: .minimize, by: .nearest)
        glTexParameter(wrapping: .horizontal, by: .clampToEdge)
        glTexParameter(wrapping: .vertical, by: .clampToEdge)
        glFramebufferTexture2D(attachment: .color(0), texture: colorTexture)
        
        glBindTexture(depthTexture)
        glTexParameter(filtering: .magnify, by: .linear)
        glTexParameter(filtering: .minimize, by: .linear)
        glTexParameter(wrapping: .horizontal, by: .clampToEdge)
        glTexParameter(wrapping: .vertical, by: .clampToEdge)
        glTexParameter(comparingBy: .lessThan)
        glFramebufferTexture2D(attachment: .depth, texture: depthTexture)
        
        glDrawBuffers([.color(0)])
        
        self.reshape()
        
        assert(self.framebuffer > 0)
        assert(glCheckFramebufferStatus(target: .draw) == .complete)
        assert({let error = glGetError(); if error != .none {print(error)}; return error == .none}())
    }
    
    deinit {
        glDeleteBuffers([colorTexture, depthTexture])
        glDeleteFramebuffers(framebuffer)
    }
}

extension OpenGLRenderTarget {
    @inline(__always)
    func clear() {
        glClearColor(clearColor.red, clearColor.green, clearColor.blue, clearColor.alpha)
        glClear([.color, .depth, .stencil])
    }
    
    func willBeginFrame() {
        glBindFramebuffer(framebuffer)
        glViewport(x: 0, y: 0, width: Int(size.width), height: Int(size.height))
        clear()
    }
    
    func didEndFrame() {
        glFlush()
    }
    
    func willBeginContent(matrices: Matrices?, viewport: Rect?) {
        glBindFramebuffer(framebuffer)
        if let viewport = viewport {
            glViewport(x: Int(viewport.position.x), y: Int(viewport.position.y), width: Int(viewport.size.width), height: Int(viewport.size.height))
        }else{
            glViewport(x: 0, y: 0, width: Int(size.width), height: Int(size.height))
        }
    }
    func didEndContent() {
        glFlush()
    }
}

#endif
