import XCTest
@testable import GameMath

final class InterpolationTests: XCTestCase {
    
    func testInterpolatedToLinear() {
        // Start value
        XCTAssertEqual(Float(-1.0).interpolated(to: 1.0, .linear(0.0)), -1.0)
        // Halfway
        XCTAssertEqual(Float(-1.0).interpolated(to: 1.0, .linear(0.5)), 0.0)
        // End value
        XCTAssertEqual(Float(-1.0).interpolated(to: 1.0, .linear(1.0)), 1.0)
    }
    
    
    func testInterpolateToLinear() {
        var value: Float = 0
        // Start value
        value = -1
        value.interpolate(to: 1.0, .linear(0.0))
        XCTAssertEqual(value, -1.0)
        // Halfway
        value = -1
        value.interpolate(to: 1.0, .linear(0.5))
        XCTAssertEqual(value, 0.0)
        // End value
        value = -1
        value.interpolate(to: 1.0, .linear(1.0))
        XCTAssertEqual(value, 1.0)
    }
    
    func testPosition3Linear() {
        let start = Position3(-1, -1, -1)
        let end = Position3(1, 1, 1)
        // Start value
        XCTAssertEqual(start.interpolated(to: end, .linear(0.0)), start)
        // Halfway
        XCTAssertEqual(start.interpolated(to: end, .linear(0.5)), .zero)
        // End value
        XCTAssertEqual(start.interpolated(to: end, .linear(1.0)), end)
    }
    
    func testSize3Linear() {
        let start = Size3(-1, -1, -1)
        let end = Size3(1, 1, 1)
        // Start value
        XCTAssertEqual(start.interpolated(to: end, .linear(0.0)), start)
        // Halfway
        XCTAssertEqual(start.interpolated(to: end, .linear(0.5)), .zero)
        // End value
        XCTAssertEqual(start.interpolated(to: end, .linear(1.0)), end)
    }
    
    func testDirection3Linear() {
        let start = Direction3(-1, -1, -1)
        let end = Direction3(1, 1, 1)
        // Start value
        XCTAssertEqual(start.interpolated(to: end, .linear(0.0)), start)
        // Halfway
        XCTAssertEqual(start.interpolated(to: end, .linear(0.5)), .zero)
        // End value
        XCTAssertEqual(start.interpolated(to: end, .linear(1.0)), end)
    }
    
    func testQuaternionLinear() {
        let start = Quaternion(0°, axis: .right).normalized
        let end = Quaternion(180°, axis: .right).normalized
        
        do {// Start value
            let value = start.interpolated(to: end, .linear(0.0, options: [])).normalized
            let expected = start
            XCTAssertEqual(value.w, expected.w, accuracy: .ulpOfOne)
            XCTAssertEqual(value.x, expected.x, accuracy: .ulpOfOne)
            XCTAssertEqual(value.y, expected.y, accuracy: .ulpOfOne)
            XCTAssertEqual(value.z, expected.z, accuracy: .ulpOfOne)
        }
        
        do {// Halfway
            let value = start.interpolated(to: end, .linear(1/2, options: [])).normalized
            let expected = Quaternion(90°, axis: .right).normalized
            let angleAroundX = expected.forward.angleAroundX
            let angleAroundY = expected.forward.angleAroundY
            let angleAroundZ = expected.forward.angleAroundZ
            XCTAssertEqual(value.forward.angleAroundX.rawValue, angleAroundX.rawValue, accuracy: .ulpOfOne)
            XCTAssertEqual(value.forward.angleAroundY.rawValue, angleAroundY.rawValue, accuracy: .ulpOfOne)
            XCTAssertEqual(value.forward.angleAroundZ.rawValue, angleAroundZ.rawValue, accuracy: .ulpOfOne)
        }
        
        do {// End value
            let value = start.interpolated(to: end, .linear(1.0, options: [])).normalized
            let expected = end
            XCTAssertEqual(value.w, expected.w, accuracy: .ulpOfOne)
            XCTAssertEqual(value.x, expected.x, accuracy: .ulpOfOne)
            XCTAssertEqual(value.y, expected.y, accuracy: .ulpOfOne)
            XCTAssertEqual(value.z, expected.z, accuracy: .ulpOfOne)
        }
    }
    
    func testQuaternionShortest() {
        // This test is difficult to perform accuraualy. To help, results are unitNormalized to bring them as close to the same format as possible before comparison. Because results are modified this a poor test, but good enough for regetion chcking.
        
        let start = Quaternion(45°, axis: .right).normalized
        let end = Quaternion(-45°, axis: .right).normalized
        
        do {// Start value
            let value = start.interpolated(to: end, .linear(0.0, options: .shortest)).normalized
            let expected = start
            XCTAssertEqual(value.w, expected.w, accuracy: .ulpOfOne)
            XCTAssertEqual(value.x, expected.x, accuracy: .ulpOfOne)
            XCTAssertEqual(value.y, expected.y, accuracy: .ulpOfOne)
            XCTAssertEqual(value.z, expected.z, accuracy: .ulpOfOne)
        }
        
        do {// Halfway
            let value = start.interpolated(to: end, .linear(1/2, options: .shortest)).normalized
            let expected = Quaternion(0°, axis: .right).normalized
            let angleAroundX = expected.forward.angleAroundX
            let angleAroundY = expected.forward.angleAroundY
            let angleAroundZ = expected.forward.angleAroundZ
            XCTAssertEqual(value.forward.angleAroundX.rawValue, angleAroundX.rawValue, accuracy: .ulpOfOne)
            XCTAssertEqual(value.forward.angleAroundY.rawValue, angleAroundY.rawValue, accuracy: .ulpOfOne)
            XCTAssertEqual(value.forward.angleAroundZ.rawValue, angleAroundZ.rawValue, accuracy: .ulpOfOne)
        }
        
        do {// End value
            let value = start.interpolated(to: end, .linear(1.0, options: .shortest)).normalized
            let expected = end
            XCTAssertEqual(value.w, expected.w, accuracy: .ulpOfOne)
            XCTAssertEqual(value.x, expected.x, accuracy: .ulpOfOne)
            XCTAssertEqual(value.y, expected.y, accuracy: .ulpOfOne)
            XCTAssertEqual(value.z, expected.z, accuracy: .ulpOfOne)
        }
    }
}
