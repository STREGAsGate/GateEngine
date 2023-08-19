import XCTest

@testable import GameMath

final class Position2Tests: XCTestCase {
    func testInit() {
        do {
            let pos = Position2(x: 1, y: 2)
            XCTAssertEqual(pos.x, 1)
            XCTAssertEqual(pos.y, 2)
        }
        do {
            let pos = Position2(1, 2)
            XCTAssertEqual(pos.x, 1)
            XCTAssertEqual(pos.y, 2)
        }
    }

    func testZero() {
        let pos = Position2(0, 0)
        XCTAssertEqual(pos, .zero)
    }

    func testDistanceFrom() {
        do {  // X axis
            let src = Position2(-5, 0)
            let dst = Position2(5, 0)
            XCTAssertEqual(src.distance(from: dst), 10)
        }
        do {  // Y axis
            let src = Position2(0, -5)
            let dst = Position2(0, 5)
            XCTAssertEqual(src.distance(from: dst), 10)
        }
    }

    func testAddition() {
        var lhs = Position2(-1, -1)
        let rhs = Position2(2, 2)
        XCTAssertEqual(lhs + rhs, Position2(1, 1))

        lhs += rhs
        XCTAssertEqual(lhs, Position2(1, 1))
    }

    func testSubtraction() {
        var lhs = Position2(2, 2)
        let rhs = Position2(-1, -1)
        XCTAssertEqual(lhs - rhs, Position2(3, 3))

        lhs -= rhs
        XCTAssertEqual(lhs, Position2(3, 3))
    }

    func testDivision() {
        do {  // Integer
            var lhs = Position2(2, 2)
            let rhs = Position2(2, 2)
            XCTAssertEqual(lhs / rhs, Position2(1, 1))

            lhs /= rhs
            XCTAssertEqual(lhs, Position2(1, 1))
        }
        do {  // FloatingPoint
            var lhs = Position2(2.5, 2.5)
            let rhs = Position2(2.5, 2.5)
            XCTAssertEqual(lhs / rhs, Position2(1, 1))

            lhs /= rhs
            XCTAssertEqual(lhs, Position2(1, 1))
        }
    }
}
