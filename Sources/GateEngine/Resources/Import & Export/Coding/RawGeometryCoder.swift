/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct RawGeometryEncoder {
    public func encode(_ value: RawGeometry) throws(EncodingError) -> Data {
        return try RawGeometryEncodableRepresenation_v1.encode(value)
    }
    
    public enum EncodingError: Error {
        /// The encoding failed due to an unknown reason
        case encodingFailed
    }
    
    public init() {
        
    }
}

public struct RawGeometryDecoder {
    public func decode(_ data: Data) throws(DecodingError) -> RawGeometry {
        guard data.isEmpty == false else { throw .decodingFailed }
        let header = data.withUnsafeBytes { data in
            data.load(as: RawGeometryCodableHeader.self)
        }
        guard header.isValid else { throw .invalidFormat }
        guard let version = header.version else { throw .unsupportedVersion }
        guard header.documentLength == data.count else { throw .decodingFailed }
        switch version {
        case .v1:
            return try RawGeometryEncodableRepresenation_v1.decode(data)
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

fileprivate struct RawGeometryCodableHeader {
    static let magic1: UInt32 = 0x45544147 // "GATE"
    static let magic2: UInt32 = 0x47574152 // "RAWG"
    let magic1: UInt32
    let magic2: UInt32
    let _version: UInt8
    private let _reserved1: UInt8 = 0
    private let _reserved2: UInt8 = 0
    private let _reserved3: UInt8 = 0
    let documentLength: UInt32 = 0

    enum Version: UInt8 {
        case v1 = 1
    }
    
    var version: Version? {
        return Version(rawValue: _version)
    }
    
    init(version: Version) {
        self.magic1 = Self.magic1
        self.magic2 = Self.magic2
        self._version = version.rawValue
    }
    
    var isValid: Bool {
        return self.magic1 == Self.magic1 && self.magic2 == Self.magic2
    }
}

fileprivate struct RawGeometryEncodableRepresenation_v1 {
    struct Header {
        var version: RawGeometryCodableHeader
        var positionValueCount: UInt32
        var uvSetCount: UInt8
        var normalValuesCount: UInt32
        var tangentValuesCount: UInt32
        var colorValuesCount: UInt32
        var indicesCount: UInt32
        
        init(rawGeometry: RawGeometry) {
            self.version = RawGeometryCodableHeader(version: .v1)
            self.positionValueCount = UInt32(rawGeometry.positions.count)
            self.uvSetCount = UInt8(rawGeometry.uvSets.count)
            self.normalValuesCount = UInt32(rawGeometry.normals.count)
            self.tangentValuesCount = UInt32(rawGeometry.tangents.count)
            self.colorValuesCount = UInt32(rawGeometry.colors.count)
            self.indicesCount = UInt32(rawGeometry.indices.count)
        }
    }
    
    static func encode(_ rawGeometry: RawGeometry) throws(RawGeometryEncoder.EncodingError) -> Data {
        var data = Data()
        withUnsafeBytes(of: Header(rawGeometry: rawGeometry)) {
            data.append(contentsOf: $0)
        }
        rawGeometry.positions.withUnsafeBytes { positions in
            data.append(contentsOf: positions)
        }
        for uvSetIndex in rawGeometry.uvSets.indices {
            let uvsCount = UInt32(rawGeometry.uvSets[uvSetIndex].count)
            withUnsafeBytes(of: uvsCount) { count in
                data.append(contentsOf: count)
            }
            rawGeometry.uvSets[uvSetIndex].withUnsafeBytes { uvs in
                data.append(contentsOf: uvs)
            }
        }
        rawGeometry.normals.withUnsafeBytes { normals in
            data.append(contentsOf: normals)
        }
        rawGeometry.tangents.withUnsafeBytes { tangents in
            data.append(contentsOf: tangents)
        }
        rawGeometry.colors.withUnsafeBytes { colors in
            data.append(contentsOf: colors)
        }
        rawGeometry.indices.withUnsafeBytes { indices in
            data.append(contentsOf: indices)
        }
        
        // Write documentLength
        data.withUnsafeMutableBytes { data in
            withUnsafePointer(to: UInt32(data.count), { count in
                data.baseAddress!.advanced(by: 12).copyMemory(from: count, byteCount: MemoryLayout<UInt32>.size)
            })
        }
        
        return data
    }
    
    static func decode(_ data: Data) throws(RawGeometryDecoder.DecodingError) -> RawGeometry {
        return data.withUnsafeBytes({ (data: UnsafeRawBufferPointer) -> RawGeometry in
            var offset: Int = 0
            let header = data.load(fromByteOffset: offset, as: Header.self)
            offset += MemoryLayout<Header>.size
            
            let positionsCount = Int(header.positionValueCount)
            let positions: [Float] = Array(UnsafeBufferPointer(start: data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: Float.self), count: positionsCount))
            offset += MemoryLayout<Float>.size * positionsCount
            
            var uvSets: [[Float]] = []
            for _ in 0 ..< header.uvSetCount {
                let uvCount: Int = Int(data.load(fromByteOffset: offset, as: UInt32.self))
                offset += MemoryLayout<UInt32>.size
                let uvs: [Float] = Array(UnsafeBufferPointer(start: data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: Float.self), count: uvCount))
                uvSets.append(uvs)
                offset += MemoryLayout<Float>.size * uvCount
            }
            
            let normalsCount = Int(header.normalValuesCount)
            let normals: [Float] = Array(UnsafeBufferPointer(start: data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: Float.self), count: normalsCount))
            offset += MemoryLayout<Float>.size * normalsCount
            
            let tangentsCount: Int = Int(header.tangentValuesCount)
            let tangents: [Float] = Array(UnsafeBufferPointer(start: data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: Float.self), count: tangentsCount))
            offset += MemoryLayout<Float>.size * tangentsCount
            
            let colorsCount: Int = Int(header.colorValuesCount)
            let colors: [Float] = Array(UnsafeBufferPointer(start: data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: Float.self), count: colorsCount))
            offset += MemoryLayout<Float>.size * colorsCount
            
            let indicesCount: Int = Int(header.indicesCount)
            let indices: [UInt16] = Array(UnsafeBufferPointer(start: data.baseAddress!.advanced(by: offset).assumingMemoryBound(to: UInt16.self), count: indicesCount))
            offset += MemoryLayout<UInt16>.size * indicesCount
            
            return RawGeometry(
                positions: positions,
                uvSets: uvSets,
                normals: normals,
                tangents: tangents,
                colors: colors,
                indices: indices
            )
        })
    }
}
