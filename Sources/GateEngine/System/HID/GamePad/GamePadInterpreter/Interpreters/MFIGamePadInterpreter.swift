/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import GameController

internal class MFIGamePadInterpreter: GamePadInterpreter {
    @inline(__always)
    var hid: HID {Game.shared.hid}
    init() {
        if #available(macOS 11.3, macCatalyst 14.5, iOS 14.5, tvOS 14.5, *) {
            GCController.shouldMonitorBackgroundEvents = true
        }
    }
    
    func beginInterpreting() {
        NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected(_:)), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected(_:)), name: .GCControllerDidDisconnect, object: nil)

        for cgController in GCController.controllers() {
            let controller = GamePad(interpreter: self, identifier: cgController as AnyObject)
            self.hid.gamePads.addNewlyConnectedGamePad(controller)
        }
    }
    
    @objc func controllerConnected(_ notification: Notification) {
        guard let identifier = notification.object as? GCController else {return}
        let controller = GamePad(interpreter: self, identifier: identifier as AnyObject)
        self.hid.gamePads.addNewlyConnectedGamePad(controller)
    }
    
    @objc func controllerDisconnected(_ notification: Notification) {
        guard let identifier = notification.object as? GCController else {return}
        if let controller = self.hid.gamePads.all.first(where: {$0.identifier as? GCController == identifier}) {
            self.hid.gamePads.removedDisconnectedGamePad(controller)
        }
    }
    
    func update() {}
    
    func endInterpreting() {
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidDisconnect, object: nil)
    }
    
    func setupGamePad(_ gamePad: GamePad) {
        guard let gcController = gamePad.identifier as? GCController else {return}
        gamePad.symbols = .appleMFI
        
        if let extended = gcController.extendedGamepad {
            if #available(macOS 11, macCatalyst 14, tvOS 14, iOS 14, *), extended is GCDualShockGamepad {
                gamePad.symbols = .sonyPlaystation
            }else if #available(macOS 11.3, macCatalyst 14.5, tvOS 14.5, iOS 14.5, *), extended is GCDualSenseGamepad {
                gamePad.symbols = .sonyPlaystation
            }else if #available(macOS 11, macCatalyst 14, tvOS 14, iOS 14, *), extended is GCXboxGamepad {
                gamePad.symbols = .microsoftXbox
            }
        }
    }
    
    func updateState(of gamePad: GamePad) {
        guard var gcController = gamePad.identifier as? GCController else {return}
        if #available(macOS 10.15, iOS 13, tvOS 13, *) {
            gcController = gcController.capture()
        }

        if let gcGamePad = gcController.microGamepad {
            gamePad.dpad.up.isPressed = gcGamePad.dpad.up.isPressed
            if gcGamePad.dpad.up.isAnalog && gcGamePad.dpad.up.isPressed {
                gamePad.dpad.up.value = gcGamePad.dpad.up.value
            }else if gcGamePad.dpad.up.isPressed {
                gamePad.dpad.up.value = 1
            }else{
                gamePad.dpad.up.value = 0
            }
            
            gamePad.dpad.down.isPressed = gcGamePad.dpad.down.isPressed
            if gcGamePad.dpad.down.isAnalog && gcGamePad.dpad.down.isPressed {
                gamePad.dpad.down.value = gcGamePad.dpad.down.value
            }else if gcGamePad.dpad.down.isPressed {
                gamePad.dpad.down.value = 1
            }else{
                gamePad.dpad.down.value = 0
            }
            
            gamePad.dpad.left.isPressed = gcGamePad.dpad.left.isPressed
            if gcGamePad.dpad.left.isAnalog && gcGamePad.dpad.left.isPressed {
                gamePad.dpad.left.value = gcGamePad.dpad.left.value
            }else if gcGamePad.dpad.left.isPressed {
                gamePad.dpad.left.value = 1
            }else{
                gamePad.dpad.left.value = 0
            }
            
            gamePad.dpad.right.isPressed = gcGamePad.dpad.right.isPressed
            if gcGamePad.dpad.right.isAnalog && gcGamePad.dpad.right.isPressed {
                gamePad.dpad.right.value = gcGamePad.dpad.right.value
            }else if gcGamePad.dpad.right.isPressed {
                gamePad.dpad.right.value = 1
            }else{
                gamePad.dpad.right.value = 0
            }
            
            gamePad.button.south.isPressed = gcGamePad.buttonA.isPressed
            if gcGamePad.buttonA.isAnalog && gcGamePad.buttonA.isPressed {
                gamePad.button.south.value = gcGamePad.buttonA.value
            }else if gcGamePad.buttonA.isPressed {
                gamePad.button.south.value = 1
            }else{
                gamePad.button.south.value = 0
            }
            
            gamePad.button.west.isPressed = gcGamePad.buttonX.isPressed
            if gcGamePad.buttonX.isAnalog && gcGamePad.buttonX.isPressed {
                gamePad.button.west.value = gcGamePad.buttonX.value
            }else if gcGamePad.buttonX.isPressed {
                gamePad.button.west.value = 1
            }else{
                gamePad.button.west.value = 0
            }
            
            if #available(macOS 10.15, iOS 13, tvOS 13, *) {
                gamePad.menu.primary.isPressed = gcGamePad.buttonMenu.isPressed
                if gcGamePad.buttonMenu.isAnalog && gcGamePad.buttonMenu.isPressed {
                    gamePad.menu.primary.value = gcGamePad.buttonMenu.value
                }else if gcGamePad.buttonMenu.isPressed {
                    gamePad.menu.primary.value = 1
                }else{
                    gamePad.menu.primary.value = 0
                }
            }
        }
        if let gcGamePad = gcController.extendedGamepad {
            gamePad.button.east.isPressed = gcGamePad.buttonB.isPressed
            if gcGamePad.buttonB.isAnalog && gcGamePad.buttonB.isPressed {
                gamePad.button.east.value = gcGamePad.buttonB.value
            }else if gcGamePad.buttonB.isPressed {
                gamePad.button.east.value = 1
            }else{
                gamePad.button.east.value = 0
            }
            
            gamePad.button.north.isPressed = gcGamePad.buttonY.isPressed
            if gcGamePad.buttonY.isAnalog && gcGamePad.buttonY.isPressed {
                gamePad.button.north.value = gcGamePad.buttonY.value
            }else if gcGamePad.buttonY.isPressed {
                gamePad.button.north.value = 1
            }else{
                gamePad.button.north.value = 0
            }
            
            gamePad.shoulder.left.isPressed = gcGamePad.leftShoulder.isPressed
            if gcGamePad.leftShoulder.isAnalog && gcGamePad.leftShoulder.isPressed {
                gamePad.shoulder.left.value = gcGamePad.leftShoulder.value
            }else if gcGamePad.leftShoulder.isPressed {
                gamePad.shoulder.left.value = 1
            }else{
                gamePad.shoulder.left.value = 0
            }
            
            gamePad.shoulder.right.isPressed = gcGamePad.rightShoulder.isPressed
            if gcGamePad.rightShoulder.isAnalog && gcGamePad.rightShoulder.isPressed {
                gamePad.shoulder.right.value = gcGamePad.rightShoulder.value
            }else if gcGamePad.rightShoulder.isPressed {
                gamePad.shoulder.right.value = 1
            }else{
                gamePad.shoulder.right.value = 0
            }
        
            gamePad.trigger.left.isPressed = gcGamePad.leftTrigger.isPressed
            if gcGamePad.leftTrigger.isAnalog && gcGamePad.leftTrigger.isPressed {
                gamePad.trigger.left.value = gcGamePad.leftTrigger.value
            }else if gcGamePad.leftTrigger.isPressed {
                gamePad.trigger.left.value = 1
            }else{
                gamePad.trigger.left.value = 0
            }
            
            gamePad.trigger.right.isPressed = gcGamePad.rightTrigger.isPressed
            if gcGamePad.rightTrigger.isAnalog && gcGamePad.rightTrigger.isPressed {
                gamePad.trigger.right.value = gcGamePad.rightTrigger.value
            }else if gcGamePad.rightTrigger.isPressed {
                gamePad.trigger.right.value = 1
            }else{
                gamePad.trigger.right.value = 0
            }
            
            gamePad.stick.left.xAxis = gcGamePad.leftThumbstick.xAxis.value
            gamePad.stick.left.yAxis = gcGamePad.leftThumbstick.yAxis.value
            
            gamePad.stick.right.xAxis = gcGamePad.rightThumbstick.xAxis.value
            gamePad.stick.right.yAxis = gcGamePad.rightThumbstick.yAxis.value
            if #available(macOS 10.14.1, iOS 12.1, tvOS 12.1, *) {
                if let leftThumbStickButton = gcGamePad.leftThumbstickButton {
                    gamePad.stick.left.button.isPressed = leftThumbStickButton.isPressed
                    if leftThumbStickButton.isAnalog && leftThumbStickButton.isPressed {
                        gamePad.stick.left.button.value = leftThumbStickButton.value
                    }else if leftThumbStickButton.isPressed {
                        gamePad.stick.left.button.value = 1
                    }else{
                        gamePad.stick.left.button.value = 0
                    }
                }
                if let rightThumbStickButton = gcGamePad.rightThumbstickButton {
                    gamePad.stick.right.button.isPressed = rightThumbStickButton.isPressed
                    if rightThumbStickButton.isAnalog && rightThumbStickButton.isPressed {
                        gamePad.stick.right.button.value = rightThumbStickButton.value
                    }else if rightThumbStickButton.isPressed {
                        gamePad.stick.right.button.value = 1
                    }else{
                        gamePad.stick.right.button.value = 0
                    }
                }
            }
            
            if #available(macOS 10.15, iOS 13, tvOS 13, *) {
                if let optionsButton = gcGamePad.buttonOptions {
                    gamePad.menu.secondary.isPressed = optionsButton.isPressed
                    if optionsButton.isAnalog && optionsButton.isPressed {
                        gamePad.menu.secondary.value = optionsButton.value
                    }else if optionsButton.isPressed {
                        gamePad.menu.secondary.value = 1
                    }else{
                        gamePad.menu.secondary.value = 0
                    }
                }
            }
        }
    }
    
    func description(of gamePad: GamePad) -> String {
        guard let gcController = gamePad.identifier as? GCController else {return "ID Missing"}
        return gcController.vendorName ?? gcController.description
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

#endif
