/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

/**
 Handles loading `RawObjectAnimation3D` from a file as encoded by `RawObjectAnimation3DEncoder`
 
 The file extension of the asset to load must match `RawObjectAnimation3DImporter.fileExtension`
 */
public struct RawObjectAnimation3DImporter: ObjectAnimation3DImporter, GateEngineNativeResourceImporter {
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
    
    public mutating func loadObjectAnimation(options: ObjectAnimation3DImporterOptions) async throws(GateEngineError) -> RawObjectAnimation3D {
        do {
            return try RawObjectAnimation3DDecoder().decode(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    /// The expected file extension
    /// Write data created with `RawObjectAnimation3DEncoder` to a file with this extension to be imported by this `SkeletalAnimationImporter`
    public static let fileExtension: String = "gateoani"
}
