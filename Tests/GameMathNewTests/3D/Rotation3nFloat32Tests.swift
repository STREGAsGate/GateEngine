import XCTest

@testable import GameMath

fileprivate typealias Scalar = Float32

final class Rotation3nFloat32Tests: XCTestCase {
    func testInit() {
        let rotation = Rotation3n<Scalar>(x: 1, y: 2, z: 3, w: 4)
        XCTAssertEqual(rotation.x, 1)
        XCTAssertEqual(rotation.y, 2)
        XCTAssertEqual(rotation.z, 3)
        XCTAssertEqual(rotation.w, 4)
    }
    
    func testEuler() {
        let rotation = Rotation3n<Scalar>(pitch: 361°, yaw: -180°, roll: 90°)
        XCTAssertEqual(rotation.pitch.asDegrees.normalized.rawValueAsDegrees, (361°).normalized.rawValueAsDegrees, accuracy: .accuracy)
        XCTAssertEqual(rotation.yaw.asDegrees.normalized.rawValueAsDegrees, (-180°).normalized.rawValueAsDegrees, accuracy: .accuracy)
        XCTAssertEqual(rotation.roll.asDegrees.normalized.rawValueAsDegrees, (90°).normalized.rawValueAsDegrees, accuracy: .accuracy)
    }
}
