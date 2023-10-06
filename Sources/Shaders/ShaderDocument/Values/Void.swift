/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Void: ShaderValue {
    public let valueRepresentation: ValueRepresentation = .void
    public let valueType: ValueType = .void
    
    public let operation: Operation? = nil

    internal init() {
        
    }
    public init(_ operation: Operation) {
        fatalError()
    }
    
    
    public func documentIdentifierInputData() -> [Int] {
        var values: [Int] = []
        values.append(contentsOf: valueRepresentation.identifier)
        values.append(contentsOf: valueType.identifier)
        return values
    }
}
