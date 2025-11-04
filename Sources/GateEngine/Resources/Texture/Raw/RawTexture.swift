/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
 
public struct RawTexture: Sendable {
    public let imageSize: Size2i
    public let imageData: Data
    
    public init(imageSize: Size2i, imageData: Data) {
        self.imageSize = imageSize
        self.imageData = imageData
    }
}
