/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
import simd
#endif

#if GameMathUseSIMD
public struct Quaternion: Vector4, SIMD, Sendable {
    public typealias Scalar = Float
    public typealias MaskStorage = SIMD4<Float>.MaskStorage
    public typealias ArrayLiteralElement = Scalar
    
    @usableFromInline
    var _storage = Float.SIMD4Storage()
    
    @_transparent
    public var scalarCount: Int {_storage.scalarCount}

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
    public var w: Scalar {
        @_transparent get {
            return _storage[3]
        }
        @_transparent set {
            _storage[3] = newValue
        }
    }
    
    @inlinable
    public init() {
        
    }
    
    @inlinable
    public init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}
#else
public struct Quaternion: Vector4, Sendable {
    public var x, y, z, w: Float
    
    public init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}
#endif

public extension Quaternion {
    @_transparent
    init(x: Float, y: Float, z: Float, w: Float) {
        self.init(x, y, z, w)
    }
    
    @available(*, unavailable, message: "Use init(x:y:z:w:) (the w is at the end now)")
    init(w: Float, x: Float, y: Float, z: Float) {
        self.init(x, y, z, w)
    }
}

public extension Quaternion {
    @inlinable
    subscript (_ index: Int) -> Float {
        @_transparent get {
            switch index {
            case 0: return x
            case 1: return y
            case 2: return z
            case 3: return w
            default:
                fatalError("Index \(index) out of range \(0..<4) for type \(type(of: self))")
            }
        }
        @_transparent set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            case 3: w = newValue
            default:
                fatalError("Index \(index) out of range \(0..<4) for type \(type(of: self))")
            }
        }
    }
}

extension Quaternion {
    @_transparent
    public init(direction: Direction3, up: Direction3 = .up, right: Direction3 = .right) {
        self = Matrix3x3(direction: direction, up: up, right: right).rotation
    }
    
    @inlinable
    public init(between v1: Direction3, and v2: Direction3) {
        let cosTheta = v1.dot(v2)
        let k = (v1.squaredLength * v2.squaredLength).squareRoot()
        
        if cosTheta / k == -1 {
            self = Quaternion(Radians(0), axis: v1.orthogonal())
        }else{
            self = Quaternion(Radians(cosTheta + k), axis: v1.cross(v2))
        }
    }
    
    /**
     Initialize as degrees around `axis`
     - parameter degrees: The angle to rotate
     - parameter axis: The direction to rotate around
     */
    @inlinable
    public init(_ angle: some Angle, axis: Direction3) {
        // Will always be radians (because degrees is explicitly below), but leave ambiguous so degrees can use a literal
        let radians = angle.rawValueAsRadians
        let sinHalfAngle: Float = sin(radians / 2.0)
        let cosHalfAngle: Float = cos(radians / 2.0)
        
        x = axis.x * sinHalfAngle
        y = axis.y * sinHalfAngle
        z = axis.z * sinHalfAngle
        w = cosHalfAngle
    }
    
    /**
     Initialize as degrees around `axis`
     - parameter degrees: The angle to rotate
     - parameter axis: The direction to rotate around
     - note: Allows initialization with `degrees` as a literial. Example: `Quaternion(180, axis: .up)`.
     */
    @_transparent
    public init(_ degrees: Degrees, axis: Direction3) {
        self.init(Radians(degrees), axis: axis)
    }
    
    @inlinable
    public init(pitch: Degrees, yaw: Degrees, roll: Degrees) {
        let _pitch: Radians = Radians(pitch)
        let _yaw: Radians = Radians(yaw)
        let _roll: Radians = Radians(roll)
        let cy: Float = cos(_roll.rawValue * 0.5)
        let sy: Float = sin(_roll.rawValue * 0.5)
        let cp: Float = cos(_yaw.rawValue * 0.5)
        let sp: Float = sin(_yaw.rawValue * 0.5)
        let cr: Float = cos(_pitch.rawValue * 0.5)
        let sr: Float = sin(_pitch.rawValue * 0.5)

        self.x = sr * cp * cy - cr * sp * sy
        self.y = cr * sp * cy + sr * cp * sy
        self.z = cr * cp * sy - sr * sp * cy
        self.w = cr * cp * cy + sr * sp * sy
    }
}

extension Quaternion {
    @_transparent
    public init(rotationMatrix rot: Matrix4x4) {
        let trace: Float = rot.a + rot.f + rot.k
        
        if trace > 0 {
            let s: Float = 0.5 / (trace + 1.0).squareRoot()
            x = (rot.g - rot.j) * s
            y = (rot.i - rot.c) * s
            z = (rot.b - rot.e) * s
            w = 0.25 / s
        }else{
            if rot.a > rot.f && rot.a > rot.k {
                let s: Float = 2.0 * (1.0 + rot.a - rot.f - rot.k).squareRoot()
                x = 0.25 * s
                y = (rot.e + rot.b) / s
                z = (rot.i + rot.c) / s
                w = (rot.g - rot.j) / s
            }else if rot.f > rot.k {
                let s: Float = 2.0 * (1.0 + rot.f - rot.a - rot.k).squareRoot()
                x = (rot.e + rot.b) / s
                y = 0.25 * s
                z = (rot.j + rot.g) / s
                w = (rot.i - rot.c) / s
            }else{
                let s: Float = 2.0 * (1.0 + rot.k - rot.a - rot.f).squareRoot()
                x = (rot.i + rot.c) / s
                y = (rot.g + rot.j) / s
                z = 0.25 * s
                w = (rot.b - rot.e) / s
            }
        }
        
        //Normalize
        let length: Float = self.magnitude
        x /= length
        y /= length
        z /= length
        w /= length
    }
    
    @_transparent
    public init(rotationMatrix rot: Matrix3x3) {
        let trace: Float = rot.a + rot.f + rot.k
        
        if trace > 0 {
            let s: Float = 0.5 / (trace + 1.0).squareRoot()
            x = (rot.g - rot.j) * s
            y = (rot.i - rot.c) * s
            z = (rot.b - rot.e) * s
            w = 0.25 / s
        }else{
            if rot.a > rot.f && rot.a > rot.k {
                let s: Float = 2.0 * (1.0 + rot.a - rot.f - rot.k).squareRoot()
                x = 0.25 * s
                y = (rot.e + rot.b) / s
                z = (rot.i + rot.c) / s
                w = (rot.g - rot.j) / s
            }else if rot.f > rot.k {
                let s: Float = 2.0 * (1.0 + rot.f - rot.a - rot.k).squareRoot()
                x = (rot.e + rot.b) / s
                y = 0.25 * s
                z = (rot.j + rot.g) / s
                w = (rot.i - rot.c) / s
            }else{
                let s: Float = 2.0 * (1.0 + rot.k - rot.a - rot.f).squareRoot()
                x = (rot.i + rot.c) / s
                y = (rot.g + rot.j) / s
                z = 0.25 * s
                w = (rot.b - rot.e) / s
            }
        }
        
        //Normalize
        let length: Float = self.magnitude
        x /= length
        y /= length
        z /= length
        w /= length
    }
}

extension Quaternion {
    @_transparent
    public mutating func lookAt(_ target: Position3, from source: Position3) {
        let forwardVector: Position3 = (source - target).normalized
        let dot: Float = Direction3.forward.dot(forwardVector)
        
        if abs(dot - -1) < .ulpOfOne {
            self.w = .pi
            self.direction = .up
        }else if abs(dot - 1) < .ulpOfOne {
            self.w = 1
            self.direction = .zero
        }else{
            let angle: Float = acos(dot)
            let axis: Direction3 = .forward.cross(forwardVector).normalized
            
            let halfAngle: Float = angle * 0.5
            let s: Float = sin(halfAngle)
            x = axis.x * s
            y = axis.y * s
            z = axis.z * s
            w = cos(halfAngle)
        }
        self = self.conjugate
    }
}

extension Quaternion {
    public enum LookAtConstraint {
        case none
        case yaw
        case pitch
        case pitchAndYaw
    }
    
    @_transparent
    public init(lookingAt target: Position3, from source: Position3, up: Direction3 = .up, right: Direction3 = .right, constraint: LookAtConstraint, isCamera: Bool) {
        self.init(Direction3(from: source, to: target), up: up, right: right, constraint: constraint, isCamera: isCamera)
    }
    
    /**
     Creates a quaternion a forward direction and optionally constrained to an Euler angle.
     - Parameter direction: The forward axis
     - Parameter up: The relative up vector, default is  `Direction3.up`.
     - Parameter right: The relative right axis. Default value is  `Direction3.right`.
     - Parameter constraint: Limits the rotation to an Euler angle. Use this to look in directions without a roll.
     */
    @inlinable
    public init(_ direction: Direction3, up: Direction3 = .up, right: Direction3 = .right, constraint: LookAtConstraint, isCamera: Bool) {
        switch constraint {
        case .none:
            self.init(direction: direction, up: up, right: right)
        case .pitch:
            let magnitude = Direction2(x: direction.x, y: direction.z).magnitude
            let value = atan2(direction.y, magnitude)
            let angle: Radians
            if isCamera {
                angle = Radians(value)
            }else{
                angle = Radians(-value)
            }
            self.init(angle, axis: right)
        case .yaw:
            var angle = direction.angleAroundY
            if isCamera {
                angle += 180°
            }
            self.init(angle, axis: up)
        case .pitchAndYaw:
            self = Self(direction, up: up, right: right, constraint: .yaw, isCamera: isCamera)
                * Self(direction, up: up, right: right, constraint: .pitch, isCamera: isCamera)
        }
    }
}

public extension Quaternion {
    @_transparent
    var direction: Direction3 {
        get {
            return Direction3(x: x, y: y, z: z)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
            self.z = newValue.z
        }
    }
    
    @_transparent
    var forward: Direction3 {
        return Direction3.forward.rotated(by: self)
    }
    @_transparent
    var backward: Direction3 {
        return Direction3.backward.rotated(by: self)
    }
    @_transparent
    var up: Direction3 {
        return Direction3.up.rotated(by: self)
    }
    @_transparent
    var down: Direction3 {
        return Direction3.down.rotated(by: self)
    }
    @_transparent
    var left: Direction3 {
        return Direction3.left.rotated(by: self)
    }
    @_transparent
    var right: Direction3 {
        return Direction3.right.rotated(by: self)
    }
}

public extension Quaternion {
    static let zero = Self(Radians(0), axis: .forward)
    
    @_transparent
    var inverse: Self {
        var absoluteValue: Float = magnitude
        absoluteValue *= absoluteValue
        absoluteValue = 1 / absoluteValue
        
        let conjugateValue = conjugate
        
        let w: Float = conjugateValue.w * absoluteValue
        let vector = conjugateValue.direction * absoluteValue
        return Self(Radians(w), axis: vector)
    }
}

public extension Quaternion {
    @_transparent
    var conjugate: Self {
        return Self(x: -x, y: -y, z: -z, w: w)
    }
    @_transparent
    var transposed: Self {
        return Matrix4x4(rotation: self).transposed().rotation
    }
}

public extension Quaternion {
    @_transparent
    func interpolated(to: Self, _ method: InterpolationMethod) -> Self {
        switch method {
        case let .linear(factor, options):
            if options.contains(.shortest) {
                return self.slerped(to: to, factor: factor)
            }else{
                return self.lerped(to: to, factor: factor)
            }
        case let .easeIn(factor, options):
            let easeInFactor = 1 - cos((factor * .pi) / 2)
            if options.contains(.shortest) {
                return self.slerped(to: to, factor: easeInFactor)
            }else{
                return self.lerped(to: to, factor: easeInFactor)
            }
        case let .easeOut(factor, options):
            let easeOutFactor = sin((factor * .pi) / 2)
            if options.contains(.shortest) {
                return self.slerped(to: to, factor: easeOutFactor)
            }else{
                return self.lerped(to: to, factor: easeOutFactor)
            }
        case let .easeInOut(factor, options):
            let easeInOutFactor = -(cos(.pi * factor) - 1) / 2
            if options.contains(.shortest) {
                return self.slerped(to: to, factor: easeInOutFactor)
            }else{
                return self.lerped(to: to, factor: easeInOutFactor)
            }
        }
    }
    
    
    //let easeInOutFactor = -(cos(.pi * factor) - 1) / 2
    
    @_transparent
    mutating func interpolate(to: Self, _ method: InterpolationMethod) {
        self = self.interpolated(to: to, method)
    }
}

internal extension Quaternion {
    @_transparent @usableFromInline
    func lerped(to q2: Self, factor t: Float) -> Self {
        var qr: Quaternion = .zero
        
        let t_ = 1 - t
        qr.x = t_ * self.x + t * q2.x
        qr.y = t_ * self.y + t * q2.y
        qr.z = t_ * self.z + t * q2.z
        qr.w = t_ * self.w + t * q2.w
        
        return qr
    }
    
    @_transparent @usableFromInline
    mutating func lerp(to q2: Self, factor: Float) {
        self = self.lerped(to: q2, factor: factor)
    }
    
    @_transparent @usableFromInline
    func slerped(to destination: Self, factor t: Float) -> Self {
        // Adapted from javagl.JglTF
        
        let a: Self = self
        let b: Self = destination
        
        let aw: Float = a.w
        let ax: Float = a.x
        let ay: Float = a.y
        let az: Float = a.z
        
        var bw: Float = b.w
        var bx: Float = b.x
        var by: Float = b.y
        var bz: Float = b.z
        
        var dot: Float = ax * bx + ay * by + az * bz + aw * bw
        if dot < 0 {
            bx = -bx
            by = -by
            bz = -bz
            bw = -bw
            dot = -dot
        }
        var s0: Float
        var s1: Float
        if (1 - dot) > .ulpOfOne {
            let omega: Float = acos(dot)
            let invSinOmega = 1 / sin(omega)
            s0 = sin((1 - t) * omega) * invSinOmega
            s1 = sin(t * omega) * invSinOmega
        }else{
            s0 = 1 - t
            s1 = t
        }
        
        let rx = s0 * ax + s1 * bx
        let ry = s0 * ay + s1 * by
        let rz = s0 * az + s1 * bz
        let rw = s0 * aw + s1 * bw

        return Quaternion(x: rx, y: ry, z: rz, w: rw)
    }
    
    @_transparent @usableFromInline
    mutating func slerp(to qb: Self, factor: Float) {
        self = self.slerped(to: qb, factor: factor)
    }
}

public extension Quaternion {
    @_transparent
    static func *=(lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    @_transparent
    static func *(lhs: Self, rhs: Self) -> Self {
        var x: Float = lhs.x * rhs.w
        x += lhs.w * rhs.x
        x += lhs.y * rhs.z
        x -= lhs.z * rhs.y
        var y: Float = lhs.y * rhs.w
        y += lhs.w * rhs.y
        y += lhs.z * rhs.x
        y -= lhs.x * rhs.z
        var z: Float = lhs.z * rhs.w
        z += lhs.w * rhs.z
        z += lhs.x * rhs.y
        z -= lhs.y * rhs.x
        var w: Float = lhs.w * rhs.w
        w -= lhs.x * rhs.x
        w -= lhs.y * rhs.y
        w -= lhs.z * rhs.z
        
        return Self(x: x, y: y, z: z, w: w)
    }
    
    @_transparent
    static func *=<V: Vector2>(lhs: inout Self, rhs: V) {
        lhs = lhs * rhs
    }
    @_transparent
    static func *<V: Vector2>(lhs: Self, rhs: V) -> Self {

        var x: Float =  lhs.w * rhs.x
        x -= lhs.z * rhs.y
        var y: Float =  lhs.w * rhs.y
        y += lhs.z * rhs.x
        var z: Float =  lhs.x * rhs.y
        z -= lhs.y * rhs.x
        var w: Float = -lhs.x * rhs.x
        w -= lhs.y * rhs.y
        return Self(x: x, y: y, z: z, w: w)
    }
    
    @_transparent
    static func *=<V: Vector3>(lhs: inout Self, rhs: V) {
        lhs = lhs * rhs
    }
    @_transparent
    static func *<V: Vector3>(lhs: Self, rhs: V) -> Self {
        var x: Float =  lhs.w * rhs.x
        x += lhs.y * rhs.z
        x -= lhs.z * rhs.y
        var y: Float =  lhs.w * rhs.y
        y += lhs.z * rhs.x
        y -= lhs.x * rhs.z
        var z: Float =  lhs.w * rhs.z
        z += lhs.x * rhs.y
        z -= lhs.y * rhs.x
        var w: Float = -lhs.x * rhs.x
        w -= lhs.y * rhs.y
        w -= lhs.z * rhs.z
        return Self(x: x, y: y, z: z, w: w)
    }
}

//MARK: - SIMD
public extension Quaternion {
    @inlinable
    var simd: SIMD4<Float> {
        @_transparent get {
            return SIMD4<Float>(x, y, z, w)
        }
        @_transparent set {
            x = newValue[0]
            y = newValue[1]
            z = newValue[2]
            w = newValue[3]
        }
    }
}

extension Quaternion: Equatable {}
extension Quaternion: Hashable {}

extension Quaternion: Codable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y, z, w])
    }
    
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        
        self.x = values[0]
        self.y = values[1]
        self.z = values[2]
        self.w = values[3]
    }
}
