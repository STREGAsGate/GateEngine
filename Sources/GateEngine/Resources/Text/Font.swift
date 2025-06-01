/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

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
    nonisolated var preferredSampleFilter: Text.SampleFilter { get }
    @MainActor mutating func texture(forKey key: Font.Key) -> Texture
    @MainActor mutating func characterData(forKey key: Font.Key, character: Character)
        -> CharacterData
    @MainActor mutating func alignedCharacter(
        forKey key: Font.Key,
        character: Character,
        origin: Position2,
        xAdvance: inout Float
    ) -> AlignedCharacter
}

public final class Font: OldResource {
    @RequiresState(.ready)
    var backend: (any FontBackend)! = nil

    internal var preferredSampleFilter: Text.SampleFilter {
        return backend.preferredSampleFilter
    }

    public init(ttfRegular regular: String) {
        super.init()
        #if DEBUG
        self._backend.configure(withOwner: self)
        #endif
        #if canImport(TrueType)
        Task.detached {
            do {
                let backend = try await TTFFont(regular: regular)
                Task { @MainActor in
                    self.backend = backend
                    self.state = .ready
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.debug("Resource \(regular) failed ->", error)
                    self.state = .failed(error: error)
                }
            } catch {
                Log.fatalError("error must be a GateEngineError")
            }
        }
        #else
        Task { @MainActor in
            Log.debug("Resource \(regular) failed: Cannot load ttf fonts on this platform.")
            self.state = .failed(reason: "Cannot load ttf fonts on this platform.")
        }
        #endif
    }

    public init(pngRegular regular: String) {
        super.init()
        #if DEBUG
        self._backend.configure(withOwner: self)
        #endif
        Task.detached {
            do {
                let backend = try await ImageFont(regular: regular)
                Task { @MainActor in
                    self.backend = backend
                    self.state = .ready
                }
            } catch let error as GateEngineError {
                Task { @MainActor in
                    Log.debug("Resource \(regular) failed ->", error)
                    self.state = .failed(error: error)
                }
            } catch {
                fatalError("error must be a GateEngineError")
            }
        }
    }

    @MainActor func characterData(
        forCharacter character: Character,
        pointSize: UInt,
        style: Font.Style
    ) -> CharacterData {
        let key = Key(style: style, pointSize: pointSize)
        return backend.characterData(forKey: key, character: character)
    }

    @MainActor func alignedCharacter(
        forCharacter character: Character,
        pointSize: UInt,
        style: Font.Style,
        origin: Position2,
        xAdvance: inout Float
    ) -> AlignedCharacter {
        let key = Key(style: style, pointSize: pointSize)
        return backend.alignedCharacter(
            forKey: key,
            character: character,
            origin: origin,
            xAdvance: &xAdvance
        )
    }

    @MainActor func texture(forPointSize pointSize: UInt, style: Font.Style) -> Texture {
        let key = Key(style: style, pointSize: pointSize)
        return backend.texture(forKey: key)
    }
}

@MainActor extension Font {
    public enum Style: Int {
        case regular
        case bold
        case italic
        case boldItalic
    }

    public struct Key: Hashable {
        let style: Font.Style
        let pointSize: UInt
    }

    @inlinable
    public nonisolated static var `default`: Font { .tuffy }

    public nonisolated static let tuffy: Font = Font(ttfRegular: "GateEngine/Fonts/Tuffy/Tuffy.ttf")
    public nonisolated static let tuffyBold: Font = Font(ttfRegular: "GateEngine/Fonts/Tuffy/Tuffy_Bold.ttf")
    public nonisolated static let micro: Font = Font(pngRegular: "GateEngine/Fonts/Micro/micro.png")
    public nonisolated static let babel: Font = Font(pngRegular: "GateEngine/Fonts/Babel/Babel.png")
}
