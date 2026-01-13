import XCTest

@testable import GameMath

fileprivate typealias Scalar = Float32

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

final class Vector3nFloat32Tests: XCTestCase {
    func testInit() {
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let vec = Imposter3(x: x, y: y, z: z)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }
    
    func testCastFromPosition3n() {
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let vecToCast = Position3n(x: x, y: y, z: z)
        let vec = Imposter3(vecToCast)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }
    
    func testCastFromDirection3n() {
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let vecToCast = Direction3n(x: x, y: y, z: z)
        let vec = Imposter3(vecToCast)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }
    
    func testCastFromSize3n() {
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let vecToCast = Size3n(x: x, y: y, z: z)
        let vec = Imposter3(vecToCast)
        XCTAssertEqual(vec.x, x)
        XCTAssertEqual(vec.y, y)
        XCTAssertEqual(vec.z, z)
    }

    func testAdd() {
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        
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
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        
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
        let x: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let y: Scalar = .random(in: -12345.56789 ... 12345.56789)
        let z: Scalar = .random(in: -12345.56789 ... 12345.56789)
        
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
        while x == 0 {x = .random(in: -12345.56789 ... 12345.56789)}
        var y: Scalar = 0
        while y == 0 {y = .random(in: -12345.56789 ... 12345.56789)}
        var z: Scalar = 0
        while z == 0 {z = .random(in: -12345.56789 ... 12345.56789)}
        
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
        while x == 0 {x = .random(in: -12345.56789 ... 12345.56789)}
        var y: Scalar = 0
        while y == 0 {y = .random(in: -12345.56789 ... 12345.56789)}
        var z: Scalar = 0
        while z == 0 {z = .random(in: -12345.56789 ... 12345.56789)}
        
        do {// Self % Self
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs.truncatingRemainder(dividingBy: lhs)
            XCTAssertEqual(result.x, x.truncatingRemainder(dividingBy: x))
            XCTAssertEqual(result.y, y.truncatingRemainder(dividingBy: y))
            XCTAssertEqual(result.z, z.truncatingRemainder(dividingBy: z))
        }
        do {// Self % Self.Scalar
            let lhs = Imposter3(x: x, y: y, z: z)
            let result = lhs.truncatingRemainder(dividingBy: x)
            XCTAssertEqual(result.x, x.truncatingRemainder(dividingBy: x))
            XCTAssertEqual(result.y, y.truncatingRemainder(dividingBy: x))
            XCTAssertEqual(result.z, z.truncatingRemainder(dividingBy: x))
        }
    }
    
    func testDot() {
        let lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let rhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let result = lhs.dot(rhs)
        XCTAssertEqual(result, (lhs.x * rhs.x) + (lhs.y * rhs.y) + (lhs.z * rhs.z), accuracy: .accuracy)
    }
    
    func testCross() {
        let lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let rhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let result = lhs.cross(rhs)
        XCTAssertEqual(result.x, lhs.y * rhs.z - lhs.z * rhs.y, accuracy: .accuracy + 0.001)
        XCTAssertEqual(result.y, lhs.z * rhs.x - lhs.x * rhs.z, accuracy: .accuracy + 0.001)
        XCTAssertEqual(result.z, lhs.x * rhs.y - lhs.y * rhs.x, accuracy: .accuracy + 0.001)
    }
    
    func testLength() {
        let lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let result = lhs.length
        XCTAssertEqual(result, lhs.x + lhs.y + lhs.z, accuracy: .accuracy)
    }
    
    func testSquaredLength() {
        let lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let result = lhs.squaredLength
        XCTAssertEqual(result, lhs.x * lhs.x + lhs.y *  lhs.y + lhs.z * lhs.z, accuracy: .accuracy)
    }
    
    func testSquareRoot() {
        let lhs = Imposter3(x: .random(in: 0.56789 ... 12345.56789), y: .random(in: 0.56789 ... 12345.56789), z: .random(in: 0.56789 ... 12345.56789))
        let result = lhs.squareRoot()
        XCTAssertEqual(result.x, lhs.x.squareRoot(), accuracy: .accuracy)
        XCTAssertEqual(result.y, lhs.y.squareRoot(), accuracy: .accuracy)
        XCTAssertEqual(result.z, lhs.z.squareRoot(), accuracy: .accuracy)
    }
    
    func testMagnitude() {
        let lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
        let result = lhs.magnitude
        XCTAssertEqual(result, (lhs.x * lhs.x + lhs.y *  lhs.y + lhs.z * lhs.z).squareRoot())
    }
    
    func testNormalize() {
        do {
            var lhs: Imposter3 = .zero
            while lhs == .zero {
                // We cannot normalize zero, so make sure this test doesn't try
                lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
            }
            lhs.normalize()
            
            XCTAssertEqual(lhs.x, lhs.x * (1.0 / lhs.magnitude), accuracy: .accuracy)
            XCTAssertEqual(lhs.y, lhs.y * (1.0 / lhs.magnitude), accuracy: .accuracy)
            XCTAssertEqual(lhs.z, lhs.z * (1.0 / lhs.magnitude), accuracy: .accuracy)
        }
        
        do {
            var lhs: Imposter3 = .zero
            while lhs == .zero {
                // We cannot normalize zero, so make sure this test doesn't try
                lhs = Imposter3(x: .random(in: -12345.56789 ... 12345.56789), y: .random(in: -12345.56789 ... 12345.56789), z: .random(in: -12345.56789 ... 12345.56789))
            }
            let result = lhs.normalized
            
            XCTAssertEqual(result.x, lhs.x * (1.0 / lhs.magnitude), accuracy: .accuracy)
            XCTAssertEqual(result.y, lhs.y * (1.0 / lhs.magnitude), accuracy: .accuracy)
            XCTAssertEqual(result.z, lhs.z * (1.0 / lhs.magnitude), accuracy: .accuracy)
        }
    }
}
