/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension HID {
    @MainActor public final class GamePadManger {
        var hid: HID { Game.shared.hid }
        let interpreters: [any GamePadInterpreter]
        public private(set) var all: [GamePad] = []
        public private(set) var any: GamePad
        let nullGamePad: GamePad

        init() {
            self.interpreters = getGamepadInterpreters()
            let nullPad = GamePad(interpreter: NullGamePadInterpreter(), identifier: nil)
            self.nullGamePad = nullPad
            self.any = nullPad

            for interpreter in interpreters {
                interpreter.beginInterpreting()
            }
        }

        var lastPollIndex: UInt8 = .max
        var pollIndex: UInt8 = 0
        func pollIfNeeded() {
            guard lastPollIndex != pollIndex else { return }
            lastPollIndex = pollIndex
            for interpreter in interpreters {
                interpreter.update()
            }
            for gamePad in all {
                gamePad.interpreter.updateState(of: gamePad)
            }
            any = all.first(where: { $0.hasInput }) ?? nullGamePad
        }

        func update() {
            pollIndex &+= 1
        }
    }
}
extension HID.GamePadManger {
    internal func addNewlyConnectedGamePad(_ gamePad: GamePad) {
        Log.info(
            "GamePad Connected: \(gamePad.interpreter.description(of: gamePad)), Symbols: \(gamePad.symbols), Connection:",
            gamePad.interpreter.userReadableName
        )
        self.all.append(gamePad)
    }

    internal func removedDisconnectedGamePad(_ gamePad: GamePad) {
        Log.info(
            "GamePad Disconnected: \(gamePad.interpreter.description(of: gamePad)), Symbols: \(gamePad.symbols), Connection:",
            gamePad.interpreter.userReadableName
        )
        gamePad.state = .disconnected
        all.removeAll(where: { $0 === gamePad })
    }
}

@MainActor private func getGamepadInterpreters() -> [any GamePadInterpreter] {
    #if os(macOS) || os(iOS) || os(tvOS)
    var interpreters: [(any GamePadInterpreter)?] = []
    #if canImport(IOKit)
    interpreters.append(IOKitGamePadInterpreter())
    #endif
    interpreters.append(MFIGamePadInterpreter())
    return interpreters.compactMap({ $0 })
    #elseif os(Linux)
    return [LinuxHIDGamePadInterpreter()]
    #elseif os(Windows)
    return [XInputGamePadInterpreter()]
    #elseif os(WASI)
    return [WASIGamePadInterpreter()]
    #else
    #error("Unsupported Platform")
    #endif
}
