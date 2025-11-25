/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension Range: BinaryCodable where Bound: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.upperBound.encode(into: &data, version: version)
        try self.lowerBound.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let upperBound: Bound = try .init(decoding: data, at: &offset, version: version)
        let lowerBound: Bound = try .init(decoding: data, at: &offset, version: version)
        self.init(uncheckedBounds: (lowerBound, upperBound))
    }
}

extension ClosedRange: BinaryCodable where Bound: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.upperBound.encode(into: &data, version: version)
        try self.lowerBound.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let upperBound: Bound = try .init(decoding: data, at: &offset, version: version)
        let lowerBound: Bound = try .init(decoding: data, at: &offset, version: version)
        self.init(uncheckedBounds: (lowerBound, upperBound))
    }
}

extension PartialRangeFrom: BinaryCodable where Bound: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.lowerBound.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let lowerBound: Bound = try .init(decoding: data, at: &offset, version: version)
        self.init(lowerBound)
    }
}

extension PartialRangeUpTo: BinaryCodable where Bound: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.upperBound.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let upperBound: Bound = try .init(decoding: data, at: &offset, version: version)
        self.init(upperBound)
    }
}

extension PartialRangeThrough: BinaryCodable where Bound: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        try self.upperBound.encode(into: &data, version: version)
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        let upperBound: Bound = try .init(decoding: data, at: &offset, version: version)
        self.init(upperBound)
    }
}
