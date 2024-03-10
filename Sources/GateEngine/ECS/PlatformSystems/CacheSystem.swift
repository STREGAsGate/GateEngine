/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class CacheSystem: PlatformSystem {
    @inlinable
    override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        Game.shared.resourceManager.update(withTimePassed: deltaTime)
    }

    override class var phase: PlatformSystem.Phase { return .postDeferred }
    override class func sortOrder() -> PlatformSystemSortOrder? { .cacheSystem }
}
