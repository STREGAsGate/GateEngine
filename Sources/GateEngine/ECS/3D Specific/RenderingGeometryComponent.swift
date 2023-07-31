/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct RenderingGeometryComponent: Component {
    /// Rendering options applied to all `geometries`
    public var flags: SceneElementFlags = .default
    
    /// Geometry references to draw
    public var geometries: Set<Geometry> = []
    public var skinnedGeometries: Set<SkinnedGeometry> = []
    
    public mutating func insert(_ geomerty: Geometry) {
        self.geometries.insert(geomerty)
    }
    
    public mutating func insert(_ geomerty: SkinnedGeometry) {
        self.skinnedGeometries.insert(geomerty)
    }
    
    public init() {}
    public static let componentID: ComponentID = ComponentID()
}
