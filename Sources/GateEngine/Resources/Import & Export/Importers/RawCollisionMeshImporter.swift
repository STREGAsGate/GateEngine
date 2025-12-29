/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

/**
 Handles loading `RawSkeleton` from a file as encoded by `RawSkeletonEncoder`
 
 The file extension of the asset to load must match `RawSkeletonImporter.fileExtension`
 */
public struct RawCollisionMeshImporter: CollisionMeshImporter, GateEngineNativeResourceImporter {
    var data: Data! = nil
    public init() {}

    public mutating func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            self.data = try Platform.current.synchronousLoadResource(from: path)
        }catch{
            throw GateEngineError(error)
        }
    }
    public mutating func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            self.data = try await Platform.current.loadResource(from: path)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public mutating func loadCollisionMesh(options: CollisionMeshImporterOptions) async throws(GateEngineError) -> RawCollisionMesh {
        do {
            return try RawCollisionMeshDecoder().decode(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    /// The expected file extension
    /// Write data created with `RawSkeletonEncoder` to a file with this extension to be imported by this `SkeletonImporter`
    public static let fileExtension: String = "gatecmsh"
}
