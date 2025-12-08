import XCTest

@testable import GateUtilities

final class BitStreamTests: XCTestCase {

    func testSubscript() {
        let stream = BitStream(0b00000100)
        XCTAssertTrue(stream[2])
        XCTAssertFalse(stream[3])
    }

    func testSeek() {
        var stream = BitStream(0b10000100)
        stream.seekBits(2)
        XCTAssertEqual(stream.readBits(1), 1)
        stream.seekBits(4)
        XCTAssertEqual(stream.readBits(1), 1)
    }
}
