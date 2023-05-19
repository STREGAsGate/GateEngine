/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath
import Shaders

public protocol CustomUniformType {}
extension Int: CustomUniformType {}
extension Bool: CustomUniformType {}
extension Float: CustomUniformType {}
extension Position2: CustomUniformType {}
extension Direction2: CustomUniformType {}
extension Size2: CustomUniformType {}
extension Position3: CustomUniformType {}
extension Direction3: CustomUniformType {}
extension Size3: CustomUniformType {}
extension Matrix3x3: CustomUniformType {}
extension Matrix4x4: CustomUniformType {}
extension Array: CustomUniformType where Element == Matrix4x4 {}

public struct Material {
    public var vertexShader: VertexShader = SystemShaders.standardVertexShader
    public var fragmentShader: FragmentShader = SystemShaders.textureSampleFragmentShader
    
    private var customUniformValues: [String:any CustomUniformType] = [:]
    internal func sortedCustomUniforms() -> [any CustomUniformType] {
        return customUniformValues.sorted(by: {$0.key.compare($1.key) == .orderedAscending}).map({$0.value})
    }
    public mutating func setCustomUniformValue(_ value: any CustomUniformType, forUniform name: String) {
        customUniformValues[name] = value
    }
    
    internal var channels: [Channel] = [Channel(color: .defaultDiffuseMapColor)]
    public mutating func channel(_ index: UInt8, _ block: (inout Channel)->Void) {
        precondition(index <= channels.count, "index must be an existing channel or the next channel \(index)")
        if index == channels.count {
            channels.append(Channel(color: .clear))
        }
        block(&channels[Int(index)])
    }
    
    internal init() {
        
    }
    
    public init(color: Color) {
        self.channels[0] = Channel(color: color)
        self.fragmentShader = SystemShaders.materialColorFragmentShader
    }
    
    public init(texture: Texture) {
        self.channels[0] = Channel(color: .defaultDiffuseMapColor, texture: texture)
        self.fragmentShader = SystemShaders.textureSampleFragmentShader
    }
    
    public init(_ config: (_ material: inout Self)->()) {
        config(&self)
    }
        
    public struct Channel: Equatable {
        public var color: Color
        public var texture: Texture? = nil
        public var scale: Size2 = .one
        public var offset: Position2 = .zero
        public var sampleFilter: SampleFilter = .linear
        public enum SampleFilter: Equatable {
            case linear
            case nearest
        }
    }
    
    @MainActor @usableFromInline var isReady: Bool {
        for channel in channels {
            if let t = channel.texture, t.state != .ready  {
                return false
            }
        }
        return true
    }
    
    @MainActor internal var renderTargets: [any _RenderTargetProtocol] {
        var renderTargets: [any _RenderTargetProtocol] = []
        for channel in channels {
            if let texture = channel.texture, let renderTarget = texture.renderTarget {
                #if DEBUG
                assert(renderTargets.contains(where: {$0 === renderTarget}) == false)
                #endif
                renderTargets.append(renderTarget)
            }
        }
        return renderTargets
    }
}
