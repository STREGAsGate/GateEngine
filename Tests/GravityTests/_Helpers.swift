import XCTest
@testable import GateEngine
@testable import Gravity

extension XCTestCase {
    func runGravity(at path: String) async {
        let gravity = Gravity()
        
        do {
            try await gravity.compile(file: path)
            let result = try gravity.runMain().gValue
            XCTAssertTrue(gravity_value_equals(Gravity.unitTestExpected!.value, result))
        }catch let error as Gravity.Error {
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
            XCTFail()
        }
    }
    
    open override func setUp() async throws {
        final class TestGameDelegate: GameDelegate {
            func didFinishLaunching(game: Game, options: LaunchOptions) {
                
            }
            func isHeadless() -> Bool {
                return true
            }
            nonisolated func gameIdentifier() -> StaticString? {
                return "com.STREGAsGate.GateEngine.tests"
            }
        }
        let delegate = await TestGameDelegate()
        Game.shared = await Game(delegate: delegate, currentPlatform: CurrentPlatform(delegate: delegate))
        await Game.shared.delegate.didFinishLaunching(game: Game.shared, options: [])
    }
}
