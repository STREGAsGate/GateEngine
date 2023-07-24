import XCTest
@testable import GravityC
@testable import Gravity


final class GravityCreateValueTests: XCTestCase {
    let gravity = Gravity()
    func testInt() {
        XCTAssertEqual(GravityValue(1), 1)
        XCTAssertEqual(GravityValue(0), 0)
        XCTAssertEqual(GravityValue(-1), -1)
        XCTAssertNotEqual(GravityValue(-1.0), -1) // Casting should not work
    }
    
    func testFloat() {
        XCTAssertEqual(GravityValue(1.12345), 1.12345)
        XCTAssertNotEqual(GravityValue(1.0), 1) // Casting should not work
        
        // Gravity assumes non-finite values as undefined
        XCTAssertEqual(GravityValue(Double.nan), .undefined)
        XCTAssertEqual(GravityValue(Double.infinity), .undefined)
        XCTAssertEqual(GravityValue(Double.signalingNaN), .undefined)
    }
    
    func testRange() {
        XCTAssertEqual(GravityValue(1 ... 10), 1 ... 10)
        XCTAssertEqual(GravityValue(1 ... 10).getRange(), 1 ... 10)
        XCTAssertEqual(GravityValue(1 ..< 10), 1 ..< 10)
        XCTAssertEqual(GravityValue(1 ..< 10).getRange(), 1 ..< 10)
    }
    
    func testString() {
        XCTAssertEqual(GravityValue("Hello Train 🚂"), "Hello Train 🚂")
        XCTAssertNotEqual(GravityValue("Hello Train 🚂 "), "Hello Train 🚂")//trailing space
    }
    
    func testBool() {
        XCTAssertEqual(GravityValue(true), true)
        XCTAssertEqual(GravityValue(false), false)
        XCTAssertNotEqual(GravityValue(true), false)
    }
    
    func testList() {
        XCTAssertEqual(GravityValue(["yup", 1, 1.1, true]), ["yup", 1, 1.1, true])
        XCTAssertEqual(GravityValue(["yup", 1, 1.1, true]), ["yup", 1, 1.1, true])
        XCTAssertNotEqual(GravityValue([1, true]), [1.0, 1]) // Casting should not work
    }
    
    func testMap() {
        XCTAssertEqual(GravityValue(["yup": 1, 1.1: true]), ["yup": 1, 1.1: true])
        XCTAssertNotEqual(GravityValue([1: true]), [1.0: 1]) // Casting should not work
    }
}
