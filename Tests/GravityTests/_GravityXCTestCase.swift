/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

public import XCTest
@testable import GateEngine
@testable import Gravity

open class GravityXCTestCase: XCTestCase {
    // This test simply makes this class have a test that passes so Xcode marks the test as completed
    // Without this Xcode marks the test ambiguous
    func testNothing() {
        XCTAssert(true)
    }
    
    @MainActor
    func runGravity(at path: String) async {
        let gravity = Gravity()

        do {
            try await gravity.compile(file: path)
            let result = try gravity.runMain().gValue
            XCTAssertTrue(gravity_value_equals(Gravity.unitTestExpected!.value, result))
        } catch GateEngineError.scriptCompileError(_) {
            let error = gravity.unitTestError!
            let expected = Gravity.unitTestExpected!
            if expected.row > -1 {  // -1 means don't compare value
                XCTAssertEqual(expected.row, error.row)
            }
            if expected.column > -1 {  // -1 means don't compare value
                XCTAssertEqual(expected.column, error.column)
            }
            XCTAssertEqual(expected.errorType, error.errorType)
        } catch {
            // A non gravity error is a failure
            Log.error("Gravity Non-Test", error)
            XCTFail("\(error)")
        }
    }

    final class TestGameDelegate: GameDelegate {
        func createMainWindow(using manager: GateEngine.WindowManager, with identifier: String) throws -> GateEngine.Window {
            return try manager.createWindow(identifier: identifier, rootViewController: ViewController())
        }
        
        func didFinishLaunching(game: Game, options: LaunchOptions) async {

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
        Game._shared = Game(delegate: delegate)

        await Game.shared.didFinishLaunching()

        #if os(WASI)
        // Removing the system finishes startup as if the user had clicked
        Game.shared.removeSystem(WASIUserActivationRenderingSystem.self)
        #endif
    }
}

#endif
