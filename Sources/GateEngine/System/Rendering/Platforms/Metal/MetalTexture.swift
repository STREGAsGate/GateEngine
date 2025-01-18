/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(MetalKit)

import MetalKit
import GameMath

final class MetalTexture: TextureBackend {
    private let renderTarget: MetalRenderTarget?
    private let _mtlTexture: (any MTLTexture)?

    var mtlTexture: any MTLTexture {
        if let _mtlTexture {
            return _mtlTexture
        }
        return renderTarget!.colorTexture!
    }

    var size: Size2 {
        return Size2(Float(mtlTexture.width), Float(mtlTexture.height))
    }

    required init(renderTargetBackend: any RenderTargetBackend) {
        renderTarget = (renderTargetBackend as! MetalRenderTarget)
        _mtlTexture = nil
    }

    required init(data: Data, size: Size2, mipMapping: MipMapping) {
        let device = Game.shared.renderer.device

        let descriptor = MTLTextureDescriptor()
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.width = Int(size.width)
        descriptor.height = Int(size.height)

        switch mipMapping {
        case .none:
            descriptor.mipmapLevelCount = 1
        case let .auto(levels):
            var width = Int(size.width / 2)
            var height = Int(size.width / 2)
            while width > 8 && height > 8 && descriptor.mipmapLevelCount <= levels {
                width /= 2
                height /= 2
                descriptor.mipmapLevelCount += 1
            }
        }

        self.renderTarget = nil
        self._mtlTexture = device.makeTexture(descriptor: descriptor)!

        self.replaceData(with: data, size: size, mipMapping: mipMapping)
    }

    func replaceData(with data: Data, size: Size2, mipMapping: MipMapping) {
        let region = MTLRegionMake2D(0, 0, Int(size.width), Int(size.height))
        data.withUnsafeBytes { (pointer) -> Void in
            mtlTexture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: pointer.baseAddress!,
                bytesPerRow: 4 * Int(size.width)
            )
        }
        
        self.generateMipMaps()
    }
    
    func generateMipMaps() {
        if let mipmapLevelCount = self._mtlTexture?.mipmapLevelCount {
            if mipmapLevelCount > 1 {
                let buffer = Game.shared.renderer.commandQueue.makeCommandBuffer()!
                let blit = buffer.makeBlitCommandEncoder()!
                blit.generateMipmaps(for: mtlTexture)
                blit.endEncoding()
                buffer.commit()
//                buffer.waitUntilCompleted()
            }
        }
    }
}
#endif
