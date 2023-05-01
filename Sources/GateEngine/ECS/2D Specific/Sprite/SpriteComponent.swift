/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */


import Foundation
import GameMath

public final class SpriteComponent: Component {
    public var opacity: Float = 1
    public var depth: Float = 0

    public var spriteSheet: SpriteSheet? = nil
    public var spriteRect: Rect = .zero
    public var spriteSize: Size2 {
        get {return spriteRect.size}
        set {self.spriteRect.size = newValue}
    }
    
    public var animations: [SpriteAnimation] = []
    public var activeAnimationIndex: Int = 0
    public var activeAnimation: SpriteAnimation? {
        if activeAnimationIndex < animations.count {
            return animations[activeAnimationIndex]
        }
        return nil
    }
    
    @MainActor public func sprite() -> Sprite? {
        assert(spriteSize != .zero, "spriteSize cannot be zero.")
        if let animation = activeAnimation, let texture = spriteSheet?.texture, texture.state == .ready {
            let columns = texture.size.width / spriteSize.width
            let rows = texture.size.height / spriteSize.height
            let startFrame = (animation.spriteSheetStart.y * columns) + animation.spriteSheetStart.x
            let endFrame = {
                if let frameCount = animation.frameCount {
                    return frameCount
                }
                let framesInAnimation = (columns * rows) - startFrame
                return framesInAnimation
            }()
            let currentFrame = floor(startFrame.interpolated(to: endFrame, .linear(animation.progress)))
            
            let currentRow = floor(currentFrame / columns)
            let currentColumn = currentFrame - (columns * currentRow)
            let coord = Position2(currentColumn, currentRow)
            
            return spriteSheet?.sprite(at: coord, withSpriteSize: spriteSize)
        }
        return spriteSheet?.sprite(at: spriteRect)
    }

    public init() {}

    public static let componentID: ComponentID = ComponentID()
}
