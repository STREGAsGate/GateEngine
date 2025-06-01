/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Transform3: Sendable {
    public var position: Position3 {
        didSet {
            assert(position.isFinite)
            if _needsUpdate == false && oldValue != position {
                _needsUpdate = true
            }
        }
    }
    public var rotation: Quaternion {
        didSet {
            assert(rotation.isFinite)
            if _needsUpdate == false && oldValue != rotation {
                _needsUpdate = true
            }
        }
    }
    public var scale: Size3 {
        didSet {
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
    
    @inlinable
    var isFinite: Bool {
        return position.isFinite && scale.isFinite && rotation.isFinite
    }
}

public extension Transform3 {
    @inlinable
    func moved(_ distance: Float, toward direction: Direction3) -> Transform3 {
        var result = self
        result.move(distance, toward: direction)
        return result
    }
    
    @inlinable
    mutating func move(_ distance: Float, toward direction: Direction3) {
        self.position.move(distance, toward: direction)
    }
}

public extension Transform3 {
    @inlinable
    func rotated(by angle: some Angle, around axis: Direction3) -> Transform3 {
        var result = self
        result.rotate(by: angle, around: axis)
        return result
    }
    
    @inlinable
    mutating func rotate(by angle: some Angle, around axis: Direction3) {
        self.rotation *= Quaternion(angle, axis: axis)
    }
}

public extension Transform3 {
    ///Returns a cached matrix, creating the cache if needed.
    @inlinable
    mutating func matrix() -> Matrix4x4 {
        if _needsUpdate {
            _matrix = self.createMatrix()
            _needsUpdate = false
        }
        return _matrix
    }
    
    ///Creates and returns a new matrix, or a cached matrix if the cache already exists.
    @inlinable
    func createMatrix() -> Matrix4x4 {
        if _needsUpdate == false {
            return _matrix
        }
        return Matrix4x4(position: self.position, rotation: self.rotation, scale: self.scale)
    }
}

extension Transform3: Equatable {
    @inlinable
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
    @inlinable
    public mutating func rotate(_ degrees: Degrees, direction: Direction3) {
        self.rotation = Quaternion(degrees, axis: direction) * self.rotation
    }
}

public extension Transform3 {
    static let `default` = Self(position: .zero, rotation: .zero, scale: .one)
}

extension Transform3 {
    @inlinable
    public func interpolated(to destination: Self, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) -> Self {
        var copy = self
        copy.interpolate(to: destination, method, options: options)
        return copy
    }
    
    @inlinable
    public mutating func interpolate(to: Self, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) {
        self.position.interpolate(to: to.position, method, options: options)
        self.rotation.interpolate(to: to.rotation, method, options: options)
        self.scale.interpolate(to: to.scale, method, options: options)
    }
}

extension Transform3 {
    @inlinable
    public func distance(from: Self) -> Float {
        return self.position.distance(from: from.position)
    }
}

extension Transform3: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([position.x, position.y, position.z,
                              rotation.x, rotation.y, rotation.z, rotation.w,
                              scale.x, scale.y, scale.z])
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        
        self.position = Position3(x: values[0], y: values[1], z: values[2])
        self.rotation = Quaternion(x: values[3], y: values[4], z: values[5], w: values[6])
        self.scale = Size3(width: values[7], height: values[8], depth: values[9])
    }
}
