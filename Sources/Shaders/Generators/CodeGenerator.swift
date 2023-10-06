/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public class CodeGenerator {
    var _nextVarIndex: UInt = 1
    var _varNames: [ObjectIdentifier:String] = [:]
    var _declaredValues: Set<ObjectIdentifier> = []
    var indentationLevel: Int = 1
    func indent() -> String {
        return String(repeating: " ", count: indentationLevel * 4)
    }
    final func prepareForReuse() {
        _nextVarIndex = 1
        _varNames.removeAll(keepingCapacity: true)
        _declaredValues.removeAll(keepingCapacity: true)
    }
    
    internal final func validate(vsh: VertexShader, fsh: FragmentShader) throws {
        try checkLinkError(vsh: vsh, fsh: fsh)
    }
    
    private final func checkLinkError(vsh: VertexShader, fsh: FragmentShader) throws {
        let vshKeys: Set<String> = Set(vsh.output._values.keys)
        let fshKeys: Set<String> = Set(fsh.input._values.keys)
        
        for fshKey in fshKeys {
            if vshKeys.contains(fshKey) == false {
                throw ShaderError("Shaders can't be linked becuase the vsh doesn't have \(fshKey) required by fsh.")
            }
        }
    }
    
    final func declareVariableIfNeeded(_ value: some ShaderValue, declarations: inout String) {
        let objectID = value.id
        guard _declaredValues.contains(objectID) == false else {return}
        _declaredValues.insert(objectID)
        
        switch value.valueRepresentation {
        case .operation:
            // TODO: Change swift version to version with the fix once there's a fix
            #if swift(<6.0) && os(WASI) // Workaround for stack overflow on WASI
            let operation = value.operation!
            self.declareVariableIfNeeded(operation.lhs, declarations: &declarations)
            self.declareVariableIfNeeded(operation.rhs, declarations: &declarations)
            switch operation.operator {
            case .add, .subtract, .multiply, .divide, .compare(_), .sampler2D(filter: _), .lerp(factor: factor):
                declarations += "\(indent())\(type(for: value)) \(variable(for: value)) = " + function(for: operation, declarations: &declarations) + ";\n"
            case .branch(comparing: _):
                declarations += function(for: operation, declarations: &declarations) + ";\n"
            }
            #else
            self.declareVariable(value, declarations: &declarations)
            #endif
        case .vec2, .vec3, .vec4, .uvec4, .mat4, .mat4Array:
            self.declareVariable(value, declarations: &declarations)
        case let .vec2Value(vec, index):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            self.declareVariableIfNeeded(index, declarations: &declarations)
        case let .vec3Value(vec, index):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            self.declareVariableIfNeeded(index, declarations: &declarations)
        case let .vec4Value(vec, index):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            self.declareVariableIfNeeded(index, declarations: &declarations)
        case let .uvec4Value(vec, index):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            self.declareVariableIfNeeded(index, declarations: &declarations)
        case let .mat4ArrayValue(array, index):
            self.declareVariableIfNeeded(array, declarations: &declarations)
            self.declareVariableIfNeeded(index, declarations: &declarations)
        #if DEBUG
        case .scalarBool(_), .scalarInt(_), .scalarUInt(_), .scalarFloat(_):
            return
        case .vertexInPosition, .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .vertexInColor(_), .vertexInJointIndices(_), .vertexInJointWeights(_):
            return
        case .vertexOutPosition, .vertexOutPointSize, .vertexOut(_), .vertexInstanceID:
            return
        case .fragmentIn(_), .fragmentOutColor, .fragmentInstanceID:
            return
        case .uniformModelMatrix, .uniformViewMatrix, .uniformProjectionMatrix, .uniformCustom(_, type: _):
            return
        case .channelScale(_), .channelOffset(_), .channelAttachment(_), .channelColor(_):
            return
        case .void:
            return
        #else
        default:
            return
        #endif
        }
    }
    
    func declareFunction(value: some ShaderValue, declarations: inout String) {
        let operation = value.operation!
        switch operation.operator {
        case .lerp(let factor):
            self.declareVariableIfNeeded(factor, declarations: &declarations)
            fallthrough
        case .add, .subtract, .multiply, .divide, .compare(_), .sampler2D(_):
            self.declareVariableIfNeeded(operation.value1, declarations: &declarations)
            self.declareVariableIfNeeded(operation.value2, declarations: &declarations)
            declarations += indent() + "\(type(for: value)) \(variable(for: value)) = " + function(value: value, operation: operation) + ";\n"
        case .branch(let comparing):
            self.declareVariableIfNeeded(comparing, declarations: &declarations)
            declareVariableIfNeeded(operation.value1, declarations: &declarations)
            declareVariableIfNeeded(operation.value2, declarations: &declarations)
            
            declarations += indent() + "\(type(for: value)) \(variable(for: value));\n"
    
            var out = indent() + "if (\(variable(for: comparing))) {\n"
            indentationLevel += 1
            out += indent() + "\(variable(for: value)) = \(variable(for: operation.value1));\n"
            indentationLevel -= 1
            out += indent() + "}else{\n"
            indentationLevel += 1
            out += indent() + "\(variable(for: value)) = \(variable(for: operation.value2));\n"
            indentationLevel -= 1
            out += indent() + "}\n"
            declarations += out
        case .discard(comparing: let comparing):
            self.declareVariableIfNeeded(comparing, declarations: &declarations)
            declareVariableIfNeeded(operation.value1, declarations: &declarations)
            
            declarations += indent() + "\(type(for: value)) \(variable(for: value)) = \(variable(for: operation.value1));\n"
            
            var out = indent() + "if (\(variable(for: comparing))) {\n"
            indentationLevel += 1
            out += indent() + "discard_fragment();\n"
            indentationLevel -= 1
            out += indent() + "}\n"
            declarations += out
        }
    }
    
    private final func declareVariable(_ value: some ShaderValue, declarations: inout String) {
        lazy var out = indent() + "\(type(for: value)) \(variable(for: value)) = "
        switch value.valueType {
        case .operation:
            self.declareFunction(value: value, declarations: &declarations)
            return
        case .bool, .int, .uint, .float:
            switch value.valueRepresentation {
            case let .scalarBool(value):
                out += "\(value)"
            case let .scalarInt(value):
                out += "\(value)"
            case let .scalarUInt(value):
                out += "\(value)"
            case let .scalarFloat(value):
                out += "\(value)"
            default:
                fatalError("\(value.valueRepresentation) not implemented")
            }
        case .float2:
            let vec2 = value as! Vec2
            self.declareVariableIfNeeded(vec2._x!, declarations: &declarations)
            self.declareVariableIfNeeded(vec2._y!, declarations: &declarations)
            out += "\(type(for: .float2))(\(variable(for: vec2._x!)),\(variable(for: vec2._y!)))"
        case .float3:
            let vec3 = value as! Vec3
            self.declareVariableIfNeeded(vec3._x!, declarations: &declarations)
            self.declareVariableIfNeeded(vec3._y!, declarations: &declarations)
            self.declareVariableIfNeeded(vec3._z!, declarations: &declarations)
            out += "\(type(for: .float3))(\(variable(for: vec3._x!)),\(variable(for: vec3._y!)),\(variable(for: vec3._z!)))"
        case .float4:
            let vec4 = value as! Vec4
            self.declareVariableIfNeeded(vec4._x!, declarations: &declarations)
            self.declareVariableIfNeeded(vec4._y!, declarations: &declarations)
            self.declareVariableIfNeeded(vec4._z!, declarations: &declarations)
            self.declareVariableIfNeeded(vec4._w!, declarations: &declarations)
            out += "\(type(for: .float4))(\(variable(for: vec4._x!)),\(variable(for: vec4._y!)),\(variable(for: vec4._z!)),\(variable(for: vec4._w!)))"
        case .uint4:
            let uvec4 = value as! UVec4
            self.declareVariableIfNeeded(uvec4._x!, declarations: &declarations)
            self.declareVariableIfNeeded(uvec4._y!, declarations: &declarations)
            self.declareVariableIfNeeded(uvec4._z!, declarations: &declarations)
            self.declareVariableIfNeeded(uvec4._w!, declarations: &declarations)
            out += "\(type(for: .uint4))(\(variable(for: uvec4._x!)),\(variable(for: uvec4._y!)),\(variable(for: uvec4._z!)),\(variable(for: uvec4._w!)))"
        case .float3x3:
            fatalError("Not implemented")
        case .float4x4:
            let mat4 = value as! Mat4
            let mtx = mat4.valueMatrix4x4!.transposedArray()
            let c0 = "\(type(for: .float4))(\(mtx[00]),\(mtx[01]),\(mtx[02]),\(mtx[03]))"
            let c1 = "\(type(for: .float4))(\(mtx[04]),\(mtx[05]),\(mtx[06]),\(mtx[07]))"
            let c2 = "\(type(for: .float4))(\(mtx[08]),\(mtx[09]),\(mtx[10]),\(mtx[11]))"
            let c3 = "\(type(for: .float4))(\(mtx[12]),\(mtx[13]),\(mtx[14]),\(mtx[15]))"
            out += "\(type(for: .float4x4))(\(c0),\(c1),\(c2),\(c3))"
        case .float4x4Array:
            fatalError("Not implemented")
        case .void, .texture2D:
            fatalError()
        }
        declarations += out + ";\n"
    }
    
    final func variable(for value: some ShaderValue) -> String {
        switch value.valueRepresentation {
        case let .scalarBool(bool):
            return "\(bool)"
        case let .scalarInt(int):
            return "\(int)"
        case let.scalarUInt(uint):
            return "\(uint)"
        case let .scalarFloat(float):
            return "\(float)"
        case .vec2, .vec3, .vec4, .mat4, .operation:
            let objectID = value.id
            if let existing = _varNames[objectID] {
                return existing
            }
            let name = "v\(_nextVarIndex)"
            _nextVarIndex += 1
            _varNames[objectID] = name
            return name
        default:
            return variable(for: value.valueRepresentation)
        }
    }
    
    func function(value: some ShaderValue, operation: Operation) -> String {
        preconditionFailure("Must override")
    }
    
    final func symbol(for `operator`: Operation.Operator) -> String {
        switch `operator` {
        case .add:
            return "+"
        case .subtract:
            return "-"
        case .multiply:
            return "*"
        case .divide:
            return "/"
        case let .compare(comparison):
            switch comparison {
            case .equal:
                return "=="
            case .notEqual:
                return "!="
            case .greater:
                return ">"
            case .greaterEqual:
                return ">="
            case .less:
                return "<"
            case .lessEqual:
                return "<="
            case .and:
                return "&&"
            case .or:
                return "||"
            }
        #if DEBUG
        case .branch(comparing: _):
            fatalError()
        case .sampler2D(filter: _):
            fatalError()
        case .lerp(factor: _):
            fatalError()
        case .discard(comparing: _):
            fatalError()
        #else
        default:
            fatalError()
        #endif
        }
    }
    
    func type(for valueType: ValueType) -> String {
        preconditionFailure("Must override")
    }
    
    final func type(for value: some ShaderValue) -> String {
        return type(for: valueType(for: value))
    }
    
    final func valueType(for value: some ShaderValue) -> ValueType {
        switch value.self {
        case is Scalar:
            switch value.valueRepresentation {
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
            case .mat4ArrayValue(_, _):
                return .float4x4
            case let .uniformCustom(_, type: valueType):
                switch valueType {
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
            case .operation:
                return valueType(for: value.operation!.value1)
            default:
                fatalError("Unhandled valueType \(value.valueRepresentation)")
            }
        case is Vec2:
            return .float2
        case is Vec3:
            return .float3
        case is Vec4:
            return .float4
        case is Mat4:
            return .float4x4
        case is Mat4Array:
            if case let .uniformCustom(_, type: type) = value.valueRepresentation {
                if case let .mat4Array(capacity) = type {
                    return .float4x4Array(capacity)
                }
            }
            fatalError()
        default:
            fatalError("Unhandled value \(Swift.type(of: value))")
        }
    }
    
    func variable(for representation: ValueRepresentation) -> String {
        preconditionFailure("Must override")
    }
    
    final func generateMain(from vertexShader: VertexShader) -> String {
        var declarations = ""
        var operations = ""
        if let position = vertexShader.output.position {
            declareVariableIfNeeded(position, declarations: &declarations)
            operations += "\(indent())\(variable(for: .vertexOutPosition)) = \(variable(for:position));\n"
        }else{
            declareVariable(vertexShader.modelViewProjectionMatrix, declarations: &declarations)
            operations += "\(indent())\(variable(for: .vertexOutPosition)) = \(variable(for: vertexShader.modelViewProjectionMatrix)) * \(type(for: .float4))(\(variable(for: vertexShader.input.geometry(0).position)),1.0);\n"
        }
        if let pointSize = vertexShader.output.pointSize {
            declareVariableIfNeeded(pointSize, declarations: &declarations)
            operations += "\(indent())\(variable(for: .vertexOutPointSize)) = \(variable(for:pointSize));\n"
        }
        for pair in vertexShader.output._values {
            let value = pair.value
            declareVariableIfNeeded(value, declarations: &declarations)
            operations += "\(indent())\(variable(for: .vertexOut(pair.key))) = \(variable(for: value));\n"
        }
//        if let texCoord = vertexShader.output.textureCoordinate {
//            declareVariableIfNeeded(texCoord, declarations: &declarations)
//            operations += "\(indent())\(variable(for: .vertexOutTexCoord)) = \(variable(for:texCoord));\n"
//        }else{
//            operations += "\(indent())\(variable(for: .vertexOutTexCoord)) = \(variable(for: .vertexInTexCoord0(0)));\n"
//        }
        return declarations + "\n" + operations
    }
    
    final func generateMain(from fragmentShader: FragmentShader) -> String {
        var declarations = ""
        var operations = ""
        if let color = fragmentShader.output.color {
            declareVariableIfNeeded(color, declarations: &declarations)
            operations += indent() + "\(variable(for: .fragmentOutColor)) = \(variable(for:color));\n"
        }else{
            operations += indent() + "\(variable(for: .fragmentOutColor)) = \(type(for: .float4))(0.5,0.5,0.5,1.0);\n"
        }
        return declarations + "\n" + operations
    }
    
    public enum InputAttribute: Hashable {
        case vertexInPosition(geometryIndex: UInt8)
        case vertexInTexCoord0(geometryIndex: UInt8)
        case vertexInTexCoord1(geometryIndex: UInt8)
        case vertexInNormal(geometryIndex: UInt8)
        case vertexInTangent(geometryIndex: UInt8)
        case vertexInColor(geometryIndex: UInt8)
        case vertexInJointIndices(geometryIndex: UInt8)
        case vertexInJointWeights(geometryIndex: UInt8)
    }
}


public extension CodeGenerator {
    static func addingLineNumbers(_ string: String) -> String {
        var string = string
        var count = 0
        for index in string.indices {
            if string[index] == "\n" {
                count += 1
            }
        }
        for index in string.indices.reversed() {
            if string[index] == "\n" || index == string.startIndex {
                var countS = "\(count) "
                while countS.count < 4 {
                    countS = " " + countS
                }
                string.insert(contentsOf: countS, at: index == string.startIndex ? index : string.index(after: index))
                count -= 1
            }
        }
        return string
    }
}
