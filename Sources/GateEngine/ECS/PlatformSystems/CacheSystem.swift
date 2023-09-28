/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class CacheSystem: PlatformSystem {
    @inlinable
    override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        game.resourceManager.update(withTimePassed: deltaTime)
    }

    override class var phase: PlatformSystem.Phase { return .postDeferred }
    override class func sortOrder() -> PlatformSystemSortOrder? { .cacheSystem }
}
