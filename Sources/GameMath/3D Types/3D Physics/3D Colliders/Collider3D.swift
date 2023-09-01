/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Collider3D {
    var center: Position3 {get}
    ///The translation difference from node centroid to geometry centroid
    var offset: Position3 {get}
    
    var position: Position3 {get}

    mutating func update(transform: Transform3)
    mutating func update(sizeAndOffsetUsingTransform transform: Transform3)
    
    func closestSurfacePoint(from point: Position3) -> Position3
    func interpenetration(comparing collider: Collider3D) -> Interpenetration3D?
    
    func surfacePoint(for ray: Ray3D) -> Position3?
    func surfaceNormal(facing point: Position3) -> Direction3
    func surfaceImpact(comparing ray: Ray3D) -> SurfaceImpact3D?
    
    var boundingBox: AxisAlignedBoundingBox3D {get}
}

public extension Collider3D {
    var position: Position3 {
        return center + offset
    }
}

public extension Collider3D {
    @inline(__always)
    func surfaceImpact(comparing ray: Ray3D) -> SurfaceImpact3D? {
        guard let point = self.surfacePoint(for: ray) else {return nil}
        let normal = self.surfaceNormal(facing: point)
        return SurfaceImpact3D(normal: normal, position: point)
    }
}

public struct Interpenetration3D {
    /// How far much the collider is penetrating.
    /// Negative values are inside positive values are outside.
    public var depth: Float
    
    /// The direction to move in ourder to resolve the penetration.
    /// This is typically a surface normal.
    public var direction: Direction3
    
    /// Points of intersection between the compared colliders
    public var points: Set<Position3>
    
    /// - returns true if the two compared colliders have penetration
    @inlinable @inline(__always)
    public var isColiding: Bool {
        return depth < -0.0001 && direction.isFinite && depth.isFinite
    }
    
    /// - returns true if the comparison can safely be used to determine penetration
    @inlinable @inline(__always)
    public var isValid: Bool {
        return depth.isFinite
        && direction.isFinite
        && points.isEmpty == false
        && points.first(where: {$0.isFinite == false}) == nil
    }
    
    public init(depth: Float, direction: Direction3, points: Set<Position3>) {
        self.depth = depth
        self.direction = direction
        self.points = points
    }
}

public struct SurfaceImpact3D: Surface3D {
    public internal(set) var normal: Direction3
    public internal(set) var position: Position3
}

public enum SurfaceType: Int {
    case wall
    case ceiling
    case ramp
    case floor

    ///True if an object can rest on this surface type
    public var isWalkable: Bool {
        switch self {
        case .floor, .ramp:
            return true
        case .wall, .ceiling:
            return false
        }
    }
}

public protocol Surface3D {
    var normal: Direction3 {get}
}

public extension Surface3D {
    @inline(__always)
    var surfaceType: SurfaceType {
        let angle: Radians = self.normal.angle(to: .up)
        switch angle.rawValue {
        case 0 ..< 0.523599:
            return .floor
        case 0.523599 ... 0.959931462601105:
            return .ramp
        case 2.70526 ... 3.14159:
            return .ceiling
        default:
            return .wall
        }
    }
}
