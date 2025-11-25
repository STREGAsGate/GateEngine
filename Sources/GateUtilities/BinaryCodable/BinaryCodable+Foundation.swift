/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Foundation)
public import Foundation

extension Data: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try self.count.encode(into: &data, version: version)
            self.withUnsafeBytes { bytes in
                data.append(contentsOf: bytes)
            }
        }
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            let count = try Int(decoding: data, at: &offset, version: version)
            let pointer = data.baseAddress!.advanced(by: offset)
            offset += count
            self.init(bytes: pointer, count: count)
        }
    }
}

extension URL: BinaryCodable {
    public func encode(into data: inout ContiguousArray<UInt8>, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            try self.absoluteString.encode(into: &data, version: version)
        }
    }
    
    public init(decoding data: UnsafeRawBufferPointer, at offset: inout Int, version: BinaryCodableVersion) throws {
        switch version {
        case .v1:
            let absoluteString: String = try .init(decoding: data, at: &offset, version: version)
            if let url = Self(string: absoluteString) {
                self = url
            }else{
                throw BinaryCodableError.failedToDecode("Failed to create URL from decoded absoluteString: \(absoluteString)")
            }
        }
    }
}

#endif
