/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class SpriteSheet {
    public let texture: Texture
    public var sampleFilter: Sprite.SampleFilter
    public var tintColor: Color
    public init(texture: Texture, sampleFilter: Sprite.SampleFilter = .nearest, tintColor: Color = .white) {
        self.texture = texture
        self.sampleFilter = sampleFilter
        self.tintColor = tintColor
    }

    public func sprite(at coord: Position2, withSpriteSize spriteSize: Size2) -> Sprite {
        var position = Position2(spriteSize)
        position.x *= Float(coord.x)
        position.y *= Float(coord.y)
        let size = Size2(spriteSize)
        let rect: Rect = Rect(position: position, size: size)
        return Sprite(texture: texture, bounds: rect, sampleFilter: sampleFilter, tintColor: tintColor)
    }
    
    public func sprite(at rect: Rect) -> Sprite {
        return Sprite(texture: texture, bounds: rect, sampleFilter: sampleFilter, tintColor: tintColor)
    }
}
