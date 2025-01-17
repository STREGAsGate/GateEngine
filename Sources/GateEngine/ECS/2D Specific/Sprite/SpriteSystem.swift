/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class SpriteSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for entity in context.entities {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                if spriteComponent.moveToNextAnimationIfNeeded {
                    spriteComponent.moveToNextAnimationIfNeeded = false
                    if spriteComponent.activeAnimation?.repeats == true {
                        let progress = spriteComponent.activeAnimation?.progress ?? 0
                        spriteComponent.animationQueue.removeFirst()
                        spriteComponent.activeAnimation?.progress = progress
                        spriteComponent.activeAnimationIndexDidChange = false
                    }else{
                        spriteComponent.animationQueue.removeFirst()
                    }
                }
                if spriteComponent.activeAnimationIndexDidChange {
                    spriteComponent.activeAnimationIndexDidChange = false
                    spriteComponent.activeAnimation?.progress = 0
                }
                switch spriteComponent.playbackState {
                case .play, .stopAtLoop, .pauseAtLoop, .playNextAnimationAtLoop:
                    if let activeAnimationIndex = spriteComponent.animationQueue.first {
                        if spriteComponent.animations.indices.contains(activeAnimationIndex) {
                            let didRepeat = spriteComponent.animations[activeAnimationIndex].didRepeatAfterAppendingTime(deltaTime)
                            if didRepeat {
                                if spriteComponent.playbackState == .playNextAnimationAtLoop {
                                    spriteComponent.moveToNextAnimationIfNeeded = true
                                    spriteComponent.playbackState = .play
                                }else if spriteComponent.playbackState == .stopAtLoop {
                                    spriteComponent.playbackState = .stop
                                    fallthrough
                                }else if spriteComponent.playbackState == .pauseAtLoop {
                                    spriteComponent.playbackState = .pause
                                }
                            }else if spriteComponent.animationQueue.count > 1 {
                                if spriteComponent.playbackState == .play {
                                    if let activeAnimation = spriteComponent.activeAnimation {
                                        if activeAnimation.isFinished {
                                            spriteComponent.animationQueue.removeFirst()
                                        }
                                    }
                                }
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
