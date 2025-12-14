//
//  Position3Tests.swift
//  GateEngine
//
//  Created by Dustin Collins on 12/13/25.
//


import XCTest

@testable import GameMath

fileprivate typealias Scalar = Float32

final class Position3nFloat32Tests: XCTestCase {
    func testInit() {
        let position = Position3n<Scalar>(x: 1, y: 2, z: 3)
        XCTAssertEqual(position.x, 1)
        XCTAssertEqual(position.y, 2)
        XCTAssertEqual(position.z, 3)
    }
    
    func testCastFromPosition3n() {
        let vectorToCast = Direction3n<Scalar>(
            x: .random(in: -01234...56789),
            y: .random(in: -01234...56789),
            z: .random(in: -01234...56789)
        )
        let position = Position3n<Scalar>(vectorToCast)
        XCTAssertEqual(position.x, vectorToCast.x)
        XCTAssertEqual(position.y, vectorToCast.y)
        XCTAssertEqual(position.z, vectorToCast.z)
    }
    
    func testCastFromDirection3n() {
        let vectorToCast = Direction3n<Scalar>(
            x: .random(in: -01234...56789),
            y: .random(in: -01234...56789),
            z: .random(in: -01234...56789)
        )
        let position = Position3n<Scalar>(vectorToCast)
        XCTAssertEqual(position.x, vectorToCast.x)
        XCTAssertEqual(position.y, vectorToCast.y)
        XCTAssertEqual(position.z, vectorToCast.z)
    }
    
    func testCastFromSize3n() {
        let vectorToCast = Size3n<Scalar>(
            x: .random(in: -01234...56789),
            y: .random(in: -01234...56789),
            z: .random(in: -01234...56789)
        )
        let position = Position3n<Scalar>(vectorToCast)
        XCTAssertEqual(position.x, vectorToCast.x)
        XCTAssertEqual(position.y, vectorToCast.y)
        XCTAssertEqual(position.z, vectorToCast.z)
    }

    func testDistance() {
        let src = Position3n<Scalar>(0, 1, 0)
        let dst = Position3n<Scalar>(0, 2, 0)
        XCTAssertEqual(src.distance(from: dst), 1)
    }

    func testIsNear() {
        let src = Position3n<Scalar>(0, 1.6, 0)
        let dst = Position3n<Scalar>(0, 2, 0)
        XCTAssert(src.isNear(dst, threshold: 0.5))
    }

    func testMoved() {
        let src = Position3n<Scalar>(0, 1, 0)
        let dst = Position3n<Scalar>(0, 2, 0)
        let expression1 = src.moved(1, toward: .up)
        XCTAssertEqual(expression1.x, dst.x, accuracy: .accuracy)
        XCTAssertEqual(expression1.y, dst.y, accuracy: .accuracy)
        XCTAssertEqual(expression1.z, dst.z, accuracy: .accuracy)
    }

    func testMove() {
        var src = Position3n<Scalar>(0, 1, 0)
        let dst = Position3n<Scalar>(0, 2, 0)
        src.move(1, toward: .up)
        XCTAssertEqual(src.x, dst.x, accuracy: .accuracy)
        XCTAssertEqual(src.y, dst.y, accuracy: .accuracy)
        XCTAssertEqual(src.z, dst.z, accuracy: .accuracy)
    }
}
