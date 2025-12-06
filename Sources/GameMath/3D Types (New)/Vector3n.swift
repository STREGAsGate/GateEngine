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
    public init(_ vector3: Vector3Counterpart) {
        self.init(
            x: Scalar(vector3.x),
            y: Scalar(vector3.y),
            z: Scalar(vector3.z)
        )
    }
    
    @inlinable
    public init(_ vector3: Vector3Counterpart, roundingRule: FloatingPointRoundingRule) where Scalar: BinaryFloatingPoint {
        self.init(
            x: Scalar(vector3.x.rounded(roundingRule)),
            y: Scalar(vector3.y.rounded(roundingRule)),
            z: Scalar(vector3.z.rounded(roundingRule))
        )
    }
    @inlinable
    public init(_ vector3: Vector3Counterpart, roundingRule: FloatingPointRoundingRule) where Scalar: BinaryInteger {
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

public extension Vector3n where Scalar: AdditiveArithmetic {
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    @inlinable
    static var zero: Self {Self(x: .zero, y: .zero, z: .zero)}
}

public extension Vector3n where Scalar: FloatingPoint {
    @inlinable
    static func / (lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

public extension Vector3n where Scalar: FixedWidthInteger {
    @inlinable
    static func / (lhs: Self, rhs: Self) -> Self {
        return Self(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    
    @inlinable
    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
}

public extension Vector3n where Scalar: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y && lhs.z < rhs.z
    }
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
