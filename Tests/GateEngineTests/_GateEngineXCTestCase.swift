/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import XCTest
@testable import GateEngine
@testable import Gravity

open class GateEngineXCTestCase: XCTestCase {
    final class TestGameDelegate: GameDelegate {
        func didFinishLaunching(game: Game, options: LaunchOptions) async {
            
        }
        func isHeadless() -> Bool {
            return true
        }
        nonisolated func gameIdentifier() -> StaticString? {
            return "com.STREGAsGate.GateEngine.tests"
        }
    }
    
    @MainActor open override func setUp() async throws {
        if Game.shared == nil {
            let delegate = TestGameDelegate()
            let platform = await CurrentPlatform(delegate: delegate)
            Game.shared = Game(delegate: delegate, currentPlatform: platform)
            
            await Game.shared.didFinishLaunching()
        }
    }
}
