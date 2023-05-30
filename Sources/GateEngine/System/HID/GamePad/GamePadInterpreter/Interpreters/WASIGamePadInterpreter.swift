/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT

import JavaScriptKit
import DOM
import Gamepad

internal class WASIGamePadInterpreter: GamePadInterpreter {
    unowned let hid: HID
    required init(hid: HID) {
        self.hid = hid
    }
    
    func beginInterpreting() {
        Log.info("Looking for gamepads")

        func addGamepad(_ event: Event) {
            let event = GamepadEvent(unsafelyWrapping: event.jsObject)
            if event.gamepad.mapping == .standard {
                let controller = GamePad(interpreter: self, identifier: event.gamepad.id)
                self.hid.gamePads.addNewlyConnectedGamePad(controller)
            }else{
                Log.warn("Ignoring non-standard gamepad:", event.gamepad.id)
            }
        }
        func removeGamepad(_ event: Event) {
            let event = GamepadEvent(unsafelyWrapping: event.jsObject)
            if let controller = self.hid.gamePads.all.first(where: {$0.identifier as? String == event.gamepad.id}) {
                self.hid.gamePads.removedDisconnectedGamePad(controller)
            }
        }
                
        globalThis.addEventListener(type: "gamepadconnected") { event in
            addGamepad(event)
        }
        globalThis.addEventListener(type: "gamepaddisconnected") { event in
            removeGamepad(event)
        }
    }
    
    func update() {}
    
    func endInterpreting() {
        (globalThis as WindowEventHandlers).ongamepadconnected = nil
        globalThis.ongamepaddisconnected = nil
    }
    
    func setupGamePad(_ gamePad: GamePad) {
        guard let _id = gamePad.identifier as? String else {return}
        let id = _id.lowercased()
        
        for keyword in ["Microsoft", "Xbox", "045e"] {
            if id.contains(keyword.lowercased()) {
                gamePad.symbols = .microsoftXbox
                return
            }
        }
        
        for keyword in ["Sony", "PlayStation", "DUALSHOCK", "054c", "PS3", "PS4", "PS5", "PS6"] {
            if id.contains(keyword.lowercased()) {
                gamePad.symbols = .sonyPlaystation
                return
            }
        }
        
        for keyword in ["Nintendo Switch", "JoyCon"] {
            if id.contains(keyword.lowercased()) {
                gamePad.symbols = .nintendoSwitch
                return
            }
        }
        
        for keyword in ["SNES", "NES"] {
            if id.contains(keyword.lowercased()) {
                gamePad.symbols = .nintendoClassic
                return
            }
        }
        
        for keyword in ["Nimbus"] {
            if id.contains(keyword.lowercased()) {
                gamePad.symbols = .appleMFI
                return
            }
        }

        switch globalThis.navigator.browser {
        case .safari:
            if id == "Wireless Controller Extended Gamepad".lowercased() {
                gamePad.symbols = .sonyPlaystation
                return
            }
        default:
            break
        }
        
        gamePad.symbols = .unknown
    }
    
    func updateState(of gamePad: GamePad) {
        guard let id = gamePad.identifier as? String else {return}
        let gamepads = globalThis.navigator.getGamepads().compactMap({$0})
        guard let wGamepad: Gamepad = gamepads.first(where: {$0.id == id}) else {return}
                
        gamePad.dpad.up.isPressed = wGamepad.buttons[12].pressed
        gamePad.dpad.up.value = Float(wGamepad.buttons[12].value)
        
        gamePad.dpad.down.isPressed = wGamepad.buttons[13].pressed
        gamePad.dpad.down.value = Float(wGamepad.buttons[13].value)
        
        gamePad.dpad.left.isPressed = wGamepad.buttons[14].pressed
        gamePad.dpad.left.value = Float(wGamepad.buttons[14].value)
        
        gamePad.dpad.right.isPressed = wGamepad.buttons[15].pressed
        gamePad.dpad.right.value = Float(wGamepad.buttons[15].value)
        
        gamePad.button.north.isPressed = wGamepad.buttons[3].pressed
        gamePad.button.north.value = Float(wGamepad.buttons[3].value)
        
        gamePad.button.south.isPressed = wGamepad.buttons[0].pressed
        gamePad.button.south.value = Float(wGamepad.buttons[0].value)
        
        gamePad.button.east.isPressed = wGamepad.buttons[1].pressed
        gamePad.button.east.value = Float(wGamepad.buttons[1].value)
        
        gamePad.button.west.isPressed = wGamepad.buttons[2].pressed
        gamePad.button.west.value = Float(wGamepad.buttons[2].value)
        
        gamePad.shoulder.left.isPressed = wGamepad.buttons[4].pressed
        gamePad.shoulder.left.value = Float(wGamepad.buttons[4].value)
        
        gamePad.shoulder.right.isPressed = wGamepad.buttons[5].pressed
        gamePad.shoulder.right.value = Float(wGamepad.buttons[5].value)
        
        gamePad.trigger.left.isPressed = wGamepad.buttons[6].pressed
        gamePad.trigger.left.value = Float(wGamepad.buttons[6].value)
        
        gamePad.trigger.right.isPressed = wGamepad.buttons[7].pressed
        gamePad.trigger.right.value = Float(wGamepad.buttons[7].value)
        
        gamePad.menu.primary.isPressed = wGamepad.buttons[9].pressed
        gamePad.menu.primary.value = Float(wGamepad.buttons[9].value)

        gamePad.menu.secondary.isPressed = wGamepad.buttons[8].pressed
        gamePad.menu.secondary.value = Float(wGamepad.buttons[8].value)

        if wGamepad.buttons.count == 17 {// MFi Nimbus Gamepads don't have this button for some reason
            gamePad.menu.tertiary.isPressed = wGamepad.buttons[16].pressed
            gamePad.menu.tertiary.value = Float(wGamepad.buttons[16].value)
        }

        gamePad.stick.left.xAxis = Float(wGamepad.axes[0])
        gamePad.stick.left.yAxis = Float(wGamepad.axes[1])
        gamePad.stick.left.button.isPressed = wGamepad.buttons[10].pressed
        gamePad.stick.left.button.value = Float(wGamepad.buttons[10].value)

        gamePad.stick.right.xAxis = Float(wGamepad.axes[2])
        gamePad.stick.right.yAxis = Float(wGamepad.axes[3])
        gamePad.stick.right.button.isPressed = wGamepad.buttons[11].pressed
        gamePad.stick.right.button.value = Float(wGamepad.buttons[11].value)
    }
    
    func description(of gamePad: GamePad) -> String {
        return gamePad.identifier as? String ?? "[ID Missing]"
    }
}

#endif
