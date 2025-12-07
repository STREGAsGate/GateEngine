/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct TextureCoordinate: Vector2, Equatable, Hashable, Sendable {
    public var x: Float
    public var y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

public extension TextureCoordinate {
    @inlinable
    var u: Float {
        get {
            return x
        }
        mutating set {
            x = newValue
        }
    }
    @inlinable
    var v: Float {
        get {
            return y
        }
        mutating set {
            y = newValue
        }
    }
    
    @inlinable
    init(u: Float, v: Float) {
        self.init(x: u, y: v)
    }
}

public extension TextureCoordinate {
    @inlinable
    init(_ vector: some Vector2) {
        self.init(x: vector.x, y: vector.y)
    }
    
    @inlinable
    init<T: Vector2n>(_ vector: T) where T.Scalar == Float {
        self.init(x: vector.x, y: vector.y)
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

extension TextureCoordinate: Codable {}
extension TextureCoordinate: BinaryCodable {}
