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
    
    public init?(hexString: String) {
        self.value = Self.hash(from: hexString)
    }
    
    public init?(filename: String) {
        self.value = Self.hash(from: filename)
    }
    
    /// Create a hash value from a filename string
    public static func hash(from filename: String) -> UInt16 {
        var hash: UInt16 = 0
        for c in filename.split(separator: ".")[0].utf8 {
            hash = (( hash >> 11 ) | ( hash << 5 ))
            hash = hash &+ UInt16(c)
        }
        return hash
    }
    
    public static func hash(from hexString: String) -> UInt16? {
        return UInt16(hexString, radix: 16)
    }
    
    public static func string(from hashValue: UInt16) -> String {
        return String(hashValue, radix: 16, uppercase: true)
    }
}

extension KojimaHash1: Codable {}
extension KojimaHash1: Sendable {}

extension KojimaHash1: Identifiable {
    public var id: UInt16 {
        return self.value
    }
}

extension KojimaHash1: Comparable {
    public static func < (lhs: KojimaHash1, rhs: KojimaHash1) -> Bool {
        return lhs.value < rhs.value
    }
}

extension KojimaHash1: Equatable {
    public static func == (lhs: KojimaHash1, rhs: KojimaHash1) -> Bool {
        return lhs.value == rhs.value
    }
}

extension KojimaHash1: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}

extension KojimaHash1: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return Self.string(from: self.value)
    }
    public var debugDescription: String {
        return "0x" + Self.string(from: self.value)
    }
}

extension KojimaHash1: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.value.encode(into: &data, version: version)
    }
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
