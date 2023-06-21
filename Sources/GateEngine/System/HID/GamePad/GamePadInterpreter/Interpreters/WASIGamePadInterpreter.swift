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
    var wGamepads: [Gamepad] = []
    
    required init(hid: HID) {
        self.hid = hid
    }
    
    func beginInterpreting() {
        func addGamepad(_ event: Event) {
            let event = GamepadEvent(unsafelyWrapping: event.jsObject)
            if event.gamepad.mapping == .standard {
                self.wGamepads.append(event.gamepad)
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
                self.wGamepads.removeAll(where: {$0.id == event.gamepad.id})
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

        switch Game.shared.platform.browser {
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
        let wGamepads = globalThis.navigator.getGamepads().compactMap({$0})
        guard let wGamepad: Gamepad = wGamepads.first(where: {$0.id == id}) else {return}
        
        let buttons = wGamepad.buttons
        let axes = wGamepad.axes
        
        let up = buttons[12]
        gamePad.dpad.up.isPressed = up.pressed
        gamePad.dpad.up.value = Float(up.value)
        
        let down = buttons[13]
        gamePad.dpad.down.isPressed = down.pressed
        gamePad.dpad.down.value = Float(down.value)
        
        let left = buttons[14]
        gamePad.dpad.left.isPressed = left.pressed
        gamePad.dpad.left.value = Float(left.value)
        
        let right = buttons[15]
        gamePad.dpad.right.isPressed = right.pressed
        gamePad.dpad.right.value = Float(right.value)
        
        let north = buttons[3]
        gamePad.button.north.isPressed = north.pressed
        gamePad.button.north.value = Float(north.value)
        
        let south = buttons[0]
        gamePad.button.south.isPressed = south.pressed
        gamePad.button.south.value = Float(south.value)

        let east = buttons[1]
        gamePad.button.east.isPressed = east.pressed
        gamePad.button.east.value = Float(east.value)
        
        let west = buttons[2]
        gamePad.button.west.isPressed = west.pressed
        gamePad.button.west.value = Float(west.value)
        
        let leftShoulder = buttons[4]
        gamePad.shoulder.left.isPressed = leftShoulder.pressed
        gamePad.shoulder.left.value = Float(leftShoulder.value)
        
        let rightShoulder = buttons[5]
        gamePad.shoulder.right.isPressed = rightShoulder.pressed
        gamePad.shoulder.right.value = Float(rightShoulder.value)
        
        let leftTrigger = buttons[6]
        gamePad.trigger.left.isPressed = leftTrigger.pressed
        gamePad.trigger.left.value = Float(leftTrigger.value)
        
        let rightTrigger = buttons[7]
        gamePad.trigger.right.isPressed = rightTrigger.pressed
        gamePad.trigger.right.value = Float(rightTrigger.value)
        
        let menuPrimary = buttons[9]
        gamePad.menu.primary.isPressed = menuPrimary.pressed
        gamePad.menu.primary.value = Float(menuPrimary.value)

        let menuSecondary = buttons[8]
        gamePad.menu.secondary.isPressed = menuSecondary.pressed
        gamePad.menu.secondary.value = Float(menuSecondary.value)

        // Some Gamepads don't contain this button
        if buttons.indices.contains(17) {
            let menuTertiary = buttons[17]
            gamePad.menu.tertiary.isPressed = menuTertiary.pressed
            gamePad.menu.tertiary.value = Float(menuTertiary.value)
        }

        gamePad.stick.left.xAxis = Float(axes[0])
        gamePad.stick.left.yAxis = Float(axes[1]) * -1
        let leftStick = buttons[10]
        gamePad.stick.left.button.isPressed = leftStick.pressed
        gamePad.stick.left.button.value = Float(leftStick.value)

        gamePad.stick.right.xAxis = Float(axes[2])
        gamePad.stick.right.yAxis = Float(axes[3]) * -1
        let rightStick = buttons[11]
        gamePad.stick.right.button.isPressed = rightStick.pressed
        gamePad.stick.right.button.value = Float(rightStick.value)
    }
    
    func description(of gamePad: GamePad) -> String {
        return gamePad.identifier as? String ?? "[ID Missing]"
    }
}

#endif
