import XCTest
@testable import GameMath

final class Position3Tests: XCTestCase {
    func testInit() {
        let position = Position3(x: 1, y: 2, z: 3)
        XCTAssertEqual(position.x, 1)
        XCTAssertEqual(position.y, 2)
        XCTAssertEqual(position.z, 3)
    }

    func testDistance() {
        let src = Position3(0, 1, 0)
        let dst = Position3(0, 2, 0)
        XCTAssertEqual(src.distance(from: dst), 1)
    }

    func testIsNear() {
        let src = Position3(0, 1.6, 0)
        let dst = Position3(0, 2, 0)
        XCTAssert(src.isNear(dst, threshold: 0.5))
    }

    func testMoved() {
        let src = Position3(0, 1, 0)
        let dst = Position3(0, 2, 0)
        let expression1 = src.moved(1, toward: .up)
        XCTAssertEqual(expression1.x, dst.x, accuracy: 0.0025)
        XCTAssertEqual(expression1.y, dst.y, accuracy: 0.0025)
        XCTAssertEqual(expression1.z, dst.z, accuracy: 0.0025)
    }

    func testMove() {
        var src = Position3(0, 1, 0)
        let dst = Position3(0, 2, 0)
        src.move(1, toward: .up)
        XCTAssertEqual(src.x, dst.x, accuracy: 0.0025)
        XCTAssertEqual(src.y, dst.y, accuracy: 0.0025)
        XCTAssertEqual(src.z, dst.z, accuracy: 0.0025)
    }
}
