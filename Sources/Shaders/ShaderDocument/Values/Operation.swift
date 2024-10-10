/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Operation: ShaderElement {
    var operation: Operation? {
        return self
    }
    let valueRepresentation: ValueRepresentation = .operation
    let valueType: ValueType = .operation
    
    public enum Operator {
        case add
        case subtract
        case multiply
        case divide
        case not
        case cast(_ valueType: ValueType)
        
        public enum Comparison {
            case equal
            case notEqual
            case greater
            case greaterEqual
            case less
            case lessEqual
            case and
            case or
            
            var identifer: Int {
                switch self {
                case .equal:
                    return 4_101
                case .notEqual:
                    return 4_102
                case .greater:
                    return 4_103
                case .greaterEqual:
                    return 4_104
                case .less:
                    return 4_105
                case .lessEqual:
                    return 4_106
                case .and:
                    return 4_107
                case .or:
                    return 4_108
                }
            }
        }
        case compare(_ comparison: Comparison)
        
        case branch(comparing: Scalar)
        case `switch`(cases: [_SwitchCase])
        case discard(comparing: Scalar)
        case sampler2D
        case sampler2DSize
        case lerp(factor: Scalar)
        case distance
    }
    
    let `operator`: Operator
    let value1: any ShaderValue
    let value2: any ShaderValue
 
    public init(lhs: Scalar, operator: Operator, rhs: Scalar) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(not lhs: Scalar) {
        self.operator = .not
        self.value1 = lhs
        self.value2 = ShaderVoid()
    }
    
    public init(_ lhs: Scalar, castTo: ValueType) {
        self.operator = .cast(castTo)
        self.value1 = lhs
        self.value2 = ShaderVoid()
    }
    
    public init(lhs: Vec2, operator: Operator, rhs: Scalar) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Vec3, operator: Operator, rhs: Scalar) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Vec4, operator: Operator, rhs: Scalar) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: UVec4, operator: Operator, rhs: Scalar) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Scalar, operator: Operator, rhs: Vec2) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Scalar, operator: Operator, rhs: Vec3) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Scalar, operator: Operator, rhs: Vec4) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Scalar, operator: Operator, rhs: UVec4) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Vec2, operator: Operator, rhs: Vec2) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Vec3, operator: Operator, rhs: Vec3) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Vec4, operator: Operator, rhs: Vec4) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: UVec4, operator: Operator, rhs: UVec4) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Mat3, operator: Operator, rhs: Vec3) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Mat3, operator: Operator, rhs: Mat3) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Mat4, operator: Operator, rhs: Vec4) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    public init(lhs: Mat4, operator: Operator, rhs: Mat4) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    internal init(lhs: Sampler2D, rhs: Vec2, operator: Operator) {
        self.operator = `operator`
        self.value1 = lhs
        self.value2 = rhs
    }
    
    internal init(sizeOf sampler: Sampler2D) {
        self.operator = .sampler2DSize
        self.value1 = sampler
        self.value2 = ShaderVoid()
    }
    
    internal init<T: ShaderValue>(comparison: Operator.Comparison, success: T,  failure: T) {
        self.operator = .compare(comparison)
        self.value1 = success
        self.value2 = failure
    }
    
    internal init<T: ShaderValue>(compare: Scalar, success: T, failure: T) {
        self.operator = .branch(comparing: compare)
        self.value1 = success
        self.value2 = failure
    }
    
    internal init<T: ShaderValue>(discardIf compare: Scalar, success: T) {
        self.operator = .discard(comparing: compare)
        self.value1 = success
        self.value2 = ShaderVoid()
    }
    
    internal init<ResultType: ShaderValue>(switch compare: Scalar, cases: [SwitchCase<ResultType>]) {
        self.operator = .switch(cases: cases.map({_SwitchCase($0)}))
        self.value1 = compare
        self.value2 = ShaderVoid()
    }
}
