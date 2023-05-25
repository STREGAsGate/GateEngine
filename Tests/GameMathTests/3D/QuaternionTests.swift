import XCTest
@testable import GameMath

final class QuaternionTests: XCTestCase {
    func testInit() {
        let quaternion = Quaternion(w: 1, x: 2, y: 3, z: 4)
        XCTAssertEqual(quaternion.w, 1)
        XCTAssertEqual(quaternion.x, 2)
        XCTAssertEqual(quaternion.y, 3)
        XCTAssertEqual(quaternion.z, 4)
    }

    func testInitDirectionUpRight() {
        let qat = Quaternion(direction: .left, up: .up, right: .right)
        let direction: Direction3 = .left
        let expected = direction.rotated(by: qat)
        XCTAssertEqual(expected.x, Direction3.forward.x, accuracy: 0.0025)
        XCTAssertEqual(expected.y, Direction3.forward.y, accuracy: 0.0025)
        XCTAssertEqual(expected.z, Direction3.forward.z, accuracy: 0.0025)
    }

    func testInitBetween() {
        do {
            let qat = Quaternion(between: .up, and: .down)
            let direction: Direction3 = qat.forward
            XCTAssertEqual(direction, .forward)
        }
        do {
            let qat = Quaternion(between: .left, and: .backward)
            let direction: Direction3 = qat.direction
            XCTAssertEqual(direction.x, 0, accuracy: 0.0025)
            XCTAssertEqual(direction.y, 0.47942555, accuracy: 0.0025)
            XCTAssertEqual(direction.z, 0, accuracy: 0.0025)
        }
    }

    func testInitRotationMatrix() {

    }
}
