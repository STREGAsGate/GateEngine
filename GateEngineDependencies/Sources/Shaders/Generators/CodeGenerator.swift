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
                throw ShaderError("[GateEngine] Shaders can't be linked becuase the vsh doesn't have \(fshKey) required by fsh.")
            }
        }
    }
    
    final func declareVariableIfNeeded(_ value: ShaderValue, declarations: inout String) {
        let objectID = ObjectIdentifier(value)
        guard _declaredValues.contains(objectID) == false else {return}
        _declaredValues.insert(objectID)
        
        switch value.valueRepresentation {
        case .operation, .vec2, .vec3, .vec4, .mat4, .scalarBool(_), .scalarInt(_), .scalarFloat(_):
            break
        case .vertexInPosition, .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .vertexInColor(_):
            return
        case .vertexOutPosition, .vertexOutPointSize, .vertexOut(_), .vertexInstanceID:
            return
        case .fragmentIn(_), .fragmentOutColor, .fragmentInstanceID:
            return
        case .uniformModelMatrix, .uniformViewMatrix, .uniformProjectionMatrix, .uniformCustom(_, type: _):
            return
        case .channelScale(_), .channelOffset(_), .channelAttachment(_), .channelColor(_):
            return
        case let .vec2X(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec2Y(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec3X(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec3Y(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec3Z(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec4X(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec4Y(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec4Z(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        case let .vec4W(vec):
            self.declareVariableIfNeeded(vec, declarations: &declarations)
            return
        }
        self.declareVariable(value, declarations: &declarations)
    }
    
    final func declareVariable(_ value: ShaderValue, declarations: inout String) {
        var out = "\t\(type(for: value)) \(variable(for: value)) = "
        switch value.valueType {
        case .operation:
            let operation = value.operation!
            self.declareVariableIfNeeded(value.operation!.lhs, declarations: &declarations)
            self.declareVariableIfNeeded(value.operation!.rhs, declarations: &declarations)
            switch operation.operator {
            case .add, .subtract, .multiply, .divide, .compare(_):
                break
            case .branch(comparing: _):
                break
            case .sampler2D(filter: _):
                break
            case let .lerp(factor: factor):
                declareVariableIfNeeded(factor, declarations: &declarations)
            }
            out += function(for: operation)
        case .bool, .int, .float1:
            switch value.valueRepresentation {
            case let .scalarBool(value):
                out += "\(value)"
            case let .scalarInt(value):
                out += "\(value)"
            case let .scalarFloat(value):
                out += "\(value)"
            default:
                fatalError()
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
        case .float3x3:
            fatalError()
        case .float4x4:
            let mat4 = value as! Mat4
            let mtx = mat4.valueMatrix4x4!.transposedArray()
            let c0 = "\(type(for: .float4))(\(mtx[00]),\(mtx[01]),\(mtx[02]),\(mtx[03]))"
            let c1 = "\(type(for: .float4))(\(mtx[04]),\(mtx[05]),\(mtx[06]),\(mtx[07]))"
            let c2 = "\(type(for: .float4))(\(mtx[08]),\(mtx[09]),\(mtx[10]),\(mtx[11]))"
            let c3 = "\(type(for: .float4))(\(mtx[12]),\(mtx[13]),\(mtx[14]),\(mtx[15]))"
            out += "\(type(for: .float4x4))(\(c0),\(c1),\(c2),\(c3))"
        case .texture2D:
            fatalError()
        }
        declarations += out + ";\n"
    }
    
    final func variable(for value: ShaderValue) -> String {
        switch value.valueRepresentation {
        case .vec2, .vec3, .vec4, .mat4, .scalarBool(_), .scalarInt(_), .scalarFloat(_), .operation:
            let objectID = ObjectIdentifier(value)
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
    
    func function(for value: Operation) -> String {
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
        case .branch(comparing: _):
            fatalError()
        case .sampler2D(filter: _):
            fatalError()
        case .lerp(factor: _):
            fatalError()
        }
    }
    
    func type(for valueType: ValueType) -> String {
        preconditionFailure("Must override")
    }
    
    final func type(for value: ShaderValue) -> String {
        return type(for: valueType(for: value))
    }
    
    final func valueType(for value: ShaderValue) -> ValueType {
        switch value.self {
        case is Scalar:
            switch value.valueRepresentation {
            case .scalarBool(_):
                return .bool
            case .scalarInt(_):
                return .int
            case .scalarFloat(_):
                return .float1
            case .vec2X(_), .vec2Y(_), .vec3X(_), .vec3Y(_), .vec3Z(_), .vec4X(_), .vec4Y(_), .vec4Z(_), .vec4W(_):
                return .float1
            case let .uniformCustom(_, type: valueType):
                switch valueType {
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
            case .operation:
                return valueType(for: value.operation!.lhs)
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
            operations += "\t\(variable(for: .vertexOutPosition)) = \(variable(for:position));\n"
        }else{
            declareVariable(vertexShader.modelViewProjectionMatrix, declarations: &declarations)
            operations += "\t\(variable(for: .vertexOutPosition)) = \(variable(for: vertexShader.modelViewProjectionMatrix)) * \(type(for: .float4))(\(variable(for: vertexShader.input.geometry(0).position)),1.0);\n"
        }
        if let pointSize = vertexShader.output.pointSize {
            declareVariableIfNeeded(pointSize, declarations: &declarations)
            operations += "\t\(variable(for: .vertexOutPointSize)) = \(variable(for:pointSize));\n"
        }
        for pair in vertexShader.output._values {
            let value = pair.value
            declareVariableIfNeeded(value, declarations: &declarations)
            operations += "\t\(variable(for: .vertexOut(pair.key))) = \(variable(for: value));\n"
        }
//        if let texCoord = vertexShader.output.textureCoordinate {
//            declareVariableIfNeeded(texCoord, declarations: &declarations)
//            operations += "\t\(variable(for: .vertexOutTexCoord)) = \(variable(for:texCoord));\n"
//        }else{
//            operations += "\t\(variable(for: .vertexOutTexCoord)) = \(variable(for: .vertexInTexCoord0(0)));\n"
//        }
        return declarations + "\n" + operations
    }
    
    final func generateMain(from fragmentShader: FragmentShader) -> String {
        var declarations = ""
        var operations = ""
        if let color = fragmentShader.output.color {
            declareVariableIfNeeded(color, declarations: &declarations)
            operations += "\t\(variable(for: .fragmentOutColor)) = \(variable(for:color));\n"
        }else{
            operations += "\t\(variable(for: .fragmentOutColor)) = \(type(for: .float4))(0.5,0.5,0.5,1.0);\n"
        }
        return declarations + "\n" + operations
    }
    
    public enum InputAttribute: Hashable {
        case vertexInPosition(geoemtryIndex: UInt8)
        case vertexInTexCoord0(geoemtryIndex: UInt8)
        case vertexInTexCoord1(geoemtryIndex: UInt8)
        case vertexInNormal(geoemtryIndex: UInt8)
        case vertexInTangent(geoemtryIndex: UInt8)
        case vertexInColor(geoemtryIndex: UInt8)
    }
}
