/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if GATEENGINE_PLATFORM_HAS_SynchronousFileSystem
import Foundation

public struct TextureAtlas {
    public let imageSize: Size2
    public let imageData: Data
    private let blockSize: Int
    private let textures: [Texture]

    internal struct Texture {
        let path: String
        let size: Size2
        let coordinate: (x: Int, y: Int)
    }
    
    internal init(size: Size2, data: Data, blockSize: Int, textures: [Texture]) {
        self.imageSize = size
        self.imageData = data
        self.blockSize = blockSize
        self.textures = textures
    }
    
    @available(*, unavailable, message: "You must use a `TextureAtlasBuilder` object to generate a `TextureAtlas`.")
    public init() {
        fatalError()
    }
    
    /**
     Move a UV into the Atlas texture space.
     
     Call this function to convert your geometry UVs to the new atlas texture.
     */
    public func convertUV(_ inUV: TextureCoordinate, forTexture path: String) -> TextureCoordinate? {
        guard let texture = textures.first(where: {$0.path == path}) else {
            return nil
        }
        
        var uv = inUV

        //Scale
        uv.x *= texture.size.width / imageSize.width
        uv.y *= texture.size.height / imageSize.height
        
        //Offset
        uv.x += Float(texture.coordinate.x * blockSize) * (1 / imageSize.width)
        uv.y += Float(texture.coordinate.y * blockSize) * (1 / imageSize.height)

        return uv
    }
    
    /// The pixel rect of the texture within the TextureAtlas image data
    public func rect(forTexture path: String) -> Rect? {
        guard let texture = textures.first(where: {$0.path == path}) else {return nil}
        return Rect(
            x: Float(texture.coordinate.x * blockSize),
            y: Float(texture.coordinate.y * blockSize),
            width: texture.size.width,
            height: texture.size.height
        )
    }
    
    @MainActor
    public func createTexture(withMipMapping mipMapping: MipMapping = .auto(levels: .max)) -> GateEngine.Texture {
        return GateEngine.Texture(data: imageData, size: imageSize, mipMapping: mipMapping)
    }
}

extension TextureAtlasBuilder {
    struct Texture: Equatable, Hashable, Sendable {
        let resourcePath: String
        var dataIndex: Array<Data>.Index
        
        nonisolated static func == (lhs: Texture, rhs: Texture) -> Bool {
            return lhs.resourcePath == rhs.resourcePath
        }
        nonisolated func hash(into hasher: inout Hasher) {
            hasher.combine(resourcePath)
        }
    }
    struct TextureData: Equatable, Hashable, Sendable {
        let width: Int
        let height: Int
        let imageData: Data
        var coordinate: (x: Int, y: Int)
        
        nonisolated static func == (lhs: TextureData, rhs: TextureData) -> Bool {
            guard lhs.width == rhs.width && lhs.height == rhs.height else {return false}
            return lhs.imageData.elementsEqual(rhs.imageData)
        }
        nonisolated func hash(into hasher: inout Hasher) {
            hasher.combine(width)
            hasher.combine(height)
            hasher.combine(imageData)
        }
    }
    
    func textureBlocksWide(texturePixelWidth: Float) -> Int {
        return Int(ceil(texturePixelWidth / Float(blockSize)))
    }

    func textureBlocksTall(texturePixelHeight: Float) -> Int {
        return Int(ceil(texturePixelHeight / Float(blockSize)))
    }
}

public final class TextureAtlasBuilder {
    var textures: [TextureAtlasBuilder.Texture] = []
    var textureDatas: [TextureAtlasBuilder.TextureData] = []
    
    /// true if this builder has changed since a TextureAtlas was generated
    public private(set) var needsGenerate: Bool = true
    
    /**
     A unit, in pixels, to restrict the layout of the inserted textures.
     If all your textures are a multiple o
     */
    let blockSize: Int
    var searchGrid: SearchGrid = SearchGrid()
    
    public init(blockSize: Int) {
        assert(blockSize >= 0, "blockSize must be positive.")
        assert(blockSize <= 1024, "blockSize cannot be greater than 1024.")
        self.blockSize = blockSize
    }
    
    /// - returns: `true` if the atlas already has the texture in question
    public func containsTexture(withPath unresolvedPath: String) -> Bool {
        return textures.contains(where: {$0.resourcePath == unresolvedPath})
    }
    
    /**
     Adds a new texture, or updates an existing texture.
     
     - parameter unresolvedPath: The resource path to the texture data.
     - parameter sacrificePerformanceForSize: When `true` additional checks are performed to merge textures that are the same but with different paths. Resulting in a smaller atlas, at the cost of performance.
     */
    public func insertTexture(withPath unresolvedPath: String, sacrificePerformanceForSize: Bool = false) throws {
        if containsTexture(withPath: unresolvedPath) {
            // Cleanup old values
            // If the texture has changed on disk we want to replace it
            removeTexture(withPath: unresolvedPath)
        }
        
        let importer = PNGImporter()
        try importer.synchronousPrepareToImportResourceFrom(path: unresolvedPath)
        let png = try importer.loadTexture(options: .none)
        let width = Int(png.size.width)
        let height = Int(png.size.height)

        var textureData = TextureData(width: width, height: height, imageData: png.data, coordinate: (0,0))
        var dataIndex = self.textureDatas.endIndex
        if sacrificePerformanceForSize, let existingIndex = self.textureDatas.firstIndex(where: {$0 == textureData}) {
            dataIndex = existingIndex
        }else{
            let coord = searchGrid.firstUnoccupiedFor(
                width: textureBlocksWide(texturePixelWidth: png.size.width),
                height: textureBlocksTall(texturePixelHeight: png.size.height),
                markOccupied: true
            )
            textureData.coordinate = coord
            textureDatas.append(textureData)
        }
        
        let texture = Texture(resourcePath: unresolvedPath, dataIndex: dataIndex)
        
        // Append new value
        self.textures.append(texture)
        
        self.needsGenerate = true
    }
    
    /// - returns: `true` if a texture was removed. `false` if the tecture was not found.
    @discardableResult
    public func removeTexture(withPath unresolvedPath: String) -> Bool {
        if let existing = textures.firstIndex(where: {$0.resourcePath == unresolvedPath}) {
            // Remove the texture
            let texture = self.textures.remove(at: existing)
            let textureData = self.textureDatas[texture.dataIndex]
            
            // If the TextureData is no longer referenced, remove it
            if self.textures.contains(where: {$0.dataIndex == texture.dataIndex}) == false {
                // Free the grid area
                searchGrid.markAsOccupied(
                    false,
                    x: textureData.coordinate.x,
                    y: textureData.coordinate.y,
                    width: textureBlocksWide(texturePixelWidth: Float(textureData.width)),
                    height: textureBlocksTall(texturePixelHeight: Float(textureData.height))
                )
                
                // Reindex the Texture dataIndex values
                self.textures = self.textures.map({ texture in
                    var texture = texture
                    if texture.dataIndex > texture.dataIndex {
                        texture.dataIndex -= 1
                    }
                    return texture
                })
                
                // Remove the data
                self.textureDatas.remove(at: texture.dataIndex)
            }
            
            self.needsGenerate = true
            
            return true
        }
        return false
    }
    
    public func generateAtlas() -> TextureAtlas {
        let textureSize: Size2 = Size2(Float(self.searchGrid.width * blockSize), Float(self.searchGrid.height * blockSize))
        
        let dstWidth = Int(textureSize.width * 4)

        var imageData: Data = Data(repeating: 0, count: Int(textureSize.width * textureSize.height) * 4)
        imageData.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
            for texture in textures {
                let textureData = self.textureDatas[texture.dataIndex]
                
                var coord = textureData.coordinate
                coord.x *= blockSize
                coord.y *= blockSize
                let srcWidth = textureData.width * 4
                let x = (coord.x * 4)
                for row in 0 ..< textureData.height {
                    let srcStart = srcWidth * row
                    let srcRange = srcStart ..< (srcStart + srcWidth)

                    let dstStart = (dstWidth * (coord.y + row)) + x
                    let dstRange = dstStart ..< dstStart + srcWidth

                    for i in 0 ..< srcRange.count {
                        let dstIndex = dstRange[i + dstRange.lowerBound]
                        let srcIndex = srcRange[i + srcRange.lowerBound]

                        bytes[dstIndex] = textureData.imageData[srcIndex]
                    }
                }
            }
        }
        
        
        let atlas = TextureAtlas(
            size: textureSize,
            data: imageData,
            blockSize: blockSize,
            textures: textures.indices.map({
                let texture = textures[$0]
                let textureData = textureDatas[texture.dataIndex]
                return TextureAtlas.Texture(
                    path: texture.resourcePath,
                    size: Size2(Float(textureData.width), Float(textureData.height)),
                    coordinate: textureData.coordinate
                )
            })
        )
        
        self.needsGenerate = false
        return atlas
    }
}

extension TextureAtlasBuilder {
    struct SearchGrid {
        var rows: [[Bool]] = []
        var width: Int {
            return rows.first?.count ?? 0
        }
        var height: Int {
            return rows.count
        }
        
        
        mutating func markAsOccupied(_ occupied: Bool, x: Int, y: Int, width: Int, height: Int) {
            // Insert new rows
            while rows.count < y + height {
                rows.append(Array(repeating: false, count: self.width))
            }
            // Insert new columns
            while rows[0].count < x + width {
                for rowIndex in rows.indices {
                    rows[rowIndex].append(false)
                }
            }
            // Mark occupied
            for row in y ..< y + height {
                for column in x ..< x + width {
                    rows[row][column] = occupied
                }
            }
        }
        
        func isOccupied(x: Int, y: Int, width: Int, height: Int) -> Bool {
            if x < self.width && y < self.height {
                for row in y ..< min(y + height, self.height) {
                    for column in x ..< min(x + width, self.width) {
                        if rows[row][column] == true {
                            // If any slot is occupied, the rectangle wont fit here
                            return true
                        }
                    }
                }
            }
            return false
        }
        
        mutating func firstUnoccupiedFor(width: Int, height: Int, markOccupied: Bool) -> (x: Int, y: Int) {
            for rowIndex in 0 ..< self.height {
                for columnIndex in 0 ..< self.width {
                    guard columnIndex + width < self.width else {break}
                    if isOccupied(x: columnIndex, y: rowIndex, width: width, height: height) == false {
                        if markOccupied {
                            markAsOccupied(true, x: columnIndex, y: rowIndex, width: width, height: height)
                        }
                        return (columnIndex, rowIndex)
                    }
                }
            }
            
            let coord: (x: Int, y: Int)
            // Attempt to keep the search grid a square
            if self.width + width > self.height + height {
                // Prefer vertical expansion
                coord = (x: 0, y: self.height)
            }else{
                // Prefer horizontal expansion
                coord = (x: self.width, y: 0)
            }
            if markOccupied {
                markAsOccupied(true, x: coord.x, y: coord.y, width: width, height: height)
            }
            return coord
        }
    }
}
#endif
