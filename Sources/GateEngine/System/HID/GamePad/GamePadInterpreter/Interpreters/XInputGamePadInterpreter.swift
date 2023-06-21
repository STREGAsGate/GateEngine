/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)

import Foundation
import GameMath
import WinSDK.DirectX.XInput14

internal class XInputGamePadInterpreter: GamePadInterpreter {
    unowned let hid: HID
    required init(hid: HID) {
        self.hid = hid
    }
    
    func beginInterpreting() {
        XInputEnable(true)
    }

    var connectedGamePads: Set<XInputIdentifier> = [] 

    class XInputIdentifier: Equatable, Hashable {
        let userIndex: UInt32
        var state: XINPUT_STATE = XINPUT_STATE()
        var previousPacket: DWORD = 0

        var stateUpdated: Bool = false

        var didChange: Bool {
            return previousPacket != state.dwPacketNumber
        }

        init(userIndex: UInt32) {
            self.userIndex = userIndex
        }

        static func ==(lhs: XInputIdentifier, rhs: XInputIdentifier) -> Bool {
            return lhs.userIndex == rhs.userIndex
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(userIndex)
        }
    }

    var updateInterval: UInt16 = .max

    func update() {
        guard updateInterval > 100 else {updateInterval += 1; return}
        updateInterval = 0
        for userIndex in 0 ..< UInt32(XUSER_MAX_COUNT) {
            let id: XInputGamePadInterpreter.XInputIdentifier = XInputIdentifier(userIndex: userIndex)
            id.previousPacket = id.state.dwPacketNumber
            id.state = XINPUT_STATE()
            id.stateUpdated = true
            if XInputGetState(userIndex, &id.state) == ERROR_SUCCESS {
                if self.connectedGamePads.contains(id) == false {
                    self.connectedGamePads.insert(id)
                    let controller = GamePad(interpreter: self, identifier: id as AnyObject)
                    self.hid.gamePads.addNewlyConnectedGamePad(controller)
                }
            }else if self.connectedGamePads.contains(id) {
                if let controller = self.hid.gamePads.all.first(where: {$0.identifier as? XInputIdentifier == id}) {
                    self.hid.gamePads.removedDisconnectedGamePad(controller)
                }
                self.connectedGamePads.remove(id)
            }
        }
    }
    
    func endInterpreting() {
        XInputEnable(false)
    }
    
    func setupGamePad(_ gamePad: GamePad) {
        gamePad.symbols = .microsoftXbox
    }
    
    func updateState(of gamePad: GamePad) {
        guard let id = gamePad.identifier as? XInputIdentifier else {return}
        if id.stateUpdated {
            id.stateUpdated = false
        }else{
            id.previousPacket = id.state.dwPacketNumber
            guard XInputGetState(id.userIndex, &id.state) == ERROR_SUCCESS else {return}
        }
        guard id.didChange else {return}

        // guard id.didChange else {return}
        let xGamePad = id.state.Gamepad
        let buttons = Int32(xGamePad.wButtons)
    
        gamePad.dpad.up.isPressed = buttons & XINPUT_GAMEPAD_DPAD_UP != 0
        gamePad.dpad.up.value = gamePad.dpad.up.isPressed ? 1 : 0

        gamePad.dpad.down.isPressed = buttons & XINPUT_GAMEPAD_DPAD_DOWN != 0
        gamePad.dpad.down.value = gamePad.dpad.down.isPressed ? 1 : 0

        gamePad.dpad.left.isPressed = buttons & XINPUT_GAMEPAD_DPAD_LEFT != 0
        gamePad.dpad.left.value = gamePad.dpad.left.isPressed ? 1 : 0

        gamePad.dpad.right.isPressed = buttons & XINPUT_GAMEPAD_DPAD_RIGHT != 0
        gamePad.dpad.right.value = gamePad.dpad.right.isPressed ? 1 : 0

        gamePad.button.north.isPressed = buttons & XINPUT_GAMEPAD_Y != 0
        gamePad.button.north.value = gamePad.button.north.isPressed ? 1 : 0

        gamePad.button.south.isPressed = buttons & XINPUT_GAMEPAD_A != 0
        gamePad.button.south.value = gamePad.button.south.isPressed ? 1 : 0

        gamePad.button.west.isPressed = buttons & XINPUT_GAMEPAD_X != 0
        gamePad.button.west.value = gamePad.button.west.isPressed ? 1 : 0

        gamePad.button.east.isPressed = buttons & XINPUT_GAMEPAD_B != 0
        gamePad.button.east.value = gamePad.button.east.isPressed ? 1 : 0

        gamePad.shoulder.left.isPressed = buttons & XINPUT_GAMEPAD_LEFT_SHOULDER != 0
        gamePad.shoulder.left.value = gamePad.shoulder.left.isPressed ? 1 : 0

        gamePad.shoulder.right.isPressed = buttons & XINPUT_GAMEPAD_RIGHT_SHOULDER != 0
        let RT_DEADZONE: Float = Float(XINPUT_GAMEPAD_TRIGGER_THRESHOLD)
        let RT_RANGE: Float = 255.0 - RT_DEADZONE
        let RT_VALUE: Float = Float(xGamePad.bLeftTrigger)
        gamePad.trigger.right.value = RT_VALUE > RT_DEADZONE ? (RT_VALUE - RT_DEADZONE) / RT_RANGE : 0
        
        gamePad.trigger.left.isPressed = xGamePad.bLeftTrigger > XINPUT_GAMEPAD_TRIGGER_THRESHOLD
        let LT_DEADZONE: Float = Float(XINPUT_GAMEPAD_TRIGGER_THRESHOLD)
        let LT_RANGE: Float = 255.0 - LT_DEADZONE
        let LT_VALUE: Float = Float(xGamePad.bLeftTrigger)
        gamePad.trigger.left.value = LT_VALUE > LT_DEADZONE ? (LT_VALUE - LT_DEADZONE) / LT_RANGE : 0

        gamePad.trigger.right.isPressed = xGamePad.bRightTrigger > XINPUT_GAMEPAD_TRIGGER_THRESHOLD
        gamePad.trigger.right.value = Float(xGamePad.bRightTrigger) / 255.0

        gamePad.menu.primary.isPressed = buttons & XINPUT_GAMEPAD_START != 0
        gamePad.menu.primary.value = gamePad.menu.primary.isPressed ? 1 : 0

        gamePad.menu.secondary.isPressed = buttons & XINPUT_GAMEPAD_BACK != 0
        gamePad.menu.secondary.value = gamePad.menu.secondary.isPressed ? 1 : 0

        let L_DEADZONE: Float = Float(XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)
        let L_RANGE: Float = 32767.0 - L_DEADZONE
        let LX_VALUE: Float = Float(xGamePad.sThumbLX)
        let LY_VALUE: Float = Float(xGamePad.sThumbLY)
        gamePad.stick.left.xAxis = abs(LX_VALUE) > L_DEADZONE ? LX_VALUE < 0 ? (LX_VALUE + L_DEADZONE) / L_RANGE : (LX_VALUE - L_DEADZONE) / L_RANGE : 0
        gamePad.stick.left.yAxis = abs(LY_VALUE) > L_DEADZONE ? LY_VALUE < 0 ? (LY_VALUE + L_DEADZONE) / L_RANGE : (LY_VALUE - L_DEADZONE) / L_RANGE : 0
        gamePad.stick.left.button.isPressed = buttons & XINPUT_GAMEPAD_LEFT_THUMB != 0
        gamePad.stick.left.button.value = gamePad.stick.left.button.isPressed ? 1 : 0

        let R_DEADZONE: Float = Float(XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE)
        let R_RANGE: Float = 32767.0
        let RX_VALUE: Float = Float(xGamePad.sThumbRX)
        let RY_VALUE: Float = Float(xGamePad.sThumbRY)
        gamePad.stick.right.xAxis = abs(RX_VALUE) > R_DEADZONE ? RX_VALUE / R_RANGE : 0
        gamePad.stick.right.yAxis = abs(RY_VALUE) > R_DEADZONE ? RY_VALUE / R_RANGE : 0
        gamePad.stick.right.button.isPressed = buttons & XINPUT_GAMEPAD_RIGHT_THUMB != 0
        gamePad.stick.right.button.value = gamePad.stick.right.button.isPressed ? 1 : 0
    }
    
    func description(of gamePad: GamePad) -> String {
        guard let id = gamePad.identifier as? XInputIdentifier else {return "ID Missing"}
        return "\(id.userIndex)"
    }
}

#endif
