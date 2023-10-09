/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if DEBUG || canImport(Direct3D12)

import Collections

public final class HLSLCodeGenerator: CodeGenerator {
    override func type(for valueType: ValueType) -> String {
        switch valueType {
        case .texture2D:
            return "texture2D"
        case .void, .operation:
            fatalError()
        case .bool:
            return "bool"
        case .int:
            return "int"
        case .uint:
            return "uint"
        case .float:
            return "float"
        case .float2:
            return "float2"
        case .float3:
            return "float3"
        case .float4:
            return "float4"
        case .uint4:
            return "uint4"
        case .float3x3:
            return "float3x3"
        case .float4x4:
            return "float4x4"
        case .float4x4Array(_):
            return "float4x4"
        }
    }
    
    override func variable(for representation: ValueRepresentation) -> String {
        switch representation {
        case .void, .operation, .vec2, .vec3, .vec4, .uvec4, .mat4, .mat4Array:
            fatalError("Should be declared.")
        case .vertexInstanceID:
            return "iid"
        case let .vertexInPosition(index):
            return "input.pos\(index)"
        case let .vertexInTexCoord0(index):
            return "input.uv\(index)_0"
        case let .vertexInTexCoord1(index):
            return "input.uv\(index)_1"
        case let .vertexInNormal(index):
            return "input.nml\(index)"
        case let .vertexInTangent(index):
            return "input.tan\(index)"
        case let .vertexInColor(index):
            return "input.clr\(index)"
        case let .vertexInJointIndices(index):
            return "input.jtIdx\(index)"
        case let .vertexInJointWeights(index):
            return "input.jtWeit\(index)"
        case .vertexOutPosition:
            return "output.pos"
        case .vertexOutPointSize:
            return "output.ptSz"
        case let .vertexOut(name):
            return "output.\(name)"
            
        case .fragmentInstanceID:
            return "input.iid"
        case let .fragmentIn(name):
            return "input.\(name)"
        case .fragmentOutColor:
            return "fClr"
        case .fragmentPosition:
            return "input.pos"
            
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
            return variable(for: vec) + "[\(variable(for: index))]"
        case let .vec3Value(vec, index):
            return variable(for: vec) + "[\(variable(for: index))]"
        case let .vec4Value(vec, index):
            return variable(for: vec) + "[\(variable(for: index))]"
        case let .uvec4Value(vec, index):
            return variable(for: vec) + "[\(variable(for: index))]"
       
        case let .mat4ArrayValue(array, index):
            return "\(variable(for: array))[\(variable(for: index))]"
            
        case let .channelAttachment(index: index):
            return "tex\(index)"
        case let .channelScale(index):
            return "materials[\(index)].scale"
        case let .channelOffset(index):
            return "materials[\(index)].offset"
        case let .channelColor(index):
            return "materials[\(index)].color"
        }
    }
    
    override func function(value: some ShaderValue, operation: Operation) -> String {
        switch operation.operator {
        case .cast(let valueType):
            return "(\(type(for: valueType)))\(variable(for: operation.value1))"
        case .add, .subtract, .divide, .compare(_):
            return "\(variable(for: operation.value1)) \(symbol(for: operation.operator)) \(variable(for: operation.value2))"
        case .multiply:
            let mul: Bool = shouldUseMul(operation: operation)

            func shouldUseMul(operation: Operation) -> Bool {
                switch operation.value1.valueType {
                case .float3x3, .float4x4:
                    return true
                case .operation:
                    if shouldUseMul(operation: operation.value1.operation!) {
                        return true
                    }
                default:
                    switch operation.value2.valueType {
                    case .float3x3, .float4x4:
                        return true
                    case .operation:
                        if shouldUseMul(operation: operation.value2.operation!) {
                            return true
                        }
                    default:
                        return false
                    }
                }
                return false
            }

            if mul {
                return "mul(\(variable(for: operation.value1)),\(variable(for: operation.value2)))"
            }
            return "\(variable(for: operation.value1)) \(symbol(for: .multiply)) \(variable(for: operation.value2))"
        case .not:
            return "\(symbol(for: operation.operator))\(variable(for: operation.value1))"
        case .branch(comparing: _):
            fatalError()
        case .switch(cases: _):
            fatalError()
        case .discard(comparing: _):
            return "discard"
        case let .sampler2D(filter: filter):
            return "\(variable(for: operation.value1)).Sample(\(filter == .nearest ? "nearestSampler" : "linearSampler"),\(variable(for: operation.value2)))"
        case .sampler2DSize:
            return "\(scopeIndentation)\(variable(for: operation.value1)).GetDimensions(\(variable(for: value)).x, \(variable(for: value)).y;\n"
        case let .lerp(factor: factor):
            return "lerp(\(variable(for: operation.value1)), \(variable(for: operation.value2)), \(variable(for: factor)))"
        }
    }
    
    public func generateShaderCode(vertexShader: VertexShader, fragmentShader: FragmentShader, attributes: ContiguousArray<InputAttribute>) throws -> (vsh: String, fsh: String) {
        try validate(vsh: vertexShader, fsh: fragmentShader)
        
        generateMain(from: vertexShader)
        let vertexMain = mainOutput
        prepareForReuse()
        generateMain(from: fragmentShader)
        let fragmentMain = mainOutput
        
        struct CustomUniform: Hashable {
            let name: String
            let type: String
        }
        func customUniforms(from shader: ShaderDocument) -> String {
            var customUniformsVsh: OrderedSet<CustomUniform> = []
            for value in shader.uniforms.sortedCustomUniforms() {
                if case let .uniformCustom(name, type: _) = value.valueRepresentation {
                    if case let .float4x4Array(capacity) = value.valueType {
                        customUniformsVsh.append(CustomUniform(name: "u_\(name)[\(capacity)]", type: "\(type(for: value))"))
                    }else{
                        customUniformsVsh.append(CustomUniform(name: "u_\(name)", type: "\(type(for: value))"))
                    }
                }
            }
            customUniformsVsh.sort {$0.name.caseInsensitiveCompare($1.name) == .orderedAscending}
            var customUniformDefineVsh: String = ""
            for uniform in customUniformsVsh {
                customUniformDefineVsh += "\n    \(uniform.type) \(uniform.name);"
            }
            return customUniformDefineVsh
        }
        let customUniformDefineVsh: String = customUniforms(from: vertexShader)
        let customUniformDefineFsh: String = customUniforms(from: fragmentShader)
        
        var vertexGeometryDefine: String = ""
        for attributeIndex in attributes.indices {
            let attribute = attributes[attributeIndex]
            switch attribute {
            case .vertexInPosition(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) pos\(geometryIndex) : POSITION;"
            case .vertexInTexCoord0(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float2)) uv\(geometryIndex)_0 : TEXCOORD0;"
            case .vertexInTexCoord1(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float2)) uv\(geometryIndex)_1 : TEXCOORD1;"
            case .vertexInNormal(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) nml\(geometryIndex) : NORMAL;"
            case .vertexInTangent(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) tan\(geometryIndex) : TANGENT;"
            case .vertexInColor(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float4)) clr\(geometryIndex) : COLOR;"
            case .vertexInJointIndices(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .uint4)) jtIdx\(geometryIndex) : BONEINDEX;"
            case .vertexInJointWeights(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float4)) jtWeit\(geometryIndex) : BONEWEIGHT;"
            }
        }
        
        var vertexOut: String = ""
        for pair in vertexShader.output._values {
            vertexOut += "    \(type(for: pair.value)) \(pair.key) : \(pair.key.uppercased());"
        }
        
        var fragmentTextureList: String = ""
        for index in fragmentShader.channels.indices {
            if fragmentTextureList.isEmpty == false {
                fragmentTextureList += ",\n"
            }
            fragmentTextureList += "Texture2D<float4> tex\(index) : register(t\(index));"
        }
        
        let vsh = """
cbuffer UniformsVsh : register(b0) {
    \(type(for: .float4x4)) pMtx;
    \(type(for: .float4x4)) vMtx;\(customUniformDefineVsh)
};
struct Material {
    \(type(for: .float2)) scale;
    \(type(for: .float2)) offset;
    \(type(for: .float4)) color;
    \(type(for: .int)) sampleFilter;
};
cbuffer Materials : register(b1) {
    Material materials[16];
};

struct VSInput {\(vertexGeometryDefine)
    float4 modelMatrix1 : ModelMatrixA;
    float4 modelMatrix2 : ModelMatrixB;
    float4 modelMatrix3 : ModelMatrixC;
    float4 modelMatrix4 : ModelMatrixD;
};
struct PSInput {
    \(type(for: .float4)) pos : SV_POSITION;
    \(type(for: .float)) ptSz : PSIZE;
\(vertexOut)
};

PSInput VSMain(VSInput input) {
    float4x4 mMtx = float4x4(input.modelMatrix1,input.modelMatrix2,input.modelMatrix3,input.modelMatrix4);
    PSInput output;
\(vertexMain)
    return output;
}
"""
        let fsh = """
cbuffer UniformsFsh : register(b0) {
    \(type(for: .float4x4)) pMtx;
    \(type(for: .float4x4)) vMtx;\(customUniformDefineFsh)
};
struct Material {
    \(type(for: .float2)) scale;
    \(type(for: .float2)) offset;
    \(type(for: .float4)) color;
    \(type(for: .int)) sampleFilter;
};
cbuffer Materials : register(b1) {
    Material materials[16];
};

struct PSInput {
    \(type(for: .float4)) pos : SV_POSITION;
    \(type(for: .float)) ptSz : PSIZE;
\(vertexOut)
};

\(fragmentTextureList)
SamplerState linearSampler : register(s0);
SamplerState nearestSampler : register(s1);

float4 PSMain(PSInput input) : SV_TARGET {
    \(type(for: .float4)) \(variable(for: .fragmentOutColor));
\(fragmentMain)
    return \(variable(for: .fragmentOutColor));
}
"""
        return (vsh, fsh)
    }
    
    public override init() {
        
    }
}

#endif
