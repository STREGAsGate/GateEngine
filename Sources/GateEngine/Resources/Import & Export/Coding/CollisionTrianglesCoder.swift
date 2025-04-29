//
//  CollisionTrianglesCoder.swift
//  GateEngine
//
//  Created by Dustin Collins on 4/8/25.
//

import GameMath

public final class CollisionMeshEncoder {
    public func encode(_ collisionMesh: CollisionMesh) throws(EncodingError) -> Data {
        return try CollisionMeshEncodableRepresenation_v1.encode(collisionMesh)
    }
    
    public enum EncodingError: Error {
        /// The encoding failed due to an unknown reason
        case encodingFailed
    }
    
    public init() {
        
    }
}

public final class CollisionMeshDecoder {
    public func decode(_ data: Data) throws(DecodingError) -> CollisionMesh {
        guard data.isEmpty == false else { throw .decodingFailed }
        let header = data.withUnsafeBytes { data in
            data.load(as: CollisionMeshCodableHeader.self)
        }
        guard header.isValid else { throw .invalidFormat }
        guard let version = header.version else { throw .unsupportedVersion }
        guard header.documentLength == data.count else { throw .decodingFailed }
        switch version {
        case .v1:
            return try CollisionMeshEncodableRepresenation_v1.decode(data)
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

fileprivate struct CollisionMeshCodableHeader {
    static let magic1: UInt32 = 0x45544147 // "GATE"
    static let magic2: UInt32 = 0x434D5348 // "CMSH"
    let magic1: UInt32
    let magic2: UInt32
    let _version: UInt8
    private let _reserved1: UInt8 = 0
    private let _reserved2: UInt8 = 0
    private let _reserved3: UInt8 = 0
    var documentLength: UInt32 = 0

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

fileprivate struct CollisionMeshEncodableRepresenation_v1 {
    struct Header {
        var version: CollisionMeshCodableHeader
        var dataOffsets: DataOffsets
        struct DataOffsets {
            var indices: UInt32 = 0
            var positions: UInt32 = 0
            var normals: UInt32 = 0
            var attributes: UInt32 = 0
        }
        
        init(collisionMesh: CollisionMesh) {
            self.version = CollisionMeshCodableHeader(version: .v1)
            self.dataOffsets = DataOffsets()
        }
    }
    struct CompactTriangleIndices {
        let p1: UInt16
        let p2: UInt16
        let p3: UInt16
        let center: UInt16
        let normal: UInt16
        let faceNormal: UInt16
        let attributes: UInt16
        
        var native: CollisionMesh.TriangleIndices {
            return CollisionMesh.TriangleIndices(
                p1: Int(p1),
                p2: Int(p2),
                p3: Int(p3),
                center: Int(center),
                normal: Int(normal),
                faceNormal: Int(faceNormal),
                attributes: Int(attributes)
            )
        }
        
        init(_ triangleIndices: CollisionMesh.TriangleIndices) {
            self.p1 = UInt16(triangleIndices.p1)
            self.p2 = UInt16(triangleIndices.p2)
            self.p3 = UInt16(triangleIndices.p3)
            self.center = UInt16(triangleIndices.center)
            self.normal = UInt16(triangleIndices.normal)
            self.faceNormal = UInt16(triangleIndices.faceNormal)
            self.attributes = UInt16(triangleIndices.attributes)
        }
    }
    
    static func encode(_ collisionMesh: CollisionMesh) throws(CollisionMeshEncoder.EncodingError) -> Data {
        var header = Header(collisionMesh: collisionMesh)
        var data = Data(repeating: 0, count: MemoryLayout<Header>.size)        
        
        header.dataOffsets.indices = UInt32(data.count)
        collisionMesh.indices.map({CompactTriangleIndices($0)}).withUnsafeBytes { bytes in
            data.append(contentsOf: bytes)
        }
        
        header.dataOffsets.positions = UInt32(data.count)
        collisionMesh.components.positions.withUnsafeBytes { bytes in
            data.append(contentsOf: bytes)
        }
        
        header.dataOffsets.normals = UInt32(data.count)
        collisionMesh.components.normals.withUnsafeBytes { bytes in
            data.append(contentsOf: bytes)
        }
        
        header.dataOffsets.attributes = UInt32(data.count)
        collisionMesh.components.attributes.withUnsafeBytes { bytes in
            data.append(contentsOf: bytes)
        }
        
        // Update header documentLength
        header.version.documentLength = UInt32(data.count)
        
        // Replace header bytes
        data.withUnsafeMutableBytes { data in
            withUnsafeBytes(of: header) { headerBytes in
                data.copyMemory(from: headerBytes)
            }
        }
        
        return data
    }
    
    static func decode(_ data: Data) throws(CollisionMeshDecoder.DecodingError) -> CollisionMesh {
        return data.withUnsafeBytes({ (data: UnsafeRawBufferPointer) -> CollisionMesh in
            let header = data.load(as: Header.self)
            
            let indicesOffset = Int(header.dataOffsets.indices)
            let positionsOffset = Int(header.dataOffsets.positions)
            let normalsOffset = Int(header.dataOffsets.normals)
            let attributesOffset = Int(header.dataOffsets.attributes)
            
            let indicesCount = (positionsOffset - indicesOffset) / MemoryLayout<CompactTriangleIndices>.size
            let positionsCount = (normalsOffset - positionsOffset) / MemoryLayout<Float>.size
            let normalsCount = (attributesOffset - normalsOffset) / MemoryLayout<Float>.size
            let attributesCount = (Int(header.version.documentLength) - attributesOffset) / MemoryLayout<UInt64>.size
            
            let indices = UnsafeBufferPointer(start: data.baseAddress!.advanced(by: indicesOffset).assumingMemoryBound(to: CompactTriangleIndices.self), count: indicesCount)
            let positions = UnsafeBufferPointer(start: data.baseAddress!.advanced(by: positionsOffset).assumingMemoryBound(to: Float.self), count: positionsCount)
            let normals = UnsafeBufferPointer(start: data.baseAddress!.advanced(by: normalsOffset).assumingMemoryBound(to: Float.self), count: normalsCount)
            let attributes = UnsafeBufferPointer(start: data.baseAddress!.advanced(by: attributesOffset).assumingMemoryBound(to: UInt64.self), count: attributesCount)
            
            return CollisionMesh(
                indices: indices.map({$0.native}),
                positions: Array(positions),
                normals: Array(normals),
                attributes: Array(attributes)
            )
        })
    }
}
