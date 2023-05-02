/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum ValueRepresentation {
    case operation
    
    case vertexInPosition(_ index: UInt8)
    case vertexInTexCoord0(_ index: UInt8)
    case vertexInTexCoord1(_ index: UInt8)
    case vertexInNormal(_ index: UInt8)
    case vertexInTangent(_ index: UInt8)
    case vertexInColor(_ index: UInt8)
    
    case vertexOutPosition
    case vertexOutPointSize
    case vertexOut(_ name: String)
    case vertexInstanceID
    
    case fragmentIn(_ name: String)
    case fragmentOutColor
    case fragmentInstanceID
    
    case uniformModelMatrix
    case uniformViewMatrix
    case uniformProjectionMatrix
    case uniformCustom(_ index: UInt8, type: CustomUniformValueType)
    
    case channelScale(_ index: UInt8)
    case channelOffset(_ index: UInt8)
    case channelColor(_ index: UInt8)
    case channelAttachment(_ index: UInt8)

    case scalarBool(_ bool: Bool)
    case scalarInt(_ int: Int)
    case scalarFloat(_ float: Float)
    
    case vec2
    case vec2X(_ vector: Vec2)
    case vec2Y(_ vector: Vec2)
    
    case vec3
    case vec3X(_ vector: Vec3)
    case vec3Y(_ vector: Vec3)
    case vec3Z(_ vector: Vec3)
    
    case vec4
    case vec4X(_ vector: Vec4)
    case vec4Y(_ vector: Vec4)
    case vec4Z(_ vector: Vec4)
    case vec4W(_ vector: Vec4)
    
    case mat4
    
    var valueType: ValueType {
        switch self {
        case .operation:
            return .operation
        case .vertexOutPointSize:
            return .float1
        case .vec2, .vertexInPosition, .vertexOutPosition:
            return .float3
        case .vec3, .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_):
            return .float2
        case .vec4, .vertexInColor(_), .fragmentOutColor:
            return .float4
        case .mat4, .uniformModelMatrix, .uniformViewMatrix, .uniformProjectionMatrix:
            return .float4x4
        case .scalarBool(_):
            return .bool
        case .scalarInt(_):
            return .int
        case .scalarFloat(_):
            return .float1
        case .vec2X(_), .vec2Y(_), .vec3X(_), .vec3Y(_), .vec3Z(_), .vec4X(_), .vec4Y(_), .vec4Z(_), .vec4W(_):
            return .float1
        case .channelAttachment(_):
            return .texture2D
        case .channelScale(_), .channelOffset(_):
            return .float2
        case .channelColor(_):
            return .float4
        case .vertexInstanceID, .fragmentInstanceID:
            return .int
        case let .uniformCustom(_, type: uniformType):
            switch uniformType {
            case .bool:
                return .bool
            case .int:
                return .int
            case .float:
                return .float1
            case .vec2:
                return .float2
            case .vec3:
                return .float3
            case .vec4:
                return .float4
            case .mat3:
                return .float3x3
            case .mat4:
                return .float4x4
            }
        case .vertexOut(_), .fragmentIn(_):
            fatalError()// Can be any value
        }
    }
    
    var isVertexInput: Bool {
        switch self {
        case .vertexInPosition(_), .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .vertexInColor(_):
            return true
        case .vertexOutPosition, .vertexOutPointSize, .vertexOut(_), .vertexInstanceID, .operation, .fragmentIn(_), .fragmentOutColor, .fragmentInstanceID, .uniformModelMatrix,
                .uniformViewMatrix, .uniformProjectionMatrix, .uniformCustom(_,_), .channelScale(_), .channelOffset(_), .channelColor(_), .channelAttachment(_),
                .scalarBool(_), .scalarInt(_), .scalarFloat(_), .vec2, .vec2X(_), .vec2Y(_), .vec3, .vec3X(_), .vec3Y(_), .vec3Z(_), .vec4, .vec4X(_), .vec4Y(_),
                .vec4Z(_), .vec4W(_), .mat4:
            return false
        }
    }
}

public enum ValueType {
    case texture2D
    case operation
    case bool
    case int
    case float1
    case float2
    case float3
    case float4
    case float3x3
    case float4x4
}

public enum CustomUniformValueType {
    case bool
    case int
    case float
    case vec2
    case vec3
    case vec4
    case mat3
    case mat4
}

enum Functions {
    case sampleTexture
}

public protocol ShaderValue: AnyObject, ShaderElement {
    var valueRepresentation: ValueRepresentation {get}
    var valueType: ValueType {get}
    var operation: Operation? {get}
}

public protocol ShaderElement: AnyObject {
//    func branch<T: Value>(_ comparison: Scalar, success: T, failure: T) -> T
    
}
//
//public extension Value {
//    func branch<T: Value>(lhs: Scalar, _ comparison: Operation.Operator.Comparison, rhs: Scalar, success: T, failure: T) -> T {
//        let compare = Scalar(Operation(lhs: lhs, comparison: comparison, rhs: rhs))
//        return T(Operation(compare: compare, success: success, failure: failure))
//    }
//}
