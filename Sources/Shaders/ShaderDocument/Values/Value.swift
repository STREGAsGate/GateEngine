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
    case vertexInJointWeights(_ index: UInt8)
    case vertexInJointIndicies(_ index: UInt8)
    
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
    case scalarUInt(_ uint: UInt)
    case scalarFloat(_ float: Float)
    
    case vec2
    case vec2Value(_ vector: Vec2, _ index: Scalar)
    
    case vec3
    case vec3Value(_ vector: Vec3, _ index: Scalar)
    
    case vec4
    case vec4Value(_ vector: Vec4, _ index: Scalar)
    
    case uvec4
    case uvec4Value(_ vector: UVec4, _ index: Scalar)
    
    case mat4
    case mat4Array(_ capacity: Int)
    case mat4ArrayValue(_ array: Mat4Array, _ index: Scalar)
    
    var valueType: ValueType {
        switch self {
        case .operation:
            return .operation
        case .vertexOutPointSize:
            return .float
        case .vec2, .vertexInPosition, .vertexOutPosition:
            return .float3
        case .vec3, .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_):
            return .float2
        case .vec4, .vertexInColor(_), .vertexInJointWeights(_), .fragmentOutColor:
            return .float4
        case .uvec4, .vertexInJointIndicies(_):
            return .uint4
        case .mat4, .mat4ArrayValue(_, _), .uniformModelMatrix, .uniformViewMatrix, .uniformProjectionMatrix:
            return .float4x4
        case let .mat4Array(capacity):
            return .float4x4Array(capacity)
        case .scalarBool(_):
            return .bool
        case .scalarInt(_):
            return .int
        case .scalarUInt(_):
            return .uint
        case .scalarFloat(_):
            return .float
        case .vec2Value(_, _), .vec3Value(_, _), .vec4Value(_, _):
            return .float
        case .uvec4Value(_, _):
            return .uint
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
            case .uint:
                return .uint
            case .float:
                return .float
            case .vec2:
                return .float2
            case .vec3:
                return .float3
            case .vec4:
                return .float4
            case .uvec4:
                return .uint4
            case .mat3:
                return .float3x3
            case .mat4:
                return .float4x4
            case let .mat4Array(capacity):
                return .float4x4Array(capacity)
            }
        case .vertexOut(_), .fragmentIn(_):
            fatalError()// Can be any value
        }
    }
    
    var isVertexInput: Bool {
        #if DEBUG
        switch self {
        case .vertexInPosition(_), .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .vertexInColor(_), .vertexInJointWeights(_), .vertexInJointIndicies(_):
            return true
        case .vertexOutPosition, .vertexOutPointSize, .vertexOut(_), .vertexInstanceID, .operation, .fragmentIn(_), .fragmentOutColor, .fragmentInstanceID, .uniformModelMatrix,
                .uniformViewMatrix, .uniformProjectionMatrix, .uniformCustom(_,_), .channelScale(_), .channelOffset(_), .channelColor(_), .channelAttachment(_),
                .scalarBool(_), .scalarInt(_), .scalarUInt(_), .scalarFloat(_), .vec2, .vec2Value(_, _), .vec3, .vec3Value(_, _), .vec4, .vec4Value(_, _), .uvec4, .uvec4Value(_, _), .mat4, .mat4Array, .mat4ArrayValue(_, _):
            return false
        }
        #else
        switch self {
        case .vertexInPosition(_), .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .vertexInColor(_), .vertexInJointWeights(_), .vertexInJointIndicies(_):
            return true
        default:
            return false
        }
        #endif
    }
}

public enum ValueType {
    case texture2D
    case operation
    case bool
    case int
    case uint
    case float
    case float2
    case float3
    case float4
    case uint4
    case float3x3
    case float4x4
    case float4x4Array(_ capacity: Int)
}

public enum CustomUniformValueType {
    case bool
    case int
    case uint
    case float
    case vec2
    case vec3
    case vec4
    case uvec4
    case mat3
    case mat4
    case mat4Array(_ capacity: Int)
}

enum Functions {
    case sampleTexture
}

public protocol ShaderValue: AnyObject, Identifiable, CustomStringConvertible, ShaderElement where ID == ObjectIdentifier {
    var valueRepresentation: ValueRepresentation {get}
    var valueType: ValueType {get}
    var operation: Operation? {get}
}

public protocol ShaderElement: AnyObject {
//    func branch<T: Value>(_ comparison: Scalar, success: T, failure: T) -> T
    
}

extension ShaderValue {
    public var description: String {
        return "\(type(of: self))(t: \(self.valueType), r: \(self.valueRepresentation))"
    }
}

//
//public extension Value {
//    func branch<T: Value>(lhs: Scalar, _ comparison: Operation.Operator.Comparison, rhs: Scalar, success: T, failure: T) -> T {
//        let compare = Scalar(Operation(lhs: lhs, comparison: comparison, rhs: rhs))
//        return T(Operation(compare: compare, success: success, failure: failure))
//    }
//}
