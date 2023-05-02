/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Vec4: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
    
    public let operation: Operation?
    
    internal var _x: Scalar?
    internal var _y: Scalar?
    internal var _z: Scalar?
    internal var _w: Scalar?
    
    public var x: Scalar {
        get {Scalar(representation: .vec4X(self), type: .float1)}
        set {self._x = newValue}
    }
    public var y: Scalar {
        get {Scalar(representation: .vec4Y(self), type: .float1)}
        set {self._y = newValue}
    }
    public var z: Scalar {
        get {Scalar(representation: .vec4Z(self), type: .float1)}
        set {self._z = newValue}
    }
    public var w: Scalar {
        get {Scalar(representation: .vec4W(self), type: .float1)}
        set {self._w = newValue}
    }
    
    public func xyz() -> Vec3 {
        return Vec3(x: Scalar(representation: .vec4X(self), type: .float1),
                    y: Scalar(representation: .vec4Y(self), type: .float1),
                    z: Scalar(representation: .vec4Z(self), type: .float1))
    }
    
    public var r: Scalar {return x}
    public var g: Scalar {return y}
    public var b: Scalar {return z}
    public var a: Scalar {return w}
    
    public func rgb() -> Vec3 {
        return xyz()
    }
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self._x = nil
        self._y = nil
        self._z = nil
        self._w = nil
    }
    
    internal init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
        self._z = nil
        self._w = nil
    }
    
    public convenience init(r: Float, g: Float, b: Float, a: Float) {
        self.init(x: r, y: g, z: b, w: a)
    }
    
    public convenience init(r: Scalar, g: Scalar, b: Scalar, a: Scalar) {
        self.init(x: r, y: g, z: b, w: a)
    }
    
    public convenience init(x: Float, y: Float, z: Float, w: Float) {
        self.init(x: Scalar(x), y: Scalar(y), z: Scalar(z), w: Scalar(w))
    }
    
    public init(x: Scalar, y: Scalar, z: Scalar, w: Scalar) {
        self.valueRepresentation = .vec4
        self.valueType = .float4
        self.operation = nil
        self._x = x
        self._y = y
        self._z = z
        self._w = w
    }
    
    public init(_ vec3: Vec3, _ w: Float) {
        self.valueRepresentation = .vec4
        self.valueType = .float4
        self.operation = nil
        self._x = Scalar(representation: .vec3X(vec3), type: .float1)
        self._y = Scalar(representation: .vec3Y(vec3), type: .float1)
        self._z = Scalar(representation: .vec3Z(vec3), type: .float1)
        self._w = Scalar(w)
    }
    
    @inlinable
    public convenience init(_ color: Color) {
        self.init(r: color.red, g: color.green, b: color.blue, a: color.alpha)
    }
    
    public func lerp(to dst: Vec4, factor: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
    
    public static func +(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    public static func *(lhs: Mat4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
}
