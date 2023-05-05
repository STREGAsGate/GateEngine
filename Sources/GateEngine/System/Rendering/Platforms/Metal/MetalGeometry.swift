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
    let primitive: DrawFlags.Primitive
    let attributes: OrderedSet<GeometryAttribute>
    let buffers: [MTLBuffer]
    let indexCount: Int
    var indexBuffer: MTLBuffer {
        return buffers.last!
    }
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
        
        let sharedBuffers: [MTLBuffer] = [
            device.makeBuffer(bytes: geometry.positions, length: MemoryLayout<Float>.stride * geometry.positions.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.uvSet1, length: MemoryLayout<Float>.stride * geometry.uvSet1.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.uvSet2, length: MemoryLayout<Float>.stride * geometry.uvSet2.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.normals, length: MemoryLayout<Float>.stride * geometry.normals.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.tangents, length: MemoryLayout<Float>.stride * geometry.tangents.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.colors, length: MemoryLayout<Float>.stride * geometry.colors.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.indicies, length: MemoryLayout<UInt16>.stride * geometry.indicies.count, options: .storageModeShared)!
        ]

        self.buffers = [
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.positions.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.uvSet1.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.uvSet2.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.normals.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.tangents.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.colors.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<UInt16>.stride * geometry.indicies.count, options: .storageModePrivate)!
        ]
        self.indexCount = geometry.indicies.count
        
        self.blit(sharedBuffers, buffers)
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
            .init(type: .uInt32, componentLength: 4, shaderAttribute: .jointIndicies),
            .init(type: .float, componentLength: 4, shaderAttribute: .jointWeights),
        ]
        
        let sharedBuffers: [MTLBuffer] = [
            device.makeBuffer(bytes: geometry.positions, length: MemoryLayout<Float>.stride * geometry.positions.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.uvSet1, length: MemoryLayout<Float>.stride * geometry.uvSet1.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.uvSet2, length: MemoryLayout<Float>.stride * geometry.uvSet2.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.normals, length: MemoryLayout<Float>.stride * geometry.normals.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.tangents, length: MemoryLayout<Float>.stride * geometry.tangents.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.colors, length: MemoryLayout<Float>.stride * geometry.colors.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: skin.jointIndicies, length: MemoryLayout<UInt32>.stride * skin.jointIndicies.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: skin.jointWeights, length: MemoryLayout<Float>.stride * skin.jointWeights.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: geometry.indicies, length: MemoryLayout<UInt16>.stride * geometry.indicies.count, options: .storageModeShared)!
        ]
        
        self.buffers = [
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.positions.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.uvSet1.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.uvSet2.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.normals.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.tangents.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * geometry.colors.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<UInt32>.stride * skin.jointIndicies.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * skin.jointWeights.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<UInt16>.stride * geometry.indicies.count, options: .storageModePrivate)!
        ]
        self.indexCount = geometry.indicies.count
        self.blit(sharedBuffers, buffers)
    }
    
    required init(lines: RawLines) {
        self.primitive = .line
        let device = Game.shared.renderer.device
        
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let sharedBuffers: [MTLBuffer] = [
            device.makeBuffer(bytes: lines.positions, length: MemoryLayout<Float>.stride * lines.positions.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: lines.colors, length: MemoryLayout<Float>.stride * lines.colors.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: lines.indicies, length: MemoryLayout<UInt16>.stride * lines.indicies.count, options: .storageModeShared)!
        ]
        
        self.buffers = [
            device.makeBuffer(length: MemoryLayout<Float>.stride * lines.positions.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * lines.colors.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<UInt16>.stride * lines.indicies.count, options: .storageModePrivate)!
        ]
        self.indexCount = lines.indicies.count
        self.blit(sharedBuffers, buffers)
    }
    
    required init(points: RawPoints) {
        self.primitive = .point
        let device = Game.shared.renderer.device
        
        
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        let sharedBuffers: [MTLBuffer] = [
            device.makeBuffer(bytes: points.positions, length: MemoryLayout<Float>.stride * points.positions.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: points.colors, length: MemoryLayout<Float>.stride * points.colors.count, options: .storageModeShared)!,
            device.makeBuffer(bytes: points.indicies, length: MemoryLayout<UInt16>.stride * points.indicies.count, options: .storageModeShared)!
        ]
        
        self.buffers = [
            device.makeBuffer(length: MemoryLayout<Float>.stride * points.positions.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<Float>.stride * points.colors.count, options: .storageModePrivate)!,
            device.makeBuffer(length: MemoryLayout<UInt16>.stride * points.indicies.count, options: .storageModePrivate)!
        ]
        self.indexCount = points.indicies.count
        self.blit(sharedBuffers, buffers)
    }
    
    private func blit(_ source: [MTLBuffer], _ destination: [MTLBuffer]) {
        assert(source.count == destination.count)
        
        let buffer = Game.shared.renderer.commandQueue.makeCommandBuffer()!
        let blit = buffer.makeBlitCommandEncoder()!
        
        for bufferIndex in source.indices {
            blit.copy(from: source[bufferIndex], sourceOffset: 0, to: destination[bufferIndex], destinationOffset: 0, size: source[bufferIndex].length)
        }
        blit.endEncoding()
        buffer.commit()
        buffer.waitUntilCompleted()
    }
}
#endif
