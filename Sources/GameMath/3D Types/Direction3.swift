/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD
public struct Direction3: Vector3, SIMD, Sendable {
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
        get {
            return _storage[0]
        }
        set {
            _storage[0] = newValue
        }
    }
    @inlinable
    public var y: Scalar {
        get {
            return _storage[1]
        }
        set {
            _storage[1] = newValue
        }
    }
    @inlinable
    public var z: Scalar {
        get {
            return _storage[2]
        }
        set {
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
public struct Direction3: Vector3, Sendable {
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
    @inlinable
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
}

public extension Direction3  {
    @inlinable
    init(from position1: Position3, to position2: Position3) {
        self = Self(position2 - position1).normalized
    }
}

public extension Direction3 {
    @inlinable
    var xy: Direction2 {
        get {
            return Direction2(x, y)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
}

public extension Direction3  {
    @_disfavoredOverload
    @inlinable
    func angle(to rhs: Self) -> Degrees {
        let v0 = self.normalized
        let v1 = rhs.normalized
        
        let dot = v0.dot(v1)
        return Degrees(rawValueAsRadians: acos(dot / (v0.magnitude * v1.magnitude)))
    }
    @inlinable
    func angle(to rhs: Self) -> Radians {
        let v0 = self.normalized
        let v1 = rhs.normalized
        
        let dot = v0.dot(v1)
        return Radians(rawValueAsRadians: acos(dot / (v0.magnitude * v1.magnitude)))
    }
    @inlinable
    var angleAroundX: Radians {
        assert(isFinite)
        return Radians(rawValueAsRadians: atan2(y, z))
    }
    @inlinable
    var angleAroundY: Radians {
        assert(isFinite)
        return Radians(rawValueAsRadians: atan2(x, z))
    }
    @inlinable
    var angleAroundZ: Radians {
        assert(isFinite)
        return Radians(rawValueAsRadians: atan2(y, x))
    }
}

public extension Direction3 {
    @inlinable
    func rotated(by rotation: Quaternion) -> Self {
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
        
        let other: Direction3 = x < y ? (x < z ? .right : .forward) : (y < z ? .up : .forward)
        return self.cross(other)
    }
    
    @inlinable
    func reflected(off normal: Self) -> Self {
        let normal = normal.normalized
        let dn = -2 * self.dot(normal)
        return (normal * dn) + self
    }
    
    /// true if the difference in angles is less than 180°
    @inlinable
    func isFrontFacing(toward direction: Direction3) -> Bool {
        return (self.dot(direction) <= 0) == false
    }
}

public extension Direction3 {
    static let up = Self(x: 0, y: 1, z: 0)
    static let down = Self(x: 0, y: -1, z: 0)
    static let left = Self(x: -1, y: 0, z: 0)
    static let right = Self(x: 1, y: 0, z: 0)
    static let forward = Self(x: 0, y: 0, z: -1)
    static let backward = Self(x: 0, y: 0, z: 1)
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
