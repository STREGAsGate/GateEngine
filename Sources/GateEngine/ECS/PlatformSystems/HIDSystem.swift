/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class HIDSystem: PlatformSystem {
    @inlinable
    override func update(withTimePassed deltaTime: Float) {
        game.hid.gamePads.update()
        game.hid.screen.update()
    }
    
    override class var phase: PlatformSystem.Phase {return .preUpdating}
}
