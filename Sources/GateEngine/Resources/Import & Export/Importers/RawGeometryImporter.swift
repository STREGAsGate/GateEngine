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
    public required init() {}

    public func loadData(path: String, options: GeometryImporterOptions) async throws -> RawGeometry {
        let data = try await Game.shared.platform.loadResource(from: path)
        return try RawGeometryDecoder().decode(data)
    }

    public static func canProcessFile(_ file: URL) -> Bool {
        return file.pathExtension.caseInsensitiveCompare(Self.fileExtension) == .orderedSame
    }
    
    /// The expected file extension
    /// Write data created with `RawGeometryEncoder` to a file with this extension to be imported by this `GeometryImporter`
    public static let fileExtension: String = "gaterg"
}
