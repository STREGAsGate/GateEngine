/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

fileprivate let magic: UInt32 = 0x4F_41_4E_49 // "OANI"

public struct RawObjectAnimation3DEncoder {
    public func encode(_ rawObjectAnimation3D: RawObjectAnimation3D) throws(GateEngineError) -> Data {
        var header = BinaryCodableHeader(magic: magic)
        
        guard let version = header.version else { throw .failedToEncode("Malformed header.") }
        
        var data: ContiguousArray<UInt8> = []
        withUnsafeBytes(of: header) {
            data.append(contentsOf: $0)
        }
        
        do {
            try rawObjectAnimation3D.encode(into: &data, version: version)
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

public struct RawObjectAnimation3DDecoder {
    public func decode(_ data: Data) throws(GateEngineError) -> RawObjectAnimation3D {
        do {
            return try data.withUnsafeBytes({ (data: UnsafeRawBufferPointer) throws -> RawObjectAnimation3D in
                var offset: Int = 0
                let header = data.load(fromByteOffset: offset, as: BinaryCodableHeader.self)
                offset += MemoryLayout<BinaryCodableHeader>.size
                
                guard let version = header.validatedVersionMatching(magic: magic, documentLength: UInt32(data.count)) else {
                    throw GateEngineError.failedToDecode("Malformed header.")
                }
                
                return try RawObjectAnimation3D(decoding: data, at: &offset, version: version)
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
