import XCTest

@testable import GameMath

final class AxisAlignedBoundingBox2DTests: XCTestCase {
    func testInit() {
        do {
            let center = Position2(1, 2)
            let offset = Position2(3, 4)
            let radius = Size2(5, 6)
            let box1 = AxisAlignedBoundingBox2D(center: center, offset: offset, radius: radius)
            XCTAssertEqual(box1.center, center)
            XCTAssertEqual(box1.offset, offset)
            XCTAssertEqual(box1.radius, radius)
        }
        do {
            let center = Position2(1, 2)
            let offset = Position2(3, 4)
            let radius = Size2(5, 6)
            let box1 = AxisAlignedBoundingBox2D(center: center, offset: offset, radius: radius)
            XCTAssertEqual(box1.center, center)
            XCTAssertEqual(box1.offset, offset)
            XCTAssertEqual(box1.radius, radius)
        }
    }

    func testPoints() {
        let box = AxisAlignedBoundingBox2D(radius: .one)
        let expectedPoints: Set<Position2> = [
            Position2(1, 1),
            Position2(1, -1),
            Position2(-1, 1),
            Position2(-1, -1),
        ]
        XCTAssertEqual(Set(box.points()), expectedPoints)
    }

    func testSelfInterpenetrationSelf() {
        do {  // ontop of eachother
            let box1 = AxisAlignedBoundingBox2D(radius: .one)
            let box2 = AxisAlignedBoundingBox2D(radius: .one)
            guard let interpenetration = box1.interpenetration(comparing: box2) else {
                XCTFail("interpentation(comparing:) failed")
                return
            }
            XCTAssertEqual(interpenetration.depth, -box1.radius.y)
        }
        do {  // postive/negative grid space
            let box1 = AxisAlignedBoundingBox2D(center: Position2(0.9, 0.9), radius: .one)
            let box2 = AxisAlignedBoundingBox2D(center: Position2(-0.9, -0.9), radius: .one)
            guard let interpenetration = box1.interpenetration(comparing: box2) else {
                XCTFail("interpentation(comparing:) failed")
                return
            }
            let expectedDepth = -Position2(box1.radius + 0.1).distance(
                from: Position2(box2.radius - 0.1)
            )
            XCTAssertEqual(interpenetration.depth, expectedDepth)
        }
    }
}
