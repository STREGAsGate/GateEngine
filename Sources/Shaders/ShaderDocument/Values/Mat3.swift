/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Mat3: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
        
    public let operation: Operation?
    public let valueMatrix3x3: Matrix3x3?
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self.valueMatrix3x3 = nil
    }
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self.valueMatrix3x3 = nil
    }
    
    public init(_ matrix: Matrix3x3) {
        self.valueRepresentation = .mat4
        self.valueType = .float4x4
        self.operation = nil
        self.valueMatrix3x3 = matrix
    }

    public static func +(lhs: Mat3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Mat3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Mat3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Mat3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    //MARK: - Matrix3x3 Operations
    public static func +(lhs: Matrix3x3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: Mat3(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Mat3, rhs: Matrix3x3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .add, rhs: Mat3(rhs)))
    }
    
    public static func -(lhs: Matrix3x3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: Mat3(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Mat3, rhs: Matrix3x3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .subtract, rhs: Mat3(rhs)))
    }
    
    public static func *(lhs: Matrix3x3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: Mat3(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Mat3, rhs: Matrix3x3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .multiply, rhs: Mat3(rhs)))
    }
    
    public static func /(lhs: Matrix3x3, rhs: Mat3) -> Mat3 {
        return Mat3(Operation(lhs: Mat3(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Mat3, rhs: Matrix3x3) -> Mat3 {
        return Mat3(Operation(lhs: lhs, operator: .divide, rhs: Mat3(rhs)))
    }
    
    public static func ==(lhs: Mat3, rhs: Mat3) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
}
