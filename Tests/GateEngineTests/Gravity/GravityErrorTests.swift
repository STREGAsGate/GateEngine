/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

import XCTest
@testable import GateEngine

@MainActor
final class GravityErrorTests: GateEngineXCTestCase {
    var gravity: Gravity! = nil
    var randomValue: Int = 0
    override func setUp() {
        gravity = Gravity()
        randomValue = Int.random(in: -10000 ..< 10000)
    }

    // Make sure syntax errors throw
    func testGravitySyntaxError() throws {
        XCTAssertThrowsError(try gravity.compile(source: "vir myVar = 10; func main() {}"))
    }

    // Make sure runtime errors throw
    func testGravityRuntimeError() throws {
        // runMain when there is no main
        try gravity.compile(source: "var myVar = 10; func myFunc() {return 1}")
        XCTAssertThrowsError(try gravity.runMain())
    }

    func testMainBeforeCompiling() throws {
        // runMain before compiling
        XCTAssertThrowsError(try gravity.runMain())
    }

    // Is this legal? No idea
    func testCompilingMultipleTimes() throws {
        try gravity.compile(source: "var myVar = 10; func main() {return 100}")
        XCTAssertEqual(try gravity.runMain(), 100)
        try gravity.compile(source: "func main() {return 101}")
        XCTAssertEqual(try gravity.runMain(), 101)
        XCTAssertEqual(gravity.getVar("myVar"), 10)
    }
}

#endif
