/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class VertexShader: ShaderDocument {
    public private(set) lazy var modelMatrix: Mat4 = Mat4(representation: .uniformModelMatrix, type: .float4x4)
    public private(set) lazy var viewMatrix: Mat4 = Mat4(representation: .uniformViewMatrix, type: .float4x4)
    public private(set) lazy var projectionMatrix: Mat4 = Mat4(representation: .uniformProjectionMatrix, type: .float4x4)
    
    public private(set) lazy var viewProjectionMatrix: Mat4 = self.projectionMatrix * self.viewMatrix
    public private(set) lazy var modelViewMatrix: Mat4 = self.viewMatrix * self.modelMatrix
    public private(set) lazy var modelViewProjectionMatrix: Mat4 = viewProjectionMatrix * self.modelMatrix
        
    var channels: [Channel] = [Channel(channelIndex: 0)]
    public func channel(_ index: UInt8) -> Channel {
        precondition(index <= channels.count, "index must be an existing channel or the next channel \(index)")
        if index == channels.count {
            channels.append(Channel(channelIndex: UInt8(channels.count)))
        }
        return channels[Int(index)]
    }
    
    public struct Input {
        public struct Geometry {
            public let position: Vec3
            public let textureCoordinate0: Vec2
            public let textureCoordinate1: Vec2
            public let color: Vec4
            public let normal: Vec3
            public let tangent: Vec3
            public let jointIndices: UVec4
            public let jointWeights: Vec4
            
            init(_ index: UInt8) {
                self.position = Vec3(representation: .vertexInPosition(index), type: .float3)
                self.textureCoordinate0 = Vec2(representation: .vertexInTexCoord0(index), type: .float2)
                self.textureCoordinate1 = Vec2(representation: .vertexInTexCoord1(index), type: .float2)
                self.color = Vec4(representation: .vertexInColor(index), type: .float4)
                self.normal = Vec3(representation: .vertexInNormal(index), type: .float4)
                self.tangent = Vec3(representation: .vertexInTangent(index), type: .float4)
                self.jointIndices = UVec4(representation: .vertexInJointIndices(index), type: .uint4)
                self.jointWeights = Vec4(representation: .vertexInJointWeights(index), type: .float4)
            }
        }
        
        public private(set) var geometries: [Geometry] = [Geometry(0)]
        public mutating func geometry(_ index: UInt8) -> Geometry {
            precondition(index <= geometries.count, "index must be an existing geometry or the next geometry \(index)")
            if index == geometries.count {
                geometries.append(Geometry(UInt8(geometries.count)))
            }
            return geometries[Int(index)]
        }
        
        public let instanceID: Scalar = Scalar(representation: .vertexInstanceID, type: .int)
    }
    public var input: Input = Input()
    
    public struct Output {
        public var position: Vec4? = nil
        public var pointSize: Scalar? = nil
        
        public var _values: [String: any ShaderValue] = [:]
        public subscript<T: ShaderValue>(key: String, interpolated: Bool = true) -> T? {
            get {_values[key] as? T}
            set {_values[key] = newValue}
        }
    }
    public var output: Output = Output()
    
    public init() {
        super.init(documentType: .vertex)
    }
}
