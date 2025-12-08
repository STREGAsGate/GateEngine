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
extension Position2n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Position2n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Position2n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Position2n: Equatable where Scalar: Equatable { }
extension Position2n: Hashable where Scalar: Hashable { }
extension Position2n: Comparable where Scalar: Comparable { }
extension Position2n: Sendable where Scalar: Sendable { }
extension Position2n: Codable where Scalar: Codable { }
extension Position2n: BinaryCodable where Scalar: BinaryCodable { }

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
extension Size2n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Size2n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Size2n: Equatable where Scalar: Equatable { }
extension Size2n: Hashable where Scalar: Hashable { }
extension Size2n: Comparable where Scalar: Comparable { }
extension Size2n: Sendable where Scalar: Sendable { }
extension Size2n: Codable where Scalar: Codable { }
extension Size2n: BinaryCodable where Scalar: BinaryCodable { }
public extension Size2n {
    @inlinable var width: Scalar { get{self.x} set{self.x = newValue} }
    @inlinable var height: Scalar { get{self.y} set{self.y = newValue} }
    
    @inlinable init(width: Scalar, height: Scalar) {
        self.init(x: width, y: height)
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

public extension Vector2n where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Scalar
    init(integerLiteral value: IntegerLiteralType) {
        self.init(x: value, y: value)
    }
}

public extension Vector2n where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral {
    typealias FloatLiteralType = Scalar
    init(floatLiteral value: FloatLiteralType) {
        self.init(x: value, y: value)
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
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals to avoid ambiguilty
    @inlinable
    static var zero: Self {Self(x: Scalar.zero, y: Scalar.zero)}
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
