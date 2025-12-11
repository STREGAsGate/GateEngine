/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Size3i = Size3n<Int>
public typealias Size3u = Size3n<UInt>

public typealias Size3f = Size3n<Float32>
public typealias Size3d = Size3n<Float64>

@frozen
public struct Size3n<Scalar: Vector3n.ScalarType>: Vector3n {
    public var x: Scalar
    public var y: Scalar
    public var z: Scalar
    /**
     This value is padding to force power of 2 memory alignment.
     Some low level functions may manipulate this value, so it's readable.
     - note: This value is not encoded or decoded.
     */
    public let w: Scalar
    
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
        self.w = 0
    }
}

public extension Size3n {
    @inlinable
    var width: Scalar {
        nonmutating get { self.x }
        mutating set { self.x = newValue }
    }
    
    @inlinable
    var height: Scalar {
        nonmutating get { self.y }
        mutating set { self.y = newValue }
    }
    
    @inlinable
    var depth: Scalar {
        nonmutating get { self.z }
        mutating set { self.z = newValue }
    }
    
    @inlinable
    static var one: Self {
        return Self(x: 1, y: 1, z: 1)
    }
    
    @inlinable
    @_transparent
    init(width: Scalar, height: Scalar, depth: Scalar) {
        self.init(x: width, y: height, z: depth)
    }
}

extension Size3n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Size3n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Size3n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Size3n: Equatable where Scalar: Equatable { }
extension Size3n: Hashable where Scalar: Hashable { }
extension Size3n: Comparable where Scalar: Comparable { }
extension Size3n: Sendable where Scalar: Sendable { }
extension Size3n: Codable where Scalar: Codable {
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
extension Size3n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Size3n: BinaryCodable where Self: BitwiseCopyable { }
