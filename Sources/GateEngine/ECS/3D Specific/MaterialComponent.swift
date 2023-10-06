/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@dynamicMemberLookup
public final class MaterialComponent: Component {

    public var material: Material

    public func setCustomUniformValue(_ value: some CustomUniformType, forUniform name: String) {
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
    public init(_ material: Material) {
        self.material = material
    }
    
    public static let componentID: ComponentID = ComponentID()
}
