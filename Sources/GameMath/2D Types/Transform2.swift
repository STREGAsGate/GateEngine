/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if GameMathUseSIMD
public struct Transform2: Sendable {
    public var position: Position2 {
        didSet {
            assert(position.isFinite)
            guard _needsUpdate == false else {return}
            if oldValue != position {
                _needsUpdate = true
            }
        }
    }
    public var rotation: Degrees {
        didSet {
            assert(rotation.isFinite)
            guard _needsUpdate == false else {return}
            if oldValue != rotation {
                _needsUpdate = true
            }
        }
    }
    public var scale: Size2 {
        didSet {
            assert(scale.isFinite)
            guard _needsUpdate == false else {return}
            if oldValue != scale {
                _needsUpdate = true
            }
        }
    }
    
    private var _needsUpdate: Bool = true
    private lazy var _matrix: Matrix4x4 = .identity
    private lazy var _rotationMatrix: Matrix4x4 = .identity
    private lazy var _scaleMatrix: Matrix4x4 = .identity
}
#else
public struct Transform2: Sendable {
    public var position: Position2 {
        didSet {
            assert(position.isFinite)
            guard _needsUpdate == false else {return}
            if oldValue != position {
                _needsUpdate = true
            }
        }
    }
    public var rotation: Degrees {
        didSet {
            assert(rotation.isFinite)
            guard _needsUpdate == false else {return}
            if oldValue != rotation {
                _needsUpdate = true
            }
        }
    }
    public var scale: Size2 {
        didSet {
            assert(scale.isFinite)
            guard _needsUpdate == false else {return}
            if oldValue != scale {
                _needsUpdate = true
            }
        }
    }
    
    private var _needsUpdate: Bool = true
    private lazy var _matrix: Matrix4x4 = .identity
    private lazy var _rotationMatrix: Matrix4x4 = .identity
    private lazy var _scaleMatrix: Matrix4x4 = .identity
}
#endif

public extension Transform2 {
    @inlinable
    init(position: Position2 = .zero, rotation: Degrees = 0, scale: Size2 = .one) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    @inlinable
    var isFinite: Bool {
        return position.isFinite && scale.isFinite && rotation.isFinite
    }
}

extension Transform2: Equatable {
    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position && lhs.rotation == rhs.rotation && lhs.scale == rhs.scale
    }
}
extension Transform2: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(rotation)
        hasher.combine(scale)
    }
}

extension Transform2 {
    public static let zero = Self(position: .zero, rotation: .zero, scale: .zero)
    
    public static let `default` = Self(position: .zero, rotation: .zero, scale: .one)
}

extension Transform2 {
    @inlinable
    public func interpolated(to destination: Self, _ method: InterpolationMethod) -> Self {
        var copy = self
        copy.interpolate(to: destination, method)
        return copy
    }
    
    @inlinable
    public mutating func interpolate(to: Self, _ method: InterpolationMethod) {
        self.position.interpolate(to: to.position, method)
        self.rotation.interpolate(to: to.rotation, method)
        self.scale.interpolate(to: to.scale, method)
    }
    
    @inlinable
    public func difference(removing: Self) -> Self {
        var transform: Self = .default
        transform.position = self.position - removing.position
        transform.rotation = self.rotation - removing.rotation
        return transform
    }
}

extension Transform2 {
    @inlinable
    public func distance(from: Self) -> Float {
        return self.position.distance(from: from.position)
    }
}

public extension Transform2 {
    @inlinable
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.position += rhs.position
        lhs.rotation = (lhs.rotation + rhs.rotation).normalized
        lhs.scale = (lhs.scale + rhs.scale) / 2
    }
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var lhsCopy = lhs
        lhsCopy += rhs
        return lhsCopy
    }
}

extension Transform2: Codable {
    @inlinable
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([position.x, position.y,
                              rotation.rawValue,
                              scale.x, scale.y])
    }
    
    @inlinable
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        
        self.position = Position2(x: values[0], y: values[1])
        self.rotation = Degrees(values[2])
        self.scale = Size2(width: values[3], height: values[4])
    }
}
