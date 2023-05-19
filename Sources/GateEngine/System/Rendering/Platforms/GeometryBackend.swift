/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Shaders

@usableFromInline
@MainActor internal protocol GeometryBackend: AnyObject {
    nonisolated var primitive: DrawFlags.Primitive {get}
    nonisolated var attributes: ContiguousArray<GeometryAttribute> {get}
    init(geometry: RawGeometry)
    init(geometry: RawGeometry, skin: Skin)
    init(lines: RawLines)
    init(points: RawPoints)
#if GATEENGINE_DEBUG_RENDERING || DEBUG
    nonisolated func isDrawCommandValid(sharedWith backend: GeometryBackend) -> Bool
#endif
}

@usableFromInline
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

extension GeometryBackend {
    @inline(__always)
    static func shaderAttributes(from geometries: ContiguousArray<Self>) -> ContiguousArray<Shaders.CodeGenerator.InputAttribute> {
        var attributes: ContiguousArray<Shaders.CodeGenerator.InputAttribute> = []
        for geometryIndex in geometries.indices {
            let geometry = geometries[geometryIndex]
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
                    attributes.append(.vertexInJointIndices(geoemtryIndex: geometryIndex))
                case .jointWeights:
                    attributes.append(.vertexInJointWeights(geoemtryIndex: geometryIndex))
                }
            }
        }
        return attributes
    }
}
