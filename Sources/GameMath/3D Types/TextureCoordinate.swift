/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct TextureCoordinate: Vector2, Equatable, Hashable, Codable, Sendable {
    public var x: Float
    public var y: Float
    
    @inlinable
    public var u: Float {get{x}set{x = newValue}}
    @inlinable
    public var v: Float {get{y}set{y = newValue}}
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public extension TextureCoordinate {
    @inlinable
    func distance(from: Self) -> Float {
        let p1 = unsafeBitCast(self, to: Position2.self)
        let p2 = unsafeBitCast(from, to: Position2.self)
        return p1.distance(from: p2)
    }
}
