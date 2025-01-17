/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import XCTest

@testable import GateEngine
@testable import Gravity

open class GateEngineXCTestCase: XCTestCase {
    final class TestGameDelegate: GameDelegate {
        func createMainWindow(using manager: GateEngine.WindowManager, with identifier: String) throws -> GateEngine.Window {
            return try manager.createWindow(identifier: identifier, rootViewController: ViewController())
        }
        
        func didFinishLaunching(game: Game, options: LaunchOptions) {

        }
        func isHeadless() -> Bool {
            return true
        }
        nonisolated func gameIdentifier() -> StaticString? {
            return "com.STREGAsGate.GateEngine.tests"
        }

        nonisolated func customResourceLocations() -> [String] {
            func moduleName() -> String {
                #if swift(>=6)
                return #file.components(separatedBy: "/")[0]
                #else
                class ModuleLocator {

                }
                let ref = String(reflecting: type(of: ModuleLocator()))
                return String(ref.split(separator: ".")[0])
                #endif
            }

            #if canImport(Darwin)
            return ["GateEngine_\(moduleName()).bundle"]
            #else
            return ["GateEngine_\(moduleName()).resources"]
            #endif
        }
    }

    @MainActor open override func setUp() async throws {
        guard Game._shared == nil else { return }

        let delegate = TestGameDelegate()
        let platform = CurrentPlatform(delegate: delegate)
        Game._shared = Game(delegate: delegate, currentPlatform: platform)

        await Game.shared.didFinishLaunching()

        #if os(WASI)
        // Removing the system finishes startup as if the user had clicked
        Game.shared.removeSystem(WASIUserActivationRenderingSystem.self)
        #endif
    }
}
