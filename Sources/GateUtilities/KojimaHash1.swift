/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/**
 Create a unique identifier from a file name.
 
 This hashing function was used by Metal Gear Solid 1 to efficiently reference files at reduced performance cost and 
 memory usage compared to string comparisons. 
 This hashing method has been dubbed "KojimaHash" by the MGS reversing community.
 
 - warning: Due to the lower bit width (16bit), this hash is more likeley to have collisions. 
 Keep track of the generated hashes to ensure there are no collisions. 
 */
public struct KojimaHash1 {
    public let value: UInt16
    
    public init(_ hash: UInt16) {
        self.value = hash
    }
    
    public init(filename: String) {
        self.value = Self.hash(filename: filename)
    }
    
    public init(filename: StaticString) {
        self.value = Self.hash(filename: filename)
    }
    
    @inlinable
    public init?(hexString: String) {
        guard let value = Self.hash(hexString: hexString) else {
            return nil
        }
        self.init(value)
    }

    /// Create a hash value from a filename string
    @inlinable
    public static func hash(filename: String) -> UInt16 {
        var hash: UInt16 = 0
        for c in filename.split(separator: ".")[0].utf8 {
            hash = (( hash >> 11 ) | ( hash << 5 ))
            hash = hash &+ UInt16(c)
        }
        return hash
    }
    
    /// Create a hash value from a filename string
    @inlinable
    public static func hash(filename: StaticString) -> UInt16 {
        var hash: UInt16 = 0
        filename.withUTF8Buffer { utf8 in
            for c in utf8 {
                // c != null && c != "."
                guard c != 0x00 && c != 0x2E else {break}
                hash = (( hash >> 11 ) | ( hash << 5 ))
                hash = hash &+ UInt16(c)
            }
        }
        return hash
    }
    
    @inlinable
    public static func hash(hexString: String) -> UInt16? {
        return UInt16(hexString, radix: 16)
    }
    
    @inlinable
    public static func string(from hashValue: UInt16) -> String {
        return String(hashValue, radix: 16, uppercase: true)
    }
}

extension KojimaHash1: Codable {}
extension KojimaHash1: Sendable {}

extension KojimaHash1: Identifiable {
    @inlinable
    public var id: UInt16 {
        return self.value
    }
}

extension KojimaHash1: Comparable {
    @inlinable
    public static func < (lhs: KojimaHash1, rhs: KojimaHash1) -> Bool {
        return lhs.value < rhs.value
    }
}

extension KojimaHash1: Equatable {
    @inlinable
    public static func == (lhs: KojimaHash1, rhs: KojimaHash1) -> Bool {
        return lhs.value == rhs.value
    }
}

extension KojimaHash1: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}

extension KojimaHash1: CustomStringConvertible, CustomDebugStringConvertible {
    @inlinable
    public var description: String {
        return Self.string(from: self.value)
    }
    @inlinable
    public var debugDescription: String {
        return "0x" + Self.string(from: self.value)
    }
}

extension KojimaHash1: BinaryCodable {
    @inlinable
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.value.encode(into: &data, version: version)
    }
    @inlinable
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        self.value = try .init(decoding: data, at: &offset, version: version)
    }
}

extension KojimaHash1: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt16
    public init(integerLiteral value: UInt16) {
        self.init(value)
    }
}

extension KojimaHash1: ExpressibleByStringLiteral {
    public typealias StringLiteralType = StaticString
    public init(stringLiteral value: StaticString) {
        self.init(filename: value)
    }
}
