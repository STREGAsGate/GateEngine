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
    
    var windowRenderTarget: RenderTarget? = nil
    init(windowBacking: (any WindowBacking)?) {
        self.framebuffer = glGenFramebuffers(count: 1)[0]
        let textures = glGenTextures(count: 2)
        self.colorTexture = textures[0]
        self.depthTexture = textures[1]
        
        self.windowRenderTarget = windowBacking != nil ? RenderTarget(backend: self) : nil
        
        glBindFramebuffer(framebuffer)
        
        glBindTexture(colorTexture)
        glTexParameter(filtering: .magnify, by: .nearest)
        glTexParameter(filtering: .minimize, by: .nearest)
        glTexParameter(wrapping: .horizontal, by: .repeat)
        glTexParameter(wrapping: .vertical, by: .repeat)
        glFramebufferTexture2D(attachment: .color(0), texture: colorTexture)
 
        glBindTexture(depthTexture)
        glTexParameter(filtering: .magnify, by: .nearest)
        glTexParameter(filtering: .minimize, by: .nearest)
        glTexParameter(wrapping: .horizontal, by: .clampToEdge)
        glTexParameter(wrapping: .vertical, by: .clampToEdge)
        glTexParameter(comparingBy: .lessThan)
        glFramebufferTexture2D(attachment: .depth, texture: depthTexture)
        
        self.reshape()
        
        assert(self.framebuffer != 0)
        assert(glCheckFramebufferStatus(target: .draw) == .complete)
        assert({let error = glGetError(); if error != .none {Log.error(error)}; return error == .none}())
    }
    
    deinit {
        glDeleteBuffers([colorTexture, depthTexture])
        glDeleteFramebuffers(framebuffer)
    }
}

extension OpenGLRenderTarget {
    @_transparent
    func clear() {
        glClearColor(clearColor.red, clearColor.green, clearColor.blue, clearColor.alpha)
        glClearDepth(1)
        glDepthMask(true)
        glClear([.color, .depth])
    }
    
    func willBeginFrame(_ frame: UInt) {
        glBindFramebuffer(framebuffer)
        clear()
    }
    
    func didEndFrame(_ frame: UInt) {
        if let windowRenderTarget {
            glBindFramebuffer(0)
            glViewport(x: 0, y: 0, width: Int(size.width), height: Int(size.height))
            glClearColor(0, 0, 0, 1)
            glClear([.color])
            let renderer: Renderer = Game.shared.renderer
            let sizeOnlyRenderTarget = renderer.openGLBackend.sizeOnlyRenderTarget
            sizeOnlyRenderTarget.size = self.size
            renderer.draw(windowRenderTarget, into: sizeOnlyRenderTarget, options: [], sampler: .nearest)
        }
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
        
    }
}

#endif
