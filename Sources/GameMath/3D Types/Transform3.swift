/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Transform3 {
    public var position: Position3 {
        @_transparent didSet {
            assert(position.isFinite)
            if _needsUpdate == false && oldValue != position {
                _needsUpdate = true
            }
        }
    }
    public var rotation: Quaternion {
        @_transparent didSet {
            assert(rotation.isFinite)
            if _needsUpdate == false && oldValue != rotation {
                _needsUpdate = true
            }
        }
    }
    public var scale: Size3 {
        @_transparent didSet {
            assert(scale.isFinite)
            if _needsUpdate == false && oldValue != scale {
                _needsUpdate = true
            }
        }
    }
    
    @usableFromInline
    var _needsUpdate: Bool = true
    @usableFromInline
    var _matrix: Matrix4x4! = nil
}

public extension Transform3 {
    @inlinable
    init(position: Position3 = .zero, rotation: Quaternion = .zero, scale: Size3 = .one) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    @_transparent
    var isFinite: Bool {
        return position.isFinite && scale.isFinite && rotation.isFinite
    }
}

public extension Transform3 {
    ///Returns a cached matrix, creating the cache if needed.
    @_transparent
    mutating func matrix() -> Matrix4x4 {
        if _needsUpdate {
            _matrix = self.createMatrix()
            _needsUpdate = false
        }
        return _matrix
    }
    
    ///Creates and returns a new matrix, or a cached matrix if the cache already exists.
    @_transparent
    func createMatrix() -> Matrix4x4 {
        if _needsUpdate == false {
            return _matrix
        }
        return Matrix4x4(position: self.position, rotation: self.rotation, scale: self.scale)
    }
}

extension Transform3: Equatable {
    @_transparent
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position && lhs.rotation == rhs.rotation && lhs.scale == rhs.scale
    }
}
extension Transform3: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(rotation)
        hasher.combine(scale)
    }
}

extension Transform3 {
    @_transparent
    public mutating func rotate(_ degrees: Degrees, direction: Direction3) {
        self.rotation = Quaternion(degrees, axis: direction) * self.rotation
    }
}

public extension Transform3 {
    static let `default` = Self(position: .zero, rotation: .zero, scale: .one)
}

extension Transform3 {
    @_transparent
    public func interpolated(to destination: Self, _ method: InterpolationMethod) -> Self {
        var copy = self
        copy.interpolate(to: destination, method)
        return copy
    }
    
    @_transparent
    public mutating func interpolate(to: Self, _ method: InterpolationMethod) {
        self.position.interpolate(to: to.position, method)
        self.rotation.interpolate(to: to.rotation, method)
        self.scale.interpolate(to: to.scale, method)
    }
    
    //TODO: Remove this. Position is the only value that is clear. Scale and rotation are confusing.
    @available(*, deprecated /*0.0.5*/, message: "This will be removed in a future update.")
    @_transparent
    public func difference(removing: Self) -> Self {
        var transform: Self = .default
        transform.position = self.position - removing.position
        transform.rotation = self.rotation * removing.rotation.inverse
        return transform
    }
}

extension Transform3 {
    @_transparent
    public func distance(from: Self) -> Float {
        return self.position.distance(from: from.position)
    }
}

//TODO: Remove operators. Position is the only value that is clear. Scale and rotation are confusing.
public extension Transform3 {
    @available(*, deprecated /*0.0.5*/, message: "This will be removed in a future update.")
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.position += rhs.position
        lhs.rotation = rhs.rotation * lhs.rotation
        lhs.rotation.normalize()
        lhs.scale = (lhs.scale + rhs.scale) / 2
    }
    @available(*, deprecated /*0.0.5*/, message: "This will be removed in a future update.")
    @_transparent
    static func +(lhs: Self, rhs: Self) -> Self {
        var lhsCopy = lhs
        lhsCopy += rhs
        return lhsCopy
    }
}

extension Transform3: Codable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([position.x, position.y, position.z,
                              rotation.w, rotation.x, rotation.y, rotation.z,
                              scale.x, scale.y, scale.z])
    }
    
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        
        self.position = Position3(x: values[0], y: values[1], z: values[2])
        self.rotation = Quaternion(w: values[3], x: values[4], y: values[5], z: values[6])
        self.scale = Size3(width: values[7], height: values[8], depth: values[9])
    }
}
