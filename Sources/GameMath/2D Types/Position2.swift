/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD
public struct Position2: Vector2, Sendable {
    @usableFromInline
    var storage: SIMD2<Float>
    
    @inlinable
    public init(x: Float, y: Float) {
        self.storage = SIMD2(x: x, y: y)
    }
    
    @inlinable
    public var x: Float {
        get {
            return storage.x
        }
        set {
            storage.x = newValue
        }
    }
    
    @inlinable
    public var y: Float {
        get {
            return storage.y
        }
        set {
            storage.y = newValue
        }
    }
}
#else
public struct Position2: Vector2, Sendable {
    public var x: Float
    public var y: Float
    
    @inlinable
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}
#endif

extension Position2: Equatable {}
extension Position2: Hashable {}
extension Position2: Codable {}

public extension Position2 {
    @inlinable
    init(_ x: Float, _ y: Float) {
        self.init(x: x, y: y)
    }
    
    static let zero = Self(x: 0, y: 0)
}

public extension Position2 {
    @inlinable
    func distance(from: Self) -> Float {
        let difference = self - from
        let distance = difference.dot(difference)
        return distance.squareRoot()
    }
}


//Addition
extension Position2 {
    //Self:Self
    @inlinable
    public static func +(lhs: Self, rhs: Self) -> Self {
        return Self(lhs.x + rhs.x,
                    lhs.y + rhs.y)
    }
    @inlinable
    public static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}

//Subtraction
extension Position2 {
    //Self:Self
    @inlinable
    public static func -(lhs: Self, rhs: Self) -> Self {
        return Self(lhs.x - rhs.x,
                    lhs.y - rhs.y)
    }
    @inlinable
    public static func -=(lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
}

//Division
extension Position2 {
    //Self:Self
    @inlinable
    public static func /(lhs: Self, rhs: Self) -> Self {
        return Self(lhs.x / rhs.x,
                    lhs.y / rhs.y)
    }
    @inlinable
    public static func /=(lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

public extension Position2 {
    /** Creates a position a specified distance from self in a particular direction
    - parameter distance: The units away from `self` to create the new position.
    - parameter direction: The angle away from self to create the new position.
     */
    @inlinable
    func moved(_ distance: Float, toward direction: Direction2) -> Self {
        return self + (direction * distance)
    }

    /** Moves `self` by a specified distance from in a particular direction
    - parameter distance: The units away to move.
    - parameter direction: The angle to move.
     */
    @inlinable
    mutating func move(_ distance: Float, toward direction: Direction2) {
        self = moved(distance, toward: direction)
    }
}

public extension Position2 {
    /** Creates a position by rotating self around an anchor point.
    - parameter origin: The anchor to rotate around.
    - parameter rotation: The direction and angle to rotate.
     */
    @inlinable
    func rotated(around anchor: Self = .zero, by angle: Direction2) -> Self {
        var p = self - anchor
        let d = p.distance(from: .zero)
        p = p.moved(d, toward: angle.normalized)
        p += anchor
        return p
    }

    /** Rotates `self` around an anchor position.
     - parameter origin: The anchor to rotate around.
     - parameter rotation: The direction and angle to rotate.
     */
    @inlinable
    mutating func rotate(around anchor: Self = .zero, by angle: Direction2) {
        self = rotated(around: anchor, by: angle)
    }
}

public extension Position2 {
    @inlinable
    mutating func clamp(within rect: Rect) {
        self.x = .maximum(self.x, rect.x)
        self.x = .minimum(self.x, rect.maxX)
        self.y = .maximum(self.y, rect.y)
        self.y = .minimum(self.y, rect.maxY)
    }
    
    @inlinable
    func clamped(within rect: Rect) -> Position2 {
        var copy = self
        copy.clamp(within: rect)
        return copy
    }
}
