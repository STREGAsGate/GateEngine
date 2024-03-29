/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum ValueRepresentation {
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
    
    var identifier: [Int] {
        switch self {
        case .void:
            return [3_100]
        case .operation:
            return [3_101]
            
        case .vertexInPosition(let index):
            return [3_201, Int(index)]
        case .vertexInTexCoord0(let index):
            return [3_202, Int(index)]
        case .vertexInTexCoord1(let index):
            return [3_203, Int(index)]
        case .vertexInNormal(let index):
            return [3_204, Int(index)]
        case .vertexInTangent(let index):
            return [3_205, Int(index)]
        case .vertexInColor(let index):
            return [3_206, Int(index)]
        case .vertexInJointWeights(let index):
            return [3_207, Int(index)]
        case .vertexInJointIndices(let index):
            return [3_208, Int(index)]
            
        case .vertexOutPosition:
            return [3_301]
        case .vertexOutPointSize:
            return [3_302]
        case .vertexOut(let name):
            var values: [Int] = [3_303]
            values.append(contentsOf: name.documentIdentifierInputData())
            return values
        case .vertexInstanceID:
            return [3_304]
            
        case .fragmentIn(let name):
            var values: [Int] = [3_401]
            values.append(contentsOf: name.documentIdentifierInputData())
            return values
        case .fragmentOutColor:
            return [3_402]
        case .fragmentInstanceID:
            return [3_403]
        case .fragmentPosition:
            return [3_404]
            
        case .uniformModelMatrix:
            return [3_501]
        case .uniformViewMatrix:
            return [3_502]
        case .uniformProjectionMatrix:
            return [3_503]
        case .uniformCustom(let name, type: let type):
            var values: [Int] = [3_504]
            values.append(contentsOf: name.documentIdentifierInputData())
            values.append(contentsOf: type.identifier)
            return values
            
        case .channelScale(let index):
            return [3_601, Int(index)]
        case .channelOffset(let index):
            return [3_602, Int(index)]
        case .channelColor(let index):
            return [3_603, Int(index)]
        case .channelAttachment(let index):
            return [3_604, Int(index)]
            
        case .scalarBool(let bool):
            return [3_701, bool ? 1 : 0]
        case .scalarInt(let int):
            return [3_702, int]
        case .scalarUInt(let uInt):
            return [3_703, Int(uInt)]
        case .scalarFloat(let float):
            return [3_704, Int(float)]
        case .vec2:
            return [3_810]
        case .vec2Value(let vector, let index):
            var values: [Int] = [3_811]
            values.append(contentsOf: index.documentIdentifierInputData())
            values.append(contentsOf: vector.documentIdentifierInputData())
            return values
        case .vec3:
            return [3_820]
        case .vec3Value(let vector, let index):
            var values: [Int] = [3_821]
            values.append(contentsOf: index.documentIdentifierInputData())
            values.append(contentsOf: vector.documentIdentifierInputData())
            return values
        case .vec4:
            return [3_830]
        case .vec4Value(let vector, let index):
            var values: [Int] = [3_831]
            values.append(contentsOf: index.documentIdentifierInputData())
            values.append(contentsOf: vector.documentIdentifierInputData())
            return values
        case .uvec4:
            return [3_840]
        case .uvec4Value(let vector, let index):
            var values: [Int] = [3_841]
            values.append(contentsOf: index.documentIdentifierInputData())
            values.append(contentsOf: vector.documentIdentifierInputData())
            return values
        case .mat4:
            return [3_850]
        case .mat4Array(let capacity):
            return [3_851, capacity]
        case .mat4ArrayValue(let mat4Array, let index):
            var values: [Int] = [3_852]
            values.append(contentsOf: index.documentIdentifierInputData())
            values.append(contentsOf: mat4Array.documentIdentifierInputData())
            return values
        }
    }
}

public enum ValueType: Equatable {
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
    
    var identifier: [Int] {
        switch self {
        case .void:
            return [1_000]
        case .texture2D:
            return [1_001]
        case .operation:
            return [1_002]
        case .bool:
            return [1_003]
        case .int:
            return [1_004]
        case .uint:
            return [1_005]
        case .float:
            return [1_006]
        case .float2:
            return [1_007]
        case .float3:
            return [1_008]
        case .float4:
            return [1_009]
        case .uint4:
            return [1_010]
        case .float3x3:
            return [1_011]
        case .float4x4:
            return [1_012]
        case .float4x4Array(let capacity):
            return [1_013, capacity]
        }
    }
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
    
    var identifier: [Int] {
        switch self {
        case .bool:
            return [2_001]
        case .int:
            return [2_002]
        case .uint:
            return [2_003]
        case .float:
            return [2_004]
        case .vec2:
            return [2_005]
        case .vec3:
            return [2_006]
        case .vec4:
            return [2_007]
        case .uvec4:
            return [2_008]
        case .mat3:
            return [2_009]
        case .mat4:
            return [2_010]
        case .mat4Array(let capacity):
            return [2_011, capacity]
        }
    }
}

enum Functions {
    case sampleTexture
}

public protocol ShaderValue: AnyObject, Identifiable, CustomStringConvertible, ShaderElement where ID == UInt64 {
    var valueRepresentation: ValueRepresentation {get}
    var valueType: ValueType {get}
    var operation: Operation? {get}
    
    init(_ operation: Operation)
}

public protocol ShaderElement: AnyObject {
    func documentIdentifierInputData() -> [Int]
//    func branch<T: Value>(_ comparison: Scalar, success: T, failure: T) -> T
    
}

extension ShaderValue {
    public var description: String {
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
public struct _SwitchCase: Equatable {
    let compare: Scalar
    let result: any ShaderValue
    init<ResultType: ShaderValue>(_ switchCase: SwitchCase<ResultType>) {
        self.compare = switchCase.compare
        self.result = switchCase.result
    }
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = []
        values.append(contentsOf: compare.documentIdentifierInputData())
        values.append(contentsOf: result.documentIdentifierInputData())
        return values
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.compare.id == rhs.compare.id
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
