/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if DEBUG || canImport(Direct3D12)

public final class HLSLCodeGenerator: CodeGenerator {
    override func type(for valueType: ValueType) -> String {
        switch valueType {
        case .texture2D:
            return "texture2D"
        case .operation:
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
        case .operation, .vec2, .vec3, .vec4, .uvec4, .mat4, .mat4Array:
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
        case let .vertexInJointIndicies(index):
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
            
        case .uniformModelMatrix:
            return "mMtx"
        case .uniformViewMatrix:
            return "vMtx"
        case .uniformProjectionMatrix:
            return "pMtx"
        case let .uniformCustom(index, type: _):
            return "u\(index)"
            
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
    
    override func function(for operation: Operation) -> String {
        switch operation.operator {
        case .add, .subtract, .divide, .compare(_):
            return "\(variable(for: operation.lhs)) \(symbol(for: operation.operator)) \(variable(for: operation.rhs))"
        case .multiply:
            return "mul(\(variable(for: operation.lhs)),\(variable(for: operation.rhs)))"
        case .branch(comparing: _):
            fatalError()
        case let .sampler2D(filter: filter):
            return "\(variable(for: operation.lhs)).Sample(\(filter == .nearest ? "nearestSampler" : "linearSampler"),\(variable(for: operation.rhs)))"
        case let .lerp(factor: factor):
            return "lerp(\(variable(for: operation.lhs)), \(variable(for: operation.rhs)), \(variable(for: factor)))"
        }
    }
    
    public func generateShaderCode(vertexShader: VertexShader, fragmentShader: FragmentShader, attributes: ContiguousArray<InputAttribute>) throws -> (vsh: String, fsh: String) {
        try validate(vsh: vertexShader, fsh: fragmentShader)
                
        let vertexMain = generateMain(from: vertexShader)
        let fragmentMain = generateMain(from: fragmentShader)
        
        var customUniformDefine: String = ""
        for value in vertexShader.sortedCustomUniforms() {
            if case let .uniformCustom(index, type: _) = value.valueRepresentation {
                if case let .float4x4Array(capacity) = value.valueType {
                    customUniformDefine += "\n    \(type(for: value)) u\(index)[\(capacity)];"
                }else{
                    customUniformDefine += "\n    \(type(for: value)) u\(index);"
                }
            }
        }
        
        var vertexGeometryDefine: String = ""
        for attributeIndex in attributes.indices {
            let attribute = attributes[attributeIndex]
            switch attribute {
            case .vertexInPosition(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) pos\(geometryIndex) : POSITION;"
            case .vertexInTexCoord0(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float2)) uv\(geometryIndex)_0 : TEXCOORD0;"
            case .vertexInTexCoord1(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float2)) uv\(geometryIndex)_1 : TEXCOORD1;"
            case .vertexInNormal(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) nml\(geometryIndex) : NORMAL;"
            case .vertexInTangent(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) tan\(geometryIndex) : TANGENT;"
            case .vertexInColor(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float4)) clr\(geometryIndex) : COLOR;"
            case .vertexInJointIndices(geoemtryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .uint4)) jtIdx\(geometryIndex) : BONEINDEX;"
            case .vertexInJointWeights(geoemtryIndex: let geometryIndex):
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
cbuffer Uniforms : register(b0) {
    \(type(for: .float4x4)) pMtx;
    \(type(for: .float4x4)) vMtx;
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
cbuffer Uniforms : register(b0) {
    \(type(for: .float4x4)) pMtx;
    \(type(for: .float4x4)) vMtx;
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
