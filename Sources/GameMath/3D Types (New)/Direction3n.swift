/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Direction3f = Direction3n<Float>

@frozen
public struct Direction3n<Scalar: Vector3n.ScalarType>: Vector3n {
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar
    private let _pad: Scalar // Foce power of 2 size
    
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
        self._pad = 0
    }
}

public extension Direction3n where Scalar: FloatingPoint {
    @inlinable
    func rotated(by rotation: Rotation3n<Scalar>) -> Self {
        let conjugate = rotation.normalized.conjugate
        let w = rotation * self * conjugate
        return w.direction
    }
    
    /// This angles perpendicular angle
    @inlinable
    func orthogonal() -> Self {
        let x = abs(self.x)
        let y = abs(self.y)
        let z = abs(self.z)
        
        let other: Self = x < y ? (x < z ? .right : .forward) : (y < z ? .up : .forward)
        return self.cross(other)
    }
    
    @_disfavoredOverload // <- prefer SIMD overloads
    @inlinable
    func reflected(off normal: Self) -> Self {
        let normal = normal.normalized
        let dn = -2 * self.dot(normal)
        return (normal * dn) + self
    }
    
    /// true if the difference in angles is less than 180°
    @inlinable
    func isFrontFacing(toward direction: Self) -> Bool {
        return (self.dot(direction) <= 0) == false
    }
}

public extension Direction3n where Scalar: BinaryFloatingPoint {
    @inlinable
    func angle(to rhs: Self) -> Radians {
        let v0 = self.normalized
        let v1 = rhs.normalized
        
        let dot = v0.dot(v1)
        return Radians(rawValueAsRadians: acos(Float(dot / (v0.magnitude * v1.magnitude))))
    }
    
    @_disfavoredOverload // <- prefer using the overload returning Radians to reduce ambiguity
    @inlinable
    func angle<T: Angle>(to rhs: Self) -> T {
        let v0 = self.normalized
        let v1 = rhs.normalized
        
        let dot = v0.dot(v1)
        return T(rawValueAsRadians: acos(Float(dot / (v0.magnitude * v1.magnitude))))
    }
    
    @inlinable
    var angleAroundX: Radians {
        return Radians(rawValueAsRadians: atan2(Float(y), Float(z)))
    }
    @inlinable
    var angleAroundY: Radians {
        return Radians(rawValueAsRadians: atan2(Float(x), Float(z)))
    }
    @inlinable
    var angleAroundZ: Radians {
        return Radians(rawValueAsRadians: atan2(Float(y), Float(x)))
    }
}

public extension Direction3n {
    @inlinable static var up: Self {
        return Self(x: 0, y: 1, z: 0)
    }
    @inlinable static var down: Self {
        return Self(x: 0, y: -1, z: 0)
    }
    @inlinable static var left: Self {
        return Self(x: -1, y: 0, z: 0)
    }
    @inlinable static var right: Self {
        return Self(x: 1, y: 0, z: 0)
    }
    @inlinable static var forward: Self {
        return Self(x: 0, y: 0, z: -1)
    }
    @inlinable static var backward: Self {
        return Self(x: 0, y: 0, z: 1)
    }
}

public extension Direction3n where Scalar: FloatingPoint {
    @inlinable
    init(from position1: Position3n<Scalar>, to position2: Position3n<Scalar>) {
        self = Self(position2 - position1).normalized
    }
    
    @inlinable
    var normalized: Self {
        var copy = self
        copy.normalize()
        return copy
    }

    @_disfavoredOverload // <- prefer SIMD overloads
    @inlinable
    mutating func normalize() {
        guard self != Self.zero else { return }
        let magnitude = self.magnitude
        let factor = 1 / magnitude
        self *= factor
        
    }
}

extension Direction3n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Direction3n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Direction3n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Direction3n: Equatable where Scalar: Equatable { }
extension Direction3n: Hashable where Scalar: Hashable { }
extension Direction3n: Comparable where Scalar: Comparable { }
extension Direction3n: Sendable where Scalar: Sendable { }
extension Direction3n: Codable where Scalar: Codable {
    enum CodingKeys: CodingKey {
        case x
        case y
        case z
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Scalar.self, forKey: .x)
        let y = try container.decode(Scalar.self, forKey: .y)
        let z = try container.decode(Scalar.self, forKey: .z)
        self.init(x: x, y: y, z: z)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.x, forKey: .y)
        try container.encode(self.x, forKey: .z)
    }
}
extension Direction3n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Direction3n: BinaryCodable where Self: BitwiseCopyable { }
