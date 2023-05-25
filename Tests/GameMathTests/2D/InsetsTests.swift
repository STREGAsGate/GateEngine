import XCTest
@testable import GameMath

final class InsetsTests: XCTestCase {
    func testInit() {
        let insets = Insets(top: 1, leading: 2, bottom: 3, trailing: 4)
        XCTAssertEqual(insets.top, 1)
        XCTAssertEqual(insets.leading, 2)
        XCTAssertEqual(insets.bottom, 3)
        XCTAssertEqual(insets.trailing, 4)
    }
    
    func testZero() {
        let insetsFloat = Insets(top: 0, leading: 0, bottom: 0, trailing: 0)
        XCTAssertEqual(insetsFloat, .zero)
        let insetsInt = Insets(top: 0, leading: 0, bottom: 0, trailing: 0)
        XCTAssertEqual(insetsInt, .zero)
    }
}
