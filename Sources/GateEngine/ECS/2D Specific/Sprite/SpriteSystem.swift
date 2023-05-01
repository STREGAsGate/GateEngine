/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class SpriteSystem: System {
    public override func update(game: Game, input: HID, layout: WindowLayout, withTimePassed deltaTime: Float) {
        for entity in game.entities {
            if let spriteComponet = entity.component(ofType: SpriteComponent.self) {
                if spriteComponet.activeAnimationIndex < spriteComponet.animations.count {
                    spriteComponet.animations[spriteComponet.activeAnimationIndex].appendTime(deltaTime)
                }
            }
        }
    }

    public override class var phase: System.Phase {.updating}
}
