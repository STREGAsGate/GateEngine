/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class UVec4: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
    
    public let operation: Operation?
    
    internal var _x: Scalar?
    internal var _y: Scalar?
    internal var _z: Scalar?
    internal var _w: Scalar?
    
    public var x: Scalar {
        return Scalar(representation: .uvec4Value(self, 0), type: .uint)
    }
    public var y: Scalar {
        return Scalar(representation: .uvec4Value(self, 1), type: .uint)
    }
    public var z: Scalar {
        return Scalar(representation: .uvec4Value(self, 2), type: .uint)
    }
    public var w: Scalar {
        return Scalar(representation: .uvec4Value(self, 3), type: .uint)
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
    
    public func xyz() -> Vec3 {
        return Vec3(x: Scalar(representation: .uvec4Value(self, 0), type: .uint),
                    y: Scalar(representation: .uvec4Value(self, 1), type: .uint),
                    z: Scalar(representation: .uvec4Value(self, 2), type: .uint))
    }
    
    public var r: Scalar { x }
    public var g: Scalar { y }
    public var b: Scalar { z }
    public var a: Scalar { w }
    
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
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
        self._z = nil
        self._w = nil
    }
    
    public convenience init(_ x: UInt, _ y: UInt, _ z: UInt, _ w: UInt) {
        self.init(x: x, y: y, z: z, w: w)
    }
    
    public convenience init(r: UInt, g: UInt, b: UInt, a: UInt) {
        self.init(x: r, y: g, z: b, w: a)
    }
    
    public convenience init(r: Scalar, g: Scalar, b: Scalar, a: Scalar) {
        self.init(x: r, y: g, z: b, w: a)
    }
    
    public convenience init(x: UInt, y: UInt, z: UInt, w: UInt) {
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

    public func lerp(to dst: UVec4, factor: Scalar) -> UVec4 {
        return UVec4(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
}

// Arithmatic
extension UVec4 {
    // Addition
    public static func +(lhs: UVec4, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +(lhs: UVec4, rhs: Scalar) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: UVec4, rhs: Int) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: UVec4, rhs: UInt) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: UVec4, rhs: Float) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func +(lhs: Scalar, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Int, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: UInt, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Float, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout UVec4, rhs: UVec4) {
        lhs = UVec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +=(lhs: inout UVec4, rhs: Scalar) {
        lhs = UVec4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout UVec4, rhs: Int) {
        lhs = UVec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout UVec4, rhs: UInt) {
        lhs = UVec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout UVec4, rhs: Float) {
        lhs = UVec4(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    
    // Subtraction
    public static func -(lhs: UVec4, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -(lhs: UVec4, rhs: Scalar) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: UVec4, rhs: Int) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: UVec4, rhs: UInt) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: UVec4, rhs: Float) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func -(lhs: Scalar, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Int, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: UInt, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Float, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout UVec4, rhs: UVec4) {
        lhs = UVec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -=(lhs: inout UVec4, rhs: Scalar) {
        lhs = UVec4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout UVec4, rhs: Int) {
        lhs = UVec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout UVec4, rhs: UInt) {
        lhs = UVec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout UVec4, rhs: Float) {
        lhs = UVec4(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    
    // Multiplication
    public static func *(lhs: UVec4, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *(lhs: UVec4, rhs: Scalar) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: UVec4, rhs: Int) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: UVec4, rhs: UInt) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: UVec4, rhs: Float) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func *(lhs: Scalar, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Int, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: UInt, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Float, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout UVec4, rhs: UVec4) {
        lhs = UVec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *=(lhs: inout UVec4, rhs: Scalar) {
        lhs = UVec4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout UVec4, rhs: Int) {
        lhs = UVec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout UVec4, rhs: UInt) {
        lhs = UVec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout UVec4, rhs: Float) {
        lhs = UVec4(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }

    // Division
    public static func /(lhs: UVec4, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /(lhs: UVec4, rhs: Scalar) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: UVec4, rhs: Int) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: UVec4, rhs: UInt) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: UVec4, rhs: Float) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func /(lhs: Scalar, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Int, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: UInt, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Float, rhs: UVec4) -> UVec4 {
        return UVec4(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout UVec4, rhs: UVec4) {
        lhs = UVec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /=(lhs: inout UVec4, rhs: Scalar) {
        lhs = UVec4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout UVec4, rhs: Int) {
        lhs = UVec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout UVec4, rhs: UInt) {
        lhs = UVec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout UVec4, rhs: Float) {
        lhs = UVec4(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
}

extension UVec4 {
    public static func ==(lhs: UVec4, rhs: UVec4) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
    
    public static func !=(lhs: UVec4, rhs: UVec4) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: rhs))
    }
}
