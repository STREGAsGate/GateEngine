/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@_fixed_layout
public protocol Vector3n<Scalar> {
    typealias ScalarType = Numeric & SIMDScalar
    associatedtype Scalar: ScalarType
    
    var x: Scalar {nonmutating get mutating set}
    var y: Scalar {nonmutating get mutating set}
    var z: Scalar {nonmutating get mutating set}
    /**
     This value is padding to force power of 2 memory alignment.
     Some low level functions may manipulate this value, so it's readable.
     - note: This value is not encoded or decoded.
     */
    var w: Scalar {nonmutating get}
    
    init(x: Scalar, y: Scalar, z: Scalar)
}

public extension Vector3n {
    @safe // <- bitcast is checked with a precondition
    @inlinable
    @_transparent
    init<T: Vector3n>(_ vector: T) where T.Scalar == Scalar {
        #if !DISTRIBUTE
        // Strip in DISTRIBUTE builds, as this check would have been proven safe during
        // development and we don't want any lingering code for performance reasons.
        precondition(
            MemoryLayout<Self>.size == MemoryLayout<T.Scalar>.size * 4,
            "Type mismatch. Types conforming to Vector3n must have 4 scalars (x: Scalar, y: Scalar, z: Scalar, w: Scalar) and a fixed layout (@frozen)."
        )
        #endif
        
        // All Vector3n types have the same memory layout, so bitcast is safe
        self = unsafeBitCast(vector, to: Self.self)
    }
    
    @_transparent
    init(_ x: Scalar, _ y: Scalar, _ z: Scalar) {
        self.init(x: x, y: y, z: z)
    }
    
    @_transparent
    init(_ value: Scalar) {
        self.init(x: value, y: value, z: value)
    }
}

public extension Vector3n where Scalar: BinaryInteger {
    @inlinable
    init<T: Vector3n>(_ vector3n: T) where T.Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector3n.x),
            y: Scalar(vector3n.y),
            z: Scalar(vector3n.z)
        )
    }
    
    @_disfavoredOverload // <- Prefer skipping rounding, because the default rule is towardsZero which is the same as casting
    @inlinable
    init<T: Vector3n>(_ vector3n: T, roundingRule: FloatingPointRoundingRule = .towardZero) where T.Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector3n.x.rounded(roundingRule)),
            y: Scalar(vector3n.y.rounded(roundingRule)),
            z: Scalar(vector3n.z.rounded(roundingRule))
        )
    }
    
    @inlinable
    init<T: Vector3n>(_ vector3n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(vector3n.x),
            y: Scalar(vector3n.y),
            z: Scalar(vector3n.z)
        )
    }
    
    @inlinable
    init<T: Vector3n>(truncatingIfNeeded vector3n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(truncatingIfNeeded: vector3n.x),
            y: Scalar(truncatingIfNeeded: vector3n.y),
            z: Scalar(truncatingIfNeeded: vector3n.z)
        )
    }
    
    @inlinable
    init?<T: Vector3n>(exactly vector3n: T) where T.Scalar: BinaryInteger {
        guard let x = Scalar(exactly: vector3n.x), let y = Scalar(exactly: vector3n.y), let z = Scalar(exactly: vector3n.z) else {
            return nil
        }
        self.init(x: x, y: y, z: z)
    }
}

public extension Vector3n where Scalar: BinaryFloatingPoint {
    @inlinable
    init<T: Vector3n>(_ vector3n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(vector3n.x),
            y: Scalar(vector3n.y),
            z: Scalar(vector3n.z)
        )
    }
}

public extension Vector3n where Scalar: _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Scalar
    init(integerLiteral value: IntegerLiteralType) {
        self.init(x: value, y: value, z: value)
    }
}

public extension Vector3n where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral {
    typealias FloatLiteralType = Scalar
    init(floatLiteral value: FloatLiteralType) {
        self.init(x: value, y: value, z: value)
    }
}

public extension Vector3n where Scalar: AdditiveArithmetic {
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    @inlinable
    static func += (lhs: inout Self, rhs: some Vector3n<Scalar>) {
        lhs = lhs + rhs
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    @inlinable
    static func -= (lhs: inout Self, rhs: some Vector3n<Scalar>) {
        lhs = lhs - rhs
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x + rhs, y: lhs.y + rhs, z: lhs.z + rhs)
    }
    
    @inlinable
    static func += (lhs: inout Self, rhs: Scalar) {
       lhs = lhs + rhs
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x - rhs, y: lhs.y - rhs, z: lhs.z - rhs)
    }
    
    @inlinable
    static func -= (lhs: inout Self, rhs: Scalar) {
       lhs = lhs - rhs
    }
    
    @inlinable
    static func + (lhs: Scalar, rhs: Self) -> Self {
        return Self(x: lhs + rhs.x, y: lhs + rhs.y, z: lhs + rhs.z)
    }
    
    @inlinable
    static func - (lhs: Scalar, rhs: Self) -> Self {
        return Self(x: lhs - rhs.x, y: lhs - rhs.y, z: lhs - rhs.z)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals to avoid ambiguilty
    @inlinable
    static var zero: Self {Self(x: .zero, y: .zero, z: .zero)}
}

public extension Vector3n where Scalar: Numeric {
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }
    
    @inlinable
    static func *= (lhs: inout Self, rhs: some Vector3n<Scalar>) {
        lhs = lhs * rhs
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    @inlinable
    static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
    
    @inlinable
    static func * (lhs: Scalar, rhs: Self) -> Self {
        return Self(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }
}

public extension Vector3n where Scalar: SignedNumeric {
    prefix static func - (operand: Self) -> Self {
        return Self(x: -operand.x, y: -operand.y, z: -operand.z)
    }
    
    mutating func negate() {
        self = -self
    }
}

public extension Vector3n where Scalar: FloatingPoint {
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: some Vector3n<Scalar>) {
        lhs = lhs / rhs
    }
    
    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
    
    @inlinable
    static func / (lhs: Scalar, rhs: Self) -> Self {
        return Self(x: lhs / rhs.x, y: lhs / rhs.y, z: lhs / rhs.z)
    }
    
    @inlinable
    nonmutating func truncatingRemainder(dividingBy other: Scalar) -> Self {
        self.truncatingRemainder(dividingBy: Self(other))
    }
    
    @inlinable
    nonmutating func truncatingRemainder(dividingBy divisors: some Vector3n<Scalar>) -> Self {
        return Self(
            x: self.x.truncatingRemainder(dividingBy: divisors.x),
            y: self.y.truncatingRemainder(dividingBy: divisors.y),
            z: self.z.truncatingRemainder(dividingBy: divisors.z),
        )
    }
    
    @inlinable
    static var nan: Self {Self(x: .nan, y: .nan, z: .nan)}
    
    @inlinable
    static var infinity: Self {Self(x: .infinity, y: .infinity, z: .infinity)}
}

public extension Vector3n where Scalar: FixedWidthInteger {
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: some Vector3n<Scalar>) {
        lhs = lhs / rhs
    }
    
    @inlinable
    static func % (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x % rhs.x, y: lhs.y % rhs.y, z: lhs.z % rhs.z)
    }
    
    @inlinable
    static func %= (lhs: inout Self, rhs: some Vector3n<Scalar>) {
        lhs = lhs % rhs
    }
    
    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
    
    @inlinable
    static func % (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x % rhs, y: lhs.y % rhs, z: lhs.z % rhs)
    }
    
    @inlinable
    static func %= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs % rhs
    }
    
    @inlinable
    static func / (lhs: Scalar, rhs: Self) -> Self {
        return Self(x: lhs / rhs.x, y: lhs / rhs.y, z: lhs / rhs.z)
    }
    
    @inlinable
    static func % (lhs: Scalar, rhs: Self) -> Self {
        return Self(x: lhs % rhs.x, y: lhs % rhs.y, z: lhs % rhs.z)
    }
}

public extension Vector3n where Scalar: Comparable {
    @inlinable
    var min: Scalar {
        nonmutating get {
            return Swift.min(x, y, z)
        }
    }
    
    @inlinable
    var max: Scalar {
        nonmutating get {
            return Swift.max(x, y, z)
        }
    }
    
    @inlinable
    nonmutating func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        var x = self.x
        if x < lowerBound.x { x = lowerBound.x }
        if x > upperBound.x { x = upperBound.x }
        
        var y = self.y
        if y < lowerBound.y { y = lowerBound.y }
        if y > upperBound.y { y = upperBound.y }
        
        var z = self.z
        if z < lowerBound.z { z = lowerBound.z }
        if z > upperBound.z { z = upperBound.z }
        
        return Self(x: x, y: y, z: z)
    }
    
    @inlinable
    mutating func clamp(from lowerBound: Self, to upperBound: Self) {
        self = self.clamped(from: lowerBound, to: upperBound)
    }

    @inlinable
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y && lhs.z < rhs.z
    }
    
    @inlinable
    static func < (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x < rhs && lhs.y < rhs && lhs.z < rhs
    }
    
    @inlinable
    static func <= (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x <= rhs && lhs.y <= rhs && lhs.z <= rhs
    }
    
    @inlinable
    static func > (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x > rhs && lhs.y > rhs && lhs.z > rhs
    }
    
    @inlinable
    static func >= (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x >= rhs && lhs.y >= rhs && lhs.z >= rhs
    }
}

@inlinable
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar : Comparable, T.Scalar : SignedNumeric {
    return T(x: abs(vector.x), y: abs(vector.y), z: abs(vector.z))
}

public extension Vector3n where Scalar: Equatable {
    @inlinable
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    @inlinable
    static func == (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x == rhs && lhs.y == rhs && lhs.z == rhs
    }
    
    @inlinable
    static func != (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x != rhs && lhs.y != rhs && lhs.z != rhs
    }
}

public extension Vector3n where Scalar: Hashable {
    @inlinable
    nonmutating func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

public extension Vector3n {
    @inlinable
    nonmutating func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return (x * vector.x) + (y * vector.y) + (z * vector.z)
    }

    @inlinable
    nonmutating func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar, Scalar: SignedNumeric {
        return Self(
            y * vector.z - z * vector.y,
            z * vector.x - x * vector.z,
            x * vector.y - y * vector.x
        )
    }
}

public extension Vector3n {
    @inlinable
    var length: Scalar {
        nonmutating get {
            return x + y + z
        }
    }

    @inlinable
    var squaredLength: Scalar {
        nonmutating get {
            return x * x + y * y + z * z
        }
    }
}

public extension Vector3n where Scalar: FloatingPoint {
    @inlinable
    var magnitude: Scalar {
        nonmutating get {
            return squaredLength.squareRoot()
        }
    }
    
    @inlinable
    nonmutating func squareRoot() -> Self {
        return Self(x: x.squareRoot(), y: y.squareRoot(), z: z.squareRoot())
    }

    @inlinable
    mutating func normalize() {
        guard self != 0 else { return }
        let magnitude = self.magnitude
        let factor = 1 / magnitude
        self *= factor
    }
    
    @inlinable
    var normalized: Self {
        nonmutating get {
            var value = self
            value.normalize()
            return value
        }
    }
}

