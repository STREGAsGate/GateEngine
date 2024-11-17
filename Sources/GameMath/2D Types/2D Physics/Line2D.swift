/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Line2D: Sendable {
    public var p1: Position2
    public var p2: Position2
    
    public init(_ p1: Position2, _ p2: Position2) {
        self.p1 = p1
        self.p2 = p2
    }
}

public extension Line2D {
    func pointNear(_ p: Position2) -> Position2 {
        let ab = p2 - p1
        let ap = p - p1
        
        var t = ap.dot(ab) / ab.squaredLength
        if t < 0 {t = 0}
        if t > 1 {t = 1}

        return p1 + (ab * t)
    }
    
    // TODO: This needs testing
    func intersection(of ray: Ray2D) -> Position2? {
        let v1 = ray.origin - p1
        let v2 = p2 - p1
        let v3 = Direction2(-ray.direction.y, ray.direction.x)
        
        let dot = v2.dot(v3)
        if abs(dot) < 0.000001 {
            return nil
        }
        
        let t1 = v2.cross(v1) / dot
        let t2 = v1.dot(v3) / dot
        
        if t1 >= 0.0 && (t2 >= 0.0 && t2 <= 1.0) {
            return ray.origin.moved(t1, toward: ray.direction)
        }

        return nil
    }
}
