/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Collections
import Shaders

@MainActor internal protocol GeometryBackend: AnyObject {
    nonisolated var primitive: DrawFlags.Primitive {get}
    nonisolated var attributes: OrderedSet<GeometryAttribute> {get}
    init(geometry: RawGeometry)
    init(geometry: RawGeometry, skin: Skin)
    init(lines: RawLines)
    init(points: RawPoints)
}

internal struct GeometryAttribute: Hashable {
    let type: AttributeType
    let componentLength: Int
    let shaderAttribute: InputAttribute
    enum AttributeType {
        case float
        case uInt16
        case uInt32
    }
    enum InputAttribute: Hashable {
        case position
        case texCoord0
        case texCoord1
        case normal
        case tangent
        case color
        case jointIndicies
        case jointWeights
    }
}

extension Array where Element == GeometryBackend {
    @_transparent
    var shaderAttributes: [Shaders.CodeGenerator.InputAttribute] {
        var attributes: [Shaders.CodeGenerator.InputAttribute] = []
        for geometryIndex in self.indices {
            let geometry = self[geometryIndex]
            let geometryIndex = UInt8(geometryIndex)
            for attributeIndex in geometry.attributes.indices {
                let attribute = geometry.attributes[attributeIndex]
                switch attribute.shaderAttribute {
                case .position:
                    attributes.append(.vertexInPosition(geoemtryIndex: geometryIndex))
                case .texCoord0:
                    attributes.append(.vertexInTexCoord0(geoemtryIndex: geometryIndex))
                case .texCoord1:
                    attributes.append(.vertexInTexCoord1(geoemtryIndex: geometryIndex))
                case .normal:
                    attributes.append(.vertexInNormal(geoemtryIndex: geometryIndex))
                case .tangent:
                    attributes.append(.vertexInTangent(geoemtryIndex: geometryIndex))
                case .color:
                    attributes.append(.vertexInColor(geoemtryIndex: geometryIndex))
                case .jointIndicies:
                    fatalError()
                case .jointWeights:
                    fatalError()
                }
            }
        }
        return attributes
    }
}
