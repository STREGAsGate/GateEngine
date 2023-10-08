/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public class ShaderDocument: Identifiable {
    public enum DocumentType {
        case vertex
        case fragment
    }
    
    public struct Channel {
        internal let channelIndex: UInt8
        public let texture: Sampler2D
        public let scale: Vec2
        public let offset: Vec2
        public let color: Vec4
        
        internal init(channelIndex: UInt8) {
            self.channelIndex = channelIndex
            self.texture = Sampler2D(valueRepresentation: .channelAttachment(channelIndex))
            self.scale = Vec2(representation: .channelScale(channelIndex), type: .float2)
            self.offset = Vec2(representation: .channelOffset(channelIndex), type: .float2)
            self.color = Vec4(representation: .channelColor(channelIndex), type: .float2)
        }
    }

    let documentType: DocumentType
    let name: String
    @usableFromInline
    internal init(documentType: DocumentType, name: String) {
        self.documentType = documentType
        self.name = name
    }
    
    public var uniforms: Uniforms = Uniforms()
    public struct Uniforms {        
        internal var customUniforms: [String: any ShaderValue] = [:]
       
        internal var arrayCapacities: [String:Int] = [:]
        public func arrayCapacityForUniform(named name: String) -> Int? {
            return arrayCapacities[name]
        }
        
        public mutating func value<T: ShaderValue>(named name: String, as type: T.Type = T.self, scalarType: CustomUniformScalarType = .float, arrayCapacity: Int? = nil) -> T {
            if let existing = customUniforms[name] as? T {
                return existing
            }
            
            let v: T
            
            switch T.self {
            case is Scalar.Type:
                assert(arrayCapacity == nil, "\(type) is not an array.")
                v = Scalar(representation: .uniformCustom(name, type: scalarType.customUniformValueType), type: scalarType.valueType) as! T
            case is Vec2.Type:
                assert(arrayCapacity == nil, "\(type) is not an array.")
                v = Vec2(representation: .uniformCustom(name, type: .vec2), type: .float2) as! T
            case is Vec3.Type:
                assert(arrayCapacity == nil, "\(type) is not an array.")
                v = Vec3(representation: .uniformCustom(name, type: .vec3), type: .float3) as! T
            case is Vec4.Type:
                assert(arrayCapacity == nil, "\(type) is not an array.")
                v = Vec4(representation: .uniformCustom(name, type: .vec4), type: .float4) as! T
            case is Mat4.Type:
                assert(arrayCapacity == nil, "\(type) is not an array.")
                v = Mat4(representation: .uniformCustom(name, type: .mat4), type: .float4x4) as! T
            case is Mat4Array.Type:
                precondition(arrayCapacity != nil, "\(type) is an array and needs an arrayCapacity value in \(#function).")
                arrayCapacities[name] = arrayCapacity
                v = Mat4Array(representation: .uniformCustom(name, type: .mat4Array(arrayCapacity!)), type: .float4x4Array(arrayCapacity!)) as! T
            default:
                fatalError()
            }
            
            customUniforms[name] = v
            return v
        }
        
        public subscript<T: ShaderValue>(_ name: String, as type: T.Type = T.self, scalarType: CustomUniformScalarType = .float, arrayCapacity: Int? = nil) -> T {
            mutating get {
                return value(named: name, as: type, scalarType: scalarType, arrayCapacity: arrayCapacity)
            }
        }
        
        public func sortedCustomUniforms() -> [any ShaderValue] {
            return customUniforms.values.sorted {
                if case let .uniformCustom(index1, type: _) = $0.valueRepresentation {
                    if case let .uniformCustom(index2, type: _) = $1.valueRepresentation {
                        return index1 < index2
                    }
                }
                return false
            }
        }
        
        internal func documentIdentifierInputData() -> [Int] {
            var values: [Int] = []
            for uniform in sortedCustomUniforms() {
                values.append(contentsOf: uniform.documentIdentifierInputData())
            }
            return values
        }
    }
    
    public enum CustomUniformScalarType {
        case bool
        case int
        case float
        internal var valueType: ValueType {
            switch self {
            case .bool:
                return .bool
            case .int:
                return .int
            case .float:
                return .float
            }
        }
        
        internal var customUniformValueType: CustomUniformValueType {
            switch self {
            case .bool:
                return .bool
            case .int:
                return .int
            case .float:
                return .float
            }
        }
    }
    
    public func branch<T: ShaderValue>(if comparing: Scalar, success: T, failure: T) -> T {
        var comparing: Scalar = comparing
        if comparing.valueType != .bool {
            comparing = Scalar(comparing, castTo: .bool)
        }
        return T(Operation(compare: comparing, success: success, failure: failure))
    }
    
    static let cacheVersion: UInt32 = 1
    internal func documentIdentifierInputData() -> [Int] {
        fatalError("Must override")
    }
//    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: {
//        if self is VertexShader {
//            return .vertexDocuemnt
//        }
//        if self is FragmentShader {
//            return .fragmentDocument
//        }
//        fatalError()
//    }())
}
