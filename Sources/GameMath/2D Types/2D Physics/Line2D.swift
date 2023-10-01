/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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
        // get dot product of e1, e2
        let e1 = Position2(p2.x - p1.x, p2.y - p1.y)
        let e2 = Position2(p.x - p1.x, p.y - p1.y)
        let valDp = e1.dot(e2)
        // get squared length of e1
        let len2 = e1.squaredLength
        return Position2((p1.x + (valDp * e1.x) / len2),
                         (p1.y + (valDp * e1.y) / len2))
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
