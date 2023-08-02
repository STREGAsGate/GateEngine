/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import JavaScriptKit
import WebAPIBase
import DOM
import WebGL1
import WebGL2

class WebGL2Texture: TextureBackend {
    let renderTarget: WebGL2RenderTarget?
    let _textureId: WebGL1.WebGLTexture?
    var _size: Size2?
    let managed: Bool

    var textureId: WebGL1.WebGLTexture {
        if let renderTarget {
            return renderTarget.colorTexture!
        }
        return _textureId!
    }

    var size: Size2 {
        if let renderTarget {
            return renderTarget.size
        }
        return _size!
    }

    required init(renderTargetBackend: any RenderTargetBackend) {
        self.renderTarget = (renderTargetBackend as! WebGL2RenderTarget)
        self._size = nil
        self._textureId = nil
        self.managed = false
    }

    required init(data: Data, size: Size2, mipMapping: MipMapping) {
        self.renderTarget = nil
        self.managed = true
        self._size = size
        let gl = WebGL2Renderer.context
        // Generate and bind texture.
        self._textureId = gl.createTexture()!
        self.replaceData(with: data, size: size, mipMapping: mipMapping)
    }

    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping) {
        self._size = size
        let gl = WebGL2Renderer.context

        gl.bindTexture(target: GL.TEXTURE_2D, texture: textureId)

        // Set parameters.
        gl.texParameteri(target: GL.TEXTURE_2D, pname: GL.TEXTURE_WRAP_S, param: GLint(GL.REPEAT))
        gl.texParameteri(target: GL.TEXTURE_2D, pname: GL.TEXTURE_WRAP_T, param: GLint(GL.REPEAT))

        gl.texParameteri(
            target: GL.TEXTURE_2D,
            pname: GL.TEXTURE_MIN_FILTER,
            param: GLint(GL.NEAREST)
        )
        gl.texParameteri(
            target: GL.TEXTURE_2D,
            pname: GL.TEXTURE_MAG_FILTER,
            param: GLint(GL.NEAREST)
        )

        // Set the texture data.
        gl.pixelStorei(pname: GL.UNPACK_ALIGNMENT, param: 1)

        gl.bindTexture(target: GL.TEXTURE_2D, texture: self.textureId)

        let document: Document = globalThis.document
        if data.count == 36, let tagID = String(data: data, encoding: .utf8),
            let ele = document.getElementById(elementId: tagID),
            let image = HTMLImageElement(from: ele)
        {
            _ = document.body?.removeChild(child: image)
            let imageSource = TexImageSource.htmlImageElement(image)
            gl.texImage2D(
                target: GL.TEXTURE_2D,
                level: 0,
                internalformat: GLint(GL.RGBA),
                format: GL.RGBA,
                type: GL.UNSIGNED_BYTE,
                source: imageSource
            )
        } else {
            let data = JSTypedArray<UInt8>(data)
            gl.texImage2D(
                target: GL.TEXTURE_2D,
                level: 0,
                internalformat: GLint(GL.RGBA),
                width: GLsizei(size.width),
                height: GLsizei(size.height),
                border: 0,
                format: GL.RGBA,
                type: GL.UNSIGNED_BYTE,
                pixels: .uint8Array(data)
            )
        }
        if case let .auto(levels) = mipMapping, levels > 1 {
            gl.texParameteri(
                target: GL.TEXTURE_2D,
                pname: GL.TEXTURE_MAX_LEVEL,
                param: GLint(levels)
            )
            gl.generateMipmap(target: GL.TEXTURE_2D)
        }
    }

    deinit {
        if managed, let _textureId {
            WebGL2Renderer.context.deleteTexture(texture: _textureId)
        }
    }
}

#endif
