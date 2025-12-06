/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(ImageIO) && canImport(CoreImage)

import ImageIO
import CoreImage
import CoreServices
import GameMath
import UniformTypeIdentifiers

public final class ApplePlatformImageImporter: TextureImporter {
    var data: Data! = nil
    var size: Size2i! = nil
    public required init() {}
    
    public func synchronousPrepareToImportResourceFrom(path: String) throws(GateEngineError) {
        do {
            let data = try Platform.current.synchronousLoadResource(from: path)
            try self.populateFromData(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public func prepareToImportResourceFrom(path: String) async throws(GateEngineError) {
        do {
            let data = try await Platform.current.loadResource(from: path)
            try self.populateFromData(data)
        }catch{
            throw GateEngineError(error)
        }
    }
    
    func populateFromData(_ data: Data) throws(GateEngineError) {
        do {
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                throw GateEngineError.failedToDecode("Failed to decode image source.")
            }
            guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
                throw GateEngineError.failedToDecode("Failed to decode subimage zero.")
            }
            self.size = Size2i(width: image.width, height: image.height)
            guard let data = image.dataProvider?.data as? Data else {
                throw GateEngineError.failedToDecode("Failed to decode data.")
            }
            self.data = data
        }catch{
            throw GateEngineError(error)
        }
    }
    
    public func synchronousLoadTexture(options: TextureImporterOptions) throws(GateEngineError) -> RawTexture {
        return RawTexture(imageSize: size, imageData: data)
    }

    public func loadTexture(options: TextureImporterOptions) async throws(GateEngineError) -> RawTexture {
        return try synchronousLoadTexture(options: options)
    }

    public static func canProcessFile(_ path: String) -> Bool {
        let pathExtension = URL(fileURLWithPath: path).pathExtension
        guard pathExtension.isEmpty == false else {return false}
        guard let uttype = UTType(tag: pathExtension, tagClass: .filenameExtension, conformingTo: .image) else {
            return false
        }
        guard let identifiers = CGImageSourceCopyTypeIdentifiers() as? [CFString] else {
            return false
        }
        return identifiers.contains(where: { UTType($0 as String) == uttype })
    }
}

#endif
