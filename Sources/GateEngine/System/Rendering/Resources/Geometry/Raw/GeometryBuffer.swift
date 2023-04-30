/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath
import Collections

/// An element array object formated as triangle primitives
public struct GeometryBuffer {
    // MARK: - Floats
    public enum FloatAttribute: Hashable {
        case position(_ index: UInt8)
        case textureCoordinate(_ index: UInt8)
        case normal(_ index: UInt8)
        case tangent(_ index: UInt8)
        case color(_ index: UInt8)
        case skinWeight(_ index: UInt8)
    }
    public var floatAttributes: OrderedSet<FloatAttribute> = []
    public var floatValues: Deque<Float> = []
    public var floatCounts: Deque<Int> = []
    
    mutating func removeValues(for attribute: FloatAttribute) {
        let index = floatAttributes.firstIndex(of: attribute)!
        let offset = self.offset(for: attribute)!
        let length = floatCounts[index]
        floatAttributes.remove(attribute)
        self.floatValues.removeSubrange(offset ..< length)
        floatCounts.remove(at: index)
    }
    
    public mutating func setValues(_ values: [Float], for attribute: FloatAttribute) {
        if floatAttributes.contains(attribute) {
            let index = floatAttributes.firstIndex(of: attribute)!
            let offset = self.offset(for: attribute)!
            let length = floatCounts[index]
            floatAttributes.remove(attribute)
            self.floatValues.removeSubrange(offset ..< length)
            floatCounts.remove(at: index)
        }
        floatCounts.append(values.count)
        self.floatValues.append(contentsOf: values)
        floatAttributes.append(attribute)
    }
    
    public func values(for attribute: FloatAttribute) -> [Float]? {
        guard let index = floatAttributes.firstIndex(of: attribute) else {return nil}
        guard let offset = self.offset(for: attribute) else {return nil}
        let length = floatCounts[index]
        let slice = floatValues[offset ..< length]
        return Array(slice)
    }
    
    internal func offset(for attribute: FloatAttribute) -> Int? {
        guard floatAttributes.contains(attribute) else {return nil}
        var offset: Int = 0
        for index in floatAttributes.indices {
            if floatAttributes[index] == attribute {
                return offset
            }
            offset += floatCounts[index]
        }
        return nil
    }
    
    // MARK: - Index
    public enum UInt16Attribute: Hashable {
        case jointIndex(_ index: UInt8)
    }
    public var indexAttributes: OrderedSet<UInt16Attribute> = []
    public var indexValues: Deque<UInt16> = []
    public var indexCounts: Deque<Int> = []
    
    mutating func removeValues(for attribute: UInt16Attribute) {
        let index = indexAttributes.firstIndex(of: attribute)!
        let offset = self.offset(for: attribute)!
        let length = indexCounts[index]
        indexAttributes.remove(attribute)
        self.indexValues.removeSubrange(offset ..< length)
        indexCounts.remove(at: index)
    }
    
    public mutating func setValues(_ values: [UInt16], for attribute: UInt16Attribute) {
        if indexAttributes.contains(attribute) {
            self.removeValues(for: attribute)
        }
        indexCounts.append(values.count)
        self.indexValues.append(contentsOf: values)
        indexAttributes.append(attribute)
    }
    
    public func values(for attribute: UInt16Attribute) -> [UInt16]? {
        guard let index = indexAttributes.firstIndex(of: attribute) else {return nil}
        guard let offset = self.offset(for: attribute) else {return nil}
        let length = indexCounts[index]
        let slice = indexValues[offset ..< length]
        return Array(slice)
    }
    
    internal func offset(for attribute: UInt16Attribute) -> Int? {
        guard indexAttributes.contains(attribute) else {return nil}
        var offset: Int = 0
        for index in indexAttributes.indices {
            if indexAttributes[index] == attribute {
                return offset
            }
            offset += indexCounts[index]
        }
        return nil
    }
}
