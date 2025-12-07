/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Vector3n<Scalar> {
    typealias ScalarType = Numeric & SIMDScalar
    associatedtype Scalar: ScalarType
    associatedtype Vector3Counterpart: GameMath.Vector3
    
    var x: Scalar {get set}
    var y: Scalar {get set}
    var z: Scalar {get set}
    init(x: Scalar, y: Scalar, z: Scalar)
}

public typealias Position3i = Position3n<Int>
public typealias Position3f = Position3n<Float>
public struct Position3n<Scalar: Vector3n.ScalarType>: Vector3n {
    public typealias Vector3Counterpart = Position3
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar
    
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
}
extension Position3n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Position3n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Position3n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Position3n: Equatable where Scalar: Equatable { }
extension Position3n: Hashable where Scalar: Hashable { }
extension Position3n: Comparable where Scalar: Comparable { }
extension Position3n: Sendable where Scalar: Sendable { }
extension Position3n: Codable where Scalar: Codable { }
extension Position3n: BinaryCodable where Scalar: BinaryCodable { }

public typealias Size3i = Size3n<Int>
public typealias Size3f = Size3n<Float>
public struct Size3n<Scalar: Vector3n.ScalarType>: Vector3n {
    public typealias Vector3Counterpart = Size3
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar
    
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public static var one: Self { .init(x: 1, y: 1, z: 1) }
}
extension Size3n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Size3n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Size3n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Size3n: Equatable where Scalar: Equatable { }
extension Size3n: Hashable where Scalar: Hashable { }
extension Size3n: Comparable where Scalar: Comparable { }
extension Size3n: Sendable where Scalar: Sendable { }
extension Size3n: Codable where Scalar: Codable { }
extension Size3n: BinaryCodable where Scalar: BinaryCodable { }
public extension Size3n {
    @inlinable var width: Scalar { get{self.x} set{self.x = newValue} }
    @inlinable var height: Scalar { get{self.y} set{self.y = newValue} }
    @inlinable var depth: Scalar { get{self.z} set{self.z = newValue} }
    
    @inlinable init(width: Scalar, height: Scalar, depth: Scalar) {
        self.init(x: width, y: height, z: depth)
    }
}

extension Vector3n where Scalar: BinaryInteger {
    @inlinable
    public init<T: Vector3n>(_ vector3n: T) where T.Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector3n.x),
            y: Scalar(vector3n.y),
            z: Scalar(vector3n.z)
        )
    }
    
    @_disfavoredOverload
    @inlinable
    public init<T: Vector3n>(_ vector3n: T, roundingRule: FloatingPointRoundingRule = .towardZero) where T.Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector3n.x.rounded(roundingRule)),
            y: Scalar(vector3n.y.rounded(roundingRule)),
            z: Scalar(vector3n.z.rounded(roundingRule))
        )
    }
    
    @inlinable
    public init<T: Vector3n>(_ vector3n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(vector3n.x),
            y: Scalar(vector3n.y),
            z: Scalar(vector3n.z)
        )
    }
    
    @inlinable
    public init<T: Vector3n>(truncatingIfNeeded vector3n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(truncatingIfNeeded: vector3n.x),
            y: Scalar(truncatingIfNeeded: vector3n.y),
            z: Scalar(truncatingIfNeeded: vector3n.z)
        )
    }
    
    @inlinable
    public init?<T: Vector3n>(exactly vector3n: T) where T.Scalar: BinaryInteger {
        guard let x = Scalar(exactly: vector3n.x), let y = Scalar(exactly: vector3n.y), let z = Scalar(exactly: vector3n.z) else {
            return nil
        }
        self.init(x: x, y: y, z: z)
    }
}

extension Vector3n where Scalar: BinaryFloatingPoint {
    @inlinable
    public init<T: Vector3n>(_ vector3n: T) where T.Scalar: BinaryInteger {
        self.init(
            x: Scalar(vector3n.x),
            y: Scalar(vector3n.y),
            z: Scalar(vector3n.z)
        )
    }
}

extension Vector3n where Scalar: BinaryInteger {
    @inlinable
    public init(_ vector3: Vector3Counterpart) {
        self.init(
            x: Scalar(vector3.x),
            y: Scalar(vector3.y),
            z: Scalar(vector3.z)
        )
    }
    
    @inlinable
    public init(_ vector3: Vector3Counterpart, roundingRule: FloatingPointRoundingRule = .towardZero) where Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector3.x.rounded(roundingRule)),
            y: Scalar(vector3.y.rounded(roundingRule)),
            z: Scalar(vector3.z.rounded(roundingRule))
        )
    }
    
    @inlinable
    public var vector3: Vector3Counterpart {
        return Vector3Counterpart(Float(x), Float(y), Float(z))
    }
}

extension Vector3n where Scalar: BinaryFloatingPoint {
    @inlinable
    public init(_ vector3: Vector3Counterpart) {
        self.init(
            x: Scalar(vector3.x),
            y: Scalar(vector3.y),
            z: Scalar(vector3.z)
        )
    }
    
    @inlinable
    public init(_ vector3: Vector3Counterpart, roundingRule: FloatingPointRoundingRule) {
        self.init(
            x: Scalar(vector3.x.rounded(roundingRule)),
            y: Scalar(vector3.y.rounded(roundingRule)),
            z: Scalar(vector3.z.rounded(roundingRule))
        )
    }

    @inlinable
    public var vector3: Vector3Counterpart {
        return Vector3Counterpart(Float(x), Float(y), Float(z))
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
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z - rhs.z)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x + rhs, y: lhs.y + rhs, z: lhs.z - rhs)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x - rhs, y: lhs.y - rhs, z: lhs.z - rhs)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
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
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
}

public extension Vector3n where Scalar: SignedNumeric {
    prefix static func - (operand: Self) -> Self {
        return Self(x: -operand.x, y: -operand.y, z: -operand.z)
    }
    
    mutating func negate() -> Self {
        return Self(x: -x, y: -y, z: -z)
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
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
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
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    @_disfavoredOverload // <- Tell the compiler to prefer using integer literals
    @inlinable
    static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}

public extension Vector3n where Scalar: Comparable {
    @inlinable
    var min: Scalar {
        return Swift.min(x, Swift.min(y, z))
    }
    
    @inlinable
    var max: Scalar {
        return Swift.max(x, Swift.max(y, z))
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y && lhs.z < rhs.z
    }
}

@inlinable
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar : Comparable, T.Scalar : SignedNumeric {
    return T(x: abs(vector.x), y: abs(vector.y), z: abs(vector.z))
}

extension Vector3n where Scalar: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension Vector3n where Scalar: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

extension Vector3n where Scalar: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.x.encode(into: &data, version: version)
        try self.y.encode(into: &data, version: version)
        try self.z.encode(into: &data, version: version)
    }
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.init(
            x: try .init(decoding: data, at: &offset, version: version),
            y: try .init(decoding: data, at: &offset, version: version),
            z: try .init(decoding: data, at: &offset, version: version)
        )
    }
}
