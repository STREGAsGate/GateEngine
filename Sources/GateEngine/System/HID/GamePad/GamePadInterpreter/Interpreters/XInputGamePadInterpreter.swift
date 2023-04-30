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
    unowned let manager: GamePadManager
    required init(manager: GamePadManager) {
        self.manager = manager
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
            let id = XInputIdentifier(userIndex: userIndex)
            id.previousPacket = id.state.dwPacketNumber
            id.state = XINPUT_STATE()
            id.stateUpdated = true
            if XInputGetState(userIndex, &id.state) == ERROR_SUCCESS {
                if self.connectedGamePads.contains(id) == false {
                    self.connectedGamePads.insert(id)
                    self.manager.queue.async {
                        let controller = GamePad(interpreter: self, identifier: id as AnyObject)
                        self.manager.addNewlyConnectedGamePad(controller)
                    }
                }
            }else if self.connectedGamePads.contains(id) {
                self.manager.queue.async {
                    if let controller = self.manager.gamePads.first(where: {$0.identifier as? XInputIdentifier == id}) {
                        self.manager.removedDisconnectedGamePad(controller)
                    }
                    self.connectedGamePads.remove(id)
                }
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
        gamePad.shoulder.right.value = gamePad.shoulder.right.isPressed ? 1 : 0

        gamePad.trigger.left.isPressed = xGamePad.bLeftTrigger > XINPUT_GAMEPAD_TRIGGER_THRESHOLD
        gamePad.trigger.left.value = max(0, min(1, Float(xGamePad.bLeftTrigger) / 255))

        gamePad.trigger.right.isPressed = xGamePad.bRightTrigger > XINPUT_GAMEPAD_TRIGGER_THRESHOLD
        gamePad.trigger.right.value = max(0, min(1, Float(xGamePad.bRightTrigger) / 255))

        gamePad.menu.primary.isPressed = buttons & XINPUT_GAMEPAD_START != 0
        gamePad.menu.primary.value = gamePad.menu.primary.isPressed ? 1 : 0

        gamePad.menu.secondary.isPressed = buttons & XINPUT_GAMEPAD_BACK != 0
        gamePad.menu.secondary.value = gamePad.menu.secondary.isPressed ? 1 : 0

        gamePad.stick.left.xAxis = max(-1, min(1, Float(xGamePad.sThumbLX) / 32767))
        gamePad.stick.left.yAxis = max(-1, min(1, Float(xGamePad.sThumbLY) / 32767))
        gamePad.stick.left.button.isPressed = buttons & XINPUT_GAMEPAD_LEFT_THUMB != 0
        gamePad.stick.left.button.value = gamePad.stick.left.button.isPressed ? 1 : 0

        gamePad.stick.right.xAxis = max(-1, min(1, Float(xGamePad.sThumbRX) / 32767))
        gamePad.stick.right.yAxis = max(-1, min(1, Float(xGamePad.sThumbRY) / 32767))
        gamePad.stick.right.button.isPressed = buttons & XINPUT_GAMEPAD_RIGHT_THUMB != 0
        gamePad.stick.right.button.value = gamePad.stick.right.button.isPressed ? 1 : 0
    }
    
    func description(of gamePad: GamePad) -> String {
        guard let id = gamePad.identifier as? XInputIdentifier else {return "ID Missing"}
        return "\(id.userIndex)"
    }
}

#endif
