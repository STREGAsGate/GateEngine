/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS) || os(iOS) || os(tvOS)
import GameController

internal class MFIGamePadInterpreter: GamePadInterpreter {
    let hid: HID = Game.shared.hid
    init?() {
        guard Self.isSupported else { return nil }
        if #available(macOS 11.3, macCatalyst 14.5, iOS 14.5, tvOS 14.5, *) {
            GCController.shouldMonitorBackgroundEvents = true
        }
    }

    func beginInterpreting() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerConnected(_:)),
            name: .GCControllerDidConnect,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDisconnected(_:)),
            name: .GCControllerDidDisconnect,
            object: nil
        )

        for cgController in GCController.controllers() {
            let controller = GamePad(interpreter: self, identifier: cgController as AnyObject)
            self.hid.gamePads.addNewlyConnectedGamePad(controller)
        }
    }

    @objc func controllerConnected(_ notification: Notification) {
        guard let identifier = notification.object as? GCController else { return }
        let controller = GamePad(interpreter: self, identifier: identifier as AnyObject)
        self.hid.gamePads.addNewlyConnectedGamePad(controller)
    }

    @objc func controllerDisconnected(_ notification: Notification) {
        guard let identifier = notification.object as? GCController else { return }
        if let controller = self.hid.gamePads.all.first(where: {
            $0.identifier as? GCController == identifier
        }) {
            self.hid.gamePads.removedDisconnectedGamePad(controller)
        }
    }

    func update() {}

    func endInterpreting() {
        NotificationCenter.default.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }

    func setupGamePad(_ gamePad: GamePad) {
        guard let gcController = gamePad.identifier as? GCController else { return }

        switch gcController.productCategory {
        case "DualShock 4", "DualSense":
            gamePad.symbols = .sonyPlaystation
        case "Xbox One":
            gamePad.symbols = .microsoftXbox
        case "Switch Pro Controller":
            gamePad.symbols = .nintendoSwitch
        case "MFi":
            gamePad.symbols = .appleMFI
        default:
            gamePad.symbols = .unknown
        }
    }

    func updateState(of gamePad: GamePad) {
        guard var gcController = gamePad.identifier as? GCController else { return }
        if #available(macOS 10.15, iOS 13, tvOS 13, *) {
            gcController = gcController.capture()
        }

        if let gcGamePad = gcController.microGamepad {
            gamePad.dpad.up.isPressed = gcGamePad.dpad.up.isPressed
            gamePad.dpad.up.value = gcGamePad.dpad.up.value

            gamePad.dpad.down.isPressed = gcGamePad.dpad.down.isPressed
            gamePad.dpad.down.value = gcGamePad.dpad.down.value

            gamePad.dpad.left.isPressed = gcGamePad.dpad.left.isPressed
            gamePad.dpad.left.value = gcGamePad.dpad.left.value

            gamePad.dpad.right.isPressed = gcGamePad.dpad.right.isPressed
            gamePad.dpad.right.value = gcGamePad.dpad.right.value

            gamePad.button.south.isPressed = gcGamePad.buttonA.isPressed
            gamePad.button.south.value = gcGamePad.buttonA.value

            gamePad.button.west.isPressed = gcGamePad.buttonX.isPressed
            gamePad.button.west.value = gcGamePad.buttonX.value

            if #available(macOS 10.15, iOS 13, tvOS 13, *) {
                gamePad.menu.primary.isPressed = gcGamePad.buttonMenu.isPressed
                gamePad.menu.primary.value = gcGamePad.buttonMenu.value
            }
        }
        if let gcGamePad = gcController.extendedGamepad {
            gamePad.button.east.isPressed = gcGamePad.buttonB.isPressed
            gamePad.button.east.value = gcGamePad.buttonB.value

            gamePad.button.north.isPressed = gcGamePad.buttonY.isPressed
            gamePad.button.north.value = gcGamePad.buttonY.value

            gamePad.shoulder.left.isPressed = gcGamePad.leftShoulder.isPressed
            gamePad.shoulder.left.value = gcGamePad.leftShoulder.value

            gamePad.shoulder.right.isPressed = gcGamePad.rightShoulder.isPressed
            gamePad.shoulder.right.value = gcGamePad.rightShoulder.value

            gamePad.trigger.left.isPressed = gcGamePad.leftTrigger.isPressed
            gamePad.trigger.left.value = gcGamePad.leftTrigger.value

            gamePad.trigger.right.isPressed = gcGamePad.rightTrigger.isPressed
            gamePad.trigger.right.value = gcGamePad.rightTrigger.value

            gamePad.stick.left.xAxis = gcGamePad.leftThumbstick.xAxis.value
            gamePad.stick.left.yAxis = gcGamePad.leftThumbstick.yAxis.value

            gamePad.stick.right.xAxis = gcGamePad.rightThumbstick.xAxis.value
            gamePad.stick.right.yAxis = gcGamePad.rightThumbstick.yAxis.value
            if #available(macOS 10.14.1, iOS 12.1, tvOS 12.1, *) {
                if let button = gcGamePad.leftThumbstickButton {
                    gamePad.stick.left.button.isPressed = button.isPressed
                    gamePad.stick.left.button.value = button.value
                }
                if let button = gcGamePad.rightThumbstickButton {
                    gamePad.stick.right.button.isPressed = button.isPressed
                    gamePad.stick.right.button.value = button.value
                }
            }

            if #available(macOS 10.15, iOS 13, tvOS 13, *) {
                if let button = gcGamePad.buttonOptions {
                    gamePad.menu.secondary.isPressed = button.isPressed
                    gamePad.menu.secondary.value = button.value
                }
            }

            if #available(macOS 11, iOS 14, tvOS 14, *) {
                if let button = gcGamePad.buttonHome {
                    gamePad.menu.tertiary.isPressed = button.isPressed
                    gamePad.menu.tertiary.value = button.value
                }
            }
        }
    }

    func description(of gamePad: GamePad) -> String {
        guard let gcController = gamePad.identifier as? GCController else { return "ID Missing" }
        return gcController.vendorName ?? gcController.description
    }

    var userReadableName: String { return "MFi" }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MFIGamePadInterpreter {
    nonisolated static var isSupported: Bool {
        guard Bundle.main.bundleIdentifier != nil else { return false }
        if #available(macOS 11.0, *) {
            return true
        }
        return false
    }
    #if canImport(IOKit)
    nonisolated static func supports(_ device: IOHIDDevice) -> Bool {
        guard Self.isSupported else { return false }
        if #available(macOS 11.0, *) {
            return GCController.supportsHIDDevice(device)
        } else {
            return false
        }
    }
    #endif
}

#endif
