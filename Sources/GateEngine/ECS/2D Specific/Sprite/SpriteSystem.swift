/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class SpriteSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        for entity in game.entities {
            if let spriteComponet = entity.component(ofType: SpriteComponent.self) {
                switch spriteComponet.playbackState {
                case .play:
                    if spriteComponet.animations.indices.contains(spriteComponet.activeAnimationIndex) {
                        spriteComponet.animations[spriteComponet.activeAnimationIndex].appendTime(deltaTime)
                    }
                case .stop:
                    spriteComponet.activeAnimation?.progress = 0
                }
            }
        }
    }

    public override class var phase: System.Phase {.updating}
    public override class func sortOrder() -> SystemSortOrder? {
        return .spriteSystem
    }
}
