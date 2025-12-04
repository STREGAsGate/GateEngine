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
    public var geometries: OrderedSet<Geometry> = [] {
        didSet {
            resourcesState = .pending
        }
    }
    public var skinnedGeometries: OrderedSet<SkinnedGeometry> = [] {
        didSet {
            resourcesState = .pending
        }
    }
    
    public var lines: OrderedSet<Lines> = [] {
        didSet {
            resourcesState = .pending
        }
    }
    
    public var points: OrderedSet<Points> = [] {
        didSet {
            resourcesState = .pending
        }
    }

    public mutating func append(_ geomerty: Geometry) {
        self.geometries.append(geomerty)
    }

    public mutating func append(_ geomerty: SkinnedGeometry) {
        self.skinnedGeometries.append(geomerty)
    }
    
    public mutating func append(_ lines: Lines) {
        self.lines.append(lines)
    }
    
    public mutating func append(_ points: Points) {
        self.points.append(points)
    }

    public init() {}
    
    public init(geometries: OrderedSet<Geometry>, flags: SceneElementFlags = .default) {
        self.geometries = geometries
        self.flags = flags
    }
    
    public init(skinnedGeometries: OrderedSet<SkinnedGeometry>, flags: SceneElementFlags = .default) {
        self.skinnedGeometries = skinnedGeometries
        self.flags = flags
    }
    
    public var resourcesState: ResourceState = .pending
    public var resources: [any Resource] {
        var resources: [any Resource] = []
        resources.reserveCapacity(geometries.count + skinnedGeometries.count + points.count + lines.count)
        for geometry in geometries {
            resources.append(geometry)
        }
        for geometry in skinnedGeometries {
            resources.append(geometry)
        }
        for lines in lines {
            resources.append(lines)
        }
        for points in points {
            resources.append(points)
        }
        return resources
    }
    
    public static let componentID: ComponentID = ComponentID()
}
