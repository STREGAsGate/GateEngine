/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Collections)

import Collections

extension Deque: BinaryCodable where Element: BinaryCodable {}
public extension Deque where Element: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try self.count.encode(into: &data, version: version)
            for element in self {
                try element.encode(into: &data, version: version)
            }
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            let count = try Int(decoding: data, at: &offset, version: version)
            
            var collection: Deque<Element> = []
            collection.reserveCapacity(count)
            for _ in 0 ..< count {
                let element = try Element(decoding: data, at: &offset, version: version)
                collection.append(element)
            }
            
            self = collection
        }
    }
}

public extension Deque where Element: BinaryCodable & BitwiseCopyable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try Array(self).encode(into: &data, version: version)
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            self.init(try Array<Element>(decoding: data, at: &offset, version: version))
        }
    }
}

extension OrderedSet: BinaryCodable where Element: BinaryCodable {}
public extension OrderedSet where Element: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try self.count.encode(into: &data, version: version)
            for element in self {
                try element.encode(into: &data, version: version)
            }
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            let count = try Int(decoding: data, at: &offset, version: version)
            
            var collection: OrderedSet<Element> = []
            collection.reserveCapacity(count)
            for _ in 0 ..< count {
                let element = try Element(decoding: data, at: &offset, version: version)
                collection.append(element)
            }
            
            self = collection
        }
    }
}

extension OrderedDictionary: BinaryCodable where Key: BinaryCodable, Value: BinaryCodable {}
public extension OrderedDictionary where Key: BinaryCodable, Value: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try self.count.encode(into: &data, version: version)
            for (key, value) in self {
                try key.encode(into: &data, version: version)
                try value.encode(into: &data, version: version)
            }
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            let count = try Int(decoding: data, at: &offset, version: version)
            var uniqueKeysWithValues: [(Key, Value)] = []
            uniqueKeysWithValues.reserveCapacity(count)
            for _ in 0 ..< count {
                let key = try Key(decoding: data, at: &offset, version: version)
                let value = try Value(decoding: data, at: &offset, version: version)
                uniqueKeysWithValues.append((key, value))
            }
            self.init(uniqueKeysWithValues: uniqueKeysWithValues)
        }
    }
}

#endif
