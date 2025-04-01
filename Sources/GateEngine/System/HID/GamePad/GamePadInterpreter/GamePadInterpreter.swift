/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@MainActor internal protocol GamePadInterpreter {
    var hid: HID { get }
    func beginInterpreting()
    func update()
    func endInterpreting()
    func setupGamePad(_ gamePad: GamePad)
    func updateState(of gamePad: GamePad)
    func description(of gamePad: GamePad) -> String
    var userReadableName: String { get }
}

extension GamePadInterpreter {
    var hid: HID { Game.shared.hid }
}
