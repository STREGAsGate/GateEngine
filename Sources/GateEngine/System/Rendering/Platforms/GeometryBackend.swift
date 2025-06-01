/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Shaders

@usableFromInline
@MainActor internal protocol GeometryBackend: AnyObject {
    nonisolated var primitive: DrawCommand.Flags.Primitive { get }
    nonisolated var attributes: ContiguousArray<GeometryAttribute> { get }
    init(geometry: RawGeometry)
    init(geometry: RawGeometry, skin: Skin)
    init(lines: RawLines)
    init(points: RawPoints)
    #if GATEENGINE_DEBUG_RENDERING || DEBUG
    nonisolated func isDrawCommandValid(sharedWith backend: any GeometryBackend) -> Bool
    #endif
}

@usableFromInline
internal struct GeometryAttribute: Hashable, Sendable {
    let type: AttributeType
    let componentLength: Int
    let shaderAttribute: InputAttribute
    enum AttributeType: Hashable, Sendable {
        case float
        case uInt16
        case uInt32
    }
    enum InputAttribute: Hashable, Sendable {
        case position
        case texCoord0
        case texCoord1
        case normal
        case tangent
        case color
        case jointIndices
        case jointWeights
    }
}

extension GeometryBackend {
    static func shaderAttributes(from geometries: [Self]) -> ContiguousArray<Shaders.CodeGenerator.InputAttribute> {
        var attributes: ContiguousArray<Shaders.CodeGenerator.InputAttribute> = []
        attributes.reserveCapacity(geometries.count * 8)
        for geometryIndex in geometries.indices {
            let geometry = geometries[geometryIndex]
            let geometryIndex = UInt8(geometryIndex)
            for attributeIndex in geometry.attributes.indices {
                let attribute = geometry.attributes[attributeIndex]
                switch attribute.shaderAttribute {
                case .position:
                    attributes.append(.vertexInPosition(geometryIndex: geometryIndex))
                case .texCoord0:
                    attributes.append(.vertexInTexCoord0(geometryIndex: geometryIndex))
                case .texCoord1:
                    attributes.append(.vertexInTexCoord1(geometryIndex: geometryIndex))
                case .normal:
                    attributes.append(.vertexInNormal(geometryIndex: geometryIndex))
                case .tangent:
                    attributes.append(.vertexInTangent(geometryIndex: geometryIndex))
                case .color:
                    attributes.append(.vertexInColor(geometryIndex: geometryIndex))
                case .jointIndices:
                    attributes.append(.vertexInJointIndices(geometryIndex: geometryIndex))
                case .jointWeights:
                    attributes.append(.vertexInJointWeights(geometryIndex: geometryIndex))
                }
            }
        }
        return attributes
    }
}
