/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

struct FontQuad {
    let min: Position2
    let max: Position2
}
struct CharacterData {
    let texturePosition: FontQuad
    let offset: Position2
    let xAdvance: Float
}
struct AlignedCharacter {
    let position: FontQuad
    let texturePosition: FontQuad
}

protocol FontBackend {
    var preferredSampleFilter: Text.SampleFilter {get}
    @MainActor mutating func texture(forKey key: Font.Key) -> Texture
    mutating func characterData(forKey key: Font.Key, character: Character) -> CharacterData
    mutating func alignedCharacter(forKey key: Font.Key, character: Character, origin: Position2, xAdvance: inout Float) -> AlignedCharacter
}

public class Font: OldResource {
    @RequiresState(.ready)
    var backend: FontBackend! = nil
    
    internal var preferredSampleFilter: Text.SampleFilter {
        return backend.preferredSampleFilter
    }
    
    public init(ttfRegular regular: String) {
        super.init()
        #if DEBUG
        self._backend.configure(withOwner: self)
        #endif
        Task(priority: .utility) {
            do {
                let backend = try await TTFFont(regular: regular)
                Task { @MainActor in
                    self.backend = backend
                    self.state = .ready
                }
            }catch{
                Task { @MainActor in
                    self.state = .failed(reason: "\(error)")
                }
            }
        }
    }
    
    public init(pngRegualar regular: String) {
        super.init()
        #if DEBUG
        self._backend.configure(withOwner: self)
        #endif
        Task(priority: .utility) {
            do {
                let backend = try await ImageFont(regular: regular)
                Task { @MainActor in
                    self.backend = backend
                    self.state = .ready
                }
            }catch{
                Task { @MainActor in
                    self.state = .failed(reason: "\(error)")
                }
            }
        }
    }
    
    func characterData(forCharacter character: Character, pointSize: UInt, style: Font.Style) -> CharacterData {
        let key = Key(style: style, pointSize: pointSize)
        return backend.characterData(forKey: key, character: character)
    }
    
    func alignedCharacter(forCharacter character: Character, pointSize: UInt, style: Font.Style, origin: Position2, xAdvance: inout Float) -> AlignedCharacter {
        let key = Key(style: style, pointSize: pointSize)
        return backend.alignedCharacter(forKey: key, character: character, origin: origin, xAdvance: &xAdvance)
    }
    
    @MainActor func texture(forPointSize pointSize: UInt, style: Font.Style) -> Texture {
        let key = Key(style: style, pointSize: pointSize)
        return backend.texture(forKey: key)
    }
}

@MainActor public extension Font {
    enum Style: Int {
        case regular
        case bold
        case italic
        case boldItalic
    }
    
    struct Key: Hashable {
        let style: Font.Style
        let pointSize: UInt
    }
    
    static let `default`: Font = tuffy
    
    static let tuffy: Font = Font(ttfRegular: "GateEngine/Fonts/Tuffy/Tuffy.ttf")
    static let micro: Font = Font(pngRegualar: "GateEngine/Fonts/Micro/Micro.png")
    static let babel: Font = Font(pngRegualar: "GateEngine/Fonts/Babel/Babel.png")
}
