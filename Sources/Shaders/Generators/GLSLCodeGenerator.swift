/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if DEBUG || (canImport(OpenGL_GateEngine) || os(WASI))

public final class GLSLCodeGenerator: CodeGenerator {
    public enum GLSLVersion: CustomStringConvertible {
        case v300es
        case v330core
        
        public var description: String {
            switch self {
            case .v330core:
                return "#version 330 core"
            case .v300es:
                return "#version 300 es"
            }
        }
    }
    
    override func type(for valueType: ValueType) -> String {
        switch valueType {
        case .texture2D:
            return "sampler2D"
        case .void, .operation:
            fatalError("operation has no type.")
        case .bool:
            return "bool"
        case .int:
            return "int"
        case .uint:
            return "uint"
        case .float:
            return "float"
        case .float2:
            return "vec2"
        case .float3:
            return "vec3"
        case .float4:
            return "vec4"
        case .uint4:
            return "uvec4"
        case .float3x3:
            return "mat3"
        case .float4x4:
            return "mat4"
        case .float4x4Array(_):
            return "mat4"
        }
    }
    
    public override func variable(for representation: ValueRepresentation) -> String {
        switch representation {
        case .vertexInstanceID:
            return "iid"
        case let .vertexInPosition(index):
            return "iPos\(index)"
        case let .vertexInTexCoord0(index):
            return "iUV\(index)_0"
        case let .vertexInTexCoord1(index):
            return "iUV\(index)_1"
        case let .vertexInNormal(index):
            return "iNml\(index)"
        case let .vertexInTangent(index):
            return "iTan\(index)"
        case let .vertexInColor(index):
            return "iClr\(index)"
        case let .vertexInJointIndices(index):
            return "iJtIdx\(index)"
        case let .vertexInJointWeights(index):
            return "iJtWeit\(index)"
        case .vertexOutPosition:
            return "gl_Position"
        case .vertexOutPointSize:
            return "gl_PointSize"
        case let .vertexOut(name):
            return "io_\(name)"
            
        case .fragmentInstanceID:
            return "iid"
        case let .fragmentIn(name):
            return "io_\(name)"
        case .fragmentOutColor:
            return "fClr"
        case .fragmentPosition:
            return "gl_FragCoord"
            
        case .uniformModelMatrix:
            return "mMtx"
        case .uniformViewMatrix:
            return "vMtx"
        case .uniformProjectionMatrix:
            return "pMtx"
        case let .uniformCustom(name, type: _):
            return "u_" + name
            
        case let .scalarBool(bool):
            return "\(bool)"
        case let .scalarInt(int):
            return "\(int)"
        case let .scalarUInt(uint):
            return "\(uint)"
        case let .scalarFloat(float):
            return "\(float)"
            
        case let .vec2Value(vec, index):
            return variable(for: vec) + "[" + variable(for: index) + "]"
        case let .vec3Value(vec, index):
            return variable(for: vec) + "[" + variable(for: index) + "]"
        case let .vec4Value(vec, index):
            return variable(for: vec) + "[" + variable(for: index) + "]"
        case let .uvec4Value(vec, index):
            return variable(for: vec) + "[" + variable(for: index) + "]"
            
        case let .mat4ArrayValue(array, index):
            return variable(for: array) + "[" + variable(for: index) + "]"
            
        case let .channelAttachment(index: index):
            return "material_\(index).texture"
        case let .channelScale(index):
            return "material_\(index).scale"
        case let .channelOffset(index):
            return "material_\(index).offset"
        case let .channelColor(index):
            return "material_\(index).color"
            
        #if DEBUG
        case .void, .operation, .vec2, .vec3, .vec4, .uvec4, .mat4, .mat4Array(_):
            fatalError("Shouldn't be asking for a name")
        #else
        default:
            fatalError()
        #endif
        }
    }
    
    override func function(value: some ShaderValue, operation: Operation) -> String {
        switch operation.operator {
        case .cast(let valueType):
            return "\(type(for: valueType))(\(variable(for: operation.value1)))"
        case .add, .subtract, .multiply, .divide, .compare(_):
            return variable(for: operation.value1) + " " + symbol(for: operation.operator) + " " + variable(for: operation.value2)
        case .not:
            return "\(symbol(for: operation.operator))\(variable(for: operation.value1))"
        case .branch(comparing: _):
            fatalError()
        case .switch(cases: _):
            fatalError()
        case .discard(comparing: _):
            return "discard"
        case .sampler2D:
            return "texture(" + variable(for: operation.value1) + "," + variable(for: operation.value2) + ")"
        case .sampler2DSize:
            return "\(scopeIndentation)\(variable(for: value)) = textureSize(\(variable(for: operation.value1)),0);\n"
        case let .lerp(factor: factor):
            return "mix(" + variable(for: operation.value1) + "," + variable(for: operation.value2) + "," + variable(for: factor) + ")"
        }
    }
    
    private func generateShaderCode(from vertexShader: VertexShader, attributes: ContiguousArray<InputAttribute>) throws -> String {
        var customUniformDefine: String = ""
        for value in vertexShader.uniforms.sortedCustomUniforms() {
            if case let .float4x4Array(capacity) = value.valueType {
                customUniformDefine += "uniform \(type(for: value.valueType)) \(variable(for: value))[\(capacity)];\n"
            }else{
                customUniformDefine += "uniform \(type(for: value.valueType)) \(variable(for: value));\n"
            }
        }
        
        var vertexGeometryDefine: String = ""
        for attributeIndex in attributes.indices {
            let attribute = attributes[attributeIndex]
            switch attribute {
            case .vertexInPosition(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float3)) \(variable(for: .vertexInPosition(geometryIndex)));\n"
            case .vertexInTexCoord0(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float2)) \(variable(for: .vertexInTexCoord0(geometryIndex)));\n"
            case .vertexInTexCoord1(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float2)) \(variable(for: .vertexInTexCoord1(geometryIndex)));\n"
            case .vertexInNormal(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float3)) \(variable(for: .vertexInNormal(geometryIndex)));\n"
            case .vertexInTangent(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float3)) \(variable(for: .vertexInTangent(geometryIndex)));\n"
            case .vertexInColor(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float4)) \(variable(for: .vertexInColor(geometryIndex)));\n"
            case .vertexInJointIndices(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .uint4)) \(variable(for: .vertexInJointIndices(geometryIndex)));\n"
            case .vertexInJointWeights(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "layout(location = \(attributeIndex)) in \(type(for: .float4)) \(variable(for: .vertexInJointWeights(geometryIndex)));\n"
            }
        }
        vertexGeometryDefine += "layout(location = \(attributes.count)) in \(type(for: .float4x4)) \(variable(for: .uniformModelMatrix));\n"
        
        var materialDefines: String = """
        struct Material {
            \(type(for: .float2)) offset;
            \(type(for: .float2)) scale;
            \(type(for: .float4)) color;
            \(type(for: .texture2D)) texture;
        };\n
        """
        for index in vertexShader.channels.indices {
            materialDefines += "uniform Material material_\(index);\n"
        }
        
        var outVariables: String = ""
        for pair in vertexShader.output._values {
            outVariables += "out \(type(for: pair.value)) \(variable(for: .vertexOut(pair.key)));\n"
        }
        
        generateMain(from: vertexShader)
        let mainOutput = mainOutput
        self.prepareForReuse()
        return """
\(version)
precision highp \(type(for: .float));

uniform \(type(for: .float4x4)) \(variable(for: .uniformViewMatrix));
uniform \(type(for: .float4x4)) \(variable(for: .uniformProjectionMatrix));\(customUniformDefine)

\(materialDefines)
\(vertexGeometryDefine)
\(outVariables)

void main() {
\(mainOutput)}
"""
    }
    
    private func generateShaderCode(from fragmentShader: FragmentShader) throws -> String {
        var customUniformDefine: String = ""
        for value in fragmentShader.uniforms.sortedCustomUniforms() {
            if case let .float4x4Array(capacity) = value.valueType {
                customUniformDefine += "uniform \(type(for: value)) \(variable(for: value))[\(capacity)];\n"
            }else{
                customUniformDefine += "uniform \(type(for: value)) \(variable(for: value));\n"
            }
        }
        
        var inVariables: String = ""
        for pair in fragmentShader.input._values {
            inVariables += "in \(type(for: pair.value)) \(variable(for: .fragmentIn(pair.key)));\n"
        }
        
        var materialDefines: String = """
        struct Material {
            \(type(for: .float2)) offset;
            \(type(for: .float2)) scale;
            \(type(for: .float4)) color;
            \(type(for: .texture2D)) texture;
        };\n
        """
        for index in fragmentShader.channels.indices {
            materialDefines += "uniform Material material_\(index);\n"
        }
        
        generateMain(from: fragmentShader)
        let mainOutput = mainOutput
        self.prepareForReuse()
        return """
\(version)
precision highp \(type(for: .float));
\(customUniformDefine)
\(materialDefines)
\(inVariables)
layout(location = 0) out \(type(for: .float4)) \(variable(for: .fragmentOutColor));

void main() {
\(mainOutput)}
"""
    }

    let version: GLSLVersion
    public required init(version: GLSLVersion) {
        self.version = version
    }
    
    
    public func generateShaderCode(vertexShader: VertexShader, fragmentShader: FragmentShader, attributes: ContiguousArray<InputAttribute>) throws -> (vertexSource: String, fragmentSource: String) {
        try validate(vsh: vertexShader, fsh: fragmentShader)
        let vsh = try generateShaderCode(from: vertexShader, attributes: attributes)
        let fsh = try generateShaderCode(from: fragmentShader)
        return (vsh, fsh)
    }
}

#endif
