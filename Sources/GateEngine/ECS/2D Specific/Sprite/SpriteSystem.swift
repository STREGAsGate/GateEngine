/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class SpriteSystem: System {
    public override func update(withTimePassed deltaTime: Float) {
        for entity in game.entities {
            entity.component(ofType: SpriteComponent.self)?.activeAnimation?.appendTime(deltaTime)
        }
    }

    public override class var phase: System.Phase {.updating}
}
