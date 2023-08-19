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
        get {Scalar(representation: .vec4Value(self, 0), type: .float)}
        set {self._x = newValue}
    }
    public var y: Scalar {
        get {Scalar(representation: .vec4Value(self, 1), type: .float)}
        set {self._y = newValue}
    }
    public var z: Scalar {
        get {Scalar(representation: .vec4Value(self, 2), type: .float)}
        set {self._z = newValue}
    }
    public var w: Scalar {
        get {Scalar(representation: .vec4Value(self, 3), type: .float)}
        set {self._w = newValue}
    }
    
    public func xyz() -> Vec3 {
        return Vec3(x: Scalar(representation: .vec4Value(self, 0), type: .float),
                    y: Scalar(representation: .vec4Value(self, 1), type: .float),
                    z: Scalar(representation: .vec4Value(self, 2), type: .float))
    }
    
    public var r: Scalar {return x}
    public var g: Scalar {return y}
    public var b: Scalar {return z}
    public var a: Scalar {return w}
    
    public func rgb() -> Vec3 {
        return xyz()
    }
    
    public subscript (index: Int) -> Scalar {
        switch index {
        case 0: return self.x
        case 1: return self.y
        case 2: return self.z
        case 3: return self.w
        default: fatalError("Index out of range.")
        }
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
        self._x = Scalar(representation: .vec3Value(vec3, 0), type: .float)
        self._y = Scalar(representation: .vec3Value(vec3, 1), type: .float)
        self._z = Scalar(representation: .vec3Value(vec3, 2), type: .float)
        self._w = Scalar(w)
    }
    
    @inlinable
    public convenience init(_ color: Color) {
        self.init(r: color.red, g: color.green, b: color.blue, a: color.alpha)
    }
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = []
        values.append(contentsOf: valueRepresentation.identifier)
        values.append(contentsOf: valueType.identifier)
        if let operation {
            values.append(contentsOf: operation.documentIdentifierInputData())
        }
        if let _w {
            values.append(contentsOf: _w.documentIdentifierInputData())
        }
        if let _x {
            values.append(contentsOf: _x.documentIdentifierInputData())
        }
        if let _y {
            values.append(contentsOf: _y.documentIdentifierInputData())
        }
        if let _z {
            values.append(contentsOf: _z.documentIdentifierInputData())
        }
        return values
    }
    
    public func lerp(to dst: Vec4, factor: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
    
    public static func +(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
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
    
    public static func +=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    public static func *(lhs: Mat4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
}
