import XCTest

@testable import GameMath

final class Matrix3x3Tests: XCTestCase {
    func testInit() {
        do {
            let matrix = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9)
            XCTAssertEqual(matrix.a, 1)
            XCTAssertEqual(matrix.b, 2)
            XCTAssertEqual(matrix.c, 3)
            XCTAssertEqual(matrix.e, 4)
            XCTAssertEqual(matrix.f, 5)
            XCTAssertEqual(matrix.g, 6)
            XCTAssertEqual(matrix.i, 7)
            XCTAssertEqual(matrix.j, 8)
            XCTAssertEqual(matrix.k, 9)
        }
        do {
            let matrix = Matrix3x3(a: 1, b: 2, c: 3, e: 4, f: 5, g: 6, i: 7, j: 8, k: 9)
            XCTAssertEqual(matrix.a, 1)
            XCTAssertEqual(matrix.b, 2)
            XCTAssertEqual(matrix.c, 3)
            XCTAssertEqual(matrix.e, 4)
            XCTAssertEqual(matrix.f, 5)
            XCTAssertEqual(matrix.g, 6)
            XCTAssertEqual(matrix.i, 7)
            XCTAssertEqual(matrix.j, 8)
            XCTAssertEqual(matrix.k, 9)
        }
        do {
            let matrix = Matrix3x3()
            XCTAssertEqual(matrix, Matrix3x3(0, 0, 0, 0, 0, 0, 0, 0, 0))
        }
        do {
            let matrix = Matrix3x3(Matrix4x4(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16))
            XCTAssertEqual(matrix, Matrix3x3(1, 2, 3, 5, 6, 7, 9, 10, 11))
        }
    }

    func testSubscript() {
        do {
            var matrix = Matrix3x3()
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
        }
        do {
            var matrix = Matrix3x3()
            matrix[0] = [1, 2, 3]
            XCTAssertEqual(matrix[0], [1, 2, 3])
            matrix[1] = [4, 5, 6]
            XCTAssertEqual(matrix[1], [4, 5, 6])
            matrix[2] = [7, 8, 9]
            XCTAssertEqual(matrix[2], [7, 8, 9])
        }
    }

    func testInitDirectionUpRight() {
        do {
            let matrix = Matrix3x3(direction: .left, up: .up, right: .right)
            let direction: Direction3 = .left
            let expression1 = direction * matrix
            let expression2 = Direction3.forward
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
        do {
            let matrix = Matrix3x3(direction: .up, up: .up, right: .right)
            let direction: Direction3 = .up
            let expression1 = direction * matrix
            let expression2 = Direction3.forward
            XCTAssertEqual(expression1.x, expression2.x, accuracy: .accuracy)
            XCTAssertEqual(expression1.y, expression2.y, accuracy: .accuracy)
            XCTAssertEqual(expression1.z, expression2.z, accuracy: .accuracy)
        }
    }

    func testRotation() {
        var matrix = Matrix3x3()
        matrix.rotation = Quaternion(720°, axis: .right)
        let nr = matrix.rotation
        XCTAssertEqual(nr.x, Quaternion.zero.x, accuracy: .accuracy)
        XCTAssertEqual(nr.y, Quaternion.zero.y, accuracy: .accuracy)
        XCTAssertEqual(nr.z, Quaternion.zero.z, accuracy: .accuracy)
        XCTAssertEqual(nr.w, Quaternion.zero.w, accuracy: .accuracy)
        XCTAssertEqual(nr.magnitude, 1)
    }

    func testTransposedArray() {
        let matrix = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9)
        XCTAssertEqual(matrix.transposedArray(), [1.0, 4.0, 7.0, 2.0, 5.0, 8.0, 3.0, 6.0, 9.0])
    }

    func testArray() {
        let matrix = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9)
        XCTAssertEqual(matrix.array(), [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0])
    }

    func testCodableJSON() {
        let matrix = Matrix3x3(1, 2, 3, 4, 5, 6, 7, 8, 9)
        do {
            let data = try JSONEncoder().encode(matrix)
            let val = try JSONDecoder().decode(Matrix3x3.self, from: data)
            XCTAssertEqual(matrix, val)

        } catch {
            XCTFail()
        }
    }
}
