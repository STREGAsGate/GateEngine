/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Vec3: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
    
    public let operation: Operation?
    
    internal var _x: Scalar?
    internal var _y: Scalar?
    internal var _z: Scalar?
    
    public var x: Scalar {
        get {Scalar(representation: .vec3X(self), type: .float1)}
        set {self._x = newValue}
    }
    public var y: Scalar {
        get {Scalar(representation: .vec3Y(self), type: .float1)}
        set {self._y = newValue}
    }
    public var z: Scalar {
        get {Scalar(representation: .vec3Z(self), type: .float1)}
        set {self._z = newValue}
    }

    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self._x = nil
        self._y = nil
        self._z = nil
    }
    
    internal init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
        self._z = nil
    }
    
    public init(x: Float, y: Float, z: Float) {
        self.valueRepresentation = .vec3
        self.valueType = .float3
        self.operation = nil
        self._x = Scalar(x)
        self._y = Scalar(y)
        self._z = Scalar(z)
    }
    
    internal init(x: Scalar, y: Scalar, z: Scalar) {
        self.valueRepresentation = .vec3
        self.valueType = .float3
        self.operation = nil

        self._x = x
        self._y = y
        self._z = z
    }
    
    public func lerp(to dst: Vec3, factor: Scalar) -> Vec3 {
        return Vec3(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
    
    public static func +(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    public static func *(lhs: Mat4, rhs: Vec3) -> Vec3 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Vec4(rhs, 1.0))).xyz()
    }
}
