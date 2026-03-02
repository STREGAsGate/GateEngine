/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Rect3f = Rect3n<Float32>
public typealias Rect3d = Rect3n<Float64>

@frozen
public struct Rect3n<Scalar: Vector3n.ScalarType> {
    public var center: Position3n<Scalar>
    public var radius: Size3n<Scalar>

    public init(size: Size3n<Scalar>, center: Position3n<Scalar>) where Scalar: FixedWidthInteger {
        self.center = center
        self.radius = size / Size3n<Scalar>(width: 2, height: 2, depth: 2)
    }
    
    public init(size: Size3n<Scalar>, center: Position3n<Scalar>) where Scalar: FloatingPoint, Scalar: ExpressibleByFloatLiteral {
        self.init(radius: size * 0.5, center: center)
    }
    
    public init(radius: Size3n<Scalar>, center: Position3n<Scalar>) {
        self.center = center
        self.radius = radius
    }
}

public extension Rect3n {
    static var zero: Self {
        return .init(radius: .zero, center: .zero)
    }
}

extension Rect3n: Rect3nSurfaceMath where Scalar: Rect3nSurfaceMath.ScalarType { }
extension Rect3n: Ray3nIntersectable where Scalar: Ray3nIntersectable.ScalarType { }

extension Rect3n: Equatable where Scalar: Equatable { }
extension Rect3n: Hashable where Scalar: Hashable { }
extension Rect3n: Sendable where Scalar: Sendable { }
extension Rect3n: Codable where Scalar: Codable {
    enum CodingKeys: CodingKey {
        case c
        case r
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.center = try container.decode(Position3n<Scalar>.self, forKey: .c)
        self.radius = try container.decode(Size3n<Scalar>.self, forKey: .r)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.center, forKey: .c)
        try container.encode(self.radius, forKey: .r)
    }
}
extension Rect3n: BitwiseCopyable where Scalar: BitwiseCopyable { }
extension Rect3n: BinaryCodable where Self: BitwiseCopyable { }
