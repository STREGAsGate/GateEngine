import XCTest
@testable import GameMath

final class RectTests: XCTestCase {
    func testInit() {
        do {
            let rect = Rect(position: Position2(1, 2), size: Size2(3, 4))
            XCTAssertEqual(rect.position, Position2(1, 2))
            XCTAssertEqual(rect.size, Size2(3, 4))
        }
        do {
            let rect = Rect(x: 1, y: 2, width: 3, height: 4)
            XCTAssertEqual(rect.position, Position2(1, 2))
            XCTAssertEqual(rect.size, Size2(3, 4))
        }
    }

    func testArea() {
        let rect = Rect(size: Size2(2, 2))
        XCTAssertEqual(rect.area, 4)
    }

    func testXYWidthHeight() {
        var rect: Rect = .zero
        rect.x = 1
        XCTAssertEqual(rect.x, 1)
        rect.y = 2
        XCTAssertEqual(rect.y, 2)
        rect.width = 3
        XCTAssertEqual(rect.width, 3)
        rect.height = 4
        XCTAssertEqual(rect.height, 4)
    }

    func testMaxYMaxX() {
        let rect = Rect(position: Position2(1, 1), size: Size2(1, 1))
        XCTAssertEqual(rect.maxX, 2)
        XCTAssertEqual(rect.maxY, 2)
    }

    func textCenter() {
        let rect = Rect(position: Position2(1, 1), size: Size2(1, 1))
        XCTAssertEqual(rect.center, Position2(1.5, 1.5))
    }

    func testIsFinite() {
        do {
            let rect = Rect(position: Position2(.nan, 1), size: Size2(.infinity, 1))
            XCTAssertFalse(rect.isFinite)
        }
        do {
            let rect = Rect(position: .zero, size: .one)
            XCTAssert(rect.isFinite)
        }
    }

    func testInterpolatedToLinear() {
        let source = Rect(position: .zero, size: Size2(1, 1))
        let destination = Rect(position: Position2(1, 1), size: Size2(2, 2))

        let value = source.interpolated(to: destination, .linear(0.5))
        let expected = Rect(position: Position2(0.5, 0.5), size: Size2(1.5, 1.5))
        XCTAssertEqual(value, expected)
    }

    func testZero() {
        let rect = Rect(position: .zero, size: .zero)
        XCTAssertEqual(rect, .zero)
    }

    func testMultiply() {
        var rect = Rect(position: Position2(1, 1), size: Size2(1, 1))
        let expected = Rect(position: Position2(2, 2), size: Size2(2, 2))
        XCTAssertEqual(rect * 2, expected)

        rect *= 2
        XCTAssertEqual(rect, expected)
    }
}
