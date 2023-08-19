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
    let attributes: ContiguousArray<GeometryAttribute>
    let buffers: ContiguousArray<any MTLBuffer>
    let indicesCount: Int
    var indexBuffer: any MTLBuffer {
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

        let sharedBuffers: ContiguousArray<any MTLBuffer> = [
            device.makeBuffer(
                bytes: geometry.positions,
                length: MemoryLayout<Float>.stride * geometry.positions.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.uvSet1,
                length: MemoryLayout<Float>.stride * geometry.uvSet1.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.uvSet2,
                length: MemoryLayout<Float>.stride * geometry.uvSet2.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.normals,
                length: MemoryLayout<Float>.stride * geometry.normals.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.tangents,
                length: MemoryLayout<Float>.stride * geometry.tangents.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.colors,
                length: MemoryLayout<Float>.stride * geometry.colors.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.indices,
                length: MemoryLayout<UInt16>.stride * geometry.indices.count,
                options: .storageModeShared
            )!,
        ]

        self.buffers = [
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.positions.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.uvSet1.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.uvSet2.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.normals.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.tangents.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.colors.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<UInt16>.stride * geometry.indices.count,
                options: .storageModePrivate
            )!,
        ]
        self.indicesCount = geometry.indices.count

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
            .init(type: .uInt32, componentLength: 4, shaderAttribute: .jointIndices),
            .init(type: .float, componentLength: 4, shaderAttribute: .jointWeights),
        ]

        let sharedBuffers: ContiguousArray<any MTLBuffer> = [
            device.makeBuffer(
                bytes: geometry.positions,
                length: MemoryLayout<Float>.stride * geometry.positions.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.uvSet1,
                length: MemoryLayout<Float>.stride * geometry.uvSet1.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.uvSet2,
                length: MemoryLayout<Float>.stride * geometry.uvSet2.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.normals,
                length: MemoryLayout<Float>.stride * geometry.normals.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.tangents,
                length: MemoryLayout<Float>.stride * geometry.tangents.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.colors,
                length: MemoryLayout<Float>.stride * geometry.colors.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: skin.jointIndices,
                length: MemoryLayout<UInt32>.stride * skin.jointIndices.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: skin.jointWeights,
                length: MemoryLayout<Float>.stride * skin.jointWeights.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: geometry.indices,
                length: MemoryLayout<UInt16>.stride * geometry.indices.count,
                options: .storageModeShared
            )!,
        ]

        self.buffers = [
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.positions.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.uvSet1.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.uvSet2.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.normals.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.tangents.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * geometry.colors.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<UInt32>.stride * skin.jointIndices.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * skin.jointWeights.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<UInt16>.stride * geometry.indices.count,
                options: .storageModePrivate
            )!,
        ]
        self.indicesCount = geometry.indices.count
        self.blit(sharedBuffers, buffers)
    }

    required init(lines: RawLines) {
        self.primitive = .line
        let device = Game.shared.renderer.device

        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]

        let sharedBuffers: ContiguousArray<any MTLBuffer> = [
            device.makeBuffer(
                bytes: lines.positions,
                length: MemoryLayout<Float>.stride * lines.positions.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: lines.colors,
                length: MemoryLayout<Float>.stride * lines.colors.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: lines.indices,
                length: MemoryLayout<UInt16>.stride * lines.indices.count,
                options: .storageModeShared
            )!,
        ]

        self.buffers = [
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * lines.positions.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * lines.colors.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<UInt16>.stride * lines.indices.count,
                options: .storageModePrivate
            )!,
        ]
        self.indicesCount = lines.indices.count
        self.blit(sharedBuffers, buffers)
    }

    required init(points: RawPoints) {
        self.primitive = .point
        let device = Game.shared.renderer.device

        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]

        let sharedBuffers: ContiguousArray<any MTLBuffer> = [
            device.makeBuffer(
                bytes: points.positions,
                length: MemoryLayout<Float>.stride * points.positions.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: points.colors,
                length: MemoryLayout<Float>.stride * points.colors.count,
                options: .storageModeShared
            )!,
            device.makeBuffer(
                bytes: points.indices,
                length: MemoryLayout<UInt16>.stride * points.indices.count,
                options: .storageModeShared
            )!,
        ]

        self.buffers = [
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * points.positions.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<Float>.stride * points.colors.count,
                options: .storageModePrivate
            )!,
            device.makeBuffer(
                length: MemoryLayout<UInt16>.stride * points.indices.count,
                options: .storageModePrivate
            )!,
        ]
        self.indicesCount = points.indices.count
        self.blit(sharedBuffers, buffers)
    }

    private func blit(
        _ source: ContiguousArray<any MTLBuffer>,
        _ destination: ContiguousArray<any MTLBuffer>
    ) {
        assert(source.count == destination.count)

        let buffer = Game.shared.renderer.commandQueue.makeCommandBuffer()!
        let blit = buffer.makeBlitCommandEncoder()!

        for bufferIndex in source.indices {
            blit.copy(
                from: source[bufferIndex],
                sourceOffset: 0,
                to: destination[bufferIndex],
                destinationOffset: 0,
                size: source[bufferIndex].length
            )
        }
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
