import XCTest
@testable import GameMath

final class RadiansTests: XCTestCase {
    
    func testInitRawValue() {
        XCTAssert(Radians(10).rawValue == 10)
        XCTAssert(Radians(rawValue: 10).rawValue == 10)
    }
    func testInitDegrees() {
        XCTAssertEqual(Radians(10°).rawValue, 0.174533, accuracy: 0.0025)
        XCTAssertEqual(Radians(10°).rawValue, 0.174533, accuracy: 0.0025)
    }
    
    // Additions
    func testRadiansPlusRadians() {
        let r1 = Radians(1.0)
        let r2 = Radians(2.0)
        XCTAssertEqual(r1 + r2, Radians(3.0))
    }
    func testRadiansPlusRawValue() {
        let r1 = Radians(1.0)
        XCTAssertEqual(r1 + 2.0, Radians(3.0))
    }
    func testRawValuePlusRadians() {
        let r1 = Radians.RawValue(2) + Radians(1.0)
        XCTAssertEqual(r1, 3.0)
    }
    
    /// Subtraction
    func testRadiansMinusRadians() {
        let r1 = Radians(1.0)
        let r2 = Radians(2.0)
        XCTAssertEqual(r1 - r2, Radians(-1.0))
    }
    func testRadiansMinusRawValue() {
        let r1 = Radians(1.0)
        XCTAssertEqual(r1 - 2.0, Radians(-1.0))
    }
    func testRawValueMinusRadians() {
        let r1 = Radians.RawValue(2) - Radians(1.0)
        XCTAssertEqual(r1, 1.0)
    }
    
    /// Multiplication
    func testRadiansMulRadians() {
        let r1 = Radians(2.0)
        let r2 = Radians(2.0)
        XCTAssertEqual(r1 * r2, Radians(4.0))
    }
    func testRadiansMulRawValue() {
        let r1 = Radians(2.0)
        XCTAssertEqual(r1 * 2.0, Radians(4.0))
    }
    func testRawValueMulRadians() {
        let r1 = Radians.RawValue(2) * Radians(2.0)
        XCTAssertEqual(r1, 4.0)
    }
    
    /// Division
    func testRadiansDivRadians() {
        let r1 = Radians(2.0)
        let r2 = Radians(2.0)
        XCTAssertEqual(r1 / r2, Radians(1.0))
    }
    func testRadiansDivRawValue() {
        let r1 = Radians(2.0)
        XCTAssertEqual(r1 / 2.0, Radians(1.0))
    }
    func testRawValueDivRadians() {
        let r1 = Radians.RawValue(2) / Radians(2.0)
        XCTAssertEqual(r1, 1.0)
    }
    
    // Min
    func testMinRadiansRadians() {
        let r1 = Radians(1.0)
        let r2 = Radians(2.0)
        XCTAssertEqual(min(r1, r2), r1)
    }
    func testMinRadiansT() {
        let r1 = Radians(1.0)
        let r2: Float = 2.0
        XCTAssertEqual(min(r1, r2), r1)
    }
    func testMinTRadians() {
        let r1: Float = 2.0
        let r2 = Radians(1.0)
        XCTAssertEqual(min(r1, r2), r2)
    }
    
    // Max
    func testMaxRadiansRadians() {
        let r1 = Radians(2.0)
        let r2 = Radians(1.0)
        XCTAssertEqual(max(r1, r2), r1)
    }
    func testMaxRadiansT() {
        let r1 = Radians(2.0)
        let r2: Float = 1.0
        XCTAssertEqual(max(r1, r2), r1)
    }
    func testMaxTRadians() {
        let r1: Float = 1.0
        let r2 = Radians(2.0)
        XCTAssertEqual(max(r1, r2), r2)
    }
    
    func testAbs() {
        let r = Radians(-1)
        XCTAssertEqual(abs(r), Radians(1))
    }
    
    func testCeil() {
        let r = Radians(0.5)
        XCTAssertEqual(ceil(r), Radians(1))
    }
    func testFloor() {
        let r = Radians(0.5)
        XCTAssertEqual(floor(r), Radians(0))
    }
    func testRound() {
        XCTAssertEqual(round(Radians(0.4)), Radians(0))
        XCTAssertEqual(round(Radians(0.6)), Radians(1))
    }
    
    // Compare
    
    func testRadiansLessThanRadians() {
        let r1 = Radians(1.0)
        let r2 = Radians(2.0)
        XCTAssert(r1 < r2)
    }
    func testRadiansLessThanRawValue() {
        let r1 = Radians(1.0)
        let r2 = Radians.RawValue(2.0)
        XCTAssert(r1 < r2)
    }
    func testRawValueLessThanRadians() {
        let r1 = Radians.RawValue(1.0)
        let r2 = Radians(2.0)
        XCTAssert(r1 < r2)
    }
    
    func testRadiansGreaterThanRadians() {
        let r1 = Radians(1.0)
        let r2 = Radians(2.0)
        XCTAssert(r2 > r1)
    }
    func testRadiansGreaterThanRawValue() {
        let r1 = Radians(1.0)
        let r2 = Radians.RawValue(2.0)
        XCTAssert(r2 > r1)
    }
    func testRawValueGreaterThanRadians() {
        let r1 = Radians.RawValue(1.0)
        let r2 = Radians(2.0)
        XCTAssert(r2 > r1)
    }
    
    // Equatable
    func testRadiansEqualRadians() {
        let r1 = Radians(1.0)
        let r2 = Radians(1.0)
        XCTAssert(r2 == r1)
    }
    func testRawValueEqualRadians() {
        let r1 = Radians.RawValue(1.0)
        let r2 = Radians(1.0)
        XCTAssert(r2 == r1)
    }
    func testRadiansEqualRawValue() {
        let r1 = Radians(1.0)
        let r2 = Radians.RawValue(1.0)
        XCTAssert(r2 == r1)
    }
}

final class DegreesTests: XCTestCase {
    

    func testInitRawValue() {
        XCTAssert(Degrees(10).rawValue == 10)
        XCTAssert(Degrees(rawValue: 10).rawValue == 10)
    }
    func testInitRadians() {
        XCTAssertEqual(Degrees(Radians(0.174533)).rawValue, 10.000004286, accuracy: 0.0025)
        XCTAssertEqual(Degrees(Radians(0.174533)).rawValue, 10.000004, accuracy: 0.0025)
    }
    
    // Additions
    func testDegreesPlusDegrees() {
        let r1 = 1.0°
        let r2 = 2.0°
        XCTAssertEqual(r1 + r2, 3°)
    }
    func testDegreesPlusRawValue() {
        let r1 = 1°
        XCTAssertEqual(r1 + 2.0, 3°)
    }
    func testRawValuePlusDegrees() {
        let r1: Degrees.RawValue = 2 + 1°
        XCTAssertEqual(r1, 3.0)
    }
    
    /// Subtraction
    func testDegreesMinusDegrees() {
        let r1 = 1°
        let r2 = 2°
        XCTAssertEqual(r1 - r2, -1°)
    }
    func testDegreesMinusRawValue() {
        let r1 = 1°
        XCTAssertEqual(r1 - 2.0, -1°)
    }
    func testRawValueMinusDegrees() {
        let r1: Degrees.RawValue = 2 - 1°
        XCTAssertEqual(r1, 1.0)
    }
    
    /// Multiplication
    func testDegreesMulDegrees() {
        let r1 = 2°
        let r2 = 2°
        XCTAssertEqual(r1 * r2, 4°)
    }
    func testDegreesMulRawValue() {
        let r1 = 2°
        XCTAssertEqual(r1 * 2.0, 4°)
    }
    func testRawValueMulDegrees() {
        let r1: Degrees.RawValue = 2 * 2°
        XCTAssertEqual(r1, 4.0)
    }
    
    /// Division
    func testDegreesDivDegrees() {
        let r1 = 2°
        let r2 = 2°
        XCTAssertEqual(r1 / r2, 1°)
    }
    func testDegreesDivRawValue() {
        let r1 = 2°
        XCTAssertEqual(r1 / 2.0, 1°)
    }
    func testRawValueDivDegrees() {
        let r1: Degrees.RawValue = 2 / 2°
        XCTAssertEqual(r1, 1.0)
    }
    
    // Min
    func testMinDegreesDegrees() {
        let r1 = 1°
        let r2 = 2°
        XCTAssertEqual(min(r1, r2), r1)
    }
    func testMinDegreesT() {
        let r1 = 1°
        let r2: Float = 2.0
        XCTAssertEqual(min(r1, r2), r1)
    }
    func testMinTDegrees() {
        let r1: Float = 2.0
        let r2 = 1°
        XCTAssertEqual(min(r1, r2), r2)
    }
    
    // Max
    func testMaxDegreesDegrees() {
        let r1 = 2°
        let r2 = 1°
        XCTAssertEqual(max(r1, r2), r1)
    }
    func testMaxDegreesT() {
        let r1 = 2°
        let r2: Float = 1.0
        XCTAssertEqual(max(r1, r2), r1)
    }
    func testMaxTDegrees() {
        let r1: Float = 1.0
        let r2 = 2°
        XCTAssertEqual(max(r1, r2), r2)
    }
    
    func testAbs() {
        let r = -1°
        XCTAssertEqual(abs(r), 1°)
    }
    
    func testCeil() {
        let r = 0.5°
        XCTAssertEqual(ceil(r), 1°)
    }
    func testFloor() {
        let r = 0.5°
        XCTAssertEqual(floor(r), 0°)
    }
    func testRound() {
        XCTAssertEqual(round(0.4°), 0°)
        XCTAssertEqual(round(0.6°), 1°)
    }
    
    // Compare
    
    func testDegreesLessThanDegrees() {
        let r1 = 1°
        let r2 = 2°
        XCTAssert(r1 < r2)
    }
    func testDegreesLessThanRawValue() {
        let r1 = 1°
        let r2: Degrees.RawValue = 2
        XCTAssert(r1 < r2)
    }
    func testRawValueLessThanDegrees() {
        let r1: Degrees.RawValue = 1
        let r2 = 2°
        XCTAssert(r1 < r2)
    }
    
    func testDegreesGreaterThanDegrees() {
        let r1 = 1°
        let r2 = 2°
        XCTAssert(r2 > r1)
    }
    func testDegreesGreaterThanRawValue() {
        let r1 = 1°
        let r2: Degrees.RawValue = 2
        XCTAssert(r2 > r1)
    }
    func testRawValueGreaterThanDegrees() {
        let r1: Degrees.RawValue = 1
        let r2 = 2°
        XCTAssert(r2 > r1)
    }
    
    // Equatable
    func testDegreesEqualDegrees() {
        let r1 = 1°
        let r2 = 1°
        XCTAssert(r2 == r1)
    }
    func testRawValueEqualDegrees() {
        let r1: Degrees.RawValue = 1
        let r2 = 1°
        XCTAssert(r2 == r1)
    }
    func testDegreesEqualRawValue() {
        let r1 = 1°
        let r2: Degrees.RawValue = 1
        XCTAssert(r2 == r1)
    }
    
    func testNormalized() {
        XCTAssertEqual(361°.normalized, 1°)
        XCTAssertEqual((-1°).normalized, 359°)
    }
    
    func testShortestAngle() {
        XCTAssertEqual(0°.shortestAngle(to: 1°), 1°)
        XCTAssertEqual(0°.shortestAngle(to: 0°), 0°)
        XCTAssertEqual(0°.shortestAngle(to: -1°), -1°)
        XCTAssertEqual(-1°.shortestAngle(to: 0°), 1°)
        XCTAssertEqual(720°.shortestAngle(to: -720°), 0°)
    }
}
