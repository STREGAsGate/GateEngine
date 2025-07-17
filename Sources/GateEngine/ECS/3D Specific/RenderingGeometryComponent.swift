/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor
public struct RenderingGeometryComponent: ResourceConstrainedComponent {
    /// Rendering options applied to all `geometries`
    public var flags: SceneElementFlags = .default

    /// Geometry references to draw
    public var geometries: Set<Geometry> = [] {
        didSet {
            resourcesState = .pending
        }
    }
    public var skinnedGeometries: Set<SkinnedGeometry> = [] {
        didSet {
            resourcesState = .pending
        }
    }

    public mutating func insert(_ geomerty: Geometry) {
        self.geometries.insert(geomerty)
    }

    public mutating func insert(_ geomerty: SkinnedGeometry) {
        self.skinnedGeometries.insert(geomerty)
    }

    public init() {}
    
    public init(geometries: Set<Geometry>, flags: SceneElementFlags = .default) {
        self.geometries = geometries
        self.flags = flags
    }
    
    public init(skinnedGeometries: Set<SkinnedGeometry>, flags: SceneElementFlags = .default) {
        self.skinnedGeometries = skinnedGeometries
        self.flags = flags
    }
    
    public var resourcesState: ResourceState = .pending
    public var resources: [any Resource] {
        var resources: [any Resource] = []
        resources.reserveCapacity(geometries.count + skinnedGeometries.count)
        for geometry in geometries {
            resources.append(geometry)
        }
        for geometry in skinnedGeometries {
            resources.append(geometry)
        }
        return resources
    }
    
    public static let componentID: ComponentID = ComponentID()
}
