/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor public final class Sprite {
    public typealias SampleFilter = Material.Channel.SampleFilter
    
    public let texture: Texture
    public var bounds: Rect
    public var sampleFilter: SampleFilter
    public var tintColor: Color

    @usableFromInline
    internal lazy var geometryScale: Size3 = {
        return Size3(bounds.size.width, bounds.size.height, 1)
    }()

    @usableFromInline
    internal lazy var uvOffset: Position2 = {
        if Game.shared.renderer.api.origin == .bottomLeft {
            return Position2(
                (bounds.position.x + 0.001) / Float(texture.size.width),
                (bounds.position.y - 0.001) / Float(texture.size.height)
            )
        } else {
            return Position2(
                (bounds.position.x + 0.001) / Float(texture.size.width),
                (bounds.position.y + 0.001) / Float(texture.size.height)
            )
        }
    }()
    @usableFromInline
    internal lazy var uvScale: Size2 = {
        var scale = Size2(
            bounds.size.width / Float(texture.size.width),
            bounds.size.height / Float(texture.size.height)
        )
        
        if Game.shared.renderer.api.origin == .bottomLeft {
            if texture.isRenderTarget {
                scale.y *= -1
            }
        }
    
        return scale
    }()

    @usableFromInline
    internal var isReady: Bool {
        return texture.state == .ready
    }

    public init(
        texture: Texture,
        bounds: Rect,
        sampleFilter: SampleFilter = .nearest,
        tintColor: Color = .white
    ) {
        self.texture = texture
        self.bounds = bounds
        self.sampleFilter = sampleFilter
        self.tintColor = tintColor
    }
}

extension Sprite: Equatable {
    public static func == (lhs: Sprite, rhs: Sprite) -> Bool {
        return lhs.texture == rhs.texture && lhs.bounds == rhs.bounds
    }
}

extension Sprite: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(texture)
        hasher.combine(bounds)
    }
}

extension Texture {
    public func sprite(withBounds bounds: Rect? = nil) -> Sprite {
        let bounds =
            bounds ?? Rect(size: Size2(width: Float(size.width), height: Float(size.height)))
        return Sprite(texture: self, bounds: bounds)
    }
}
