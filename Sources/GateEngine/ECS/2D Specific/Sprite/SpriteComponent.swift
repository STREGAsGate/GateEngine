/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class SpriteComponent: Component {
    public var opacity: Float = 1
    public var depth: Float = 0
    public enum Mode {
        case subRect
        case pose
        case animation
    }
    public var spriteSheet: SpriteSheet! = nil
    public var mode: Mode = .pose

    public var subRect: Rect = .zero
    
    public var poseCoordinate: Position2 = .zero
    public var poseSize: Size2 = .zero

    public var animations: [SpriteAnimation] = []
    public var activeAnimationIndex: Int = 0
    public var activeAnimation: SpriteAnimation? {
        if activeAnimationIndex < animations.count {
            return animations[activeAnimationIndex]
        }
        return nil
    }
    
    @MainActor public func sprite() -> Sprite? {
        switch mode {
        case .subRect:
            return spriteSheet?.sprite(at: subRect)
        case .pose:
            return spriteSheet?.sprite(at: poseCoordinate, withSpriteSize: poseSize)
        case .animation:
            return activeAnimation?.currentSprite()
        }
    }

    public init() {}

    public static let componentID: ComponentID = ComponentID()
}
