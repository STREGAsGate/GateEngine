/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(OpenGL_GateEngine)
import struct Foundation.Data
import OpenGL_GateEngine

class OpenGLTexture: TextureBackend {
    let renderTarget: OpenGLRenderTarget?
    let _textureId: GLuint?
    var _size: Size2i?
    let managed: Bool

    var textureId: GLuint {
        if let renderTarget {
            return renderTarget.colorTexture
        }
        return _textureId!
    }

    var size: Size2i {
        if let renderTarget {
            return renderTarget.size
        }
        return _size!
    }

    required init(renderTargetBackend: any RenderTargetBackend) {
        self.renderTarget = (renderTargetBackend as! OpenGLRenderTarget)
        self._textureId = nil
        self._size = nil
        self.managed = false
    }

    required init(rawTexture: RawTexture, mipMapping: MipMapping) {
        self.renderTarget = nil
        self.managed = true
        self._size = rawTexture.imageSize
        self._textureId = glGenTextures(count: 1)[0]
        self.replaceData(with: rawTexture, mipMapping: mipMapping)
    }

    func replaceData(with rawTexture: RawTexture, mipMapping: MipMapping) {
        glBindTexture(textureId)

        // Set parameters.
        glTexParameter(wrapping: .horizontal, by: .repeat)
        glTexParameter(wrapping: .vertical, by: .repeat)

        glTexParameter(filtering: .minimize, by: .nearest)
        glTexParameter(filtering: .magnify, by: .nearest)

        // Set the texture data.
        glPixelStorei(parameter: .unpack, value: 1)

        let width = Int(rawTexture.imageSize.width)
        let height = Int(rawTexture.imageSize.height)
        glTexImage2D(
            internalFormat: .rgba,
            width: width,
            height: height,
            format: .rgba,
            type: .uint8,
            pixels: rawTexture.imageData
        )
        if case let .auto(levels) = mipMapping, levels > 1 {
            rawTexture.imageData.withUnsafeBytes { (pointer) -> Void in
                glGenerateMipmap(target: .texture2D)
            }
        }
    }

    deinit {
        if managed, let textureId = _textureId {
            glDeleteTextures(textureId)
        }
    }
}

#endif
