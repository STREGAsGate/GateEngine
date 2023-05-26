/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension Rect {
    @inlinable @inline(__always)
    public func nearest(outsidePositionFrom circle: Circle) -> Position2 {
        var position = circle.center
        
        if intersects(circle) {
            if circle.center.x > center.x {//Go Right
                position.x = circle.center.x + circle.radius + (width/2)
            }else if circle.center.x < center.x {//Go Left
                position.x = circle.center.x - circle.radius - (width/2)
            }
            if circle.center.y > center.y {//Go Up
                position.y = circle.center.y - circle.radius - (height/2)
            }else if circle.center.y < center.y {//Go Down
                position.y = circle.center.y + circle.radius + (height/2)
            }
        }
        
        return position
    }

    @inlinable @inline(__always)
    public func intersects(_ rect: Rect) -> Bool {
        var part1: Bool {
            let lhs = abs(x - rect.x) * 2
            let rhs = width + rect.width
            return lhs <= rhs
        }
        var part2: Bool {
            let lhs = abs(y - rect.y) * 2
            let rhs = height + rect.height
            return lhs <= rhs
        }
        return part1 && part2
    }

    @inlinable @inline(__always)
    public func contains(_ position: Position2) -> Bool {
        if position.x < x || position.x > maxX {
            return false
        }
        if position.y < y || position.y > maxY {
            return false
        }
        return true
    }
    
    @inlinable @inline(__always)
    public func intersects(_ circle: Circle) -> Bool {
        let topLeft = Position2(x: circle.center.x - circle.radius, y: circle.center.y - circle.radius)
        if contains(topLeft) {
            return true
        }
        
        let topRight = Position2(x: circle.center.x + circle.radius, y: circle.center.y - circle.radius)
        if contains(topRight) {
            return true
        }
        
        let bottomLeft = Position2(x: circle.center.x - circle.radius, y: circle.center.y + circle.radius)
        if contains(bottomLeft) {
            return true
        }
        
        let bottomRight = Position2(x: circle.center.x + circle.radius, y: circle.center.y + circle.radius)
        if contains(bottomRight) {
            return true
        }
        
        return false
    }
}
