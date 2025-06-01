/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public import GameMath

public final class Mat4: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
        
    public let operation: Operation?
    public let valueMatrix4x4: Matrix4x4?
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self.valueMatrix4x4 = nil
    }
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self.valueMatrix4x4 = nil
    }
    
    public init(_ matrix: Matrix4x4) {
        self.valueRepresentation = .mat4
        self.valueType = .float4x4
        self.operation = nil
        self.valueMatrix4x4 = matrix
    }

    public static func +(lhs: Mat4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Mat4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Mat4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Mat4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    //MARK: - Matrix4x4 Operations
    public static func +(lhs: Matrix4x4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: Mat4(lhs), operator: .add, rhs: rhs))
    }
    public static func +(lhs: Mat4, rhs: Matrix4x4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .add, rhs: Mat4(rhs)))
    }
    
    public static func -(lhs: Matrix4x4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: Mat4(lhs), operator: .subtract, rhs: rhs))
    }
    public static func -(lhs: Mat4, rhs: Matrix4x4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .subtract, rhs: Mat4(rhs)))
    }
    
    public static func *(lhs: Matrix4x4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: Mat4(lhs), operator: .multiply, rhs: rhs))
    }
    public static func *(lhs: Mat4, rhs: Matrix4x4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .multiply, rhs: Mat4(rhs)))
    }
    
    public static func /(lhs: Matrix4x4, rhs: Mat4) -> Mat4 {
        return Mat4(Operation(lhs: Mat4(lhs), operator: .divide, rhs: rhs))
    }
    public static func /(lhs: Mat4, rhs: Matrix4x4) -> Mat4 {
        return Mat4(Operation(lhs: lhs, operator: .divide, rhs: Mat4(rhs)))
    }
    
    public static func ==(lhs: Mat4, rhs: Mat4) -> Scalar {
        return Scalar(Operation(lhs: lhs, operator: .compare(.equal), rhs: rhs))
    }
}
