/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class FragmentShader: ShaderDocument {
    var channels: [Channel] = [Channel(channelIndex: 0)]
    public func channel(_ index: UInt8) -> Channel {
        precondition(index <= channels.count, "index must be an existing channel or the next channel \(index)")
        if index == channels.count {
            channels.append(Channel(channelIndex: UInt8(channels.count)))
        }
        return channels[Int(index)]
    }
    
    public struct Input {
        public let position: Vec4 = Vec4(representation: .fragmentPosition, type: .float4)
        
        public var _values: [String: any ShaderValue] = [:]
        public subscript<T: ShaderValue>(key: String, scalarType: CustomUniformScalarType = .float) -> T {
            mutating get {
                if let existing = _values[key] as? T {
                    return existing
                }
                let v: T
                switch T.self {
                case is Scalar.Type:
                    v = Scalar(representation: .fragmentIn(key), type: scalarType.valueType) as! T
                case is Vec2.Type:
                    v = Vec2(representation: .fragmentIn(key), type: .float2) as! T
                case is Vec3.Type:
                    v = Vec3(representation: .fragmentIn(key), type: .float3) as! T
                case is Vec4.Type:
                    v = Vec4(representation: .fragmentIn(key), type: .float4) as! T
                case is Mat4.Type:
                    v = Mat4(representation: .fragmentIn(key), type: .float4x4) as! T
                default:
                    fatalError()
                }
                _values[key] = v
                return v
            }
            set {_values[key] = newValue}
        }
    }
    public var input: Input = Input()
    
    public struct Output {
        public var color: Vec4? = nil
    }
    public var output: Output = Output()
    
    public convenience init(name: String? = nil, _file: StaticString = #file, _line: Int = #line) {
        self.init(documentType: .fragment, name: name ?? "FSH(\(_file):\(_line))")
    }
}
