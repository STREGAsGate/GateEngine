/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

/**
 Handles loading `RawSkin` from a file as encoded by `RawSkinEncoder`
 
 The file extension of the asset to load must match `RawSkinImporter.fileExtension`
 */
public struct RawSkinImporter: SkinImporter, GateEngineNativeResourceImporter {
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
    
    public mutating func loadSkin(options: SkinImporterOptions) async throws(GateEngineError) -> RawSkin {
        do {
            return try RawSkinDecoder().decode(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    /// The expected file extension
    /// Write data created with `RawSkinEncoder` to a file with this extension to be imported by this `SkinImporter`
    public static let fileExtension: String = "gateskin"
}
