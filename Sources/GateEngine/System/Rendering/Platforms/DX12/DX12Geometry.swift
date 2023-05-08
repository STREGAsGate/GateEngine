/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import WinSDK

class DX12Geometry: GeometryBackend, SkinnedGeometryBackend {
    let primitive: DrawFlags.Primitive
    let attributes: ContiguousArray<GeometryAttribute>
    let buffers: ContiguousArray<Any>
    let indiciesCount: Int
    var indexBuffer: Any {
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
        
        self.buffers = []
        self.indiciesCount = 0
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
            .init(type: .uInt32, componentLength: 4, shaderAttribute: .jointIndicies),
            .init(type: .float, componentLength: 4, shaderAttribute: .jointWeights),
        ]
        self.buffers = []
        self.indiciesCount = 0
    }
    
    required init(lines: RawLines) {
        self.primitive = .line
        
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        self.buffers = []
        self.indiciesCount = lines.indicies.count
    }
    
    required init(points: RawPoints) {
        self.primitive = .point
  
        self.attributes = [
            .init(type: .float, componentLength: 3, shaderAttribute: .position),
            .init(type: .float, componentLength: 4, shaderAttribute: .color),
        ]
        
        self.buffers = []
        self.indiciesCount = 0
    }
    
#if GATEENGINE_DEBUG_RENDERING || DEBUG
    func isDrawCommandValid(sharedWith backend: GeometryBackend) -> Bool {
        let backend = backend as! Self
        if indiciesCount != backend.indiciesCount {
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
