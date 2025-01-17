/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(ImageIO) && canImport(CoreImage)

import ImageIO
import CoreImage
import CoreServices

public final class ApplePlatformImageImporter: TextureImporter {
    public required init() {}

    public func process(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (
        data: Data, size: Size2
    ) {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw GateEngineError.generic("Failed to decode image source.")
        }
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw GateEngineError.generic("Failed to decode subimage zero.")
        }
        let size = Size2(Float(image.width), Float(image.height))
        guard let data = image.dataProvider?.data as? Data else {
            throw GateEngineError.generic("Failed to decode data.")
        }
        return (data, size)
    }

    public static func canProcessFile(_ file: URL) -> Bool {
        guard let identifiers = (CGImageSourceCopyTypeIdentifiers() as? [CFString]) else {
            return false
        }
        guard
            let uttype = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension,
                file.pathExtension as CFString,
                kUTTypeImage
            )?.takeRetainedValue()
        else { return false }
        return identifiers.contains(where: { $0 == uttype })
    }
}

#endif
