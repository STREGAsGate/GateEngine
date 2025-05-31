/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

/**
 Handles loading `RawGeometry` from a file as encoded by `RawGeometryEncoder`
 
 The file extension of the asset to load must match `RawGeometryImporter.fileExtension`
 */
public final class RawGeometryImporter: GeometryImporter {
    var data: Data! = nil
    public required init() {}

    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            self.data = try Platform.current.synchronousLoadResource(from: path)
        }catch{
            throw GateEngineError(error)
        }
    }
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            self.data = try await Platform.current.loadResource(from: path)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public func loadGeometry(options: GeometryImporterOptions) async throws(GateEngineError) -> RawGeometry {
        do {
            return try RawGeometryDecoder().decode(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    /// The expected file extension
    /// Write data created with `RawGeometryEncoder` to a file with this extension to be imported by this `GeometryImporter`
    public static let fileExtension: String = "gaterg"
    public static func supportedFileExtensions() -> [String] {
        return [Self.fileExtension]
    }
}
