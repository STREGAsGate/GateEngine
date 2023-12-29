/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
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
        return Scalar(representation: .vec4Value(self, 0), type: .float)
    }
    public var y: Scalar {
        return Scalar(representation: .vec4Value(self, 1), type: .float)
    }
    public var z: Scalar {
        return Scalar(representation: .vec4Value(self, 2), type: .float)
    }
    public var w: Scalar {
        return Scalar(representation: .vec4Value(self, 3), type: .float)
    }
    
    public var xy: Vec2 {
        get {
            return Vec2(x: Scalar(representation: .vec4Value(self, 0), type: .float),
                        y: Scalar(representation: .vec4Value(self, 1), type: .float))
        }
    }
    
    public var xyz: Vec3 {
        get {
            return Vec3(x: Scalar(representation: .vec4Value(self, 0), type: .float),
                        y: Scalar(representation: .vec4Value(self, 1), type: .float),
                        z: Scalar(representation: .vec4Value(self, 2), type: .float))
        }
    }
    
    public var r: Scalar { x }
    public var g: Scalar { y }
    public var b: Scalar { z }
    public var a: Scalar { w }
    
    public var rgb: Vec3 { xyz }
    
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
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
        self._z = nil
        self._w = nil
    }
    
    public convenience init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.init(x: x, y: y, z: z, w: w)
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
    
    @_disfavoredOverload
    public init(_ vec3: Vec3, _ w: Float) {
        self.valueRepresentation = .vec4
        self.valueType = .float4
        self.operation = nil
        self._x = Scalar(representation: .vec3Value(vec3, 0), type: .float)
        self._y = Scalar(representation: .vec3Value(vec3, 1), type: .float)
        self._z = Scalar(representation: .vec3Value(vec3, 2), type: .float)
        self._w = Scalar(w)
    }
    
    public init(_ vec3: Vec3, _ w: Scalar) {
        self.valueRepresentation = .vec4
        self.valueType = .float4
        self.operation = nil
        self._x = Scalar(representation: .vec3Value(vec3, 0), type: .float)
        self._y = Scalar(representation: .vec3Value(vec3, 1), type: .float)
        self._z = Scalar(representation: .vec3Value(vec3, 2), type: .float)
        if w.valueType != .float {
            self._w = Scalar(w, castTo: .float)
        }else{
            self._w = w
        }
    }
    
    @inlinable
    public convenience init(_ color: Color) {
        self.init(r: color.red, g: color.green, b: color.blue, a: color.alpha)
    }
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = [2_000]
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
    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: .valueVec4)
    
    public func lerp(to dst: Vec4, factor: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
}

// Arithmatic
extension Vec4 {
    // Addition
    public static func +(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Vec4, rhs: Int) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Vec4, rhs: UInt) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Vec4, rhs: Float) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func +(lhs: Scalar, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Int, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: UInt, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Float, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +=(lhs: inout Vec4, rhs: Scalar) {
        lhs = Vec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Vec4, rhs: Int) {
        lhs = Vec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Vec4, rhs: UInt) {
        lhs = Vec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Vec4, rhs: Float) {
        lhs = Vec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    
    // Subtraction
    public static func -(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Vec4, rhs: Int) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Vec4, rhs: UInt) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Vec4, rhs: Float) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func -(lhs: Scalar, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Int, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: UInt, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Float, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -=(lhs: inout Vec4, rhs: Scalar) {
        lhs = Vec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout Vec4, rhs: Int) {
        lhs = Vec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Vec4, rhs: UInt) {
        lhs = Vec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Vec4, rhs: Float) {
        lhs = Vec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    
    // Multiplication
    public static func *(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Vec4, rhs: Int) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Vec4, rhs: UInt) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Vec4, rhs: Float) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func *(lhs: Scalar, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Int, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: UInt, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Float, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *=(lhs: inout Vec4, rhs: Scalar) {
        lhs = Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout Vec4, rhs: Int) {
        lhs = Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Vec4, rhs: UInt) {
        lhs = Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Vec4, rhs: Float) {
        lhs = Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Mat4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    
    // Division
    public static func /(lhs: Vec4, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /(lhs: Vec4, rhs: Scalar) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Vec4, rhs: Int) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Vec4, rhs: UInt) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Vec4, rhs: Float) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func /(lhs: Scalar, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Int, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: UInt, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Float, rhs: Vec4) -> Vec4 {
        return Vec4(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout Vec4, rhs: Vec4) {
        lhs = Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /=(lhs: inout Vec4, rhs: Scalar) {
        lhs = Vec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout Vec4, rhs: Int) {
        lhs = Vec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Vec4, rhs: UInt) {
        lhs = Vec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Vec4, rhs: Float) {
        lhs = Vec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
}

extension Vec4 {
    public static func ==(lhs: Vec4, rhs: Vec4) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
    
    public static func !=(lhs: Vec4, rhs: Vec4) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: rhs))
    }
}
