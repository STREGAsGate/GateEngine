/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(Darwin) && canImport(ModelIO)

import Foundation
import ModelIO

public final class ApplePlatformModelImporter: GeometryImporter {
    public required init() {}

    private func positions(from mesh: MDLMesh) throws -> [Float] {
        guard let attributeData = mesh.vertexAttributeData(
            forAttributeNamed: MDLVertexAttributePosition,
            as: .float3
        ) else {
            throw GateEngineError.failedToDecode("Model has no positions.")
        }
        var values: [Float] = []
        values.reserveCapacity(mesh.vertexCount * 3)
        for index in 0 ..< mesh.vertexCount {
            let start = attributeData.dataStart.advanced(by: attributeData.stride * index)
                .assumingMemoryBound(to: Float.self)
            let buffer = UnsafeBufferPointer<Float>(start: start, count: 3)
            values.append(contentsOf: buffer)
        }
        return values
    }

    func uvSets(from mesh: MDLMesh) -> [[Float]] {
        guard let attributeData = mesh.vertexAttributeData(
            forAttributeNamed: MDLVertexAttributeTextureCoordinate,
            as: .float2
        ) else { return [[]] }
        var values: [Float] = []
        values.reserveCapacity(mesh.vertexCount * 2)
        for index in 0 ..< mesh.vertexCount {
            let start = attributeData.dataStart.advanced(by: attributeData.stride * index)
                .assumingMemoryBound(to: Float.self)
            var buffer = UnsafeMutableBufferPointer<Float>(start: start, count: 2)
            withUnsafeMutableBytes(of: &buffer) { buffer in
                // Flip vertical coordinate
                for index in stride(from: 0, to: buffer.count, by: 2) {
                    buffer[index] = 1 - buffer[index]
                }
            }

            values.append(contentsOf: buffer)
        }
        return [values]
    }

    func normals(from mesh: MDLMesh) -> [Float]? {
        guard let attributeData = mesh.vertexAttributeData(
            forAttributeNamed: MDLVertexAttributeNormal,
            as: .float3
        ) else { return nil }
        var values: [Float] = []
        values.reserveCapacity(mesh.vertexCount * 3)
        for index in 0 ..< mesh.vertexCount {
            let start = attributeData.dataStart.advanced(by: attributeData.stride * index)
                .assumingMemoryBound(to: Float.self)
            let buffer = UnsafeBufferPointer<Float>(start: start, count: 3)
            values.append(contentsOf: buffer)
        }
        return values
    }

    func tangents(from mesh: MDLMesh) -> [Float]? {
        // TODO: tangents might be float4 and we are just clipping the last value. Need to convert if that's the case
        guard let attributeData = mesh.vertexAttributeData(
            forAttributeNamed: MDLVertexAttributeTangent,
            as: .float3
        ) else { return nil }
        var values: [Float] = []
        values.reserveCapacity(mesh.vertexCount * 3)
        for index in 0 ..< mesh.vertexCount {
            let start = attributeData.dataStart.advanced(by: attributeData.stride * index)
                .assumingMemoryBound(to: Float.self)
            let buffer = UnsafeBufferPointer<Float>(start: start, count: 3)
            values.append(contentsOf: buffer)
        }
        return values
    }

    func colors(from mesh: MDLMesh) -> [Float]? {
        guard let attributeData = mesh.vertexAttributeData(
            forAttributeNamed: MDLVertexAttributeColor,
            as: .float4
        ) else { return nil }
        var values: [Float] = []
        values.reserveCapacity(mesh.vertexCount * 4)
        for index in 0 ..< mesh.vertexCount {
            let start = attributeData.dataStart.advanced(by: attributeData.stride * index)
                .assumingMemoryBound(to: Float.self)
            let buffer = UnsafeBufferPointer<Float>(start: start, count: 4)
            values.append(contentsOf: buffer)
        }
        return values
    }

    func indices(from submeshes: [MDLSubmesh]) throws -> [UInt16] {
        var indices: [UInt16] = []
        for submesh in submeshes {
            let indexBuffer = submesh.indexBuffer
            let start = indexBuffer.map().bytes
            switch submesh.indexType {
            case .invalid:
                throw GateEngineError.failedToDecode("Model has corrupted indices.")
            case .uInt8, .uint8:
                let buffer = UnsafeBufferPointer(
                    start: start.assumingMemoryBound(to: UInt8.self),
                    count: submesh.indexCount
                )
                indices.append(contentsOf: Array(buffer).map({ UInt16($0) }))
            case .uInt16, .uint16:
                let buffer = UnsafeBufferPointer(
                    start: start.assumingMemoryBound(to: UInt16.self),
                    count: submesh.indexCount
                )
                indices.append(contentsOf: Array(buffer))
            case .uInt32, .uint32:
                let buffer = UnsafeBufferPointer(
                    start: start.assumingMemoryBound(to: UInt32.self),
                    count: submesh.indexCount
                )
                indices.append(contentsOf: Array(buffer).map({ UInt16($0) }))
            @unknown default:
                throw GateEngineError.failedToDecode(
                    "Can't parse indices. Unhandled index type."
                )
            }
        }
        return indices
    }
    
    public func loadData(path: String, options: GeometryImporterOptions) async throws -> RawGeometry {
        let asset = MDLAsset(url: URL(fileURLWithPath: path))

        for meshIndex in 0 ..< asset.count {
            guard let mesh = asset.object(at: meshIndex) as? MDLMesh else {
                throw GateEngineError.failedToDecode("mesh[\(meshIndex)] is not a MDLMesh instance.")
            }
            if let name = options.subobjectName {
                guard mesh.name.caseInsensitiveCompare(name) == .orderedSame else { continue }
            }

            guard let submeshes = mesh.submeshes as? [MDLSubmesh] else {
                throw GateEngineError.failedToDecode("mesh[\(meshIndex)] contains no submeshes.")
            }

            return RawGeometry(positions: try positions(from: mesh),
                               uvSets: uvSets(from: mesh),
                               normals: normals(from: mesh),
                               tangents: tangents(from: mesh),
                               colors: colors(from: mesh),
                               indices: try indices(from: submeshes))
        }
        if let name = options.subobjectName {
            throw GateEngineError.failedToDecode("Failed to locate model named \(name).")
        }
        throw GateEngineError.failedToDecode("Failed to locate model.")
    }

    public static func canProcessFile(_ file: URL) -> Bool {
        return MDLAsset.canImportFileExtension(file.pathExtension)
    }
}

#endif
