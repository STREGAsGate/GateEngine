import XCTest

@testable import GameMath

final class Size2Tests: XCTestCase {
    func testInit() {
        let size = Size2(1, 1)
        XCTAssertEqual(size.width, 1)
        XCTAssertEqual(size.height, 1)
    }
}
