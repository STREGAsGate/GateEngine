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
        return Scalar(representation: .vec3Value(self, 0), type: .float)
    }
    public var y: Scalar {
        return Scalar(representation: .vec3Value(self, 1), type: .float)
    }
    public var z: Scalar {
        return Scalar(representation: .vec3Value(self, 2), type: .float)
    }
    
    public var r: Scalar { x }
    public var g: Scalar { y }
    public var b: Scalar { z }
    
    public subscript (index: Int) -> Scalar {
        switch index {
        case 0: return self.x
        case 1: return self.y
        case 2: return self.z
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
    }
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
        self._z = nil
    }
    
    public convenience init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
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
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = [3_000]
        values.append(contentsOf: valueRepresentation.identifier)
        values.append(contentsOf: valueType.identifier)
        if let operation {
            values.append(contentsOf: operation.documentIdentifierInputData())
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
    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: .valueVec3)
    
    public func lerp(to dst: Vec3, factor: Scalar) -> Vec3 {
        return Vec3(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
}

// Arithmatic
extension Vec3 {
    // Addition
    public static func +(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Vec3, rhs: Scalar) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Vec3, rhs: Int) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Vec3, rhs: UInt) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Vec3, rhs: Float) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Scalar, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Int, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: UInt, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Float, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Vec3, rhs: Vec3) {
        lhs = Vec3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +=(lhs: inout Vec3, rhs: Scalar) {
        lhs = Vec3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Vec3, rhs: Int) {
        lhs = Vec3(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Vec3, rhs: UInt) {
        lhs = Vec3(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Vec3, rhs: Float) {
        lhs = Vec3(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    
    // Subtraction
    public static func -(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Vec3, rhs: Scalar) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Vec3, rhs: Int) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Vec3, rhs: UInt) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Vec3, rhs: Float) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Scalar, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Int, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: UInt, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Float, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -=(lhs: inout Vec3, rhs: Vec3) {
        lhs = Vec3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -=(lhs: inout Vec3, rhs: Scalar) {
        lhs = Vec3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout Vec3, rhs: Int) {
        lhs = Vec3(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Vec3, rhs: UInt) {
        lhs = Vec3(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Vec3, rhs: Float) {
        lhs = Vec3(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    
    // Multiplication
    public static func *(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *(lhs: Vec3, rhs: Scalar) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Vec3, rhs: Int) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Vec3, rhs: UInt) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Vec3, rhs: Float) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func *(lhs: Scalar, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Int, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: UInt, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Float, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *=(lhs: inout Vec3, rhs: Vec3) {
        lhs = Vec3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *=(lhs: inout Vec3, rhs: Scalar) {
        lhs = Vec3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout Vec3, rhs: Int) {
        lhs = Vec3(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Vec3, rhs: UInt) {
        lhs = Vec3(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Vec3, rhs: Float) {
        lhs = Vec3(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Mat4, rhs: Vec3) -> Vec3 {
        return Vec4(Operation(lhs: lhs, operator: .multiply, rhs: Vec4(rhs, 1.0))).xyz
    }
    
    // Division
    public static func /(lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /(lhs: Vec3, rhs: Scalar) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Vec3, rhs: Int) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Vec3, rhs: UInt) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Vec3, rhs: Float) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func /(lhs: Scalar, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Int, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: UInt, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Float, rhs: Vec3) -> Vec3 {
        return Vec3(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /=(lhs: inout Vec3, rhs: Vec3) {
        lhs = Vec3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /=(lhs: inout Vec3, rhs: Scalar) {
        lhs = Vec3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout Vec3, rhs: Int) {
        lhs = Vec3(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Vec3, rhs: UInt) {
        lhs = Vec3(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Vec3, rhs: Float) {
        lhs = Vec3(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
}

extension Vec3 {
    public static func ==(lhs: Vec3, rhs: Vec3) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
    
    public static func !=(lhs: Vec3, rhs: Vec3) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: rhs))
    }
}
