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
final class GravityMultipleInstanceTests: GateEngineXCTestCase {
    func testMultipleInstanceSetVar() async throws {
        let script = "extern var myVar; func main() {return myVar}"

        let gravity1 = Gravity()
        let gravity2 = Gravity()

        try await gravity1.compile(source: script)
        gravity1.setVar("myVar", to: 66)

        try await gravity2.compile(source: script)
        gravity2.setVar("myVar", to: 77)

        gravity1.setVar("myVar", to: 11)
        gravity2.setVar("myVar", to: 10)

        XCTAssertEqual(try gravity2.runMain(), 10)
        XCTAssertEqual(try gravity1.runMain(), 11)
    }
}

#endif
