/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal final class NullGamePadInterpreter: GamePadInterpreter {
    var hid: HID { Game.shared.hid }
    init() {}
    func beginInterpreting() {}
    func update() {}
    func endInterpreting() {}
    func setupGamePad(_ gamePad: GamePad) {}
    func updateState(of gamePad: GamePad) {}
    func description(of gamePad: GamePad) -> String { "ID Missing" }
    var userReadableName: String { return "Null" }
}
