import XCTest
@testable import GameMath

final class Matrix4x4Tests: XCTestCase {
    func testInit() {
        do {
            let matrix = Matrix4x4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
            XCTAssertEqual(matrix.array(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        }
        do {
            let matrix = Matrix4x4(a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12, m: 13, n: 14, o: 15, p: 16)
            XCTAssertEqual(matrix.array(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        }
        do {
            let matrix = Matrix4x4(repeating: 128)
            XCTAssertEqual(matrix.array(), Array(repeating: 128, count: 16))
        }
        do {
            let matrix = Matrix4x4([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
            XCTAssertEqual(matrix.array(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        }
        do {
            let matrix = Matrix4x4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
            XCTAssertEqual(matrix.array(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
        }
    }

    func testIdentity() {
        let identity = Matrix4x4(a: 1, b: 0, c: 0, d: 0,
                                        e: 0, f: 1, g: 0, h: 0,
                                        i: 0, j: 0, k: 1, l: 0,
                                        m: 0, n: 0, o: 0, p: 1)
        XCTAssertEqual(identity, .identity)
    }

    func testBecomeIdentity() {
        var mtx = Matrix4x4(repeating: 100)
        mtx.becomeIdentity()
        XCTAssertEqual(mtx, .identity)
    }

    func testInverse() {
        let mtx = Matrix4x4(position: Position3(1, 2, 3))
        let expected = Matrix4x4(a: 1.0, b: 0.0, c: 0.0, d: -1.0,
                                        e: 0.0, f: 1.0, g: 0.0, h: -2.0,
                                        i: 0.0, j: 0.0, k: 1.0, l: -3.0,
                                        m: 0.0, n: 0.0, o: 0.0, p: 1.0)
        XCTAssertEqual(mtx.inverse, expected)
    }

    func testSubscript() {
        do {
            var matrix = Matrix4x4(repeating: 0)
            matrix[0] = 1
            XCTAssertEqual(matrix[0], 1)
            matrix[1] = 2
            XCTAssertEqual(matrix[1], 2)
            matrix[2] = 3
            XCTAssertEqual(matrix[2], 3)
            matrix[3] = 4
            XCTAssertEqual(matrix[3], 4)
            matrix[4] = 5
            XCTAssertEqual(matrix[4], 5)
            matrix[5] = 6
            XCTAssertEqual(matrix[5], 6)
            matrix[6] = 7
            XCTAssertEqual(matrix[6], 7)
            matrix[7] = 8
            XCTAssertEqual(matrix[7], 8)
            matrix[8] = 9
            XCTAssertEqual(matrix[8], 9)
            matrix[9] = 10
            XCTAssertEqual(matrix[9], 10)
            matrix[10] = 11
            XCTAssertEqual(matrix[10], 11)
            matrix[11] = 12
            XCTAssertEqual(matrix[11], 12)
            matrix[12] = 13
            XCTAssertEqual(matrix[12], 13)
            matrix[13] = 14
            XCTAssertEqual(matrix[13], 14)
            matrix[14] = 15
            XCTAssertEqual(matrix[14], 15)
            matrix[15] = 16
            XCTAssertEqual(matrix[15], 16)
        }
        do {
            var matrix = Matrix4x4(repeating: 0)
            matrix[0] = [1, 2, 3, 4]
            XCTAssertEqual(matrix[0], [1, 2, 3, 4])
            matrix[1] = [5, 6, 7, 8]
            XCTAssertEqual(matrix[1], [5, 6, 7, 8])
            matrix[2] = [9, 10, 11, 12]
            XCTAssertEqual(matrix[2], [9, 10, 11, 12])
            matrix[3] = [13, 14, 15, 16]
            XCTAssertEqual(matrix[3], [13, 14, 15, 16])
        }
    }

    func testTransform() {
        var matrix = Matrix4x4(position: Position3(1, 2, 3))
        XCTAssertEqual(matrix.transform.position, Position3(1, 2, 3))
        matrix.position = Position3(3,2,1)
        XCTAssertEqual(matrix.position, Position3(3, 2, 1))
    }

    func testQuaternion() {
        let quat1 = Quaternion(90°, axis: .right)
        let quat2 = Matrix4x4(rotation: quat1).rotation
        let angle1 = quat1.forward.angle(to: .right).rawValue
        let angle2 = quat2.forward.angle(to: .right).rawValue
        XCTAssertEqual(angle1, angle2, accuracy: 0.0025)
    }

    #if false
    func testMultiplicationPerformance() {
        let m1 = Transform3(position: Position3(128, 128, 128),
                                   rotation: Quaternion(128°, axis: .up),
                                   scale: .one).createMatrix()
        let m2 = Transform3(position: Position3(0, 1, 2),
                                   rotation: Quaternion(90°, axis: .up),
                                   scale: Size3(-100, -15, -1)).createMatrix()
        let m3 = Transform3(position: Position3(-128, -128, -128),
                                   rotation: Quaternion(-65°, axis: .up),
                                   scale: Size3(100, 15, 1)).createMatrix()

        func doMath() {
            var mtx: Matrix4x4 = .identity
            mtx *= m1 * m2 * m3
            mtx *= m1 * m2 * m3
            mtx *= m1 * m2 * m3
            mtx *= m1 * m2 * m3
            func more() -> Matrix4x4 {
                return m1 * m2 * m3
            }
            for _ in 1 ..< 5000 {
                mtx *= more()
                mtx *= more()
            }
            for _ in 1 ..< 10000 {
                mtx *= more()
            }
        }
        measure {
            doMath()
        }
    }
    #endif
}
