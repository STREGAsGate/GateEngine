import XCTest

@testable import GameMath

final class Direction3Tests: XCTestCase {
    func testInit() {
        let direction = Direction3(x: 1, y: 2, z: 3)
        XCTAssertEqual(direction.x, 1)
        XCTAssertEqual(direction.y, 2)
        XCTAssertEqual(direction.z, 3)
    }

    func testInitFromTo() {
        do {  //Up
            let src = Position3(x: 0, y: 0, z: 0)
            let dst = Position3(x: 0, y: 1, z: 0)
            let expression1 = Direction3(from: src, to: dst)
            let expression2 = Direction3.up
            XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.0025)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.0025)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.0025)
        }
        do {  //Down
            let src = Position3(x: 0, y: 0, z: 0)
            let dst = Position3(x: 0, y: -1, z: 0)
            let expression1 = Direction3(from: src, to: dst)
            let expression2 = Direction3.down
            XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.0025)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.0025)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.0025)
        }
        do {  //Left
            let src = Position3(x: 0, y: 0, z: 0)
            let dst = Position3(x: -1, y: 0, z: 0)
            let expression1 = Direction3(from: src, to: dst)
            let expression2 = Direction3.left
            XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.0025)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.0025)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.0025)
        }
        do {  //Right
            let src = Position3(x: 0, y: 0, z: 0)
            let dst = Position3(x: 1, y: 0, z: 0)
            let expression1 = Direction3(from: src, to: dst)
            let expression2 = Direction3.right
            XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.0025)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.0025)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.0025)
        }
        do {  //Forward
            let src = Position3(x: 0, y: 0, z: 0)
            let dst = Position3(x: 0, y: 0, z: -1)
            let expression1 = Direction3(from: src, to: dst)
            let expression2 = Direction3.forward
            XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.0025)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.0025)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.0025)
        }
        do {  //Backward
            let src = Position3(x: 0, y: 0, z: 0)
            let dst = Position3(x: 0, y: 0, z: 1)
            let expression1 = Direction3(from: src, to: dst)
            let expression2 = Direction3.backward
            XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.0025)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.0025)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.0025)
        }
    }

    func testAngleTo() {
        let src: Direction3 = .up
        let dst: Direction3 = .right
        let value = src.angle(to: dst).rawValue
        let expected = Radians(90°).rawValue
        XCTAssertEqual(value, expected, accuracy: 0.0025)
    }

    func testAngleAroundX() {
        XCTAssertEqual(Direction3.right.angleAroundX, 0)
        XCTAssertEqual(Direction3.up.angleAroundX, Radians(90°))
    }

    func testAngleAroundY() {
        XCTAssertEqual(Direction3.up.angleAroundY, 0)
        XCTAssertEqual(Direction3.right.angleAroundY, Radians(90°))
    }

    func testAngleAroundZ() {
        XCTAssertEqual(Direction3.forward.angleAroundZ, 0)
        XCTAssertEqual(Direction3.up.angleAroundZ, Radians(90°))
    }

    func testRotated() {
        let src: Direction3 = .up
        let qat = Quaternion(90°, axis: .right).normalized
        let result = src.rotated(by: qat).normalized
        let expected = Direction3(0, 0, 1).normalized
        XCTAssertEqual(result.x, expected.x, accuracy: .ulpOfOne)
        XCTAssertEqual(result.y, expected.y, accuracy: .ulpOfOne)
        XCTAssertEqual(result.z, expected.z, accuracy: .ulpOfOne)
    }

    func testOrthogonal() {
        XCTAssertEqual(Direction3(x: 1, y: 2, z: 3).orthogonal(), Direction3(0, 3, -2))
        XCTAssertEqual(Direction3(x: 2, y: 1, z: 3).orthogonal(), Direction3(-3, 0, 2))
        XCTAssertEqual(Direction3(x: -2, y: -1, z: 1).orthogonal(), Direction3(1, -2, 0))
        XCTAssertEqual(Direction3(x: -1, y: -2, z: 1).orthogonal(), Direction3(2, -1, 0))
    }

    func testReflectedOff() {
        let src: Direction3 = .up
        let dst: Direction3 = .down
        let expression1 = src.reflected(off: dst)
        let expression2 = dst
        XCTAssertEqual(expression1.x, expression2.x, accuracy: 0.01)
        XCTAssertEqual(expression1.y, expression2.y, accuracy: 0.01)
        XCTAssertEqual(expression1.z, expression2.z, accuracy: 0.01)
    }

    func testUpDownLeftRightForwardBackward() {
        XCTAssertEqual(Direction3(x: 0, y: 1, z: 0), .up)
        XCTAssertEqual(Direction3(x: 0, y: -1, z: 0), .down)
        XCTAssertEqual(Direction3(x: -1, y: 0, z: 0), .left)
        XCTAssertEqual(Direction3(x: 1, y: 0, z: 0), .right)
        XCTAssertEqual(Direction3(x: 0, y: 0, z: -1), .forward)
        XCTAssertEqual(Direction3(x: 0, y: 0, z: 1), .backward)
    }
}
