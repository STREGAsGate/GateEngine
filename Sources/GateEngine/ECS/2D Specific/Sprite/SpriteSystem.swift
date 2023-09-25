/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class SpriteSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        for entity in game.entities {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                switch spriteComponent.playbackState {
                case .play, .stopAtLoop, .pauseAtLoop:
                    if spriteComponent.animations.indices.contains(spriteComponent.activeAnimationIndex) {
                        let didRepeat = spriteComponent.animations[spriteComponent.activeAnimationIndex].didRepeatAfterAppendingTime(deltaTime)
                        if didRepeat {
                            if spriteComponent.playbackState == .stopAtLoop {
                                spriteComponent.playbackState = .stop
                                fallthrough
                            }else if spriteComponent.playbackState == .pauseAtLoop {
                                spriteComponent.playbackState = .pause
                            }
                        }
                    }
                case .stop:
                    spriteComponent.activeAnimation?.progress = 0
                case .pause:
                    break
                }
            }
        }
    }

    public override class var phase: System.Phase { .updating }
    public override class func sortOrder() -> SystemSortOrder? { .spriteSystem }
}
