/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Vector2n<Scalar> {
    typealias ScalarType = Numeric & SIMDScalar
    associatedtype Scalar: ScalarType
    associatedtype Vector2Counterpart: GameMath.Vector2
    
    var x: Scalar {get mutating set}
    var y: Scalar {get mutating set}
    init(x: Scalar, y: Scalar)
}

public typealias Position2i = Position2n<Int>
public typealias Position2f = Position2n<Float>
public struct Position2n<Scalar: Vector2n.ScalarType>: Vector2n {
    public typealias Vector2Counterpart = Position2
    public var x: Scalar
    public var y: Scalar
    
    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }
}
public extension Position2n where Scalar: FloatingPoint {
    /** Creates a position a specified distance from self in a particular direction
    - parameter distance: The units away from `self` to create the new position.
    - parameter direction: The angle away from self to create the new position.
     */
    @inlinable
    nonmutating func moved(_ distance: Scalar, toward direction: Direction2n<Scalar>) -> Self {
        return self + (direction.normalized * distance)
    }

    /** Moves `self` by a specified distance from in a particular direction
    - parameter distance: The units away to move.
    - parameter direction: The angle to move.
     */
    @inlinable
    mutating func move(_ distance: Scalar, toward direction: Direction2n<Scalar>) {
        self = moved(distance, toward: direction)
    }
}
extension Position2n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Position2n: Equatable where Scalar: Equatable { }
extension Position2n: Hashable where Scalar: Hashable { }
extension Position2n: Comparable where Scalar: Comparable { }
extension Position2n: Sendable where Scalar: Sendable { }
extension Position2n: Codable where Scalar: Codable { }
extension Position2n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Position2n: BinaryCodable where Self: BitwiseCopyable { }

public typealias Direction2i = Direction2n<Int>
public typealias Direction2f = Direction2n<Float>
public struct Direction2n<Scalar: Vector2n.ScalarType>: Vector2n {
    public typealias Vector2Counterpart = Size2
    public var x: Scalar
    public var y: Scalar
    
    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }
    
    public static var one: Self { .init(x: 1, y: 1) }
}
public extension Direction2n where Scalar: FloatingPoint {
    @inlinable
    init(from position1: Position2n<Scalar>, to position2: Position2n<Scalar>) {
        self = Self(position2 - position1).normalized
    }
}
extension Direction2n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Direction2n: Equatable where Scalar: Equatable { }
extension Direction2n: Hashable where Scalar: Hashable { }
extension Direction2n: Comparable where Scalar: Comparable { }
extension Direction2n: Sendable where Scalar: Sendable { }
extension Direction2n: Codable where Scalar: Codable { }
extension Direction2n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Direction2n: BinaryCodable where Self: BitwiseCopyable { }

public typealias Size2i = Size2n<Int>
public typealias Size2f = Size2n<Float>
public struct Size2n<Scalar: Vector2n.ScalarType>: Vector2n {
    public typealias Vector2Counterpart = Size2
    public var x: Scalar
    public var y: Scalar
    
    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }
    
    public static var one: Self { .init(x: 1, y: 1) }
}
extension Size2n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Size2n: Equatable where Scalar: Equatable { }
extension Size2n: Hashable where Scalar: Hashable { }
extension Size2n: Comparable where Scalar: Comparable { }
extension Size2n: Sendable where Scalar: Sendable { }
extension Size2n: Codable where Scalar: Codable { }
extension Size2n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Size2n: BinaryCodable where Self: BitwiseCopyable { }
public extension Size2n {
    @inlinable var width: Scalar { get{self.x} set{self.x = newValue} }
    @inlinable var height: Scalar { get{self.y} set{self.y = newValue} }
    
    @inlinable init(width: Scalar, height: Scalar) {
        self.init(x: width, y: height)
    }
}

public extension Vector2n {
    @safe // <- bitcast is checked with a precondition
    @inlinable
    @_transparent
    init<T: Vector2n>(_ vector: T) where T.Scalar == Scalar {
        #if !DISTRIBUTE
        // Strip in DISTRIBUTE builds, as this check would have been proven safe during
        // development and we don't want any lingering code for performance reasons.
        precondition(
            MemoryLayout<Self>.size == MemoryLayout<T.Scalar>.size * 2,
            "Type mismatch. Types conforming to Vector3n must have 4 scalars (x: Scalar, y: Scalar, z: Scalar, w: Scalar) and a fixed layout (@frozen)."
        )
        #endif
        
        // All Vector3n types have the same memory layout, so bitcast is safe
        self = unsafeBitCast(vector, to: Self.self)
    }
    
    @inlinable
    @_transparent
    init(_ x: Scalar, _ y: Scalar) {
        self.init(x: x, y: y)
    }
    
    @inlinable
    @_transparent
    init(_ value: Scalar) {
        self.init(x: value, y: value)
    }
}

extension Vector2n where Scalar: BinaryInteger {
    @inlinable
    public init(_ vector2n: some Vector2n<Scalar>) {
        self.init(
            x: vector2n.x,
            y: vector2n.y
        )
    }
    
    @inlinable
    public init<T: Vector2n>(_ vector2n: T) where T.Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector2n.x),
            y: Scalar(vector2n.y)
        )
    }
    
    @inlinable
    public init<T: Vector2n>(truncatingIfNeeded vector2n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(truncatingIfNeeded: vector2n.x),
            y: Scalar(truncatingIfNeeded: vector2n.y)
        )
    }
}

extension Vector2n where Scalar: BinaryFloatingPoint {
    @inlinable
    public init(_ vector2n: some Vector2n<Scalar>) {
        self.init(
            x: vector2n.x,
            y: vector2n.y
        )
    }
    
    @inlinable
    public init<T: Vector2n>(_ vector2n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(vector2n.x),
            y: Scalar(vector2n.y)
        )
    }
}

extension Vector2n where Scalar: BinaryInteger {
    @inlinable
    public init(_ vector2: Vector2Counterpart) {
        self.init(
            x: Scalar(vector2.x),
            y: Scalar(vector2.y)
        )
    }
    
    @inlinable
    public init(_ vector2: Vector2Counterpart, roundingRule: FloatingPointRoundingRule) {
        self.init(
            x: Scalar(vector2.x.rounded(roundingRule)),
            y: Scalar(vector2.y.rounded(roundingRule))
        )
    }
    
    @inlinable
    public var vector2: Vector2Counterpart {
        return Vector2Counterpart(Float(x), Float(y))
    }
}

extension Vector2n where Scalar: BinaryFloatingPoint {
    @inlinable
    public init(_ vector2: Vector2Counterpart) {
        self.init(
            x: Scalar(vector2.x),
            y: Scalar(vector2.y)
        )
    }
    
    @inlinable
    public init(_ vector2: Vector2Counterpart, roundingRule: FloatingPointRoundingRule) {
        self.init(
            x: Scalar(vector2.x.rounded(roundingRule)),
            y: Scalar(vector2.y.rounded(roundingRule)),
        )
    }

    @inlinable
    public var vector2: Vector2Counterpart {
        return Vector2Counterpart(Float(x), Float(y))
    }
}

public extension Vector2n where Scalar: AdditiveArithmetic {
    @inlinable
    static func + (lhs: Self, rhs: some Vector2n<Scalar>) -> Self {
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector2n<Scalar>) -> Self {
        return Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x - rhs, y: lhs.y - rhs)
    }
    
    @inlinable
    static var zero: Self {Self(x: .zero, y: .zero)}
}

public extension Vector2n where Scalar: Numeric {
    @inlinable
    static func * (lhs: Self, rhs: some Vector2n<Scalar>) -> Self {
        return Self(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    @inlinable
    static func *= (lhs: inout Self, rhs: some Vector2n<Scalar>) {
        lhs = lhs * rhs
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    @inlinable
    static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
    
    @inlinable
    init?<T: Vector2n>(exactly vector2n: T) where T.Scalar: BinaryInteger {
        guard let x = Scalar(exactly: vector2n.x), let y = Scalar(exactly: vector2n.y) else {
            return nil
        }
        self.init(x: x, y: y)
    }
}

public extension Vector2n where Scalar: SignedNumeric {
    prefix static func - (operand: Self) -> Self {
        return Self(x: -operand.x, y: -operand.y)
    }
    
    mutating func negate() -> Self {
        return Self(x: -x, y: -y)
    }
}

public extension Vector2n where Scalar: FloatingPoint {
    @inlinable
    static func / (lhs: Self, rhs: some Vector2n<Scalar>) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: some Vector2n<Scalar>) {
        lhs = lhs / rhs
    }
    
    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
    
    @inlinable
    nonmutating func truncatingRemainder(dividingBy other: Scalar) -> Self {
        self.truncatingRemainder(dividingBy: Self(other))
    }
    
    @inlinable
    nonmutating func truncatingRemainder(dividingBy divisors: some Vector2n<Scalar>) -> Self {
        return Self(
            x: self.x.truncatingRemainder(dividingBy: divisors.x),
            y: self.y.truncatingRemainder(dividingBy: divisors.y)
        )
    }
    
    @inlinable
    var isFinite: Bool {
        nonmutating get {
            return x.isFinite && y.isFinite
        }
    }
    
    @inlinable
    static var nan: Self {Self(x: .nan, y: .nan)}
    
    @inlinable
    static var infinity: Self {Self(x: .infinity, y: .infinity)}
}

public extension Vector2n where Scalar: FixedWidthInteger {
    @inlinable
    static func / (lhs: Self, rhs: some Vector2n<Scalar>) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: some Vector2n<Scalar>) {
        lhs = lhs / rhs
    }
    
    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}

public extension Vector2n where Scalar: Comparable {
    @inlinable
    var min: Scalar {
        return Swift.min(x, y)
    }
    
    @inlinable
    var max: Scalar {
        return Swift.max(x, y)
    }
    
    @inlinable
    static func < (lhs: Self, rhs: some Vector2n<Scalar>) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
}

@inlinable
public func abs<T: Vector2n>(_ vector: T) -> T where T.Scalar : Comparable, T.Scalar : SignedNumeric {
    return T(x: abs(vector.x), y: abs(vector.y))
}

extension Vector2n where Scalar: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: some Vector2n<Scalar>) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x == rhs && lhs.y == rhs
    }
    
    @inlinable
    public static func != (lhs: Self, rhs: Scalar) -> Bool {
        return lhs.x == rhs && lhs.y == rhs
    }
}

extension Vector2n where Scalar: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public extension Vector2n where Scalar: Comparable {
    @inlinable
    nonmutating func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        var x = self.x
        if x < lowerBound.x { x = lowerBound.x }
        if x > upperBound.x { x = upperBound.x }
        
        var y = self.y
        if y < lowerBound.y { y = lowerBound.y }
        if y > upperBound.y { y = upperBound.y }

        return Self(x: x, y: y)
    }
    
    @inlinable
    mutating func clamp(from lowerBound: Self, to upperBound: Self) {
        self = self.clamped(from: lowerBound, to: upperBound)
    }
}

public extension Vector2n {
    @inlinable
    nonmutating func dot<V: Vector2n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return (x * vector.x) + (y * vector.y)
    }
    
    @inlinable
    nonmutating func cross<V: Vector2n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return (x * vector.y) - (y * vector.x)
    }
}

public extension Vector2n {
    @inlinable
    var length: Scalar {
        nonmutating get {
            return x + y
        }
    }

    @inlinable
    var squaredLength: Scalar {
        nonmutating get {
            return x * x + y * y
        }
    }
}

public extension Vector2n where Scalar: FloatingPoint, Self: Equatable {
    @inlinable
    var magnitude: Scalar {
        nonmutating get {
            return squaredLength.squareRoot()
        }
    }
    
    @inlinable
    nonmutating func squareRoot() -> Self {
        return Self(x: x.squareRoot(), y: y.squareRoot())
    }

    @inlinable
    mutating func normalize() {
        guard self != Self.zero else { return }
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

extension Vector2n where Scalar: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.x.encode(into: &data, version: version)
        try self.y.encode(into: &data, version: version)
    }
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.init(
            x: try .init(decoding: data, at: &offset, version: version),
            y: try .init(decoding: data, at: &offset, version: version)
        )
    }
}
