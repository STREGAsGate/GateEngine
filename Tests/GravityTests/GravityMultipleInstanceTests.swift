import XCTest
@testable import GravityC
@testable import Gravity

// These tests make sure multiple instances of `Gravity` can co-exist.

final class GravityMultipleInstanceTests: XCTestCase {
    func testMultipleInstanceSetVar() throws {
        let script = "extern var myVar; func main() {return myVar}"
        
        let gravity1 = Gravity()
        let gravity2 = Gravity()
        
        try gravity1.compile(script)
        gravity1.setVar("myVar", to: 66)
        
        try gravity2.compile(script)
        gravity2.setVar("myVar", to: 77)
        
        gravity1.setVar("myVar", to: 11)
        gravity2.setVar("myVar", to: 10)
        
        XCTAssertEqual(try gravity2.runMain(), 10)
        XCTAssertEqual(try gravity1.runMain(), 11)
    }
}
