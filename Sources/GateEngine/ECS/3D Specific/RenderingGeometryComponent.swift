/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class RenderingGeometryComponent: Component {
    /// Rendering options applied to all `geometries`
    public var flags: SceneElementFlags = .default
    
    /// Geometry references to draw
    public var geometry: Geometry? = nil
    public var skinnedGeometry: SkinnedGeometry? = nil
    
    public init() {}
    public static let componentID: ComponentID = ComponentID()
}
