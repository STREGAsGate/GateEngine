/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(ImageIO) && canImport(CoreImage)
import Foundation
import GameMath
import ImageIO
import CoreImage
import UniformTypeIdentifiers

public class ApplePlatformImageImporter: TextureImporter {
    public required init() {}
    
    public func process(data: Data, size: Size2?, options: TextureImporterOptions) throws -> (data: Data, size: Size2) {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {throw "Failed to decode."}
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {throw "Failed to decode."}
        let size = Size2(Float(image.width), Float(image.height))
        guard let data = image.dataProvider?.data as? Data else {throw "Failed to decode."}
        return (data, size)
    }

    public class func canProcessFile(_ file: URL) -> Bool {
        guard let identifers = (CGImageSourceCopyTypeIdentifiers() as? [CFString])?.compactMap({UTType($0 as String)}) else {return false}
        let uttype = UTType(filenameExtension: file.pathExtension, conformingTo: .image)
        return identifers.contains(where: {$0 == uttype})
    }
}
#endif
