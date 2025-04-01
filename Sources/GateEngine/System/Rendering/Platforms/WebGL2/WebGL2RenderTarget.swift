/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if HTML5
import DOM
import WebGL1
import WebGL2
import GameMath

final class WebGL2RenderTarget: RenderTargetBackend {
    let context: WebGL2RenderingContext
    let framebuffer: WebGLFramebuffer?

    let colorTexture: WebGL1.WebGLTexture?
    let depthTexture: WebGL1.WebGLTexture?

    var size: Size2

    var clearColor: Color = .clear

    func reshape() {
        if isWindow {
            let element = globalThis.document.getElementById(elementId: "mainCanvas")!
            let canvas = HTMLCanvasElement(from: element)!
            canvas.width = UInt32(self.size.width)
            canvas.height = UInt32(self.size.height)
        } else {
            context.bindTexture(target: GL.TEXTURE_2D, texture: colorTexture)
            context.texImage2D(
                target: GL.TEXTURE_2D,
                level: 0,
                internalformat: GLint(GL.RGBA),
                width: GLsizei(size.width),
                height: GLsizei(size.height),
                border: 0,
                format: GL.RGBA,
                type: GL.UNSIGNED_BYTE,
                pixels: nil
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MIN_FILTER,
                param: GLint(GL.LINEAR)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_WRAP_S,
                param: GLint(GL.CLAMP_TO_EDGE)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_WRAP_T,
                param: GLint(GL.CLAMP_TO_EDGE)
            )
            #if GATEENGINE_DEBUG_RENDERING
            Game.shared.renderer.checkError()
            #endif
            context.bindTexture(target: GL.TEXTURE_2D, texture: depthTexture)
            context.texImage2D(
                target: GL.TEXTURE_2D,
                level: 0,
                internalformat: GLint(GL.DEPTH_COMPONENT24),
                width: GLsizei(size.width),
                height: GLsizei(size.height),
                border: 0,
                format: GL.DEPTH_COMPONENT,
                type: GL.UNSIGNED_INT,
                pixels: nil
            )
            #if GATEENGINE_DEBUG_RENDERING
            Game.shared.renderer.checkError()
            #endif
        }
    }
    let isWindow: Bool
    init(isWindow: Bool) {
        self.isWindow = isWindow

        self.context = WebGL2Renderer.context

        if isWindow {
            let element = globalThis.document.getElementById(elementId: "mainCanvas")!
            let canvas = HTMLCanvasElement(from: element)!
            self.framebuffer = nil
            self.colorTexture = nil
            self.depthTexture = nil
            self.size = Size2(Float(canvas.width), Float(canvas.height))
        } else {
            self.framebuffer = context.createFramebuffer()!
            self.colorTexture = context.createTexture()!
            self.depthTexture = context.createTexture()!
            self.size = Size2(2, 2)

            context.bindTexture(target: GL.TEXTURE_2D, texture: colorTexture)
            context.texImage2D(
                target: GL.TEXTURE_2D,
                level: 0,
                internalformat: GLint(GL.RGBA),
                width: GLsizei(size.width),
                height: GLsizei(size.height),
                border: 0,
                format: GL.RGBA,
                type: GL.UNSIGNED_BYTE,
                pixels: nil
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MIN_FILTER,
                param: GLint(GL.LINEAR)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MAG_FILTER,
                param: GLint(GL.NEAREST)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_WRAP_S,
                param: GLint(GL.CLAMP_TO_EDGE)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_WRAP_T,
                param: GLint(GL.CLAMP_TO_EDGE)
            )

            context.bindTexture(target: GL.TEXTURE_2D, texture: depthTexture)
            context.texImage2D(
                target: GL.TEXTURE_2D,
                level: 0,
                internalformat: GLint(GL.DEPTH_COMPONENT24),
                width: GLsizei(size.width),
                height: GLsizei(size.height),
                border: 0,
                format: GL.DEPTH_COMPONENT,
                type: GL.UNSIGNED_INT,
                pixels: nil
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MIN_FILTER,
                param: GLint(GL.LINEAR)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MAG_FILTER,
                param: GLint(GL.NEAREST)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_WRAP_S,
                param: GLint(GL.CLAMP_TO_EDGE)
            )
            context.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_WRAP_T,
                param: GLint(GL.CLAMP_TO_EDGE)
            )

            context.bindFramebuffer(target: GL.FRAMEBUFFER, framebuffer: framebuffer!)
            context.framebufferTexture2D(
                target: GL.FRAMEBUFFER,
                attachment: GL.COLOR_ATTACHMENT0,
                textarget: GL.TEXTURE_2D,
                texture: colorTexture,
                level: 0
            )
            context.framebufferTexture2D(
                target: GL.FRAMEBUFFER,
                attachment: GL.DEPTH_ATTACHMENT,
                textarget: GL.TEXTURE_2D,
                texture: depthTexture,
                level: 0
            )

            #if GATEENGINE_DEBUG_RENDERING
            Game.shared.renderer.checkError()
            #endif
        }
    }

    deinit {
        if let framebuffer {
            WebGL2Renderer.context.deleteFramebuffer(framebuffer: framebuffer)
        }
        if let colorTexture {
            WebGL2Renderer.context.deleteTexture(texture: colorTexture)
        }
        if let depthTexture {
            WebGL2Renderer.context.deleteTexture(texture: depthTexture)
        }
    }
}

extension WebGL2RenderTarget {
    func willBeginFrame(_ frame: UInt) {
        context.bindFramebuffer(target: GL.FRAMEBUFFER, framebuffer: framebuffer)
        context.clearColor(
            red: clearColor.red,
            green: clearColor.green,
            blue: clearColor.blue,
            alpha: clearColor.alpha
        )
        context.clear(mask: GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)
        context.enable(cap: GL.BLEND)
        context.blendFunc(sfactor: GL.SRC_ALPHA, dfactor: GL.ONE_MINUS_SRC_ALPHA)
    }

    func didEndFrame(_ frame: UInt) {
        if isWindow {
            context.flush()
        }
    }

    func willBeginContent(matrices: Matrices?, viewport: Rect?, scissorRect: Rect?) {
        context.bindFramebuffer(target: GL.FRAMEBUFFER, framebuffer: framebuffer)
        
        if let viewport {
            context.viewport(
                x: GLint(viewport.x), 
                y: GLint(viewport.y), 
                width: GLsizei(viewport.width), 
                height: GLsizei(viewport.height)
            )
        }else{
            context.viewport(x: 0, y: 0, width: GLsizei(size.width), height: GLsizei(size.height))
        }
        
        if let scissorRect {
            context.scissor(
                x: GLint(scissorRect.x), 
                y: GLint(scissorRect.y), 
                width: GLsizei(scissorRect.width), 
                height: GLsizei(scissorRect.height)
            )
        }else{
            context.viewport(x: 0, y: 0, width: GLsizei(size.width), height: GLsizei(size.height))
        }
    }
    func didEndContent() {
        context.flush()
    }
}

#endif
