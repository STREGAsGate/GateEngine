/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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
    var _size: Size2?
    let managed: Bool
    
    var textureId: GLuint {
        if let renderTarget {
            return renderTarget.colorTexture
        }
        return _textureId!
    }

    var size: Size2 {
        if let renderTarget {
            return renderTarget.size
        }
        return _size!
    }
    
    required init(renderTargetBackend: RenderTargetBackend) {
        self.renderTarget = (renderTargetBackend as! OpenGLRenderTarget)
        self._textureId = nil
        self._size = nil
        self.managed = false
    }
    
    required init(data: Data, size: Size2, mipMapping: MipMapping) {
        self.renderTarget = nil
        self.managed = true
        self._size = size
        self._textureId = glGenTextures(count: 1)[0]
        self.replaceData(with: data, size: size, mipMapping: mipMapping)
    }
    
    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping) {
        glBindTexture(textureId)
        
        // Set parameters.
        glTexParameter(wrapping: .horizontal, by: .repeat)
        glTexParameter(wrapping: .vertical, by: .repeat)
        
        glTexParameter(filtering: .minimize, by: .nearest)
        glTexParameter(filtering: .magnify, by: .nearest)
        
        // Set the texture data.
        glPixelStorei(parameter: .unpack, value: 1)
        
        let width = Int(size.width)
        let height = Int(size.height)
        glTexImage2D(internalFormat: .rgba, width: width, height: height, format: .rgba, type: .uint8, pixels: data)
        if case let .auto(levels) = mipMapping, levels > 1  {
            data.withUnsafeBytes { (pointer) -> Void in
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
