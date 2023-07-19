import XCTest
@testable import GameMath

final class Transform3Tests: XCTestCase {
    func testInit() {
        let p = Position3(1, 2, 3)
        let r = Quaternion(x: 0, y: 0, z: 0, w: 1)
        let s = Size3(1, 2, 3)
        let t = Transform3(position: p, rotation: r, scale: s)
        
        XCTAssertEqual(t.position, p)
        XCTAssertEqual(t.rotation, r)
        XCTAssertEqual(t.scale, s)
    }
}
