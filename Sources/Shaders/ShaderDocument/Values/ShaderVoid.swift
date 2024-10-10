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
}
