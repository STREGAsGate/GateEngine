/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)
import Foundation
import LinuxSupport

fileprivate class HIDController {
    var guid: SDL2ControllerGUID {
        return map.id
    }
    let map: SDL2ControllerMap
    let path: String
    var buttonElements: [ElementCache] = []
    var axesElements: [ElementCache] = []
    var hatElements: [ElementCache] = []
    
    struct ElementCache {
        let number: Int
        let min: Int
        let max: Int
    }
    init(map: SDL2ControllerMap, path: String) {
        self.map = map
        self.path = path
    }
}

fileprivate let BITS_PER_LONG: Int = MemoryLayout<CUnsignedLong>.size * 8
fileprivate func NBITS(_ x: Int) -> Int {((((x)-1)/BITS_PER_LONG)+1)}
fileprivate func EVDEV_OFF(_ x: Int) -> Int {((x)%BITS_PER_LONG)}
fileprivate func EVDEV_LONG(_ x: Int) -> Int {((x)/BITS_PER_LONG)}
fileprivate func test_bit(_ bit: Int, _ array: Array<UInt32>) -> Bool {((array[EVDEV_LONG(bit)] >> EVDEV_OFF(bit)) & 1) != 0}

internal class LinuxHIDGamePadInterpreter: GamePadInterpreter {
    unowned let hid: HID
    required init(hid: HID) {
        self.hid = hid
    }

    let sdl2Database: SDL2Database? = try? SDL2Database()

    var connected: [String:Int32] = [:]
    
    func guidFromPath(_ path: String, _ fd: Int32) -> SDL2ControllerGUID? {        
        // SDL2 changes values for some devices to support db GUIDs
        // We duplicate that to make sure the db entries function as expected
        func fixUp(input: input_id) -> input_id {
            var input = input
            if inpid.vendor == 0x045e && inpid.product == 0x0b05 && inpid.version == 0x0903 {
                /* This is a Microsoft Xbox One Elite Series 2 controller */
                var keybit = Array<UInt32>(repeating: 0, count: Int(KEY_MAX))

                /* The first version of the firmware duplicated all the inputs */
                if ioctl(Int32(fd), Int32(EVIOCGBIT(EV_KEY, Int32(keybit.count))), &keybit) >= 0 && test_bit(0x2c0, keybit) {
                    /* Change the version to 0x0902, so we can map it differently */
                    inpid.version = 0x0902
                }
            }

            /* For Atari vcs modern and classic controllers have the version reflecting
            * firmware version, but the mapping stays stable so ignore
            * version information */
            if (inpid.vendor == 0x3250 && (inpid.product == 0x1001 || inpid.product == 0x1002)) {
                inpid.version = 0
            }
            return input
        }

        var inpid: input_id = input_id()
        guard ioctl(fd, EVIOCGID, &inpid) >= 0 else {return nil}
        inpid = fixUp(input: inpid)

        return SDL2ControllerGUID(vendorID: Int(inpid.vendor), productID: Int(inpid.product), hidVersion: Int(inpid.version), transport: Int(inpid.bustype))
    }

    func checkConnectedJoysticks() {
        guard let joysticks: [String] = try? FileManager.default.contentsOfDirectory(atPath: "/dev/input").map({"/dev/input/" + $0}) else {return}
        let old: Dictionary<String, Int32>.Keys = self.connected.keys
        for val: String in old {
            if joysticks.contains(val) == false {
                if let gamePad: GamePad = hid.gamePads.all.first(where: {($0.identifier as! HIDController).path == val}) {
                    hid.gamePads.removedDisconnectedGamePad(gamePad)
                }
                if let fd: Int32 = connected[val] {
                    close(fd)
                }
                connected[val] = nil
            }
        }
        for val: String in joysticks {
            if self.connected.keys.contains(val) == false {                
                let fd: Int32 = open(val, O_RDONLY, 0)
                self.connected[val] = fd

                func failed() {
                    close(fd)
                    self.connected[val] = nil
                }

                guard let guid: SDL2ControllerGUID = guidFromPath(val, fd) else {failed(); continue}
                guard var map: SDL2ControllerMap = sdl2Database?.controllers[guid] else {failed(); continue}
                //Use our generated guid with vendor and product IDs
                map.id = guid
                
                let gamePad: GamePad = GamePad(interpreter: self, identifier: HIDController(map: map, path: val))
                hid.gamePads.addNewlyConnectedGamePad(gamePad)
            }
        }
    }

    func beginInterpreting() {
        checkConnectedJoysticks()
    }

    var lastUpdate: Date = .distantPast
    func update() {
        // Check controller changes every 3 seconds
        guard lastUpdate.timeIntervalSinceNow < -3 else {return}
        checkConnectedJoysticks()
        lastUpdate = Date()
    }
    
    func endInterpreting() {
        for fd in connected.values {
            close(fd)
        }
        connected.removeAll()
    }
    func setupGamePad(_ gamePad: GamePad) {
        guard let controller = gamePad.identifier as? HIDController else {return}
        guard let fd = connected[controller.path] else {return}

        gamePad.symbols = controller.map.symbols()

        var keybit = Array<UInt32>(repeating: 0, count: NBITS(Int(KEY_MAX)))
        var absbit = Array<UInt32>(repeating: 0, count: NBITS(Int(ABS_MAX)))
        var relbit = Array<UInt32>(repeating: 0, count: NBITS(Int(REL_MAX)))
        var ffbit  = Array<UInt32>(repeating: 0, count: NBITS(Int(FF_MAX)))
        
        let k = ioctl(fd, EVIOCGBIT(EV_KEY, Int32(MemoryLayout<UInt32>.size * keybit.count)), &keybit) >= 0
        let a = ioctl(fd, EVIOCGBIT(EV_ABS, Int32(MemoryLayout<UInt32>.size * absbit.count)), &absbit) >= 0
        let r = ioctl(fd, EVIOCGBIT(EV_REL, Int32(MemoryLayout<UInt32>.size * relbit.count)), &relbit) >= 0

        if (k && a && r) {
            for i in 0 ..< ABS_MAX {
                guard (ABS_HAT0X ..< ABS_HAT3Y).contains(i) == false else {continue}
                guard test_bit(Int(i), absbit) else {continue}

                var absinfo = input_absinfo()
                guard ioctl(fd, EVIOCGABS(i), &absinfo) >= 0 else {continue}

                let element = HIDController.ElementCache(number: Int(i), min: Int(absinfo.minimum), max: Int(absinfo.maximum))
                controller.axesElements.append(element)
            }

            for i in stride(from: Int(ABS_HAT0X), through: Int(ABS_HAT3Y), by: 2) {
                if (test_bit(i, absbit) || test_bit(i + 1, absbit)) {
                    var absinfo = input_absinfo()
                    let hat_index = (i - Int(ABS_HAT0X)) / 2

                    if (ioctl(fd, EVIOCGABS(Int32(i)), &absinfo) < 0) {
                        continue
                    }

                    let element = HIDController.ElementCache(number: hat_index, min: Int(absinfo.minimum), max: Int(absinfo.maximum))
                    controller.hatElements.append(element)
                }
            }

            for i in Int(BTN_JOYSTICK) ..< Int(KEY_MAX) {
                if (test_bit(i, keybit)) {
                    let element = HIDController.ElementCache(number: i, min: 0, max: 1)
                    controller.buttonElements.append(element)
                }
            }
            for i in 0 ..< Int(BTN_JOYSTICK) {
                if (test_bit(i, keybit)) {
                    let element = HIDController.ElementCache(number: i, min: 0, max: 1)
                    controller.buttonElements.append(element)
                }
            }
        }
    }



    func updateState(of gamePad: GamePad) {
        guard let controller = gamePad.identifier as? HIDController else {return}
        guard let fd = connected[controller.path] else {return}

        var keyinfo = Array<UInt32>(repeating: 0, count: NBITS(Int(KEY_MAX)))
        guard ioctl(fd, EVIOCGKEY(Int32(MemoryLayout<UInt32>.size * keyinfo.count)), &keyinfo) >= 0 else {return}

        func value(from controller: HIDController, for button: SDL2ControllerMap.Element) -> Float {
            guard let element = controller.map.elements[button] else {return 0}
            switch element.kind {
            case .button:
                let number = controller.buttonElements[element.id].number
                return test_bit(number, keyinfo) ? 1 : 0
            case let .hat(position):
                let number = controller.hatElements[element.id].number
                var hatInfoX = input_absinfo()
                guard ioctl(fd, EVIOCGABS(Int32(number) + ABS_HAT0X), &hatInfoX) >= 0 else {return 8}
                var hatInfoY = input_absinfo()
                guard ioctl(fd, EVIOCGABS(Int32( number) + ABS_HAT0Y), &hatInfoY) >= 0 else {return 8}
                
                switch (hatInfoX.value, hatInfoY.value) {
                case (0, -1)://up
                    return position == 1 ? 1 : 0
                case (1, -1)://upRight
                    return (position == 1 || position == 2) ? 1 : 0
                case (1, 0)://right
                    return position == 2 ? 1 : 0
                case (1, 1)://rightDown
                    return (position == 2 || position == 4) ? 1 : 0
                case (0, 1)://down
                    return position == 4 ? 1 : 0
                case (-1, 1)://leftDown
                    return (position == 4 || position == 8) ? 1 : 0
                case (-1, 0)://left
                    return position == 8 ? 1 : 0
                case (-1, -1)://upLeft
                    return (position == 1 || position == 8) ? 1 : 0
                default:
                    return 0
                }
            case let .analog(axis):
                let number = controller.axesElements[element.id].number
                var axisInfo = input_absinfo()
                guard ioctl(fd, EVIOCGABS(Int32(number)), &axisInfo) >= 0 else {return 0}
                let factor: Float = {
                    switch axis {
                    case .whole, .wholeInverted:
                        let distance = Float(abs(axisInfo.minimum - axisInfo.maximum))
                        var value = Float(axisInfo.minimum + axisInfo.value) / distance
                        if axis == .wholeInverted {
                            value *= -1
                        }
                        return value
                    case .negative:
                        if axisInfo.value < 0 {
                            return Float(axisInfo.value) / Float(axisInfo.minimum)
                        }
                    case .positive:
                        if axisInfo.value > 0 {
                            return Float(axisInfo.value) / Float(axisInfo.maximum)
                        }
                    }
                    return 0
                }()
                return Float(-1).interpolated(to: 1, .linear(factor))
            }
        }

        gamePad.dpad.up.value = value(from: controller, for: .dPadUp)
        gamePad.dpad.up.isPressed = gamePad.dpad.up.value > 0.1

        gamePad.dpad.down.value = value(from: controller, for: .dPadDown)
        gamePad.dpad.down.isPressed = gamePad.dpad.down.value > 0.1

        gamePad.dpad.left.value = value(from: controller, for: .dPadLeft)
        gamePad.dpad.left.isPressed = gamePad.dpad.left.value > 0.1

        gamePad.dpad.right.value = value(from: controller, for: .dPadRight)
        gamePad.dpad.right.isPressed = gamePad.dpad.right.value > 0.1

        gamePad.button.south.value = value(from: controller, for: .buttonA)
        gamePad.button.south.isPressed = gamePad.button.south.value > 0.1

        gamePad.button.east.value = value(from: controller, for: .buttonB)
        gamePad.button.east.isPressed = gamePad.button.east.value > 0.1

        gamePad.button.west.value = value(from: controller, for: .buttonX)
        gamePad.button.west.isPressed = gamePad.button.west.value > 0.1

        gamePad.button.north.value = value(from: controller, for: .buttonY)
        gamePad.button.north.isPressed = gamePad.button.north.value > 0.1

        gamePad.shoulder.left.value = value(from: controller, for: .shoulderL)
        gamePad.shoulder.left.isPressed = gamePad.shoulder.left.value > 0.1

        gamePad.shoulder.right.value = value(from: controller, for: .shoulderR)
        gamePad.shoulder.right.isPressed = gamePad.shoulder.right.value > 0.1

        gamePad.trigger.left.value = value(from: controller, for: .triggerL)
        gamePad.trigger.left.isPressed = gamePad.trigger.left.value > 0.1

        gamePad.trigger.right.value = value(from: controller, for: .triggerR)
        gamePad.trigger.right.isPressed = gamePad.trigger.right.value > 0.1

        gamePad.stick.left.button.value = value(from: controller, for: .buttonStickL)
        gamePad.stick.left.button.isPressed = gamePad.stick.left.button.value > 0.1
        gamePad.stick.left.xAxis = value(from: controller, for: .stickLAxisX)
        gamePad.stick.left.yAxis = value(from: controller, for: .stickLAxisY) * -1

        gamePad.stick.right.button.value = value(from: controller, for: .buttonStickR)
        gamePad.stick.right.button.isPressed = gamePad.stick.right.button.value > 0.1
        gamePad.stick.right.xAxis = value(from: controller, for: .stickRAxisX)
        gamePad.stick.right.yAxis = value(from: controller, for: .stickRAxisY) * -1

        gamePad.menu.primary.value = value(from: controller, for: .menuStart)
        gamePad.menu.primary.isPressed = gamePad.menu.primary.value > 0.1

        gamePad.menu.secondary.value = value(from: controller, for: .menuBack)
        gamePad.menu.secondary.isPressed = gamePad.menu.secondary.value > 0.1

        gamePad.menu.tertiary.value = value(from: controller, for: .menuGuid)
        gamePad.menu.tertiary.isPressed = gamePad.menu.tertiary.value > 0.1
    }
    
    func description(of gamePad: GamePad) -> String {
        let identifier: HIDController = gamePad.identifier as! HIDController
        return (identifier.map.name ?? "[Unknown]") + ", GUID: \(identifier.guid)"
    }
}

#endif
