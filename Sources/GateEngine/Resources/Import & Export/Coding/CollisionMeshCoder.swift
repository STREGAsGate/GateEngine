/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

fileprivate let magic: UInt32 = 0x43_4D_53_48 // "CMSH"

public struct CollisionMeshEncoder {
    public func encode(_ collisionMesh: CollisionMesh) throws(GateEngineError) -> Data {
        var header = BinaryCodableHeader(magic: magic)
        
        guard let version = header.version else { throw .failedToEncode("Malformed header.") }
        
        var data: ContiguousArray<UInt8> = []
        withUnsafeBytes(of: header) {
            data.append(contentsOf: $0)
        }
        
        do {
            try collisionMesh.encode(into: &data, version: version)
        }catch let error as GateEngineError {
            // rethrow any GateEngineError
            throw error
        }catch{
            // Throw generic failure for other errors
            throw GateEngineError.failedToEncode("Unknown error: \(error.localizedDescription)")
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
    
    public init() {
        
    }
}

public final class CollisionMeshDecoder {
    public func decode(_ data: Data) throws(GateEngineError) -> CollisionMesh {
        do {
            return try data.withUnsafeBytes({ (data: UnsafeRawBufferPointer) throws -> CollisionMesh in
                var offset: Int = 0
                let header = data.load(fromByteOffset: offset, as: BinaryCodableHeader.self)
                offset += MemoryLayout<BinaryCodableHeader>.size
                
                guard let version = header.validatedVersionMatching(magic: magic, documentLength: UInt32(data.count)) else {
                    throw GateEngineError.failedToDecode("Malformed header.")
                }
                
                return try CollisionMesh(decoding: data, at: &offset, version: version)
            })
        }catch let error as GateEngineError {
            // rethrow any GateEngineError
            throw error
        }catch{
            // Throw generic failure for other errors
            throw GateEngineError.failedToDecode("Unknown error: \(error.localizedDescription)")
        }
    }

    public init() {
        
    }
}
