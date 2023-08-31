/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Line2D {
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
}
