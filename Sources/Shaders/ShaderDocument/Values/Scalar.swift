/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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
    
    internal init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
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
    
    public func lerp(to dst: Scalar, factor: Scalar) -> Scalar {
        return Scalar(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
    
    public static func +(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Scalar, rhs: Scalar) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    public static func +=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /=(lhs: inout Scalar, rhs: Scalar) {
        lhs = Scalar(Operation(lhs: lhs, operator: .divide, rhs: rhs))
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
