/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal class NullGamePadInterpreter: GamePadInterpreter {
    let hid: HID
    required init(hid: HID) {
        self.hid = hid
    }
    
    func beginInterpreting() {}
    func update() {}
    func endInterpreting() {}
    func setupGamePad(_ gamePad: GamePad) {}
    func updateState(of gamePad: GamePad) {}
    func description(of gamePad: GamePad) -> String {"ID Missing"}
}
