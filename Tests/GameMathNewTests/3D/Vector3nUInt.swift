import XCTest

@testable import GameMath

fileprivate typealias Scalar = UInt

fileprivate struct Imposter3: Vector3n, Equatable {
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

final class Vector3nUIntTests: XCTestCase {
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
        let x: Scalar = .random(in: 0 ... 15)
        let y: Scalar = .random(in: 0 ... 15)
        let z: Scalar = .random(in: 0 ... 15)
        
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
        let x: Scalar = .random(in: 120 ... 250)
        let y: Scalar = .random(in: 120 ... 250)
        let z: Scalar = .random(in: 120 ... 250)
        
        let larger: Scalar = .random(in: 251 ... .max)
        let smaller: Scalar = .random(in: .min ..< 120)
        
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
            let result = lhs - smaller
            XCTAssertEqual(result.x, x - smaller)
            XCTAssertEqual(result.y, y - smaller)
            XCTAssertEqual(result.z, z - smaller)
        }
        do {// Self -= Self.Scalar
            var lhs = Imposter3(x: x, y: y, z: z)
            lhs -= smaller
            XCTAssertEqual(lhs.x, x - smaller)
            XCTAssertEqual(lhs.y, y - smaller)
            XCTAssertEqual(lhs.z, z - smaller)
        }
        do {// Self.Scalar - Self
            let vec = Imposter3(x: x, y: y, z: z)
            let result = larger - vec
            XCTAssertEqual(result.x, larger - x)
            XCTAssertEqual(result.y, larger - y)
            XCTAssertEqual(result.z, larger - z)
        }
    }
    
    func testMul() {
        let x: Scalar = .random(in: 0 ... 15)
        let y: Scalar = .random(in: 0 ... 15)
        let z: Scalar = .random(in: 0 ... 15)
        
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
        while x == 0 {x = .random(in: 0 ... 15)}
        var y: Scalar = 0
        while y == 0 {y = .random(in: 0 ... 15)}
        var z: Scalar = 0
        while z == 0 {z = .random(in: 0 ... 15)}
        
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
        while x == 0 {x = .random(in: 0 ... 15)}
        var y: Scalar = 0
        while y == 0 {y = .random(in: 0 ... 15)}
        var z: Scalar = 0
        while z == 0 {z = .random(in: 0 ... 15)}
        
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
        let lhs = Imposter3(x: .random(in: 0 ... 15), y: .random(in: 0 ... 15), z: .random(in: 0 ... 15))
        let rhs = Imposter3(x: .random(in: 0 ... 15), y: .random(in: 0 ... 15), z: .random(in: 0 ... 15))
        let result = lhs.dot(rhs)
        XCTAssertEqual(result, (lhs.x * rhs.x) + (lhs.y * rhs.y) + (lhs.z * rhs.z))
    }
    
    func testCross() {
        // An unsigned cross product would either be zero or raise an exception
    }
    
    func testNormalize() {
        // Only FloatingPoint can be normalized
    }
}
