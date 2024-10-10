/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor
public enum ValueRepresentation: Sendable {
    case void
    case operation
    
    case vertexInPosition(_ index: UInt8)
    case vertexInTexCoord0(_ index: UInt8)
    case vertexInTexCoord1(_ index: UInt8)
    case vertexInNormal(_ index: UInt8)
    case vertexInTangent(_ index: UInt8)
    case vertexInColor(_ index: UInt8)
    case vertexInJointWeights(_ index: UInt8)
    case vertexInJointIndices(_ index: UInt8)
    
    case vertexOutPosition
    case vertexOutPointSize
    case vertexOut(_ name: String)
    case vertexInstanceID
    
    case fragmentIn(_ name: String)
    case fragmentOutColor
    case fragmentInstanceID
    case fragmentPosition
    
    case uniformModelMatrix
    case uniformViewMatrix
    case uniformProjectionMatrix
    case uniformCustom(_ name: String, type: CustomUniformValueType)
    
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
        case .void:
            return .void
        case .operation:
            return .operation
        case .vertexOutPointSize:
            return .float
        case .vec2, .vertexInPosition, .vertexOutPosition:
            return .float3
        case .vec3, .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .fragmentPosition:
            return .float2
        case .vec4, .vertexInColor(_), .vertexInJointWeights(_), .fragmentOutColor:
            return .float4
        case .uvec4, .vertexInJointIndices(_):
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
}

public enum ValueType: Equatable, Sendable {
    case void
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

public enum CustomUniformValueType: Sendable {
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

public protocol ShaderValue: AnyObject, CustomStringConvertible, ShaderElement {
    var valueRepresentation: ValueRepresentation {get}
    var valueType: ValueType {get}
    var operation: Operation? {get}
    
    init(_ operation: Operation)
}

public protocol ShaderElement: AnyObject {
//    func branch<T: Value>(_ comparison: Scalar, success: T, failure: T) -> T
    
}

extension ShaderValue {
    public nonisolated var description: String {
        return "\(type(of: self))(t: \(self.valueType), r: \(self.valueRepresentation))"
    }
}

public struct SwitchCase<ResultType: ShaderValue> {
    let compare: Scalar
    let result: ResultType
    
    public static func `case`(_ compare: Int, result: ResultType) -> SwitchCase {
        return SwitchCase(compare: Scalar(compare), result: result)
    }
}

public struct _SwitchCase {
    let compare: Scalar
    let result: any ShaderValue
    init<ResultType: ShaderValue>(_ switchCase: SwitchCase<ResultType>) {
        self.compare = switchCase.compare
        self.result = switchCase.result
    }
}
public extension ShaderValue {
    func `switch`<ResultType: ShaderValue>(_ cases: [SwitchCase<ResultType>]) -> ResultType where Self == Scalar {
        var compare = self
        if compare.valueType != .int {
            compare = Scalar(compare, castTo: .int)
        }
        return ResultType(Operation(switch: compare, cases: cases))
    }
}
public extension ShaderValue {
    func branch<T: ShaderValue>(success: T, failure: T) -> T where Self == Scalar {
        var this: Scalar = self
        if this.valueType != .bool {
            this = Scalar(self, castTo: .bool)
        }
        return T(Operation(compare: this, success: success, failure: failure))
    }
    
    /**
     Insert a fragment discard inline.
     - parameter comparing: A value that when true will cause a discard.
     - returns: A variable of the same value as the variable this function was called on.
     - note: Cannot be called from a vertex shader.
     */
    func discard<T: ShaderValue>(if comparing: some Scalar) -> T {
        var comparing: Scalar = comparing
        if comparing.valueType != .bool {
            comparing = Scalar(comparing, castTo: .bool)
        }
        return T(Operation(discardIf: comparing, success: self))
    }
}

internal extension String {
    func documentIdentifierInputData() -> [Int] {
        var values: [Int] = []
        values.reserveCapacity(self.count)
        
        for charaacter in self {
            for scalar in charaacter.unicodeScalars {
                values.append(Int(bitPattern: UInt(scalar.value)))
            }
        }
        return values
    }
}
