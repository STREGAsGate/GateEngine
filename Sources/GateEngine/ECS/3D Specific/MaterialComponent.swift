/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@dynamicMemberLookup
public final class MaterialComponent: Component {

    public var material: Material = Material()

    public func setCustomUniformValue(_ value: any CustomUniformType, forUniform name: String) {
        material.setCustomUniformValue(value, forUniform: name)
    }

    public func channel(_ index: UInt8, _ block: (_ channel: inout Material.Channel) -> Void) {
        material.channel(index, block)
    }

    /// Set to `false` if this entity has transparency and then manually sort this object in your rendering system
    public var isOpaque: Bool = true

    public var shouldTransparencySort: Bool {
        return isOpaque == false  // || material.opacity < 1.0
    }

    public init() {}
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Material, T>) -> T {
        get { return material[keyPath: keyPath] }
        set { material[keyPath: keyPath] = newValue }
    }

    public static let componentID: ComponentID = ComponentID()
}
