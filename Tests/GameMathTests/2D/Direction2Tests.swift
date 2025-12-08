import XCTest

@testable import GameMath

final class Direction2Tests: XCTestCase {
    func testInit() {
        let direction = Direction2(x: 1, y: 2)
        XCTAssertEqual(direction.x, 1)
        XCTAssertEqual(direction.y, 2)
    }

    func testInitFromTo() {
        do {  //Up
            let src = Position2(x: 0, y: 0)
            let dst = Position2(x: 0, y: 1)
            let expression1 = Direction2(from: src, to: dst)
            let expression2 = Direction2.up
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
        }
        do {  //Down
            let src = Position2(x: 0, y: 0)
            let dst = Position2(x: 0, y: -1)
            let expression1 = Direction2(from: src, to: dst)
            let expression2 = Direction2.down
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
        }
        do {  //Left
            let src = Position2(x: 0, y: 0)
            let dst = Position2(x: -1, y: 0)
            let expression1 = Direction2(from: src, to: dst)
            let expression2 = Direction2.left
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
        }
        do {  //Right
            let src = Position2(x: 0, y: 0)
            let dst = Position2(x: 1, y: 0)
            let expression1 = Direction2(from: src, to: dst)
            let expression2 = Direction2.right
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
        }
    }

    func testAngleTo() {
        let src: Direction2 = .up
        let dst: Direction2 = .right
        let value = src.angle(to: dst).rawValue
        let expected = Radians(90°).rawValue
        XCTAssertEqual(value, expected, accuracy: .accuracy)
    }

    func testAngleAroundZ() {
        let direction: Direction2 = .right
        XCTAssertEqual(direction.angleAroundZ, Radians(90°))
    }

    func testZero() {
        let direction = Direction2(0, 0)
        XCTAssertEqual(direction, .zero)
    }

    func testUp() {
        let direction = Direction2(0, 1)
        XCTAssertEqual(direction, .up)
    }

    func testDown() {
        let direction = Direction2(0, -1)
        XCTAssertEqual(direction, .down)
    }

    func testLeft() {
        let direction = Direction2(-1, 0)
        XCTAssertEqual(direction, .left)
    }

    func testRight() {
        let direction = Direction2(1, 0)
        XCTAssertEqual(direction, .right)
    }
}
