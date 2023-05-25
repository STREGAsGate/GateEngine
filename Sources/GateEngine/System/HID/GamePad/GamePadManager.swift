/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

public extension HID {
    @MainActor final class GamePadManger {
        unowned let hid: HID
        let interpreters: [GamePadInterpreter]
        public private(set) var all: [GamePad] = []
        public private(set) var any: GamePad
        let nullGamePad: GamePad
        
        init(hid: HID) {
            self.hid = hid
            self.interpreters = getGamepadInterpreters(hid: hid)
            let nullPad = GamePad(interpreter: NullGamePadInterpreter(hid: hid), identifier: nil)
            self.nullGamePad = nullPad
            self.any = nullPad
            
            for interpreter in interpreters {
                interpreter.beginInterpreting()
            }
        }
        
        var lastPollIndex: UInt8 = .max
        var pollIndex: UInt8 = 0
        func pollIfNeeded() {
            guard lastPollIndex != pollIndex else {return}
            lastPollIndex = pollIndex
            for interpreter in interpreters {
                interpreter.update()
            }
            for gamePad in all {
                gamePad.interpreter.updateState(of: gamePad)
            }
            any = all.first(where: {$0.hasInput}) ?? nullGamePad
        }
        
        @inline(__always)
        func update() {
            pollIndex &+= 1
        }
    }
}
extension HID.GamePadManger {
    internal func addNewlyConnectedGamePad(_ gamePad: GamePad) {
        print("[GateEngine] GamePad connected:", gamePad.interpreter.description(of: gamePad))
        self.all.append(gamePad)
    }
    
    internal func removedDisconnectedGamePad(_ gamePad: GamePad) {
        print("[GateEngine] GamePad disconnected:", gamePad.interpreter.description(of: gamePad))
        gamePad.state = .disconnected
        all.removeAll(where: {$0 === gamePad})
    }
}

@_transparent
@MainActor fileprivate func getGamepadInterpreters(hid: HID) -> [GamePadInterpreter] {
    #if os(macOS)
    if Bundle.main.bundleIdentifier == nil {
        // GameController (MFI) framework doesn't function without an application bundle
        // This can happen if the application is executed without a bundle, such as a swift executable package
        // We ommit the MFI interpretter becuase it will never get any controllers
        return [HIDGamePadInterpreter(hid: hid)]
    }
    return [HIDGamePadInterpreter(hid: hid), MFIGamePadInterpreter(hid: hid)]
    #elseif os(Linux)
    return [LinuxHIDGamePadInterpreter(hid: hid)]
    #elseif os(Windows)
    return [XInputGamePadInterpreter(hid: hid)]
    #elseif os(iOS) || os(tvOS)
    return [MFIGamePadInterpreter(hid: hid)]
    #elseif os(WASI)
    return [WASIGamePadInterpreter(hid: hid)]
    #elseif os(Android)
    return []
    #elseif os(PS4)
    return []
    #endif
}
