/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

struct ImageFont: FontBackend {
    private let fontData: [Font.Style:(data: Data, size: Size2?, importer: TextureImporter.Type)]
    internal var nativePointSizes: [Font.Style:UInt] = [:]
    internal var textures: [Font.Style:Texture] = [:]
    internal var characterXAdvances: [Font.Style:[Float]] = [:]
    
    init(regular: String) async throws {
        let url = URL(fileURLWithPath: regular)
        guard let importer = await Game.shared.resourceManager.textureImporterForFile(url) else {
            Log.debug("No TextureImporter for file \"\(regular)\"")
            throw GateEngineError.failedToDecode("No TextureImporter for file \"\(regular)\"")
        }
        let regular = try await importer.loadData(path: regular, options: .none)
        
        let fontData: [Font.Style:(data: Data, size: Size2?, importer: TextureImporter.Type)] = [.regular : (regular.data, regular.size, type(of: importer))]
//        fontData[.bold] = bold
//        fontData[.italic] = italic
//        fontData[.boldItalic] = boldItalic
        self.fontData = fontData
    }
    
    @MainActor mutating func characterData(forKey key: Font.Key, character: Character) -> CharacterData {
        let textureSize = textures[key.style]!.size
        let pixelsHigh = textureSize.width / 16
        let pixelsWide = textureSize.height / 16
        
        let utf8Decimal = Int(character.utf8.first!)
        let codepoint: Float = Float(utf8Decimal)
        let row: Float = Float(UInt(codepoint / 16))
        let column: Float = 16 + (Float(codepoint) - ((row + 1) * 16))
        
        let nPixelX = 1 / textureSize.width
        let nPixelY = 1 / textureSize.height
        
        let minX: Float = nPixelX * (column * pixelsWide)
        let maxX: Float = minX + (nPixelX * pixelsWide)
        
        let minY: Float = nPixelY * (row * pixelsHigh)
        let maxY: Float = minY + (nPixelY * pixelsHigh)
        
        let xAdvance = characterXAdvances[key.style]?[utf8Decimal] ?? 0
        return CharacterData(texturePosition: FontQuad(min: Position2(minX, minY),
                                                       max: Position2(maxX, maxY)),
                             offset: .zero,
                             xAdvance: xAdvance)
    }
    
    @MainActor mutating func alignedCharacter(forKey key: Font.Key, character: Character, origin: GameMath.Position2, xAdvance: inout Float) -> AlignedCharacter {
        
        let nativePointSize = nativePointSizes[key.style]!
        let scaledPointSize = Float(key.pointSize - (key.pointSize % nativePointSize))
        
        let sizeMultiple = floor(scaledPointSize / Float(nativePointSize))
 
        let charData = self.characterData(forKey: key, character: character)
        xAdvance = charData.xAdvance * sizeMultiple
        
        let maxX = origin.x + Float(scaledPointSize)
        let maxY = origin.y + Float(scaledPointSize)
        return AlignedCharacter(position: FontQuad(min: Position2(origin.x, origin.y),
                                                   max: Position2(maxX, maxY)),
                                texturePosition: charData.texturePosition)
    }
    
    mutating func texture(forKey key: Font.Key) -> Texture {
        if let existing = textures[key.style] {
            return existing
        }
        populate(style: key.style)
        return textures[key.style]!
    }
    
    @MainActor private mutating func populate(style: Font.Style) {
        let fontData = fontData[style]!
        let (data, size) = try! fontData.importer.init().process(data: fontData.data, size: fontData.size, options: .none)
        
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)
        let pointSize = Int(width / 16)
        
        let pixelsHigh = width / 16
        let pixelsWide = height / 16
                
        var xAdvances = Array<Float>(repeating: 0, count: 256)
        var image: [UInt8] = []
        image.reserveCapacity(Int(width * height * 4))
        for index in stride(from: 3, to: data.count, by: 4) {
            let byte = data[index]
            image.append(255)
            image.append(255)
            image.append(255)
            image.append(byte)
            
            if byte > 0 {
                let pixelX = (index / 4) % width
                let pixelY = (index / 4) / width
                
                let xIndex = pixelX / pixelsWide
                let yIndex = pixelY / pixelsHigh
                
                let codePoint = (16 * yIndex) + xIndex
                xAdvances[codePoint] = Float(max(xAdvances[codePoint], Float(pixelX % pixelsWide) + 2))
            }
        }
        
        var total: Float = 0
        var count = 0
        for index in xAdvances.indices {
            let v = xAdvances[index]
            if v > 0 {
                total += v
                count += 1
            }
        }
        
        let averageXAdvance = total / Float(count)
        for index in xAdvances.indices {
            if xAdvances[index] == 0 {
                xAdvances[index] = averageXAdvance
            }
        }

        self.characterXAdvances[style] = xAdvances
        assert(image.count == data.count)
        
        let texture = Texture(data: Data(image), size: size, mipMapping: .none)
        
        self.textures[style] = texture
        self.nativePointSizes[style] = UInt(pointSize)
    }
    
    var preferredSampleFilter: Text.SampleFilter {.nearest}
}
