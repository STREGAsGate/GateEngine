/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class SpriteComponent: Component {
    public var depth: Float = 0
    public var opacity: Float = 1
    public var tintColor: Color = .white

    public var spriteSheet: SpriteSheet? = nil
    public var spriteRect: Rect = .zero
    public var spriteSize: Size2 {
        get {
            return self.spriteRect.size
        }
        set {
            self.spriteRect.size = newValue
        }
    }

    public var spriteCoordinate: Position2 {
        get {
            let x = self.spriteRect.position.x / self.spriteSize.width
            let y = self.spriteRect.position.y / self.spriteSize.height
            return Position2(x, y)
        }
        set {
            precondition(spriteSize != .zero, "spriteSize must be set first!")
            let x = self.spriteSize.width * newValue.x
            let y = self.spriteSize.height * newValue.y
            self.spriteRect.position = Position2(x, y)
        }
    }

    public var animations: [SpriteAnimation] = []
    public var activeAnimationIndex: Int = 0
    public var activeAnimation: SpriteAnimation? {
        get {
            if animations.indices.contains(activeAnimationIndex) {
                return animations[activeAnimationIndex]
            }
            return nil
        }
        set {
            guard let newValue else { return }
            animations[activeAnimationIndex] = newValue
        }
    }

    public enum PlaybackState {
        case play
        case stop
    }
    public lazy var playbackState: PlaybackState = activeAnimation != nil ? .play : .stop

    @MainActor public func sprite() -> Sprite? {
        assert(spriteSize != .zero, "spriteSize cannot be zero.")
        switch playbackState {
        case .play:
            if let animation = activeAnimation,
                let texture = spriteSheet?.texture,
                texture.state == .ready
            {
                let columns = texture.size.width / spriteSize.width
                let rows = texture.size.height / spriteSize.height
                let startFrame = (animation.spriteSheetStart.y * columns) + animation.spriteSheetStart.x
                let endFrame = {
                    if let frameCount = animation.frameCount {
                        return startFrame + frameCount
                    }
                    let framesInAnimation = (columns * rows) - startFrame
                    return framesInAnimation
                }()
                let currentFrame = floor(
                    startFrame.interpolated(to: endFrame, .linear(animation.progress))
                )

                let currentRow = floor(currentFrame / columns)
                let currentColumn = currentFrame - (columns * currentRow)
                let coord = Position2(currentColumn, currentRow)

                return spriteSheet?.sprite(at: coord, withSpriteSize: spriteSize)
            }
            return nil
        case .stop:
            return spriteSheet?.sprite(at: spriteRect)
        }
    }

    public init() {}

    public static let componentID: ComponentID = ComponentID()
}
