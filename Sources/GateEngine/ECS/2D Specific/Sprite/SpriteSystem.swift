/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class SpriteSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        for entity in game.entities {
            if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
                switch spriteComponent.playbackState {
                case .play:
                    if spriteComponent.animations.indices.contains(spriteComponent.activeAnimationIndex) {
                        spriteComponent.animations[spriteComponent.activeAnimationIndex].appendTime(deltaTime)
                    }
                case .stop:
                    spriteComponent.activeAnimation?.progress = 0
                }
            }
        }
    }

    public override class var phase: System.Phase {.updating}
    public override class func sortOrder() -> SystemSortOrder? {
        return .spriteSystem
    }
}
