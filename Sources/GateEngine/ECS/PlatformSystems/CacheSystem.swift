/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class CacheSystem: PlatformSystem {
    @inlinable
    override func update(withTimePassed deltaTime: Float) {
        game.resourceManager.update(withTimePassed: deltaTime)
    }
    
    override class var phase: PlatformSystem.Phase {return .postDeffered}
}
