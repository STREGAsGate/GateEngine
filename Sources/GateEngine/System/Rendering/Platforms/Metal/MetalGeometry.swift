/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(MetalKit)

import MetalKit
import Collections

class MetalGeometry: GeometryBackend, SkinnedGeometryBackend {
    let primitive: DrawCommand.Flags.Primitive
    let attributes: ContiguousArray<GeometryAttribute>
    let buffer: any MTLBuffer
    let bufferOffsets: [Int]
    let indicesCount: Int

    required init(geometry: RawGeometry) {
        self.primitive = .triangle
        let device = Game.shared.renderer.device

        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord0),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord1),
            .init(type: .float, componentLength: 3, shaderAttribute: .tangent),
            .init(type: .float, componentLength: 3, shaderAttribute: .normal),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
                
        let posOffset = 0
        let posSize = geometry.positions.count * MemoryLayout<Float>.size
        let uv1Offset = posOffset + posSize + (posSize % 16)
        let uv1Size = geometry.uvSet1.count * MemoryLayout<Float>.size
        let uv2Offset = uv1Offset + uv1Size + (uv1Size % 16)
        let uv2Size = geometry.uvSet2.count * MemoryLayout<Float>.size
        let tanOffset = uv2Offset + uv2Size + (uv2Size % 16)
        let tanSize = geometry.tangents.count * MemoryLayout<Float>.size
        let nmlOffset = tanOffset + tanSize + (tanSize % 16)
        let nmlSize = geometry.normals.count * MemoryLayout<Float>.size
        let clrOffset = nmlOffset + nmlSize + (nmlSize % 16)
        let clrSize = geometry.colors.count * MemoryLayout<Float>.size
        let indOffset = clrOffset + clrSize + (clrSize % 16)
        let indSize = geometry.indices.count * MemoryLayout<UInt16>.size
        let totalBytes: Int = indOffset + indSize + (indSize % 16)
        
        self.bufferOffsets = [posOffset, uv1Offset, uv2Offset, tanOffset, nmlOffset, clrOffset, indOffset]
        
        let sharedBuffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModeShared
        )!
        
        let bytes = sharedBuffer.contents()
        geometry.positions.withUnsafeBytes { pointer in
            bytes.advanced(by: posOffset).copyMemory(from: pointer.baseAddress!, byteCount: posSize)
        }
        geometry.uvSet1.withUnsafeBytes { pointer in
            bytes.advanced(by: uv1Offset).copyMemory(from: pointer.baseAddress!, byteCount: uv1Size)
        }
        geometry.uvSet2.withUnsafeBytes { pointer in
            bytes.advanced(by: uv2Offset).copyMemory(from: pointer.baseAddress!, byteCount: uv2Size)
        }
        geometry.tangents.withUnsafeBytes { pointer in
            bytes.advanced(by: tanOffset).copyMemory(from: pointer.baseAddress!, byteCount: tanSize)
        }
        geometry.normals.withUnsafeBytes { pointer in
            bytes.advanced(by: nmlOffset).copyMemory(from: pointer.baseAddress!, byteCount: nmlSize)
        }
        geometry.colors.withUnsafeBytes { pointer in
            bytes.advanced(by: clrOffset).copyMemory(from: pointer.baseAddress!, byteCount: clrSize)
        }
        geometry.indices.withUnsafeBytes { pointer in
            bytes.advanced(by: indOffset).copyMemory(from: pointer.baseAddress!, byteCount: indSize)
        }
        
        self.buffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModePrivate
        )!
        
        self.indicesCount = geometry.indices.count

        self.blit(sharedBuffer, self.buffer)
    }

    required init(geometry: RawGeometry, skin: Skin) {
        self.primitive = .triangle
        let device = Game.shared.renderer.device

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
        
        let posOffset = 0
        let posSize = geometry.positions.count * MemoryLayout<Float>.size
        let uv1Offset = posOffset + posSize + (posSize % 16)
        let uv1Size = geometry.uvSet1.count * MemoryLayout<Float>.size
        let uv2Offset = uv1Offset + uv1Size + (uv1Size % 16)
        let uv2Size = geometry.uvSet2.count * MemoryLayout<Float>.size
        let tanOffset = uv2Offset + uv2Size + (uv2Size % 16)
        let tanSize = geometry.tangents.count * MemoryLayout<Float>.size
        let nmlOffset = tanOffset + tanSize + (tanSize % 16)
        let nmlSize = geometry.normals.count * MemoryLayout<Float>.size
        let clrOffset = nmlOffset + nmlSize + (nmlSize % 16)
        let clrSize = geometry.colors.count * MemoryLayout<Float>.size
        let sinOffset = clrOffset + clrSize + (clrSize % 16)
        let sinSize = skin.jointIndices.count * MemoryLayout<UInt32>.size
        let swtOffset = sinOffset + sinSize + (sinSize % 16)
        let swtSize = skin.jointWeights.count * MemoryLayout<Float>.size
        let indOffset = swtOffset + swtSize + (swtSize % 16)
        let indSize = geometry.indices.count * MemoryLayout<UInt16>.size
        let totalBytes: Int = indOffset + indSize + (indSize % 16)
        
        self.bufferOffsets = [posOffset, uv1Offset, uv2Offset, tanOffset, nmlOffset, clrOffset, sinOffset, swtOffset, indOffset]
        
        let sharedBuffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModeShared
        )!
        
        let bytes = sharedBuffer.contents()
        geometry.positions.withUnsafeBytes { pointer in
            bytes.advanced(by: posOffset).copyMemory(from: pointer.baseAddress!, byteCount: posSize)
        }
        geometry.uvSet1.withUnsafeBytes { pointer in
            bytes.advanced(by: uv1Offset).copyMemory(from: pointer.baseAddress!, byteCount: uv1Size)
        }
        geometry.uvSet2.withUnsafeBytes { pointer in
            bytes.advanced(by: uv2Offset).copyMemory(from: pointer.baseAddress!, byteCount: uv2Size)
        }
        geometry.tangents.withUnsafeBytes { pointer in
            bytes.advanced(by: tanOffset).copyMemory(from: pointer.baseAddress!, byteCount: tanSize)
        }
        geometry.normals.withUnsafeBytes { pointer in
            bytes.advanced(by: nmlOffset).copyMemory(from: pointer.baseAddress!, byteCount: nmlSize)
        }
        geometry.colors.withUnsafeBytes { pointer in
            bytes.advanced(by: clrOffset).copyMemory(from: pointer.baseAddress!, byteCount: clrSize)
        }
        skin.jointIndices.withUnsafeBytes { pointer in
            bytes.advanced(by: sinOffset).copyMemory(from: pointer.baseAddress!, byteCount: sinSize)
        }
        skin.jointWeights.withUnsafeBytes { pointer in
            bytes.advanced(by: swtOffset).copyMemory(from: pointer.baseAddress!, byteCount: swtSize)
        }
        geometry.indices.withUnsafeBytes { pointer in
            bytes.advanced(by: indOffset).copyMemory(from: pointer.baseAddress!, byteCount: indSize)
        }

        self.buffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModePrivate
        )!
        
        self.indicesCount = geometry.indices.count

        self.blit(sharedBuffer, self.buffer)
    }

    required init(lines: RawLines) {
        self.primitive = .line
        let device = Game.shared.renderer.device

        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let posOffset = 0
        let posSize = lines.positions.count * MemoryLayout<Float>.size
        let clrOffset = posOffset + posSize + (posSize % 16)
        let clrSize = lines.colors.count * MemoryLayout<Float>.size
        let indOffset = clrOffset + clrSize + (clrSize % 16)
        let indSize = lines.indices.count * MemoryLayout<UInt16>.size
        let totalBytes: Int = indOffset + indSize + (indSize % 16)
        
        self.bufferOffsets = [posOffset, clrOffset, indOffset]
        
        let sharedBuffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModeShared
        )!
        
        let bytes = sharedBuffer.contents()
        lines.positions.withUnsafeBytes { pointer in
            bytes.advanced(by: posOffset).copyMemory(from: pointer.baseAddress!, byteCount: posSize)
        }
        lines.colors.withUnsafeBytes { pointer in
            bytes.advanced(by: clrOffset).copyMemory(from: pointer.baseAddress!, byteCount: clrSize)
        }
        lines.indices.withUnsafeBytes { pointer in
            bytes.advanced(by: indOffset).copyMemory(from: pointer.baseAddress!, byteCount: indSize)
        }
        
        self.buffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModePrivate
        )!
        
        self.indicesCount = lines.indices.count

        self.blit(sharedBuffer, self.buffer)
    }

    required init(points: RawPoints) {
        self.primitive = .point
        let device = Game.shared.renderer.device

        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let posOffset = 0
        let posSize = points.positions.count * MemoryLayout<Float>.size
        let clrOffset = posOffset + posSize + (posSize % 16)
        let clrSize = points.colors.count * MemoryLayout<Float>.size
        let indOffset = clrOffset + clrSize + (clrSize % 16)
        let indSize = points.indices.count * MemoryLayout<UInt16>.size
        let totalBytes: Int = indOffset + indSize + (indSize % 16)
        
        self.bufferOffsets = [posOffset, clrOffset, indOffset]
        
        let sharedBuffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModeShared
        )!
        
        let bytes = sharedBuffer.contents()
        points.positions.withUnsafeBytes { pointer in
            bytes.advanced(by: posOffset).copyMemory(from: pointer.baseAddress!, byteCount: posSize)
        }
        points.colors.withUnsafeBytes { pointer in
            bytes.advanced(by: clrOffset).copyMemory(from: pointer.baseAddress!, byteCount: clrSize)
        }
        points.indices.withUnsafeBytes { pointer in
            bytes.advanced(by: indOffset).copyMemory(from: pointer.baseAddress!, byteCount: indSize)
        }

        self.buffer = device.makeBuffer(
            length: totalBytes,
            options: .storageModePrivate
        )!
        
        self.indicesCount = points.indices.count

        self.blit(sharedBuffer, self.buffer)
    }

    private func blit(
        _ source: any MTLBuffer,
        _ destination: any MTLBuffer
    ) {
        let buffer = Game.shared.renderer.commandQueue.makeCommandBuffer()!
        let blit = buffer.makeBlitCommandEncoder()!

        blit.copy(
            from: source,
            sourceOffset: 0,
            to: destination,
            destinationOffset: 0,
            size: source.length
        )
        
        blit.endEncoding()
        buffer.commit()
        buffer.waitUntilCompleted()
    }

    #if GATEENGINE_DEBUG_RENDERING || DEBUG
    func isDrawCommandValid(sharedWith backend: any GeometryBackend) -> Bool {
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
}
#endif
