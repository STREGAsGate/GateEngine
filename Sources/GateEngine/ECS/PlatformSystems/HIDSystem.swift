/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class HIDSystem: PlatformSystem {
    override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        input.update(deltaTime)
    }
    
    override class var phase: PlatformSystem.Phase {return .preUpdating}
    override class func sortOrder() -> PlatformSystemSortOrder? {.hidSystem}
}
