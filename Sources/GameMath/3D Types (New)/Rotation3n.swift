/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Rotation3f = Rotation3n<Float32>
public typealias Rotation3d = Rotation3n<Float64>

/// A Quaternion
@frozen
public struct Rotation3n<Scalar: FloatingPoint & SIMDScalar> {    
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar
    public var w: Scalar
    
    public init(x: Scalar, y: Scalar, z: Scalar, w: Scalar) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

extension Rotation3n where Scalar: BinaryFloatingPoint {
    /**
     Initialize as degrees around `axis`
     - parameter angle: The angle to rotate
     - parameter axis: The direction to rotate around
     */
    @_disfavoredOverload // <- prefer values to be degrees
    @inlinable
    public init(_ angle: some Angle, axis: Direction3n<Scalar>) {
        let radians = Scalar(angle.rawValueAsRadians)
        let sinHalfAngle = sin(radians / 2.0)
        let cosHalfAngle = cos(radians / 2.0)

        self.init(
            x: axis.x * sinHalfAngle,
            y: axis.y * sinHalfAngle,
            z: axis.z * sinHalfAngle,
            w: cosHalfAngle
        )
    }
    
    /**
     Initialize as degrees around `axis`
     - parameter angle: The angle to rotate
     - parameter axis: The direction to rotate around
     */
    @inlinable
    public init(_ angle: Degrees, axis: Direction3n<Scalar>) {
        self.init(angle.asRadians, axis: axis)
    }
}

public extension Rotation3n where Scalar: BinaryFloatingPoint {
    @inlinable
    var pitch: Radians {
        return direction.angleAroundX
    }
    
    @inlinable
    var yaw: Radians {
        return direction.angleAroundY
    }
    
    @inlinable
    var roll: Radians {
        return direction.angleAroundZ
    }
}

public extension Rotation3n {
    @inlinable
    var direction: Direction3n<Scalar> {
        get {
            return Direction3n(x: x, y: y, z: z)
        }
        mutating set {
            self.x = newValue.x
            self.y = newValue.y
            self.z = newValue.z
        }
    }
    

    @inlinable
    var forward: Direction3n<Scalar> {
        return Direction3n<Scalar>.forward.rotated(by: self)
    }
    @inlinable
    var backward: Direction3n<Scalar> {
        return Direction3n<Scalar>.backward.rotated(by: self)
    }
    @inlinable
    var up: Direction3n<Scalar> {
        return Direction3n<Scalar>.up.rotated(by: self)
    }
    @inlinable
    var down: Direction3n<Scalar> {
        return Direction3n<Scalar>.down.rotated(by: self)
    }
    @inlinable
    var left: Direction3n<Scalar> {
        return Direction3n<Scalar>.left.rotated(by: self)
    }
    @inlinable
    var right: Direction3n<Scalar> {
        return Direction3n<Scalar>.right.rotated(by: self)
    }
}

extension Rotation3n {
    @inlinable
    public var length: Scalar {
        return x + y + z + w
    }
    
    @inlinable
    public var squaredLength: Scalar {
        return x * x + y * y + z * z + w * w
    }
    
    @inlinable
    public var magnitude: Scalar {
        return squaredLength.squareRoot()
    }

    @inlinable
    public var normalized: Self {
        var value = self
        value.normalize()
        return value
    }
    
    @inlinable
    public mutating func normalize() {
        guard self != .zero else { return }
        let magnitude = self.magnitude
        let factor = 1 / magnitude
        self *= factor
    }
    
    @inlinable
    public func squareRoot() -> Self {
        return Self(x: x.squareRoot(), y: y.squareRoot(), z: z.squareRoot(), w: w.squareRoot())
    }
    
    @inlinable
    var conjugate: Self {
        return Self(x: -x, y: -y, z: -z, w: w)
    }
}

extension Rotation3n: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    public static func + (lhs: Rotation3n<Scalar>, rhs: Rotation3n<Scalar>) -> Rotation3n<Scalar> {
        return Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, w: lhs.w + rhs.w)
    }
    
    public static func - (lhs: Rotation3n<Scalar>, rhs: Rotation3n<Scalar>) -> Rotation3n<Scalar> {
        return Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, w: lhs.w - rhs.w)
    }
    
    public static var zero: Rotation3n<Scalar> {
        return Self(x: .zero, y: .zero, z: .zero, w: 1)
    }
}

extension Rotation3n where Scalar: SignedNumeric {
    public static prefix func - (rhs: Rotation3n<Scalar>) -> Rotation3n<Scalar> {
        return rhs.conjugate
    }
    
    public mutating func negate() {
        self = self.conjugate
    }
}

extension Rotation3n {
    public static func * (lhs: Self, rhs: Self) -> Self {
        var x: Scalar = lhs.x * rhs.w
        x += lhs.w * rhs.x
        x += lhs.y * rhs.z
        x -= lhs.z * rhs.y
        var y: Scalar = lhs.y * rhs.w
        y += lhs.w * rhs.y
        y += lhs.z * rhs.x
        y -= lhs.x * rhs.z
        var z: Scalar = lhs.z * rhs.w
        z += lhs.w * rhs.z
        z += lhs.x * rhs.y
        z -= lhs.y * rhs.x
        var w: Scalar = lhs.w * rhs.w
        w -= lhs.x * rhs.x
        w -= lhs.y * rhs.y
        w -= lhs.z * rhs.z
        
        return Self(x: x, y: y, z: z, w: w)
    }
    
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

extension Rotation3n {
    public static func * (lhs: Self, rhs: Direction3n<Scalar>) -> Self {
        var x: Scalar =  lhs.w * rhs.x
        x += lhs.y * rhs.z
        x -= lhs.z * rhs.y
        var y: Scalar =  lhs.w * rhs.y
        y += lhs.z * rhs.x
        y -= lhs.x * rhs.z
        var z: Scalar =  lhs.w * rhs.z
        z += lhs.x * rhs.y
        z -= lhs.y * rhs.x
        var w: Scalar = -lhs.x * rhs.x
        w -= lhs.y * rhs.y
        w -= lhs.z * rhs.z
        return Self(x: x, y: y, z: z, w: w)
    }
    
    public static func *= (lhs: inout Self, rhs: Direction3n<Scalar>) {
        lhs = lhs * rhs
    }
}
    
extension Rotation3n {
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs, w: lhs.w * rhs)
    }
    
    public static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }

    public static func / (lhs: Self, rhs: Scalar) -> Self {
        return Self(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs, w: lhs.w / rhs)
    }
    
    public static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}

extension Rotation3n: Equatable where Scalar: Equatable { }
extension Rotation3n: Hashable where Scalar: Hashable { }
extension Rotation3n: Sendable where Scalar: Sendable { }
extension Rotation3n: Codable where Scalar: Codable { }
extension Rotation3n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Rotation3n: BinaryCodable where Self: BitwiseCopyable { }
