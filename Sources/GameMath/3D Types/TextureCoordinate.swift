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
    public var u: Float {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    @inlinable
    public var v: Float {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public extension TextureCoordinate {
    @inlinable
    func distance(from: Self) -> Float {
        let p1 = Position2(self.x, self.y)
        let p2 = Position2(from.x, from.y)
        return p1.distance(from: p2)
    }
}
