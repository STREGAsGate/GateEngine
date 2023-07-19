/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Sampler2D: ShaderValue {
    public internal(set) var operation: Operation? = nil
    
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType = .texture2D
    
    init(valueRepresentation: ValueRepresentation) {
        self.valueRepresentation = valueRepresentation
    }
    
    public enum Filter {
        case nearest
        case linear
    }
    
    public func sample(at textCoord: Vec2, filter: Filter = .linear) -> Vec4 {
        return Vec4(Operation(lhs: self, rhs: textCoord, operator: .sampler2D(filter: filter)))
    }
}
