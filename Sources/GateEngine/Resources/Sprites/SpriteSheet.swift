/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class SpriteSheet {
    public let texture: Texture
    public var sampleFilter: Sprite.SampleFilter
    public var tintColor: Color

    public init(
        texture: Texture,
        sampleFilter: Sprite.SampleFilter = .nearest,
        tintColor: Color = .white
    ) {
        self.texture = texture
        self.sampleFilter = sampleFilter
        self.tintColor = tintColor
    }

    @inlinable @inline(__always) @_disfavoredOverload
    public convenience init(
        as path: TexturePath,
        mipMapping: MipMapping = .none,
        options: TextureImporterOptions = .none,
        sampleFilter: Sprite.SampleFilter = .nearest,
        tintColor: Color = .white
    ) {
        self.init(
            path: path.value,
            mipMapping: mipMapping,
            options: options,
            sampleFilter: sampleFilter,
            tintColor: tintColor
        )
    }

    public convenience init(
        path: String,
        sizeHint: Size2? = nil,
        mipMapping: MipMapping = .none,
        options: TextureImporterOptions = .none,
        sampleFilter: Sprite.SampleFilter = .nearest,
        tintColor: Color = .white
    ) {
        let texture = Texture(path: path, sizeHint: sizeHint, mipMapping: mipMapping, options: options)
        self.init(texture: texture, sampleFilter: sampleFilter, tintColor: tintColor)
    }

    public func sprite(at coord: Position2, withSpriteSize spriteSize: Size2) -> Sprite {
        let rect: Rect = Rect(position: coord * spriteSize, size: spriteSize)
        return Sprite(
            texture: texture,
            bounds: rect,
            sampleFilter: sampleFilter,
            tintColor: tintColor
        )
    }

    public func sprite(at rect: Rect) -> Sprite {
        return Sprite(
            texture: texture,
            bounds: rect,
            sampleFilter: sampleFilter,
            tintColor: tintColor
        )
    }
}
