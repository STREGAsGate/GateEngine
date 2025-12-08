import XCTest

@testable import GameMath

fileprivate typealias Scalar = Float64

final class Direction3nFloat64Tests: XCTestCase {
    func testInit() {
        let direction = Direction3n<Scalar>(x: 1, y: 2, z: 3)
        XCTAssertEqual(direction.x, 1)
        XCTAssertEqual(direction.y, 2)
        XCTAssertEqual(direction.z, 3)
    }

    func testInitFromTo() {
        do {  //Up
            let src = Position3n<Scalar>(x: 0, y: 0, z: 0)
            let dst = Position3n<Scalar>(x: 0, y: 1, z: 0)
            let expression1 = Direction3n<Scalar>(from: src, to: dst)
            let expression2 = Direction3n<Scalar>.up
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
        do {  //Down
            let src = Position3n<Scalar>(x: 0, y: 0, z: 0)
            let dst = Position3n<Scalar>(x: 0, y: -1, z: 0)
            let expression1 = Direction3n<Scalar>(from: src, to: dst)
            let expression2 = Direction3n<Scalar>.down
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
        do {  //Left
            let src = Position3n<Scalar>(x: 0, y: 0, z: 0)
            let dst = Position3n<Scalar>(x: -1, y: 0, z: 0)
            let expression1 = Direction3n<Scalar>(from: src, to: dst)
            let expression2 = Direction3n<Scalar>.left
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
        do {  //Right
            let src = Position3n<Scalar>(x: 0, y: 0, z: 0)
            let dst = Position3n<Scalar>(x: 1, y: 0, z: 0)
            let expression1 = Direction3n<Scalar>(from: src, to: dst)
            let expression2 = Direction3n<Scalar>.right
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
        do {  //Forward
            let src = Position3n<Scalar>(x: 0, y: 0, z: 0)
            let dst = Position3n<Scalar>(x: 0, y: 0, z: -1)
            let expression1 = Direction3n<Scalar>(from: src, to: dst)
            let expression2 = Direction3n<Scalar>.forward
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
        do {  //Backward
            let src = Position3n<Scalar>(x: 0, y: 0, z: 0)
            let dst = Position3n<Scalar>(x: 0, y: 0, z: 1)
            let expression1 = Direction3n<Scalar>(from: src, to: dst)
            let expression2 = Direction3n<Scalar>.backward
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
    }

    func testAngleTo() {
        let src: Direction3n<Scalar> = .up
        let dst: Direction3n<Scalar> = .right
        let value = src.angle(to: dst).rawValue
        let expected = Radians(90°).rawValue
        XCTAssertEqual(value, expected, accuracy: Radians.RawValue(Scalar.accuracy))
    }

    func testAngleAroundX() {
        XCTAssertEqual(Direction3n<Scalar>.right.angleAroundX, 0)
        XCTAssertEqual(Radians(Direction3n<Scalar>.up.angleAroundX), Radians(90°))
    }

    func testAngleAroundY() {
        XCTAssertEqual(Direction3n<Scalar>.up.angleAroundY, 0)
        XCTAssertEqual(Radians(Direction3n<Scalar>.right.angleAroundY), Radians(90°))
    }

    func testAngleAroundZ() {
        XCTAssertEqual(Direction3n<Scalar>.forward.angleAroundZ, 0)
        XCTAssertEqual(Radians(Direction3n<Scalar>.up.angleAroundZ), Radians(90°))
    }

    func testRotated() {
        let src: Direction3n<Scalar> = .up
        let qat = Rotation3n<Scalar>(90°, axis: .right).normalized
        let result = src.rotated(by: qat).normalized
        let expected = Direction3n<Scalar>(0, 0, 1).normalized
        XCTAssertEqual(result.x, expected.x, accuracy: .accuracy)
        XCTAssertEqual(result.y, expected.y, accuracy: .accuracy)
        XCTAssertEqual(result.z, expected.z, accuracy: .accuracy)
    }

    func testOrthogonal() {
        XCTAssertEqual(Direction3n<Scalar>(x: 1, y: 2, z: 3).orthogonal(), Direction3n<Scalar>(0, 3, -2))
        XCTAssertEqual(Direction3n<Scalar>(x: 2, y: 1, z: 3).orthogonal(), Direction3n<Scalar>(-3, 0, 2))
        XCTAssertEqual(Direction3n<Scalar>(x: -2, y: -1, z: 1).orthogonal(), Direction3n<Scalar>(1, -2, 0))
        XCTAssertEqual(Direction3n<Scalar>(x: -1, y: -2, z: 1).orthogonal(), Direction3n<Scalar>(2, -1, 0))
    }

    func testReflectedOff() {
        let src: Direction3n<Scalar> = .up
        let dst: Direction3n<Scalar> = .down
        let expression1 = src.reflected(off: dst)
        let expression2 = dst
        XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
        XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
        XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
    }

    func testUpDownLeftRightForwardBackward() {
        XCTAssertEqual(Direction3n<Scalar>(x: 0, y: 1, z: 0), .up)
        XCTAssertEqual(Direction3n<Scalar>(x: 0, y: -1, z: 0), .down)
        XCTAssertEqual(Direction3n<Scalar>(x: -1, y: 0, z: 0), .left)
        XCTAssertEqual(Direction3n<Scalar>(x: 1, y: 0, z: 0), .right)
        XCTAssertEqual(Direction3n<Scalar>(x: 0, y: 0, z: -1), .forward)
        XCTAssertEqual(Direction3n<Scalar>(x: 0, y: 0, z: 1), .backward)
    }
}
