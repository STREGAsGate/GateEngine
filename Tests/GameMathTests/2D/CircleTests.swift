import XCTest

@testable import GameMath

final class CircleTests: XCTestCase {
    func testInit() {
        let circle = Circle(center: .zero, radius: 1)
        XCTAssertEqual(circle.center, .zero)
        XCTAssertEqual(circle.radius, 1)
    }
}
