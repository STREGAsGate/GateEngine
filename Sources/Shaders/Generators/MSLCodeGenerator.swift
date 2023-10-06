/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if DEBUG || canImport(MetalKit)

import Collections

public final class MSLCodeGenerator: CodeGenerator {
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
        case .void:
            fatalError("Cannot exist.")
        case .operation, .vec2, .vec3, .vec4, .uvec4, .mat4, .mat4Array:
            fatalError("Should be declared already.")
        case .vertexInstanceID:
            return "iid"
        case let .vertexInPosition(index):
            return "in.pos\(index)"
        case let .vertexInTexCoord0(index):
            return "in.uv\(index)_0"
        case let .vertexInTexCoord1(index):
            return "in.uv\(index)_1"
        case let .vertexInNormal(index):
            return "in.nml\(index)"
        case let .vertexInTangent(index):
            return "in.tan\(index)"
        case let .vertexInColor(index):
            return "in.clr\(index)"
        case let .vertexInJointIndices(index):
            return "in.jtIdx\(index)"
        case let .vertexInJointWeights(index):
            return "in.jtWeit\(index)"
        case .vertexOutPosition:
            return "out.pos"
        case .vertexOutPointSize:
            return "out.ptSz"
        case let .vertexOut(name):
            return "out.\(name)"
            
        case .fragmentInstanceID:
            return "in.iid"
        case let .fragmentIn(name):
            return "in.\(name)"
        case .fragmentOutColor:
            return "fClr"
            
        case .uniformModelMatrix:
            return "instances[iid].mMtx"
        case .uniformViewMatrix:
            return "uniforms.vMtx"
        case .uniformProjectionMatrix:
            return "uniforms.pMtx"
        case let .uniformCustom(index, type: _):
            return "uniforms.u\(index)"
            
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
        case .add, .subtract, .multiply, .divide, .compare(_):
            return "\(variable(for: operation.value1)) \(symbol(for: operation.operator)) \(variable(for: operation.value2))"
        case .branch(comparing: _):
            fatalError()
        case let .sampler2D(filter: filter):
            return "\(variable(for: operation.value1)).sample(\(filter == .nearest ? "nearestSampler" : "linearSampler"),\(variable(for: operation.value2)))"
        case let .lerp(factor: factor):
            return "mix(\(variable(for: operation.value1)), \(variable(for: operation.value2)), \(variable(for: factor)))"
        case .discard(comparing: _):
            return "discard;"
        }
    }
    
    public func generateShaderCode(vertexShader: VertexShader, fragmentShader: FragmentShader, attributes: ContiguousArray<InputAttribute>) throws -> String {
        try validate(vsh: vertexShader, fsh: fragmentShader)
                
        let vertexMain = generateMain(from: vertexShader)
        let fragmentMain = generateMain(from: fragmentShader)
        
        var customUniforms: OrderedSet<CustomUniform> = []
        struct CustomUniform: Hashable {
            let name: String
            let type: String
        }
        for value in vertexShader.sortedCustomUniforms() {
            if case let .uniformCustom(index, type: _) = value.valueRepresentation {
                if case let .float4x4Array(capacity) = value.valueType {
                    customUniforms.append(CustomUniform(name: "u\(index)[\(capacity)]", type: "\(type(for: value))"))
                }else{
                    customUniforms.append(CustomUniform(name: "u\(index)", type: "\(type(for: value))"))
                }
            }
        }
        for value in fragmentShader.sortedCustomUniforms() {
            if case let .uniformCustom(index, type: _) = value.valueRepresentation {
                if case let .float4x4Array(capacity) = value.valueType {
                    customUniforms.append(CustomUniform(name: "u\(index)[\(capacity)]", type: "\(type(for: value))"))
                }else{
                    customUniforms.append(CustomUniform(name: "u\(index)", type: "\(type(for: value))"))
                }
            }
        }
        
        customUniforms.sort {$0.name.caseInsensitiveCompare($1.name) == .orderedAscending}
        
        var customUniformDefine: String = ""
        for uniform in customUniforms {
            customUniformDefine += "\n    \(uniform.type) \(uniform.name);"
        }
        
        var vertexGeometryDefine: String = ""
        for attributeIndex in attributes.indices {
            let attribute = attributes[attributeIndex]
            switch attribute {
            case .vertexInPosition(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) pos\(geometryIndex) [[attribute(\(attributeIndex))]];"
            case .vertexInTexCoord0(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float2)) uv\(geometryIndex)_0 [[attribute(\(attributeIndex))]];"
            case .vertexInTexCoord1(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float2)) uv\(geometryIndex)_1 [[attribute(\(attributeIndex))]];"
            case .vertexInTangent(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) tan\(geometryIndex) [[attribute(\(attributeIndex))]];"
            case .vertexInNormal(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float3)) nml\(geometryIndex) [[attribute(\(attributeIndex))]];"
            case .vertexInColor(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float4)) clr\(geometryIndex) [[attribute(\(attributeIndex))]];"
            case .vertexInJointIndices(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .uint4)) jtIdx\(geometryIndex) [[attribute(\(attributeIndex))]];"
            case .vertexInJointWeights(geometryIndex: let geometryIndex):
                vertexGeometryDefine += "\n    \(type(for: .float4)) jtWeit\(geometryIndex) [[attribute(\(attributeIndex))]];"
            }
        }
        
        var vertexOut: String = ""
        for pair in vertexShader.output._values {
            vertexOut += "    \(type(for: pair.value)) \(pair.key);"
        }
        
        var fragmentTextureList: String = ""
        for index in fragmentShader.channels.indices {
            if fragmentTextureList.isEmpty == false {
                fragmentTextureList += ",\n"
            }
            fragmentTextureList += "                                            texture2d<float> tex\(index) [[texture(\(index))]]"
        }
        
        return """
#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
typedef struct {
    \(type(for: .float2)) scale;
    \(type(for: .float2)) offset;
    \(type(for: .float4)) color;
    \(type(for: .int)) sampleFilter;
} Material;
typedef struct {
    \(type(for: .float4x4)) pMtx;
    \(type(for: .float4x4)) vMtx;\(customUniformDefine)
} Uniforms;
typedef struct {
    \(type(for: .float4x4)) mMtx;
    \(type(for: .float4x4)) iMMtx;
} InstanceUniforms;
typedef struct {\(vertexGeometryDefine)
} Vertex;
typedef struct {
    \(type(for: .float4)) pos [[position]];
    \(type(for: .float)) ptSz [[point_size]];
\(vertexOut)
    int iid [[flat]];
} Fragment;

vertex Fragment vertex\(UInt(bitPattern: vertexShader.id.hashValue))(Vertex in [[stage_in]],
                                          constant Uniforms & uniforms [[buffer(\(attributes.count + 0))]],
                                          constant InstanceUniforms *instances [[buffer(\(attributes.count + 1))]],
                                          constant Material *materials [[buffer(\(attributes.count + 2))]],
                                          sampler linearSampler [[sampler(0)]],
                                          sampler nearestSampler [[sampler(1)]],
                                          ushort uiid [[instance_id]]) {
    \(type(for: .int)) iid = uiid;
    Fragment out;
    out.iid = iid;
\(vertexMain)
    return out;
}
fragment \(type(for: .float4)) fragment\(UInt(bitPattern: fragmentShader.id.hashValue))(Fragment in [[stage_in]],
                                            constant Uniforms & uniforms [[buffer(0)]],
                                            constant Material *materials [[buffer(1)]],
                                            sampler linearSampler [[sampler(0)]],
                                            sampler nearestSampler [[sampler(1)]],
\(fragmentTextureList)) {
    \(type(for: .float4)) \(variable(for: .fragmentOutColor));
\(fragmentMain)
    return \(variable(for: .fragmentOutColor));
}
"""
    }
    
    public override init() {
        
    }
}

#endif
