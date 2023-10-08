/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Mat4Array: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
        
    public let operation: Operation?
    public let valueMatrix4x4Array: [Matrix4x4]?
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self.valueMatrix4x4Array = nil
    }
    
    public init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self.valueMatrix4x4Array = nil
    }
    
    public init(_ matricies: [Matrix4x4]) {
        self.valueRepresentation = .mat4Array(matricies.count)
        self.valueType = .float4x4Array(matricies.count)
        self.operation = nil
        self.valueMatrix4x4Array = matricies
    }
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = [8_000]
        values.append(contentsOf: valueRepresentation.identifier)
        values.append(contentsOf: valueType.identifier)
        if let operation {
            values.append(contentsOf: operation.documentIdentifierInputData())
        }
        if let valueMatrix4x4Array {
            for mat4x4 in valueMatrix4x4Array {
                values.append(contentsOf: mat4x4.array().map({Int($0)}))
            }
        }
        return values
    }
    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: .valueMat4Array)
    
    public func element(at index: Scalar) -> Mat4 {
        return Mat4(representation: .mat4ArrayValue(self, index), type: .float4x4)
    }
    
    public subscript (index: Scalar) -> Mat4 {
        return element(at: index)
    }
}
