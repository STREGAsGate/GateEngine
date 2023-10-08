/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Vec2: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
    
    public let operation: Operation?
    
    internal var _x: Scalar?
    internal var _y: Scalar?
    
    public var x: Scalar {
        get {Scalar(representation: .vec2Value(self, 0), type: .float)}
        set {self._x = newValue}
    }
    public var y: Scalar {
        get {Scalar(representation: .vec2Value(self, 1), type: .float)}
        set {self._y = newValue}
    }
    
    public subscript (index: Int) -> Scalar {
        switch index {
        case 0: return self.x
        case 1: return self.y
        default: fatalError("Index out of range.")
        }
    }
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self._x = nil
        self._y = nil
    }
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
    }
    
    public convenience init(_ x: Float, _ y: Float) {
        self.init(x: x, y: y)
    }
    
    public init(x: Float, y: Float) {
        self.valueRepresentation = .vec2
        self.valueType = .float2
        self.operation = nil
        self._x = Scalar(x)
        self._y = Scalar(y)
    }
    
    public init(x: Scalar, y: Scalar) {
        self.valueRepresentation = .vec2
        self.valueType = .float2
        self.operation = nil
        self._x = x
        self._y = y
    }
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = [4_000]
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
        return values
    }
    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: .valueVec2)
    
    public func lerp(to dst: Vec2, factor: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
}

// Arithmatic
extension Vec2 {
    // Addition
    public static func +(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Vec2, rhs: Int) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Vec2, rhs: UInt) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Vec2, rhs: Float) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func +(lhs: Scalar, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Int, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: UInt, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Float, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    @_disfavoredOverload
    public static func +=(lhs: inout Vec2, rhs: Scalar) {
        lhs = Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Vec2, rhs: Int) {
        lhs = Vec2(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Vec2, rhs: UInt) {
        lhs = Vec2(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Vec2, rhs: Float) {
        lhs = Vec2(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    
    // Subtraction
    public static func -(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Vec2, rhs: Int) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Vec2, rhs: UInt) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Vec2, rhs: Float) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func -(lhs: Scalar, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Int, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: UInt, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Float, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -=(lhs: inout Vec2, rhs: Scalar) {
        lhs = Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout Vec2, rhs: Int) {
        lhs = Vec2(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Vec2, rhs: UInt) {
        lhs = Vec2(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Vec2, rhs: Float) {
        lhs = Vec2(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    
    // Multiplication
    public static func *(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Vec2, rhs: Int) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Vec2, rhs: UInt) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Vec2, rhs: Float) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func *(lhs: Scalar, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Int, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: UInt, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Float, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *=(lhs: inout Vec2, rhs: Scalar) {
        lhs = Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout Vec2, rhs: Int) {
        lhs = Vec2(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Vec2, rhs: UInt) {
        lhs = Vec2(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Vec2, rhs: Float) {
        lhs = Vec2(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }

    // Division
    public static func /(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Vec2, rhs: Int) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Vec2, rhs: UInt) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Vec2, rhs: Float) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    @_disfavoredOverload
    public static func /(lhs: Scalar, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Int, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: UInt, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Float, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /=(lhs: inout Vec2, rhs: Scalar) {
        lhs = Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout Vec2, rhs: Int) {
        lhs = Vec2(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Vec2, rhs: UInt) {
        lhs = Vec2(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Vec2, rhs: Float) {
        lhs = Vec2(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
}

extension Vec2 {
    public static func ==(lhs: Vec2, rhs: Vec2) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
    
    public static func !=(lhs: Vec2, rhs: Vec2) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: rhs))
    }
}

