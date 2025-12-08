/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Position3i = Position3n<Int>
public typealias Position3f = Position3n<Float>

@frozen
public struct Position3n<Scalar: Vector3n.ScalarType>: Vector3n {
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

public extension Position3n {
    @inlinable
    var xy: Position2n<Scalar> {
        get {
            return Position2n(x: x, y: y)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    
    @inlinable
    var xz: Position2n<Scalar> {
        get {
            return Position2n(x: x, y: z)
        }
        set {
            self.x = newValue.x
            self.z = newValue.y
        }
    }
}

public extension Position3n where Scalar: FloatingPoint {
    /** The distance between `from` and `self`
    - parameter from: A value representing the source position.
     */
    @_disfavoredOverload // <- prefer SIMD overloads
    @inlinable
    func distance(from: Self) -> Scalar {
        let difference = self - from
        let distance = difference.dot(difference)
        return distance.squareRoot()
    }
    
    @_disfavoredOverload // <- prefer SIMD overloads
    @inlinable
    func squaredDistance(from: Self) -> Scalar {
        let difference = self - from
        return pow(difference.x, 2) + pow(difference.y, 2) + pow(difference.z, 2)
    }

    /** Returns true when the distance from `self` and  `rhs` is less then `threshold`
    - parameter rhs: A value representing the destination position.
    - parameter threshold: The maximum distance that is considered "near".
     */
    @inlinable
    func isNear(_ rhs: Self, threshold: Scalar) -> Bool {
        return self.distance(from: rhs) < threshold
    }
}

public extension Position3n where Scalar: FloatingPoint {
    /** Creates a position a specified distance from self in a particular direction
    - parameter distance: The units away from `self` to create the new position.
    - parameter direction: The angle away from self to create the new position.
     */
    @inlinable
    func moved(_ distance: Scalar, toward direction: Direction3n<Scalar>) -> Self {
        return self + (direction.normalized * distance)
    }

    /** Moves `self` by a specified distance from in a particular direction
    - parameter distance: The units away to move.
    - parameter direction: The angle to move.
     */
    @inlinable
    mutating func move(_ distance: Scalar, toward direction: Direction3n<Scalar>) {
        self = moved(distance, toward: direction)
    }
}

public extension Position3n where Scalar: FloatingPoint {
    /** Creates a position by rotating self around an anchor point.
    - parameter origin: The anchor to rotate around.
    - parameter rotation: The direction and angle to rotate.
     */
    @inlinable
    func rotated(around anchor: Self = .zero, by rotation: Rotation3n<Scalar>) -> Self {
        let d = self.distance(from: anchor)
        return anchor.moved(d, toward: rotation.forward)
    }

    /** Rotates `self` around an anchor position.
     - parameter origin: The anchor to rotate around.
     - parameter rotation: The direction and angle to rotate.
     */
    @inlinable
    mutating func rotate(around anchor: Self = .zero, by rotation: Rotation3n<Scalar>) {
        self = rotated(around: anchor, by: rotation)
    }
}

extension Position3n: AdditiveArithmetic where Scalar: AdditiveArithmetic { }
extension Position3n: ExpressibleByIntegerLiteral where Scalar: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral & ExpressibleByIntegerLiteral { }
extension Position3n: ExpressibleByFloatLiteral where Scalar: FloatingPoint & _ExpressibleByBuiltinFloatLiteral & ExpressibleByFloatLiteral { }
extension Position3n: Equatable where Scalar: Equatable { }
extension Position3n: Hashable where Scalar: Hashable { }
extension Position3n: Comparable where Scalar: Comparable { }
extension Position3n: Sendable where Scalar: Sendable { }
extension Position3n: Codable where Scalar: Codable {
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
extension Position3n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Position3n: BinaryCodable where Self: BitwiseCopyable { }
