/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import Shaders

@MainActor
@dynamicMemberLookup
public final class MaterialComponent: ResourceConstrainedComponent {
    public var vertexShader: VertexShader? = nil
    public var fragmentShader: FragmentShader? = nil
    public var blendMode: DrawCommand.Flags.BlendMode = .normal
    
    public var material: Material {
        didSet {
            self.resourcesState = .pending
        }
    }
    
    // TODO: Remove abiguity
    // The type of value is used when building a shader. If an int literal is used and a float is needed the shader will not behave properly
    // Remove generic overloads and replace them with verbose named functions such as the "asFloat" below
    public func setCustomUniformValue(_ value: some CustomUniformType, forUniform name: String) {
        material.setCustomUniformValue(value, forUniform: name)
    }
    
    public func setCustomUniformValue(asFloat value: Float, forUniform name: String) {
        material.setCustomUniformValue(value, forUniform: name)
    }

    @discardableResult
    public func channel<ResultType>(_ index: UInt8, _ block: (_ channel: inout Material.Channel) -> ResultType) -> ResultType {
        return material.channel(index, block)
    }

    /// Set to `false` if this entity has transparency and then manually sort this object in your rendering system
    public var isOpaque: Bool = true

    public var shouldTransparencySort: Bool {
        return isOpaque == false  // || material.opacity < 1.0
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Material, T>) -> T {
        get { return material[keyPath: keyPath] }
        set { material[keyPath: keyPath] = newValue }
    }

    public init() {
        self.material = Material()
    }
    public init(config: (_ material: inout Material) -> Void) {
        self.material = Material()
        config(&self.material)
    }
    public init(vertexShader vsh: VertexShader? = nil, fragmentShader fsh: FragmentShader? = nil, _ material: Material) {
        self.vertexShader = vsh
        self.fragmentShader = fsh
        self.material = material
    }
    
    public var resourcesState: ResourceState = .pending
    public var resources: [any Resource] {
        var resources: [any Resource] = []
        for channel in material.channels {
            if let texture = channel.texture {
                resources.append(texture)
            }
        }
        return resources
    }
    
    public static let componentID: ComponentID = ComponentID()
}
