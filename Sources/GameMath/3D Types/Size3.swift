/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD
public struct Size3: Vector3, SIMD, Sendable {
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
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }
}
#else
public struct Size3: Vector3, Sendable {
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

public extension Size3 {
    @inlinable
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
    
    @inlinable
    init(width x: Float, height y: Float, depth z: Float) {
        self.init(x: x, y: y, z: z)
    }
}

public extension Size3 {
    @inlinable
    var xy: Size2 {
        get {
            return Size2(x, y)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
}

public extension Size3 {
    #if !GameMathUseSIMD
    static let one = Self(width: 1, height: 1, depth: 1)
    static let zero = Self(0)
    #endif
    static let almostZero = Self(.ulpOfOne)
}

extension Size3 {
    @inlinable
    public var width: Float {
        get {
            return x
        }
        set(val) {
            x = val
        }
    }

    @inlinable
    public var height: Float {
        get {
            return y
        }
        set(val) {
            y = val
        }
    }

    @inlinable
    public var depth: Float {
        get {
            return z
        }
        set(val) {
            z = val
        }
    }
}

extension Size3: Hashable {}
extension Size3: Codable {
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y, z])
    }

    @inlinable
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        self.init(values[0], values[1], values[2])
    }
}
extension Size3: BinaryCodable {}
