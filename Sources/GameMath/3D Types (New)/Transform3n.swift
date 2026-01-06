/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public typealias Transform3f = Transform3n<Float32>
public typealias Transform3d = Transform3n<Float64>

public struct Transform3n<Scalar: Vector3n.ScalarType & BinaryFloatingPoint> {
    public var position: Position3n<Scalar> {
        didSet {
            assert(position.isFinite)
            if oldValue != position {
                _needsUpdate = true
            }
        }
    }
    public var rotation: Rotation3n<Scalar> {
        didSet {
            assert(rotation.isFinite)
            if oldValue != rotation {
                _needsUpdate = true
            }
        }
    }
    public var scale: Size3n<Scalar> {
        didSet {
            assert(scale.isFinite)
            if oldValue != scale {
                _needsUpdate = true
            }
        }
    }
    
    @usableFromInline
    var _needsUpdate: Bool = true
    @usableFromInline
    var _matrix: Matrix4x4? = nil
}

public extension Transform3n {
    @inlinable
    init(position: Position3n<Scalar> = .zero, rotation: Rotation3n<Scalar> = .zero, scale: Size3n<Scalar> = .one) {
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    @inlinable
    var isFinite: Bool {
        return position.isFinite && scale.isFinite && rotation.isFinite
    }
}

public extension Transform3n {
    @inlinable
    func moved(_ distance: Scalar, toward direction: Direction3n<Scalar>) -> Self {
        var result = self
        result.move(distance, toward: direction)
        return result
    }
    
    @inlinable
    mutating func move(_ distance: Scalar, toward direction: Direction3n<Scalar>) {
        self.position.move(distance, toward: direction)
    }
}

public extension Transform3n {
    /**
     Move this transform into a parent transform.
     
     This function will return a transfom that is adjusted to be inside the `parent` transform.
     For example: If this transform is a box, and parent transform is a room, then the resulting transform will be the transform of the box from within the room.
     
     - parameter parent: The transform that will be the parent space of this transform
     */
    func movedInside(_ parent: Self) -> Self {
        let mtx = parent.createMatrix() * self.createMatrix()
        return Self(position: .init(oldVector: mtx.position), rotation: .init(oldVector: mtx.rotation.conjugate), scale: .init(oldVector: mtx.scale))
    }
}

public extension Transform3n {
    @inlinable
    func rotated(by angle: some Angle, around axis: Direction3n<Scalar>) -> Self {
        var result = self
        result.rotate(by: angle, around: axis)
        return result
    }
    
    @inlinable
    mutating func rotate(by angle: some Angle, around axis: Direction3n<Scalar>) {
        self.rotation *= Rotation3n(angle, axis: axis)
    }
}

public extension Transform3n {
    ///Returns a cached matrix, creating the cache if needed.
    @inlinable
    @safe // <- _needsUpdate will always be true if _matrix has no value, so this is safe
    mutating func matrix() -> Matrix4x4 {
        if _needsUpdate {
            _matrix = self.createMatrix()
            _needsUpdate = false
        }
        return _matrix.unsafelyUnwrapped
    }
    
    ///Creates and returns a new matrix, or a cached matrix if the cache already exists.
    @inlinable
    @safe // _needsUpdate can only be true if _matrix has a value so this is safe
    func createMatrix() -> Matrix4x4 {
        if _needsUpdate == false {
            return _matrix.unsafelyUnwrapped
        }
        return Matrix4x4(position: self.position.oldVector, rotation: self.rotation.oldVector, scale: self.scale.oldVector)
    }
}

extension Transform3n: Equatable {
    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position && lhs.rotation == rhs.rotation && lhs.scale == rhs.scale
    }
}
extension Transform3n: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(rotation)
        hasher.combine(scale)
    }
}

extension Transform3n {
    @inlinable
    public mutating func rotate(_ degrees: Degrees, direction: Direction3n<Scalar>) {
        self.rotation = Rotation3n(degrees, axis: direction) * self.rotation
    }
}

public extension Transform3n {
    static var `default`: Self {Self(position: .zero, rotation: .zero, scale: .one)}
}

extension Transform3n {
    @inlinable
    public func distance(from: Self) -> Scalar {
        return self.position.distance(from: from.position)
    }
}

extension Transform3n: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([position.x, position.y, position.z,
                              rotation.x, rotation.y, rotation.z, rotation.w,
                              scale.x, scale.y, scale.z])
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Scalar>.self)
        
        self.position = Position3n(x: values[0], y: values[1], z: values[2])
        self.rotation = Rotation3n(x: values[3], y: values[4], z: values[5], w: values[6])
        self.scale = Size3n(width: values[7], height: values[8], depth: values[9])
    }
}

extension Transform3n: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.position.encode(into: &data, version: version)
        try self.rotation.encode(into: &data, version: version)
        try self.scale.encode(into: &data, version: version)
    }
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.position = try .init(decoding: data, at: &offset, version: version)
        self.rotation = try .init(decoding: data, at: &offset, version: version)
        self.scale = try .init(decoding: data, at: &offset, version: version)
    }
}
