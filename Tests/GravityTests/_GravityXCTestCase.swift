/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import XCTest
@testable import GateEngine
@testable import Gravity

open class GravityXCTestCase: XCTestCase {
    func runGravity(at path: String) async {
        let gravity = Gravity()
        
        do {
            try await gravity.compile(file: path)
            let result = try gravity.runMain().gValue
            XCTAssertTrue(gravity_value_equals(Gravity.unitTestExpected!.value, result))
        }catch let GateEngineError.scriptCompileError(gravityError) {
            let error = gravity.unitTestError!
            let expected = Gravity.unitTestExpected!
            if expected.row > -1 {// -1 means don't compare value
                XCTAssertEqual(expected.row, error.row)
            }
            if expected.column > -1 {// -1 means don't compare value
                XCTAssertEqual(expected.column, error.column)
            }
            XCTAssertEqual(expected.errorType, error.errorType)
        }catch{
            // A non gravity error is a failure
            Log.error("Gravity Non-Test", error)
            XCTFail("\(error)")
        }
    }
    
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
            let platform = CurrentPlatform(delegate: delegate)
            Game.shared = Game(delegate: delegate, currentPlatform: platform)
            
            await Game.shared.didFinishLaunching()
        }
    }
}
