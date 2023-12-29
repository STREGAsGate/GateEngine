/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Scalar: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
    
    public let operation: Operation?
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
    }
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
    }
    
    public convenience init(_ scalar: Scalar, castTo valueType: ValueType) {
        self.init(Operation(scalar, castTo: valueType))
    }
    
    public init(_ bool: Bool) {
        self.valueRepresentation = .scalarBool(bool)
        self.valueType = .bool
        self.operation = nil
    }
    
    public init(_ int: Int) {
        self.valueRepresentation = .scalarInt(int)
        self.valueType = .int
        self.operation = nil
    }
    
    public init(_ uint: UInt) {
        self.valueRepresentation = .scalarUInt(uint)
        self.valueType = .uint
        self.operation = nil
    }
    
    public init(_ float: Float) {
        self.valueRepresentation = .scalarFloat(float)
        self.valueType = .float
        self.operation = nil
    }
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = []
        values.append(contentsOf: valueRepresentation.identifier)
        values.append(contentsOf: valueType.identifier)
        return values
    }
    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: .valueScalar)
    
    public func lerp(to dst: Scalar, factor: Scalar) -> Scalar {
        return Scalar(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
}

// Arithmatic
extension Scalar {
    // Addition
    @_disfavoredOverload
    public static func +(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func +(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +(lhs: Int, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: UInt, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Float, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .add, rhs: rhs))
    }
    public static func +=(lhs: inout Scalar, rhs: Int) {
        lhs = Scalar(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Scalar, rhs: UInt) {
        lhs = Scalar(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    public static func +=(lhs: inout Scalar, rhs: Float) {
        lhs = Scalar(Operation(lhs: lhs, operator: .add, rhs: Scalar(rhs)))
    }
    
    // Subtraction
    @_disfavoredOverload
    public static func -(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -(lhs: Int, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: UInt, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Float, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .subtract, rhs: rhs))
    }
    @_disfavoredOverload
    public static func -=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func -=(lhs: inout Scalar, rhs: Int) {
        lhs = Scalar(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Scalar, rhs: UInt) {
        lhs = Scalar(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    public static func -=(lhs: inout Scalar, rhs: Float) {
        lhs = Scalar(Operation(lhs: lhs, operator: .subtract, rhs: Scalar(rhs)))
    }
    
    // Multiplication
    @_disfavoredOverload
    public static func *(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *(lhs: Int, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: UInt, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Float, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .multiply, rhs: rhs))
    }
    @_disfavoredOverload
    public static func *=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func *=(lhs: inout Scalar, rhs: Int) {
        lhs = Scalar(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Scalar, rhs: UInt) {
        lhs = Scalar(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    public static func *=(lhs: inout Scalar, rhs: Float) {
        lhs = Scalar(Operation(lhs: lhs, operator: .multiply, rhs: Scalar(rhs)))
    }
    
    // Division
    @_disfavoredOverload
    public static func /(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /(lhs: Int, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: UInt, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Float, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: Scalar(lhs), operator: .divide, rhs: rhs))
    }
    @_disfavoredOverload
    public static func /=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    public static func /=(lhs: inout Scalar, rhs: Int) {
        lhs = Scalar(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Scalar, rhs: UInt) {
        lhs = Scalar(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
    public static func /=(lhs: inout Scalar, rhs: Float) {
        lhs = Scalar(Operation(lhs: lhs, operator: .divide, rhs: Scalar(rhs)))
    }
}

extension Scalar {
    public static func &&(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.and), rhs: rhs))
    }
    public static func ||(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.or), rhs: rhs))
    }
    
    @_disfavoredOverload
    public static func ==(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
    public static func ==(lhs: Scalar, rhs: Bool) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: Scalar(rhs)))
    }
    public static func ==(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: Scalar(rhs)))
    }
    public static func ==(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: Scalar(rhs)))
    }
    public static func ==(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: Scalar(rhs)))
    }
    
    @_disfavoredOverload
    public static func !=(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: rhs))
    }
    public static func !=(lhs: Scalar, rhs: Bool) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: Scalar(rhs)))
    }
    public static func !=(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: Scalar(rhs)))
    }
    public static func !=(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: Scalar(rhs)))
    }
    public static func !=(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.notEqual), rhs: Scalar(rhs)))
    }
    
    @_disfavoredOverload
    public static func >(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greater), rhs: rhs))
    }
    public static func >(lhs: Scalar, rhs: Bool) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greater), rhs: Scalar(rhs)))
    }
    public static func >(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greater), rhs: Scalar(rhs)))
    }
    public static func >(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greater), rhs: Scalar(rhs)))
    }
    public static func >(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greater), rhs: Scalar(rhs)))
    }
    
    @_disfavoredOverload
    public static func <(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.less), rhs: rhs))
    }
    public static func <(lhs: Scalar, rhs: Bool) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.less), rhs: Scalar(rhs)))
    }
    public static func <(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.less), rhs: Scalar(rhs)))
    }
    public static func <(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.less), rhs: Scalar(rhs)))
    }
    public static func <(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.less), rhs: Scalar(rhs)))
    }
    
    @_disfavoredOverload
    public static func >=(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greaterEqual), rhs: rhs))
    }
    public static func >=(lhs: Scalar, rhs: Bool) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greaterEqual), rhs: Scalar(rhs)))
    }
    public static func >=(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greaterEqual), rhs: Scalar(rhs)))
    }
    public static func >=(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greaterEqual), rhs: Scalar(rhs)))
    }
    public static func >=(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.greaterEqual), rhs: Scalar(rhs)))
    }
    
    @_disfavoredOverload
    public static func <=(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.lessEqual), rhs: rhs))
    }
    public static func <=(lhs: Scalar, rhs: Bool) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.lessEqual), rhs: Scalar(rhs)))
    }
    public static func <=(lhs: Scalar, rhs: Int) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.lessEqual), rhs: Scalar(rhs)))
    }
    public static func <=(lhs: Scalar, rhs: UInt) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.lessEqual), rhs: Scalar(rhs)))
    }
    public static func <=(lhs: Scalar, rhs: Float) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.lessEqual), rhs: Scalar(rhs)))
    }
    
    public static prefix func !(lhs: Scalar) -> Scalar {
        return Scalar(Operation(not: lhs))
    }
}

extension Scalar: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Bool
    public convenience init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension Scalar: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public convenience init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Scalar: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Float
    public convenience init(floatLiteral value: Float) {
        self.init(value)
    }
}
