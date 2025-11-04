/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public enum BinaryCodableVersion: UInt8, CaseIterable {
    case v1 = 1
    
    public static var latest: Self {
        return Self.allCases.last!
    }
}

public struct BinaryCodableHeader {
    static let magic1: UInt32 = 0x45544147 // "GATE"
    let magic1: UInt32
    let magic2: UInt32
    let _version: UInt8
    private let _reserved1: UInt8 = 0
    private let _reserved2: UInt8 = 0
    private let _reserved3: UInt8 = 0
    public var documentLength: UInt32 = 0

    public var version: BinaryCodableVersion? {
        return BinaryCodableVersion(rawValue: _version)
    }
    
    public init(version: BinaryCodableVersion = .latest, magic: UInt32) {
        self.magic1 = Self.magic1
        self.magic2 = magic
        self._version = version.rawValue
    }
    
    /// Returns the BinaryCodableVersion if the header is valid and matches the criteria 
    public func validatedVersionMatching(magic magic2: UInt32, documentLength: UInt32) -> BinaryCodableVersion? {
        guard self.magic1 == Self.magic1 else {return nil}
        guard self.magic2 == magic2 else {return nil}
        guard self.documentLength == documentLength else {return nil}
        return self.version
    }
}

/// GateEngine standard binary codable format
public protocol BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws
}

public extension BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        let padding = MemoryLayout<Self>.alignment - (data.count % MemoryLayout<Self>.alignment)
        if padding > 0 {
            data.append(contentsOf: Array(repeating: 0, count: padding))
        }
        withUnsafeBytes(of: self) { bytes in
            data.append(contentsOf: bytes)
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        offset += MemoryLayout<Self>.alignment - (offset % MemoryLayout<Self>.alignment)
        
        self = data.load(fromByteOffset: offset, as: Self.self)
        offset += MemoryLayout<Self>.size
    }
}

extension Array: BinaryCodable where Element: BinaryCodable {}
public extension Array where Element: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.count.encode(into: &data, version: version)
        for element in self {
            try element.encode(into: &data, version: version)
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let count = try Int(decoding: data, at: &offset, version: version)
        
        var collection: Array<Element> = []
        collection.reserveCapacity(count)
        for _ in 0 ..< count {
            let element = try Element(decoding: data, at: &offset, version: version)
            collection.append(element)
        }
        
        self = collection
    }
}

extension Set: BinaryCodable where Element: BinaryCodable {}
public extension Set where Element: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.count.encode(into: &data, version: version)
        for element in self {
            try element.encode(into: &data, version: version)
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let count = try Int(decoding: data, at: &offset, version: version)
        
        var collection: Set<Element> = []
        collection.reserveCapacity(count)
        for _ in 0 ..< count {
            let element = try Element(decoding: data, at: &offset, version: version)
            collection.insert(element)
        }
        
        self = collection
    }
}

extension Dictionary: BinaryCodable where Key: BinaryCodable, Value: BinaryCodable {}
public extension Dictionary where Key: BinaryCodable, Value: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.count.encode(into: &data, version: version)
        for (key, value) in self {
            try key.encode(into: &data, version: version)
            try value.encode(into: &data, version: version)
        }
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
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

extension Bool: BinaryCodable {}
extension Int8: BinaryCodable {}
extension Int16: BinaryCodable {}
extension Int32: BinaryCodable {}
extension UInt8: BinaryCodable {}
extension UInt16: BinaryCodable {}
extension UInt32: BinaryCodable {}
extension Float32: BinaryCodable {}
extension Float64: BinaryCodable {}

extension Int: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try Int32(self).encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let i32 = try Int32(decoding: data, at: &offset, version: version)
        self = Int(i32)
    }
}

extension UInt: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try UInt32(self).encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let u32 = try UInt32(decoding: data, at: &offset, version: version)
        self = UInt(u32)
    }
}

extension String: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        self.cString(using: .utf8)!.withUnsafeBytes { utf8Bytes in
            data.append(contentsOf: utf8Bytes)
        }
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let pointer = data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: CChar.self)
        self.init(cString: pointer)
        offset += self.utf8.count
    }
}

#if canImport(Foundation)
public import struct Foundation.Data
extension Data: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try data.withUnsafeBytes { bytes in
            try bytes.count.encode(into: &data, version: version)
            data.append(contentsOf: bytes)
        }
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let count = try Int(decoding: data, at: &offset, version: version)
        self.init(bytes: data.baseAddress!.advanced(by: offset), count: count)
        offset += count
    }
}
#endif

public extension RawRepresentable where Self: BinaryCodable, RawValue: BinaryCodable {
    func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.rawValue.encode(into: &data, version: version)
    }
    
    init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let rawValue = try RawValue(decoding: data, at: &offset, version: version)
        self = .init(rawValue: rawValue)!
    }
}

extension Optional: BinaryCodable where Wrapped: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch self {
        case .some(let value):
            try Bool(true).encode(into: &data, version: version)
            try value.encode(into: &data, version: version)
        case .none:
            try Bool(false).encode(into: &data, version: version)
        }
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let hasValue = try Bool(decoding: data, at: &offset, version: version)
        if hasValue {
            self = try Wrapped(decoding: data, at: &offset, version: version)
        }else{
            self = nil
        }
    }
}
