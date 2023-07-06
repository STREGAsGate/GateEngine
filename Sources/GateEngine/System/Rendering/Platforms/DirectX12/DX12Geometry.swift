/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import WinSDK
import Direct3D12

class DX12Geometry: GeometryBackend, SkinnedGeometryBackend {
    let primitive: DrawFlags.Primitive
    let attributes: ContiguousArray<GeometryAttribute>
    let buffers: ContiguousArray<D3DResource>
    let indicesCount: Int
    @inline(__always)
    var indexBuffer: D3DResource {
        return buffers.last!
    }
    required init(geometry: RawGeometry) {
        self.primitive = .triangle
        
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord0),
            .init(type: .float, componentLength: 2, shaderAttribute: .texCoord1),
            .init(type: .float, componentLength: 3, shaderAttribute: .tangent),
            .init(type: .float, componentLength: 3, shaderAttribute: .normal),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        self.buffers = [
            DX12Renderer.createBuffer(withData: geometry.positions, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.uvSet1, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.uvSet2, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.tangents, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.normals, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.colors, heapProperties: .forBuffer, state: .genericRead),

            DX12Renderer.createBuffer(withData: geometry.indices, heapProperties: .forBuffer, state: .genericRead),
        ]
        self.indicesCount = geometry.indices.count
    }
    
    required init(geometry: RawGeometry, skin: Skin) {
        self.primitive = .triangle
        
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

        self.buffers = [
            DX12Renderer.createBuffer(withData: geometry.positions, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.uvSet1, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.uvSet2, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.tangents, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.normals, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: geometry.colors, heapProperties: .forBuffer, state: .genericRead),

            DX12Renderer.createBuffer(withData: skin.jointIndices, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: skin.jointWeights, heapProperties: .forBuffer, state: .genericRead),

            DX12Renderer.createBuffer(withData: geometry.indices, heapProperties: .forBuffer, state: .genericRead),
        ]
        self.indicesCount = geometry.indices.count
    }
    
    required init(lines: RawLines) {
        self.primitive = .line
        
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        self.buffers = [
            DX12Renderer.createBuffer(withData: lines.positions, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: lines.colors, heapProperties: .forBuffer, state: .genericRead),

            DX12Renderer.createBuffer(withData: lines.indices, heapProperties: .forBuffer, state: .genericRead),
        ]
        self.indicesCount = lines.indices.count
    }
    
    required init(points: RawPoints) {
        self.primitive = .point
  
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        self.buffers = [
            DX12Renderer.createBuffer(withData: points.positions, heapProperties: .forBuffer, state: .genericRead),
            DX12Renderer.createBuffer(withData: points.colors, heapProperties: .forBuffer, state: .genericRead),

            DX12Renderer.createBuffer(withData: points.indices, heapProperties: .forBuffer, state: .genericRead),
        ]
        self.indicesCount = points.indices.count
    }

    
    
#if GATEENGINE_DEBUG_RENDERING || DEBUG
    func isDrawCommandValid(sharedWith backend: GeometryBackend) -> Bool {
        let backend: Self = backend as! Self
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
