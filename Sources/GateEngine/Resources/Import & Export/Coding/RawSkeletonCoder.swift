/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct RawSkeletonEncoder {
    public func encode(_ rawSkeleton: RawSkeleton) throws(EncodingError) -> Data {
        let magic: UInt32 = 0x47574152 // "SKTN"
        var header = BinaryCodableHeader(magic: magic)
        
        guard let version = header.version else { throw .encodingFailed }
        
        var data: ContiguousArray<UInt8> = []
        withUnsafeBytes(of: header) {
            data.append(contentsOf: $0)
        }
        
        do {
            try rawSkeleton.joints.count.encode(into: &data, version: version)
            for joint in rawSkeleton.joints {
                try joint.id.encode(into: &data, version: version)
                try joint.parent.encode(into: &data, version: version)
                try joint.name.encode(into: &data, version: version)
                try joint.localTransform.encode(into: &data, version: version)
            }
        }catch{
            throw .encodingFailed
        }
        
        // Write documentLength
        header.documentLength = UInt32(data.count)
        data.withUnsafeMutableBytes { data in
            withUnsafePointer(to: header, { header in
                data.baseAddress!.copyMemory(from: header, byteCount: MemoryLayout<BinaryCodableHeader>.size)
            })
        }
        
        return Data(data)
    }
    
    public enum EncodingError: Error {
        /// The encoding failed due to an unknown reason
        case encodingFailed
    }
    
    public init() {
        
    }
}

public struct RawSkeletonDecoder {
    public func decode(_ data: Data) throws(DecodingError) -> RawSkeleton {
        do {
            return try data.withUnsafeBytes({ (data: UnsafeRawBufferPointer) throws -> RawSkeleton in
                var offset: Int = 0
                let header = data.load(fromByteOffset: offset, as: BinaryCodableHeader.self)
                offset += MemoryLayout<BinaryCodableHeader>.size
                
                guard let version = header.version else { throw GateEngineError.failedToDecode("Malformed header.") }
                
                let jointCount = try Int(decoding: data, at: &offset, version: version)
                
                var joints: [RawSkeleton.RawJoint] = []
                joints.reserveCapacity(jointCount)
                
                for _ in 0 ..< jointCount {
                    joints.append(
                        RawSkeleton.RawJoint(
                            id: try .init(decoding: data, at: &offset, version: version),
                            parent: try .init(decoding: data, at: &offset, version: version),
                            name: try .init(decoding: data, at: &offset, version: version),
                            localTransform: try .init(decoding: data, at: &offset, version: version)
                        )
                    )
                }
                
                return RawSkeleton(rawJoints: joints)
                
            })
        }catch{
            throw .decodingFailed
        }
    }
    
    public enum DecodingError: Error {
        /// The data is empty or corrupted.
        case decodingFailed
        /// The data does not appear to be intended for this decoder.
        case invalidFormat
        /// This version of GateEngine doesn't support loading this file.
        /// - note: It's best to encode and decode with the same GateEngine version.
        case unsupportedVersion
    }
    
    public init() {
        
    }
}
