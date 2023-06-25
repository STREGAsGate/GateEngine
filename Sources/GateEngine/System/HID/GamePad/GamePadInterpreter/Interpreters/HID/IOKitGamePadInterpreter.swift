/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(IOKit)

import Foundation
import IOKit.hid

fileprivate class HIDController {
    let guid: SDL2ControllerGUID
    let device: IOHIDDevice
    var buttonElements: [ElementCache] = []
    var axesElements: [ElementCache] = []
    var hatElements: [ElementCache] = []
    
    struct ElementCache {
        let cookie: IOHIDElementCookie
        let element: IOHIDElement
        let min: Int
        let max: Int
    }
    
    init(guid: SDL2ControllerGUID, device: IOHIDDevice) {
        self.guid = guid
        self.device = device
    }
}
internal class IOKitGamePadInterpreter: GamePadInterpreter {
    @inline(__always)
    var hid: HID {Game.shared.hid}
    init?() { }
    
    static let sdlDatabase = try! SDL2Database()
    var sdlDatabase: SDL2Database {
        return Self.sdlDatabase
    }
        
    private let hidManager: IOHIDManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

    func beginInterpreting() {
        IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
        
        let criterion: [[String:Any]] = [[kIOHIDDeviceUsagePageKey : kHIDPage_GenericDesktop, kIOHIDDeviceUsageKey : kHIDUsage_GD_GamePad],
                                         [kIOHIDDeviceUsagePageKey : kHIDPage_GenericDesktop, kIOHIDDeviceUsageKey : kHIDUsage_GD_Joystick],
                                         [kIOHIDDeviceUsagePageKey : kHIDPage_GenericDesktop, kIOHIDDeviceUsageKey : kHIDUsage_GD_MultiAxisController]]
        IOHIDManagerSetDeviceMatchingMultiple(hidManager, criterion as CFArray?)
        
        IOHIDManagerRegisterDeviceMatchingCallback(hidManager, gamepadWasAdded, nil)
        IOHIDManagerRegisterDeviceRemovalCallback(hidManager, gamepadWasRemoved, nil)
//        IOHIDManagerRegisterInputValueCallback(hidManager, gamepadAction, nil)
        let ioreturn = IOHIDManagerOpen(hidManager, IOOptionBits(kIOHIDOptionsTypeSeizeDevice))
        if ioreturn != kIOReturnSuccess {
            Log.error("HID controller error: ", ioreturn)
        }
    }
    
    func update() {}
    
    func endInterpreting() {
        IOHIDManagerClose(hidManager, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerUnscheduleFromRunLoop(hidManager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
    }
    
    func setupGamePad(_ gamePad: GamePad) {
        guard let hidController = gamePad.identifier as! HIDController? else {fatalError("Identifier is not an IOHIDDevice!")}

        gamePad.symbols = sdlDatabase.controllers[hidController.guid]?.symbols() ?? .unknown
        
        let elements: [IOHIDElement] = IOHIDDeviceCopyMatchingElements(hidController.device, nil, IOOptionBits(kIOHIDOptionsTypeNone)) as! [IOHIDElement]
        
        var hats: [IOHIDElement] = []
        var buttons: [IOHIDElement] = []
        var analogs: [IOHIDElement] = []
        
        var existing: Set<IOHIDElement> = []
        
        func processElements(_ elements: [IOHIDElement]) {
            for element in elements {
                guard CFGetTypeID(element) == IOHIDElementGetTypeID() else {continue}
                guard existing.contains(element) == false else {continue}
                let usagePage = Int(IOHIDElementGetUsagePage(element));
                switch IOHIDElementGetType(element) {
                case kIOHIDElementTypeInput_Axis, kIOHIDElementTypeInput_Button, kIOHIDElementTypeInput_Misc:
                    let usage = Int(IOHIDElementGetUsage(element))
                    switch usagePage {
                    case kHIDPage_GenericDesktop:
                        switch usage {
                        case kHIDUsage_GD_X, kHIDUsage_GD_Y, kHIDUsage_GD_Z,
                             kHIDUsage_GD_Rx, kHIDUsage_GD_Ry, kHIDUsage_GD_Rz,
                             kHIDUsage_GD_Slider, kHIDUsage_GD_Dial, kHIDUsage_GD_Wheel:
                            analogs.append(element)
                            existing.insert(element)
                        case kHIDUsage_GD_Hatswitch:
                            hats.append(element)
                            existing.insert(element)
                        case kHIDUsage_GD_DPadUp, kHIDUsage_GD_DPadDown, kHIDUsage_GD_DPadRight, kHIDUsage_GD_DPadLeft,
                             kHIDUsage_GD_Start, kHIDUsage_GD_Select, kHIDUsage_GD_SystemMenu:
                            buttons.append(element)
                            existing.insert(element)
                        default:
                            break
                        }
                    case kHIDPage_Simulation:
                        switch usage {
                        case kHIDUsage_Sim_Rudder, kHIDUsage_Sim_Throttle, kHIDUsage_Sim_Accelerator, kHIDUsage_Sim_Brake:
                            analogs.append(element)
                            existing.insert(element)
                        default:
                            break;
                        }
                    case kHIDPage_Button, kHIDPage_Consumer:
                        buttons.append(element)
                        existing.insert(element)
                    default:
                        break
                    }
                case kIOHIDElementTypeCollection:
                    processElements(IOHIDElementGetChildren(element) as! [IOHIDElement])
                default:
                    break
                }
            }
        }
        processElements(elements)
        
        for element in buttons.sorted(by: {IOHIDElementGetUsage($0) < IOHIDElementGetUsage($1)}) {
            hidController.buttonElements.append(HIDController.ElementCache(cookie: IOHIDElementGetCookie(element),
                                                                           element: element,
                                                                           min: IOHIDElementGetLogicalMin(element),
                                                                           max: IOHIDElementGetLogicalMax(element)))
        }
        for element in hats.sorted(by: {IOHIDElementGetUsage($0) < IOHIDElementGetUsage($1)}) {
            hidController.hatElements.append(HIDController.ElementCache(cookie: IOHIDElementGetCookie(element),
                                                                        element: element,
                                                                        min: IOHIDElementGetLogicalMin(element),
                                                                        max: IOHIDElementGetLogicalMax(element)))
        }
        for element in analogs.sorted(by: {IOHIDElementGetUsage($0) < IOHIDElementGetUsage($1)}) {
            hidController.axesElements.append(HIDController.ElementCache(cookie: IOHIDElementGetCookie(element),
                                                                         element: element,
                                                                         min: IOHIDElementGetLogicalMin(element),
                                                                         max: IOHIDElementGetLogicalMax(element)))
        }
    }
    
    func updateState(of gamePad: GamePad) {
        guard let controller = gamePad.identifier as! HIDController? else {fatalError("Identifier is not an IOHIDDevice!")}
        
        if let sdlController = sdlDatabase.controllers[controller.guid] {
            updateStateForSDL2Controller(gamePad, controller: sdlController)
        }else{
            fatalError("GamePad was supposed to be supported but there is no implememntation.")
        }
    }
    
    func description(of gamePad: GamePad) -> String {
        let id = (gamePad.identifier as! HIDController).guid
        return (sdlDatabase.controllers[id]?.name ?? "[Unknown]") + ", GUID: \(id.guid)"
    }
    
    var userReadableName: String {return "IOKit"}
}

fileprivate func supportedDeviceIdentifierFrom(_ device: IOHIDDevice) -> SDL2ControllerGUID? {
    guard MFIGamePadInterpreter.supports(device) == false else {return nil}

    guard let vendorID = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int else {return nil}
    guard let productID = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int else {return nil}
    guard let version = IOHIDDeviceGetProperty(device, kIOHIDVersionNumberKey as CFString) as? Int else {return nil}
    guard let transport = IOHIDDeviceGetProperty(device, kIOHIDTransportKey as CFString) as? String else {return nil}
    
    var sldTransport: SDL2ControllerGUID.Transport = .usb
    switch transport {
    case kIOHIDTransportBluetoothValue:
        sldTransport = .bluetooth
    case kIOHIDTransportBluetoothLowEnergyValue:
        sldTransport = .bluetooth
    default:
        break
    }
    
    let guid = SDL2ControllerGUID(vendorID: vendorID, productID: productID, hidVersion: version, transport: Int(sldTransport.rawValue))
    guard IOKitGamePadInterpreter.sdlDatabase.controllers.keys.contains(guid) == true else {return nil}
    return guid
}

fileprivate func gamepadWasAdded(inContext: UnsafeMutableRawPointer?, inResult: IOReturn, inSender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
    guard let guid = supportedDeviceIdentifierFrom(device) else {
        IOHIDDeviceClose(device, .zero)
        return
    }
    
    Task {@MainActor in
        if let interpreter = Game.shared.hid.gamePads.interpreters.first(where:{$0 is IOKitGamePadInterpreter}) as? IOKitGamePadInterpreter {
            let controller = GamePad(interpreter: interpreter, identifier: HIDController(guid: guid, device: device))
            interpreter.hid.gamePads.addNewlyConnectedGamePad(controller)
        }
    }
}

fileprivate func gamepadWasRemoved(inContext: UnsafeMutableRawPointer?, inResult: IOReturn, inSender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
    Task {@MainActor in
        let interpreter = Game.shared.hid.gamePads.interpreters.filter({$0 is IOKitGamePadInterpreter}).first! as! IOKitGamePadInterpreter
        if let controller = interpreter.hid.gamePads.all.first(where: {($0.identifier as? HIDController)?.device === device}) {
            interpreter.hid.gamePads.removedDisconnectedGamePad(controller)
        }
    }
}

fileprivate func gamepadAction(inContext: UnsafeMutableRawPointer?, inResult: IOReturn, inSender: UnsafeMutableRawPointer?, value: IOHIDValue) {
    //print("Gamepad talked!");
//    let element = IOHIDValueGetElement(value);
    // print("Element:", element);

//    let elementValue = IOHIDValueGetIntegerValue(value)
//    let physical = IOHIDValueGetScaledValue(value, IOHIDValueScaleType(kIOHIDValueScaleTypePhysical))
//    let calibrated = IOHIDValueGetScaledValue(value, IOHIDValueScaleType(kIOHIDValueScaleTypeCalibrated))
//
//    if DualShock4Wired_256(rawValue:IOHIDElementGetCookie(element)) == nil {
//        print("Element: \(IOHIDElementGetCookie(element))", elementValue, physical, calibrated)
//    }
}

extension IOKitGamePadInterpreter {
    func integerValue(from device: IOHIDDevice, element: IOHIDElement, cookie: IOHIDElementCookie) -> Int? {
        let value = IOHIDValueCreateWithIntegerValue(nil, element, 0, 0)
        var pointer = Unmanaged<IOHIDValue>.passUnretained(value)
        if IOHIDDeviceGetValue(device, element, &pointer) == kHIDSuccess {
            return IOHIDValueGetIntegerValue(pointer.takeUnretainedValue()) as Int
        }
        return nil
    }
    func normalizedValue(device: IOHIDDevice, element: IOHIDElement, cookie: IOHIDElementCookie, min: Int, max: Int, axis: SDL2ControllerMap.Value.Kind.Axis) -> Float? {
        guard let intValue = integerValue(from: device, element: element, cookie: cookie) else {return nil}

        switch axis {
        case .whole, .wholeInverted:
            let distance = Float(abs(min - max))
            var value = Float(min + intValue) / distance
            if axis == .wholeInverted {
                value *= -1
            }
            return value
        case .negative:
            if intValue < 0 {
                return Float(intValue) / Float(min)
            }
        case .positive:
            if intValue > 0 {
                return Float(intValue) / Float(max)
            }
        }
        return nil
    }
}


extension IOKitGamePadInterpreter {
    func updateStateForSDL2Controller(_ gamePad: GamePad, controller: SDL2ControllerMap) {
        guard let hidDevice = gamePad.identifier as! HIDController? else {fatalError("Identifier is not an IOHIDDevice!")}
        
        func hatValue(_ hatValue: Int, matches rawValue: Int, max: Int) -> Bool {
            var hatValue = hatValue
            if max == 3 {
                //convert from 4 position to 8 position
                hatValue *= 2
            }
            
            let dUp: Set = [7,0,1]
            let dRight: Set = [1,2,3]
            let dDown: Set = [3,4,5]
            let dLeft: Set = [5,6,7]
            
            switch rawValue {
            case 1:
                return dUp.contains(hatValue)
            case 2:
                return dRight.contains(hatValue)
            case 4:
                return dDown.contains(hatValue)
            case 8:
                return dLeft.contains(hatValue)
            default:
                return false
            }
        }
        
        func valueFor(_ value: SDL2ControllerMap.Value?, invert: Bool) -> Float {
            guard let value = value else {return 0}

            switch value.kind {
            case .hat(_):
                break
            case .button:
                break
            case let .analog(axis):
                let elementID = hidDevice.axesElements[value.id]
                var axisValue: Float
                if let value = normalizedValue(device: hidDevice.device, element: elementID.element, cookie: elementID.cookie, min: elementID.min, max: elementID.max, axis: axis) {
                    axisValue = Float(-1.0).interpolated(to: 1.0, .linear(value))
                }else{
                    axisValue = 0
                }
                if invert {
                    axisValue *= -1
                }
                return axisValue
            }
            return 0
        }
        
        func update(_ button: GamePad.ButtonState, withValue value: SDL2ControllerMap.Value?) {
            guard let value = value else {return}

            switch value.kind {
            case let .hat(position):
                let elementID = hidDevice.hatElements[value.id]
                if let dPadValue = integerValue(from: hidDevice.device, element: elementID.element, cookie: elementID.cookie) {
                    button.isPressed = hatValue(dPadValue, matches: position, max: elementID.max)
                }
            case .button:
                let elementID = hidDevice.buttonElements[value.id]
                if let value = integerValue(from: hidDevice.device, element: elementID.element, cookie: elementID.cookie), value != 0 {
                    button.isPressed = true
                    button.value = 1
                }else{
                    button.isPressed = false
                    button.value = 0
                }
            case .analog:
                button.value = valueFor(value, invert: false)
                button.isPressed = button.value > 0.1
            }
        }
        
        update(gamePad.dpad.up, withValue: controller.elements[.dPadUp])
        update(gamePad.dpad.down, withValue: controller.elements[.dPadDown])
        update(gamePad.dpad.left, withValue: controller.elements[.dPadLeft])
        update(gamePad.dpad.right, withValue: controller.elements[.dPadRight])

        update(gamePad.button.north, withValue: controller.elements[.buttonY])
        update(gamePad.button.south, withValue: controller.elements[.buttonA])
        update(gamePad.button.west, withValue: controller.elements[.buttonX])
        update(gamePad.button.east, withValue: controller.elements[.buttonB])

        update(gamePad.shoulder.left, withValue: controller.elements[.shoulderL])
        update(gamePad.shoulder.right, withValue: controller.elements[.shoulderR])
        
        update(gamePad.trigger.left, withValue: controller.elements[.triggerL])
        update(gamePad.trigger.right, withValue: controller.elements[.triggerR])

        update(gamePad.menu.primary, withValue: controller.elements[.menuStart])
        update(gamePad.menu.secondary, withValue: controller.elements[.menuBack])
        update(gamePad.menu.tertiary, withValue: controller.elements[.menuGuid])

        update(gamePad.stick.left.button, withValue: controller.elements[.buttonStickL])
        gamePad.stick.left.xAxis = valueFor(controller.elements[.stickLAxisX], invert: false)
        gamePad.stick.left.yAxis = valueFor(controller.elements[.stickLAxisY], invert: true)

        update(gamePad.stick.right.button, withValue: controller.elements[.buttonStickR])
        gamePad.stick.right.xAxis = valueFor(controller.elements[.stickRAxisX], invert: false)
        gamePad.stick.right.yAxis = valueFor(controller.elements[.stickRAxisY], invert: true)
    }
}

#endif
