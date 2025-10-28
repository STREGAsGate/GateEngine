/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

/**
 Handles loading `RawSkeletalAnimation` from a file as encoded by `RawSkeletalAnimationEncoder`
 
 The file extension of the asset to load must match `RawSkeletalAnimationImporter.fileExtension`
 */
public final class RawSkeletalAnimationImporter: SkeletalAnimationImporter, GateEngineNativeResourceImporter {
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
    
    public func loadSkeletalAnimation(options: SkeletalAnimationImporterOptions) async throws -> RawSkeletalAnimation {
        do {
            return try RawSkeletalAnimationDecoder().decode(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    /// The expected file extension
    /// Write data created with `RawSkeletalAnimationEncoder` to a file with this extension to be imported by this `SkeletalAnimationImporter`
    public static let fileExtension: String = "gatesani"
}
