import XCTest

@testable import GameMath

fileprivate typealias Scalar = Int16

fileprivate struct Imposter3: Vector3n {
    var x: Scalar
    var y: Scalar
    var z: Scalar
    let w: Scalar
    
    init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
        self.w = 0
    }
}

final class Vector3nInt16Tests: XCTestCase {
    func testInit() {
        let x: Scalar = .random(in: .min ... .max)
        let y: Scalar = .random(in: .min ... .max)
        let z: Scalar = .random(in: .min ... .max)
        let vec = Imposter3(x: x, y: y, z: z)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }
    
    func testCastFromPosition3n() {
        let x: Scalar = .random(in: .min ... .max)
        let y: Scalar = .random(in: .min ... .max)
        let z: Scalar = .random(in: .min ... .max)
        let vecToCast = Position3n(x: x, y: y, z: z)
        let vec = Imposter3(vecToCast)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }
    
    func testCastFromDirection3n() {
        let x: Scalar = .random(in: .min ... .max)
        let y: Scalar = .random(in: .min ... .max)
        let z: Scalar = .random(in: .min ... .max)
        let vecToCast = Direction3n(x: x, y: y, z: z)
        let vec = Imposter3(vecToCast)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }
    
    func testCastFromSize3n() {
        let x: Scalar = .random(in: .min ... .max)
        let y: Scalar = .random(in: .min ... .max)
        let z: Scalar = .random(in: .min ... .max)
        let vecToCast = Size3n(x: x, y: y, z: z)
        let vec = Imposter3(vecToCast)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }

    func testAdd() {
        let x: Scalar = .random(in: -127 ... 127)
        let y: Scalar = .random(in: -127 ... 127)
        let z: Scalar = .random(in: -127 ... 127)
        
        do {// Self + Self
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs + lhs
            XCTAssertEqual(result.x, x + x)
            XCTAssertEqual(result.y, y + y)
            XCTAssertEqual(result.z, z + z)
        }
        do {// Self += Self
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs += lhs
            XCTAssertEqual(lhs.x, x + x)
            XCTAssertEqual(lhs.y, y + y)
            XCTAssertEqual(lhs.z, z + z)
        }
        do {// Self + Self.Scalar
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs + x
            XCTAssertEqual(result.x, x + x)
            XCTAssertEqual(result.y, y + x)
            XCTAssertEqual(result.z, z + x)
        }
        do {// Self += Self.Scalar
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs += y
            XCTAssertEqual(lhs.x, x + y)
            XCTAssertEqual(lhs.y, y + y)
            XCTAssertEqual(lhs.z, z + y)
        }
        do {// Self.Scalar + Self
            let vec = Imposter3(x: x, y: y, z: z)
            let result = z + vec
            XCTAssertEqual(result.x, z + x)
            XCTAssertEqual(result.y, z + y)
            XCTAssertEqual(result.z, z + z)
        }
    }
    
    func testSub() {
        let x: Scalar = .random(in: -127 ... 127)
        let y: Scalar = .random(in: -127 ... 127)
        let z: Scalar = .random(in: -127 ... 127)
        
        do {// Self - Self
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs - lhs
            XCTAssertEqual(result.x, x - x)
            XCTAssertEqual(result.y, y - y)
            XCTAssertEqual(result.z, z - z)
        }
        do {// Self -= Self
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs -= lhs
            XCTAssertEqual(lhs.x, x - x)
            XCTAssertEqual(lhs.y, y - y)
            XCTAssertEqual(lhs.z, z - z)
        }
        do {// Self - Self.Scalar
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs - x
            XCTAssertEqual(result.x, x - x)
            XCTAssertEqual(result.y, y - x)
            XCTAssertEqual(result.z, z - x)
        }
        do {// Self -= Self.Scalar
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs -= y
            XCTAssertEqual(lhs.x, x - y)
            XCTAssertEqual(lhs.y, y - y)
            XCTAssertEqual(lhs.z, z - y)
        }
        do {// Self.Scalar - Self
            let vec = Imposter3(x: x, y: y, z: z)
            let result = z - vec
            XCTAssertEqual(result.x, z - x)
            XCTAssertEqual(result.y, z - y)
            XCTAssertEqual(result.z, z - z)
        }
    }
    
    func testMul() {
        let x: Scalar = .random(in: -15 ... 15)
        let y: Scalar = .random(in: -15 ... 15)
        let z: Scalar = .random(in: -15 ... 15)
        
        do {// Self * Self
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs * lhs
            XCTAssertEqual(result.x, x * x)
            XCTAssertEqual(result.y, y * y)
            XCTAssertEqual(result.z, z * z)
        }
        do {// Self *= Self
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs *= lhs
            XCTAssertEqual(lhs.x, x * x)
            XCTAssertEqual(lhs.y, y * y)
            XCTAssertEqual(lhs.z, z * z)
        }
        do {// Self * Self.Scalar
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs * x
            XCTAssertEqual(result.x, x * x)
            XCTAssertEqual(result.y, y * x)
            XCTAssertEqual(result.z, z * x)
        }
        do {// Self *= Self.Scalar
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs *= y
            XCTAssertEqual(lhs.x, x * y)
            XCTAssertEqual(lhs.y, y * y)
            XCTAssertEqual(lhs.z, z * y)
        }
        do {// Self.Scalar * Self
            let vec = Imposter3(x: x, y: y, z: z)
            let result = z * vec
            XCTAssertEqual(result.x, z * x)
            XCTAssertEqual(result.y, z * y)
            XCTAssertEqual(result.z, z * z)
        }
    }
    
    
    func testDiv() {
        var x: Scalar = 0
        while x == 0 {x = .random(in: -127 ... 127)}
        var y: Scalar = 0
        while y == 0 {y = .random(in: -127 ... 127)}
        var z: Scalar = 0
        while z == 0 {z = .random(in: -127 ... 127)}
        
        do {// Self / Self
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs / lhs
            XCTAssertEqual(result.x, x / x)
            XCTAssertEqual(result.y, y / y)
            XCTAssertEqual(result.z, z / z)
        }
        do {// Self /= Self
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs /= lhs
            XCTAssertEqual(lhs.x, x / x)
            XCTAssertEqual(lhs.y, y / y)
            XCTAssertEqual(lhs.z, z / z)
        }
        do {// Self / Self.Scalar
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs / x
            XCTAssertEqual(result.x, x / x)
            XCTAssertEqual(result.y, y / x)
            XCTAssertEqual(result.z, z / x)
        }
        do {// Self /= Self.Scalar
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs /= y
            XCTAssertEqual(lhs.x, x / y)
            XCTAssertEqual(lhs.y, y / y)
            XCTAssertEqual(lhs.z, z / y)
        }
        do {// Self.Scalar / Self
            let vec = Imposter3(x: x, y: y, z: z)
            let result = z / vec
            XCTAssertEqual(result.x, z / x)
            XCTAssertEqual(result.y, z / y)
            XCTAssertEqual(result.z, z / z)
        }
    }
    
    func testRemainder() {
        var x: Scalar = 0
        while x == 0 {x = .random(in: -127 ... 127)}
        var y: Scalar = 0
        while y == 0 {y = .random(in: -127 ... 127)}
        var z: Scalar = 0
        while z == 0 {z = .random(in: -127 ... 127)}
        
        do {// Self % Self
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs % lhs
            XCTAssertEqual(result.x, x % x)
            XCTAssertEqual(result.y, y % y)
            XCTAssertEqual(result.z, z % z)
        }
        do {// Self %= Self
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs %= lhs
            XCTAssertEqual(lhs.x, x % x)
            XCTAssertEqual(lhs.y, y % y)
            XCTAssertEqual(lhs.z, z % z)
        }
        do {// Self % Self.Scalar
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs % x
            XCTAssertEqual(result.x, x % x)
            XCTAssertEqual(result.y, y % x)
            XCTAssertEqual(result.z, z % x)
        }
        do {// Self %= Self.Scalar
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs %= y
            XCTAssertEqual(lhs.x, x % y)
            XCTAssertEqual(lhs.y, y % y)
            XCTAssertEqual(lhs.z, z % y)
        }
        do {// Self.Scalar % Self
            let vec = Imposter3(x: x, y: y, z: z)
            let result = z % vec
            XCTAssertEqual(result.x, z % x)
            XCTAssertEqual(result.y, z % y)
            XCTAssertEqual(result.z, z % z)
        }
    }
    
    func testDot() {
        let lhs = Imposter3(x: .random(in: -15 ... 15), y: .random(in: -15 ... 15), z: .random(in: -15 ... 15))
        let rhs = Imposter3(x: .random(in: -15 ... 15), y: .random(in: -15 ... 15), z: .random(in: -15 ... 15))
        let result = lhs.dot(rhs)
        XCTAssertEqual(result, (lhs.x * rhs.x) + (lhs.y * rhs.y) + (lhs.z * rhs.z))
    }
    
    func testCross() {
        let lhs = Imposter3(x: .random(in: -15 ... 15), y: .random(in: -15 ... 15), z: .random(in: -15 ... 15))
        let rhs = Imposter3(x: .random(in: -15 ... 15), y: .random(in: -15 ... 15), z: .random(in: -15 ... 15))
        let result = lhs.cross(rhs)
        XCTAssertEqual(result.x, lhs.y * rhs.z - lhs.z * rhs.y)
        XCTAssertEqual(result.y, lhs.z * rhs.x - lhs.x * rhs.z)
        XCTAssertEqual(result.z, lhs.x * rhs.y - lhs.y * rhs.x)
    }
    
    func testNormalize() {
        // Only FloatingPoint can be normalized
    }
}
