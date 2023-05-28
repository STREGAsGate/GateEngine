/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

#if GameMathUseSIMD
public struct Direction3: Vector3, SIMD {
    public typealias Scalar = Float
    public typealias MaskStorage = SIMD3<Float>.MaskStorage
    public typealias ArrayLiteralElement = Scalar
    
    @usableFromInline
    var _storage = Float.SIMD4Storage()

    @inlinable
    public init(arrayLiteral elements: Self.ArrayLiteralElement...) {
        for index in elements.indices {
            _storage[index] = elements[index]
        }
    }
    
    @inlinable
    public var x: Scalar {
        @_transparent get {
            return _storage[0]
        }
        @_transparent set {
            _storage[0] = newValue
        }
    }
    @inlinable
    public var y: Scalar {
        @_transparent get {
            return _storage[1]
        }
        @_transparent set {
            _storage[1] = newValue
        }
    }
    @inlinable
    public var z: Scalar {
        @_transparent get {
            return _storage[2]
        }
        @_transparent set {
            _storage[2] = newValue
        }
    }
    
    @inlinable
    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}
#else
public struct Direction3: Vector3 {
    public var x: Float
    public var y: Float
    public var z: Float
    
    @inlinable
    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

#endif

public extension Direction3 {
    @_transparent
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
}

public extension Direction3  {
    @_transparent
    init(from position1: Position3, to position2: Position3) {
        self = Self(position2 - position1).normalized
    }
}

public extension Direction3  {
    @_transparent
    func angle(to rhs: Self) -> Radians {
        let v0 = self.normalized
        let v1 = rhs.normalized
        
        let dot = v0.dot(v1)
        return Radians(acos(dot / (v0.magnitude * v1.magnitude)))
    }
    @_transparent
    var angleAroundX: Radians {
        assert(isFinite)
        return Radians(atan2(y, z))
    }
    @_transparent
    var angleAroundY: Radians {
        assert(isFinite)
        return Radians(atan2(x, z))
    }
    @_transparent
    var angleAroundZ: Radians {
        assert(isFinite)
        return Radians(atan2(y, x))
    }
}

public extension Direction3 {
    @_transparent
    func rotated(by rotation: Quaternion) -> Self {
        let conjugate = rotation.normalized.conjugate
        let w = rotation * self * conjugate
        return w.direction
    }
    
    @_transparent
    func orthogonal() -> Self {
        let x = abs(self.x)
        let y = abs(self.y)
        let z = abs(self.z)
        
        let other: Direction3 = x < y ? (x < z ? .right : .forward) : (y < z ? .up : .forward)
        return self.cross(other)
    }
    
    @_transparent
    func reflected(off normal: Self) -> Self {
        let normal = normal.normalized
        let dn = -2 * self.dot(normal)
        return (normal * dn) + self
    }
    
    /// true if the difference in angles is less than 180°
    @_transparent
    func isFrontFacing(toward direction: Direction3) -> Bool {
        return (self.dot(direction) <= 0) == false
    }
}

public extension Direction3 {
    static let up = Self(x: 0, y: 1, z: 0)
    static let down = Self(x: 0, y: -1, z: 0)
    static var left = Self(x: -1, y: 0, z: 0)
    static var right = Self(x: 1, y: 0, z: 0)
    static var forward = Self(x: 0, y: 0, z: -1)
    static var backward = Self(x: 0, y: 0, z: 1)
}

#if !GameMathUseSIMD
public extension Direction3 {
    static let zero = Self(0)
}
#endif

extension Direction3: Hashable {}
extension Direction3: Codable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y, z])
    }

    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        self.init(values[0], values[1], values[2])
    }
}
