/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public class CodeGenerator {
    struct Scope {
        var nextVarIndex: Int
        var varNames: [ObjectIdentifier: String] = [:]
        var declaredValues: Set<ObjectIdentifier> = []
    }
    var _scopes: [Scope] = []
    var currentScope: Scope {
        get {
            return _scopes[_scopes.count - 1]
        }
        set {
            _scopes[_scopes.count - 1] = newValue
        }
    }
    var mainOutput: String = ""
    var scopeIndentation = ""
    func pushScope() {
        _scopes.append(Scope(nextVarIndex: _scopes.isEmpty ? 0 : currentScope.nextVarIndex))
        scopeIndentation = String(repeating: " ", count: _scopes.count * 4)
    }
    func popScope() {
        _scopes.removeLast()
        scopeIndentation = String(repeating: " ", count: _scopes.count * 4)
    }
    
    func currentScopeNeedsDeclaration(for value: some ShaderValue) -> Bool {
        let objectID = ObjectIdentifier(value)// value.id
        for scopeIndex in _scopes.indices {
            if _scopes[scopeIndex].declaredValues.contains(objectID) {
                return false
            }
        }
        return true
    }
    func varName(for value: some ShaderValue) -> String {
        let objectID = ObjectIdentifier(value)
        for scopeIndex in _scopes.indices.reversed() {
            let scope = _scopes[scopeIndex]
            if let name = scope.varNames[objectID] {
                return name
            }
        }
        
        currentScope.nextVarIndex += 1
        let name = "v\(currentScope.nextVarIndex)"
        currentScope.varNames[objectID] = name
        return name
    }
   
    final func prepareForReuse() {
        _scopes.removeAll(keepingCapacity: true)
        mainOutput = ""
    }
    
    internal final func validate(vsh: VertexShader, fsh: FragmentShader) throws {
        try checkLinkError(vsh: vsh, fsh: fsh)
    }
    
    private final func checkLinkError(vsh: VertexShader, fsh: FragmentShader) throws {
        let vshKeys: Set<String> = Set(vsh.output._values.keys)
        let fshKeys: Set<String> = Set(fsh.input._values.keys)
        
        for fshKey in fshKeys {
            if vshKeys.contains(fshKey) == false {
                throw ShaderError("Shaders can't be linked because \(vsh.name) doesn't have \"\(fshKey)\" required by \(fsh.name).")
            }
        }
    }
    
    final func declareVariableIfNeeded(_ value: some ShaderValue) {
        guard currentScopeNeedsDeclaration(for: value) else {return}
        currentScope.declaredValues.insert(ObjectIdentifier(value))
        
        switch value.valueRepresentation {
        case .operation:
            self.declareFunction(value: value)
        case .vec2, .vec3, .vec4, .uvec4, .mat4, .mat4Array:
            self.declareVariable(value)
        case let .vec2Value(vec, index):
            self.declareVariableIfNeeded(vec)
            self.declareVariableIfNeeded(index)
        case let .vec3Value(vec, index):
            self.declareVariableIfNeeded(vec)
            self.declareVariableIfNeeded(index)
        case let .vec4Value(vec, index):
            self.declareVariableIfNeeded(vec)
            self.declareVariableIfNeeded(index)
        case let .uvec4Value(vec, index):
            self.declareVariableIfNeeded(vec)
            self.declareVariableIfNeeded(index)
        case let .mat4ArrayValue(array, index):
            self.declareVariableIfNeeded(array)
            self.declareVariableIfNeeded(index)
        #if DEBUG
        case .scalarBool(_), .scalarInt(_), .scalarUInt(_), .scalarFloat(_):
            return
        case .vertexInPosition, .vertexInTexCoord0(_), .vertexInTexCoord1(_), .vertexInNormal(_), .vertexInTangent(_), .vertexInColor(_), .vertexInJointIndices(_), .vertexInJointWeights(_):
            return
        case .vertexOutPosition, .vertexOutPointSize, .vertexOut(_), .vertexInstanceID:
            return
        case .fragmentIn(_), .fragmentOutColor, .fragmentInstanceID, .fragmentPosition:
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
    
    func declareFunction(value: some ShaderValue) {
        let operation = value.operation!
        switch operation.operator {
        case .cast(_):
            self.declareVariableIfNeeded(operation.value1)
            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value)) = " + function(value: value, operation: operation) + ";\n"
        case .lerp(let factor):
            self.declareVariableIfNeeded(factor)
            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value)) = " + function(value: value, operation: operation) + ";\n"
        case .add, .subtract, .multiply, .divide, .compare(_), .sampler2D(_):
            self.declareVariableIfNeeded(operation.value1)
            self.declareVariableIfNeeded(operation.value2)
            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value)) = " + function(value: value, operation: operation) + ";\n"
        case .not:
            self.declareVariableIfNeeded(operation.value1)
            mainOutput +=  scopeIndentation + "\(type(for: value)) \(variable(for: value)) = \(symbol(for: .not))\(variable(for: operation.value1))"
        case .sampler2DSize:
            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value));\n"
            mainOutput += function(value: value, operation: operation)
        case .branch(let comparing):
            self.declareVariableIfNeeded(comparing)

            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value));\n"
    
            mainOutput += scopeIndentation + "if (\(variable(for: comparing))) {\n"
            pushScope()
            declareVariableIfNeeded(operation.value1)
            mainOutput += scopeIndentation + "\(variable(for: value)) = \(variable(for: operation.value1));\n"
            popScope()
            mainOutput += scopeIndentation + "}else{\n"
            pushScope()
            declareVariableIfNeeded(operation.value2)
            mainOutput += scopeIndentation + "\(variable(for: value)) = \(variable(for: operation.value2));\n"
            popScope()
            mainOutput += scopeIndentation + "}\n"
        case .switch(cases: let cases):
            declareVariableIfNeeded(operation.value1)
    
            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value));\n"
            mainOutput += scopeIndentation + "switch (\(variable(for: operation.value1))) {\n"
            for `case` in cases {
                pushScope()
                mainOutput += scopeIndentation + "case \(variable(for: `case`.compare)): {\n"
                pushScope()
                declareVariableIfNeeded(`case`.result)
                mainOutput += scopeIndentation + "\(variable(for: value)) = \(variable(for: `case`.result));\n"
                mainOutput += scopeIndentation + "break;\n"
                popScope()
                mainOutput += scopeIndentation + "}\n"
                popScope()
            }
            mainOutput += scopeIndentation + "}\n"
        case .discard(comparing: let comparing):
            self.declareVariableIfNeeded(comparing)
            declareVariableIfNeeded(operation.value1)
            
            mainOutput += scopeIndentation + "\(type(for: value)) \(variable(for: value)) = \(variable(for: operation.value1));\n"
            
            mainOutput += scopeIndentation + "if (\(variable(for: comparing))) {\n"
            pushScope()
            mainOutput += scopeIndentation + function(value: value, operation: operation) + ";\n"
            popScope()
            mainOutput += scopeIndentation + "}\n"
        }
    }
    
    private final func declareVariable(_ value: some ShaderValue) {
        lazy var out = scopeIndentation + "\(type(for: value)) \(variable(for: value)) = "
        switch value.valueType {
        case .operation:
            fatalError()
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
            self.declareVariableIfNeeded(vec2._x!)
            self.declareVariableIfNeeded(vec2._y!)
            out += "\(type(for: .float2))(\(variable(for: vec2._x!)),\(variable(for: vec2._y!)))"
        case .float3:
            let vec3 = value as! Vec3
            self.declareVariableIfNeeded(vec3._x!)
            self.declareVariableIfNeeded(vec3._y!)
            self.declareVariableIfNeeded(vec3._z!)
            out += "\(type(for: .float3))(\(variable(for: vec3._x!)),\(variable(for: vec3._y!)),\(variable(for: vec3._z!)))"
        case .float4:
            let vec4 = value as! Vec4
            self.declareVariableIfNeeded(vec4._x!)
            self.declareVariableIfNeeded(vec4._y!)
            self.declareVariableIfNeeded(vec4._z!)
            self.declareVariableIfNeeded(vec4._w!)
            out += "\(type(for: .float4))(\(variable(for: vec4._x!)),\(variable(for: vec4._y!)),\(variable(for: vec4._z!)),\(variable(for: vec4._w!)))"
        case .uint4:
            let uvec4 = value as! UVec4
            self.declareVariableIfNeeded(uvec4._x!)
            self.declareVariableIfNeeded(uvec4._y!)
            self.declareVariableIfNeeded(uvec4._z!)
            self.declareVariableIfNeeded(uvec4._w!)
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
        mainOutput += out + ";\n"
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
            return varName(for: value)
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
        case .not:
            return "!"
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
        case .cast(_):
            fatalError()
        case .branch(comparing: _):
            fatalError()
        case .sampler2D(filter: _):
            fatalError()
        case .sampler2DSize:
            fatalError()
        case .lerp(factor: _):
            fatalError()
        case .discard(comparing: _):
            fatalError()
        case .switch(cases: _):
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
                if case .compare(_) = value.operation?.operator {
                    return .bool
                }
                if case .cast(let valueType) = value.operation?.operator {
                    return valueType
                }
                return valueType(for: value.operation!.value1)
            case .fragmentIn(_):
                return value.valueType
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
    
    final func generateMain(from vertexShader: VertexShader) {
        pushScope()
        if let position = vertexShader.output.position {
            declareVariableIfNeeded(position)
            mainOutput += "\(scopeIndentation)\(variable(for: .vertexOutPosition)) = \(variable(for:position));\n"
        }else{
            declareVariable(vertexShader.modelViewProjectionMatrix)
            mainOutput += "\(scopeIndentation)\(variable(for: .vertexOutPosition)) = \(variable(for: vertexShader.modelViewProjectionMatrix)) * \(type(for: .float4))(\(variable(for: vertexShader.input.geometry(0).position)),1.0);\n"
        }
        if let pointSize = vertexShader.output.pointSize {
            declareVariableIfNeeded(pointSize)
            mainOutput += "\(scopeIndentation)\(variable(for: .vertexOutPointSize)) = \(variable(for:pointSize));\n"
        }
        for pair in vertexShader.output._values {
            let value = pair.value
            declareVariableIfNeeded(value)
            mainOutput += "\(scopeIndentation)\(variable(for: .vertexOut(pair.key))) = \(variable(for: value));\n"
        }
//        if let texCoord = vertexShader.output.textureCoordinate {
//            declareVariableIfNeeded(texCoord, declarations: &declarations)
//            operations += "\(scopeIndentation)\(variable(for: .vertexOutTexCoord)) = \(variable(for:texCoord));\n"
//        }else{
//            operations += "\(scopeIndentation)\(variable(for: .vertexOutTexCoord)) = \(variable(for: .vertexInTexCoord0(0)));\n"
//        }
        popScope()
    }
    
    final func generateMain(from fragmentShader: FragmentShader) {
        pushScope()
        if let color = fragmentShader.output.color {
            declareVariableIfNeeded(color)
            mainOutput += scopeIndentation + "\(variable(for: .fragmentOutColor)) = \(variable(for:color));\n"
        }else{
            mainOutput += scopeIndentation + "\(variable(for: .fragmentOutColor)) = \(type(for: .float4))(0.5,0.5,0.5,1.0);\n"
        }
        popScope()
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
