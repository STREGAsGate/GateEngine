/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Collider2D: Codable {
    var center: Position2 {get}
    ///The translation difference from node centroid to geometry centroid
    var offset: Position2 {get}
    
    var position: Position2 {get}

    mutating func update(transform: Transform2)
    
    func closestSurfacePoint(from point: Position2) -> Position2
    func interpenetration(comparing collider: Collider2D) -> Interpenetration2D?
    
    func surfacePoint(for ray: Ray2D) -> Position2?
    func surfaceNormal(facing point: Position2) -> Direction2
    func surfaceImpact(comparing ray: Ray2D) -> SurfaceImpact2D?
    
    var volume: Float {get}
}

public extension Collider2D {
    var position: Position2 {
        return center + offset
    }
}

public extension Collider2D {
    func surfaceImpact(comparing ray: Ray2D) -> SurfaceImpact2D? {
        guard let point = self.surfacePoint(for: ray) else {return nil}
        let normal = self.surfaceNormal(facing: point)
        return SurfaceImpact2D(normal: normal, position: point)
    }
}

public struct Interpenetration2D {
    public var depth: Float
    public var direction: Direction2
    public var points: Set<Position2>
    public var isColiding: Bool {
        return depth < 0 && direction.isFinite && depth.isFinite
    }
    public var isValid: Bool {
        return depth.isFinite
        && direction.isFinite
        && points.first(where: {$0.isFinite == false}) == nil
    }

    public init(depth: Float, direction: Direction2, points: Set<Position2>) {
        self.depth = depth
        self.direction = direction
        self.points = points
    }
}

public struct SurfaceImpact2D {
    public internal(set) var normal: Direction2
    public internal(set) var position: Position2
}
