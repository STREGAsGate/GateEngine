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
        func didFinishLaunching(game: Game, options: LaunchOptions) {
            
        }
        func isHeadless() -> Bool {
            return true
        }
        nonisolated func gameIdentifier() -> StaticString? {
            return "com.STREGAsGate.GateEngine.tests"
        }
        
        nonisolated func customResourceLocations() -> [String] {
            #if hasFeature(ConciseMagicFile)
            let module = #file.components(separatedBy: "/")[0]
            #else
            let module = "\(type(of: Self.self))".components(separatedBy: ".")[0]
            #endif
            
            #if canImport(Darwin)
            return ["Contents/Resources/GateEngine_\(module).bundle"]
            #else
            return ["GateEngine_\(module).resources"]
            #endif
        }
    }
    
    @MainActor open override func setUp() async throws {
        if Game.shared == nil {
            let delegate = TestGameDelegate()
            let platform = CurrentPlatform(delegate: delegate)
            Game.shared = Game(delegate: delegate, currentPlatform: platform)
            
            await Game.shared.didFinishLaunching()
        }
    }
}
