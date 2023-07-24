import XCTest
@testable import GravityC
@testable import Gravity

extension URL {
    @_transparent
    init(resource: String) {
        self = Bundle.module.resourceURL!.appendingPathComponent("_Resources").appendingPathComponent(resource)
    }
}

extension XCTestCase {
    @_transparent
    func runGravity(at url: URL) {
        let gravity = Gravity()
        
        do {
            try gravity.compile(url)
            let result = try gravity.runMain().gValue
            XCTAssertTrue(gravity_value_equals(gravity.unitTestExpected!.value, result))
        }catch let error as Gravity.Error {
            let expected = gravity.unitTestExpected!
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
}
