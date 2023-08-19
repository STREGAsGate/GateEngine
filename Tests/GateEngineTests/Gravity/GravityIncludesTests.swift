/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if !DISABLE_GRAVITY_TESTS

import XCTest
@testable import GateEngine

// These tests make sure multiple instances of `Gravity` can co-exist.
final class GravityIncludesTests: GateEngineXCTestCase {
    func testIncludes() async throws {
        let gravity = Gravity()
        try await gravity.compile(file: "Resources/Scripts/includes1.gravity")

        XCTAssertEqual(try gravity.runMain(), 123_456_789)
    }
}

#endif
