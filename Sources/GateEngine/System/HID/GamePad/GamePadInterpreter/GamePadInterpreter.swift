/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor internal protocol GamePadInterpreter {
    init(hid: HID)
    var hid: HID {get}
    func beginInterpreting()
    func update()
    func endInterpreting()
    func setupGamePad(_ gamePad: GamePad)
    func updateState(of gamePad: GamePad)
    func description(of gamePad: GamePad) -> String
}
