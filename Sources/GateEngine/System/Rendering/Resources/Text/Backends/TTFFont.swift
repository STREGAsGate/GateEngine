/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(TrueType)
import TrueType

typealias CharData = TrueType.stbtt_bakedchar
typealias AlignedQuad = TrueType.stbtt_aligned_quad

@_transparent
fileprivate func bakeFontBitmap(fontData: Data, _ offset: Int32 = 0, pixelHeight: Float, pixels: inout [UInt8], pixelsWidth: Int32, pixelsHeight: Int32, firstChar: Int32, charCount: Int32, charData: inout [CharData]) -> Int32 {
    return fontData.withUnsafeBytes { fontData in
        return stbtt_BakeFontBitmap(fontData.baseAddress?.assumingMemoryBound(to: UInt8.self), offset, pixelHeight, &pixels, pixelsWidth, pixelsHeight, firstChar, charCount, &charData)
    }
}

@_transparent
fileprivate func getBakedQuad(characterData: [CharData], pixelsWidth: Int32, pixelsHeight: Int32, charIndex: Int32, xPosition: inout Float, yPosition: inout Float) -> AlignedQuad {
    return characterData.withUnsafeBufferPointer { characterData in
        var quad = AlignedQuad()
        stbtt_GetBakedQuad(characterData.baseAddress, pixelsWidth, pixelsHeight, charIndex, &xPosition, &yPosition, &quad, 1)
        return quad
    }
}

@MainActor struct TTFFont: FontBackend {
    private let fontData: [Font.Style:Data]
    internal var textures: [Font.Key:Texture] = [:]
    internal var textureSizes: [Font.Key:Size2] = [:]
    internal var characterDatas: [Font.Key:[CharData]] = [:]
    
    init(regular: String) async throws {
        let regular = try await Game.shared.platform.loadResource(from: regular)
        assert(regular.isEmpty == false, "ttf file cannot be empty.")
        let fontData: [Font.Style:Data] = [.regular : regular]
//        fontData[.bold] = bold
//        fontData[.italic] = italic
//        fontData[.boldItalic] = boldItalic
        self.fontData = fontData
    }
    
    mutating func characterData(forKey key: Font.Key, character: Character) -> CharacterData {
        let characterData: [CharData] = {
            if let existing = self.characterDatas[key] {
                return existing
            }
            populate(forPointSize: key.pointSize, style: key.style)
            return self.characterDatas[key]!
        }()
        
        let codepoint = character.utf8.first!
        let charData = characterData[Int(codepoint)]
        return CharacterData(texturePosition: FontQuad(min: Position2(Float(charData.x0), Float(charData.y0)),
                                                       max: Position2(Float(charData.x1), Float(charData.y1))),
                             offset: Position2(charData.xoff, charData.yoff),
                             xAdvance: charData.xadvance)
    }
    
    mutating func alignedCharacter(forKey key: Font.Key, character: Character, origin: GameMath.Position2, xAdvance: inout Float) -> AlignedCharacter {
        let textureSize = textureSize(forPointSize: key.pointSize, style: key.style)
        let characterData: [CharData] = {
            if let existing = self.characterDatas[key] {
                return existing
            }
            populate(forPointSize: key.pointSize, style: key.style)
            return self.characterDatas[key]!
        }()
        let index = Int(character.utf8.first!)
        var pX = origin.x
        var pY = origin.y
        let result = getBakedQuad(characterData: characterData, pixelsWidth: Int32(textureSize.width), pixelsHeight: Int32(textureSize.height), charIndex: Int32(index), xPosition: &pX, yPosition: &pY)
        xAdvance = pX - origin.x
        return AlignedCharacter(position: FontQuad(min: Position2(result.x0, result.y0),
                                                   max: Position2(result.x1, result.y1)),
                                texturePosition: FontQuad(min: Position2(result.s0, result.t0),
                                                          max: Position2(result.s1, result.t1)))
    }
    
    mutating func texture(forKey key: Font.Key) -> Texture {
        if let existing = textures[key] {
            return existing
        }
        populate(forPointSize: key.pointSize, style: key.style)
        return textures[key]!
    }
    
    private func textureSize(forPointSize pointSize: UInt, style: Font.Style) -> Size2 {
        let size = Float((pointSize + 1) * 10)
        return Size2(size, size)
    }
    
    private mutating func populate(forPointSize pointSize: UInt, style: Font.Style) {
        let size = textureSize(forPointSize: pointSize, style: style)
        let width: Int32 = Int32(size.width)
        let height: Int32 = Int32(size.height)
        
        var charData: [CharData] = Array(repeating: CharData(), count: 256)
        var pixels: [UInt8] = Array(repeating: .max, count: Int(width * height))
        let data: Data = fontData[style] ?? fontData[.regular]!
        let result = bakeFontBitmap(fontData: data, pixelHeight: Float(pointSize), pixels: &pixels, pixelsWidth: width, pixelsHeight: height, firstChar: 0, charCount: 256, charData: &charData)
        assert(result > 0)
        
        var image: [UInt8] = []
        image.reserveCapacity(Int(width * height * 4))
        for pixel in pixels {
            image.append(pixel)
            image.append(pixel)
            image.append(pixel)
            image.append(pixel)
        }
        
        let texture = Texture(data: Data(image), size: size, mipMapping: .none)
        
        let key = Font.Key(style: style, pointSize: pointSize)
        self.textures[key] = texture
        self.textureSizes[key] = Size2(Float(width), Float(height))
        self.characterDatas[key] = charData
    }
    
    nonisolated var preferredSampleFilter: Text.SampleFilter {.nearest}
}

#endif
