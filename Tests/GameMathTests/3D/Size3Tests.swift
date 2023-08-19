import XCTest

@testable import GameMath

final class Size3Tests: XCTestCase {
    func testInit() {
        let size = Size3(width: 1, height: 2, depth: 3)
        XCTAssertEqual(size.x, 1)
        XCTAssertEqual(size.y, 2)
        XCTAssertEqual(size.z, 3)
    }
}
