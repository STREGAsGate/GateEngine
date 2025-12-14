/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import XCTest
@testable import GateEngine

@MainActor
final class RawGeometryTests: GateEngineXCTestCase {
    func testInt() {
        XCTAssertTrue(RawGeometry().isEmpty)
        
        // Array literal
        let triangle = Triangle(p1: 1.0, p2: 1.0, p3: 1.0)
        XCTAssertEqual([triangle].first, triangle)
        XCTAssertEqual(RawGeometry(arrayLiteral: triangle).first, triangle)
    }
    
    func testEquatable() {
        let triangle1 = Triangle(p1: .zero + 1, p2: .zero + 2, p3: .zero + 3)
        let triangle2 = Triangle(p1: .zero + 4, p2: .zero + 5, p3: .zero + 6)
        let triangle3 = Triangle(p1: .zero + 7, p2: .zero + 8, p3: .zero + 9)
        let triangle4 = Triangle(p1: .zero + 10, p2: .zero + 11, p3: .zero + 12)
        
        let rawGeometry1: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        let rawGeometry2: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        
        XCTAssertEqual(rawGeometry1, rawGeometry2)
    }
    
    func testSwapAt() {
        let triangle1 = Triangle(p1: .zero + 1, p2: .zero + 2, p3: .zero + 3)
        let triangle2 = Triangle(p1: .zero + 4, p2: .zero + 5, p3: .zero + 6)
        let triangle3 = Triangle(p1: .zero + 7, p2: .zero + 8, p3: .zero + 9)
        let triangle4 = Triangle(p1: .zero + 10, p2: .zero + 11, p3: .zero + 12)
        
        var rawGeometry: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        
        rawGeometry.swapAt(0, 3)
        let expected1: RawGeometry = [triangle4, triangle2, triangle3, triangle1]
        XCTAssertEqual(rawGeometry, expected1)
        
        rawGeometry.swapAt(1, 2)
        let expected2: RawGeometry = [triangle4, triangle3, triangle2, triangle1]
        XCTAssertEqual(rawGeometry, expected2)
        
        rawGeometry.swapAt(2, 0)
        let expected3: RawGeometry = [triangle2, triangle3, triangle4, triangle1]
        XCTAssertEqual(rawGeometry, expected3)
    }
    
    func testRemoveAndInsert() {
        let triangle1 = Triangle(p1: .zero + 1, p2: .zero + 2, p3: .zero + 3)
        let triangle2 = Triangle(p1: .zero + 4, p2: .zero + 5, p3: .zero + 6)
        let triangle3 = Triangle(p1: .zero + 7, p2: .zero + 8, p3: .zero + 9)
        let triangle4 = Triangle(p1: .zero + 10, p2: .zero + 11, p3: .zero + 12)
        
        var rawGeometry: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        
        // remove at left insert at right
        let expected1: RawGeometry = [triangle1, triangle3, triangle2, triangle4]
        let remove1 = rawGeometry.remove(at: 1)
        XCTAssertEqual(remove1, triangle2)
        rawGeometry.insert(remove1, at: 2)
        XCTAssertEqual(rawGeometry[2], triangle2)
        XCTAssertEqual(rawGeometry, expected1)
        
        // remove at right insert at left
        let expected2: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        let remove2 = rawGeometry.remove(at: 2)
        XCTAssertEqual(remove2, triangle2)
        rawGeometry.insert(remove2, at: 1)
        XCTAssertEqual(rawGeometry[1], triangle2)
        XCTAssertEqual(rawGeometry, expected2)
        
        // remove at 0 insert at end
        let expected3: RawGeometry = [triangle2, triangle3, triangle4, triangle1]
        let remove3 = rawGeometry.remove(at: 0)
        XCTAssertEqual(remove3, triangle1)
        XCTAssertEqual(rawGeometry[0], triangle2)
        rawGeometry.insert(remove3, at: rawGeometry.endIndex)
        XCTAssertEqual(rawGeometry[rawGeometry.endIndex - 1], triangle1)
        XCTAssertEqual(rawGeometry, expected3)
        
        // remove at end insert at 0
        let expected4: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        let remove4 = rawGeometry.remove(at: rawGeometry.endIndex - 1)
        XCTAssertEqual(remove4, triangle1)
        XCTAssertEqual(rawGeometry[rawGeometry.endIndex - 1], triangle4)
        rawGeometry.insert(remove4, at: 0)
        XCTAssertEqual(rawGeometry[0], triangle1)
        XCTAssertEqual(rawGeometry, expected4)
        
        // stress
        for _ in 0 ..< 1000 {
            let index = rawGeometry.indices.randomElement()!
            let removed = rawGeometry.remove(at: index)
            rawGeometry.insert(removed, at: index)
            XCTAssertEqual(rawGeometry[index], removed)
        }
    }
    
    func testAppend() {
        let triangle1 = Triangle(p1: .zero + 1, p2: .zero + 2, p3: .zero + 3)
        let triangle2 = Triangle(p1: .zero + 4, p2: .zero + 5, p3: .zero + 6)
        let triangle3 = Triangle(p1: .zero + 7, p2: .zero + 8, p3: .zero + 9)
        let triangle4 = Triangle(p1: .zero + 10, p2: .zero + 11, p3: .zero + 12)
        
        var rawGeometry: RawGeometry = [triangle1, triangle2, triangle3]
        rawGeometry.append(triangle4)
        let expected: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        XCTAssertEqual(rawGeometry, expected)
    }
    
    func testBinaryCodable() throws {
        let triangle1 = Triangle(p1: .zero + 1, p2: .zero + 2, p3: .zero + 3)
        let triangle2 = Triangle(p1: .zero + 4, p2: .zero + 5, p3: .zero + 6)
        let triangle3 = Triangle(p1: .zero + 7, p2: .zero + 8, p3: .zero + 9)
        let triangle4 = Triangle(p1: .zero + 10, p2: .zero + 11, p3: .zero + 12)
        
        var rawGeometry: RawGeometry = [triangle1, triangle2, triangle3, triangle4]
        
        var data: ContiguousArray<UInt8> = []
        
        try rawGeometry.encode(into: &data, version: .latest)
        
        let decoded: RawGeometry = try data.withUnsafeBytes { bytes in
            var offset = 0
            return try RawGeometry(decoding: bytes, at: &offset, version: .latest)
        }

        XCTAssertEqual(rawGeometry, decoded)
    }
}
