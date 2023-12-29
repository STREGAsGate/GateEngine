/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class ShaderVoid: ShaderValue {
    public let valueRepresentation: ValueRepresentation = .void
    public let valueType: ValueType = .void
    
    public let operation: Operation? = nil

    internal init() {
        
    }
    public init(_ operation: Operation) {
        fatalError()
    }
    
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = [1_000]
        values.append(contentsOf: valueRepresentation.identifier)
        values.append(contentsOf: valueType.identifier)
        return values
    }
    lazy public private(set) var id: UInt64 = HashGenerator.generateID(self.documentIdentifierInputData(), seed: .valueVoid)
}
