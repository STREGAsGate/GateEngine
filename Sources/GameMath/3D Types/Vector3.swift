/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
import simd
#endif

#if GameMathUseSIMD && canImport(Accelerate)
import Accelerate
#endif

#if GameMathUseSIMD
public protocol Vector3: SIMD, Equatable, Sendable, ExpressibleByFloatLiteral where FloatLiteralType == Float, Scalar == Float, MaskStorage == SIMD3<Float>.MaskStorage, ArrayLiteralElement == Scalar {
    var x: Scalar {get set}
    var y: Scalar {get set}
    var z: Scalar {get set}
    init(x: Scalar, y: Scalar, z: Scalar)
    
    static var zero: Self {get}
}
#else
public protocol Vector3: Equatable, Sendable, ExpressibleByFloatLiteral where FloatLiteralType == Float {
    var x: Float {get set}
    var y: Float {get set}
    var z: Float {get set}
    init(x: Float, y: Float, z: Float)
    
    static var zero: Self {get}
}
#endif

#if GameMathUseSIMD
public extension Vector3 {
    @inlinable
    var scalarCount: Int {return 3}
    
    @inlinable
    init(_ simd: SIMD3<Float>) {
        self.init(simd[0], simd[1], simd[2])
    }
}
#endif
 
public extension Vector3 {
    @inlinable
    subscript (_ index: Int) -> Float {
        get {
            switch index {
            case 0: return x
            case 1: return y
            case 2: return z
            default:
                fatalError("Index \(index) out of range \(0..<3) for type \(type(of: self))")
            }
        }
        set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default:
                fatalError("Index \(index) out of range \(0..<3) for type \(type(of: self))")
            }
        }
    }
}

public extension Vector3 {
    @inlinable
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
    
    @inlinable
    init(_ value: Float) {
        self.init(value, value, value)
    }
    
    @inlinable
    init(_ values: [Float]) {
        assert(values.count == 3, "Values must have 3 elements. Use init(_: Float) to fill x,y,z with a single value.")
        self.init(values[0], values[1], values[2])
    }
    
    // Alternative init for any collection, including subranges
    @_disfavoredOverload
    @inlinable
    init<C: RandomAccessCollection>(_ values: C) where C.Element == Float {
        assert(values.count == 3, "Values must have 3 elements. Use init(_: Float) to fill x,y,z with a single value.")
        let index0 = values.startIndex
        let index1 = values.index(after: index0)
        let index2 = values.index(after: index1)
        self.init(values[index0], values[index1], values[index2])
    }
    
    @_disfavoredOverload
    @inlinable
    init(_ values: Float...) {
        self.init(values)
    }
    
    @inlinable
    init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
    
    @inlinable
    init(xy: some Vector2, z: Float) {
        self.init(xy.x, xy.y, z)
    }
    @inlinable
    init(xz: some Vector2, y: Float) {
        self.init(xz.x, y, xz.y)
    }
    @inlinable
    init(x: Float, yz: some Vector2) {
        self.init(x, yz.x, yz.y)
    }
}

//Mark: Integer Casting
extension Vector3 {
    @inlinable
    public init<V: Vector3>(_ value: V) {
        self = Self(value.x, value.y, value.z)
    }
    @inlinable
    public init() {
        self.init(0, 0, 0)
    }
}

extension Vector3 {
    @inlinable
    public var isFinite: Bool {
        return x.isFinite && y.isFinite && z.isFinite
    }
}

public extension Vector3 {
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter value: The amount to add to `x`. To subtract use a negative value.
     - returns: A new Self with `x` incremented by `value`.
    */
    @inlinable
    func addingTo(x: Float) -> Self {
        return Self(self.x + x, y, z)
    }
    
    /**
     Returns a new instance with `y` incremented by `value`.
     - parameter value: The amount to add to `y`. To subtract use a negative value.
     - returns: A new Self with `y` incremented by `value`.
    */
    @inlinable
    func addingTo(y value: Float) -> Self {
        return Self(x, y + value, z)
    }
    
    /**
     Returns a new instance with `z` incremented by `value`.
     - parameter value: The amount to add to `z`. To subtract use a negative value.
     - returns: A new Self with `z` incremented by `value`.
    */
    @inlinable
    func addingTo(z value: Float) -> Self {
        return Self(x, y, z + value)
    }
    
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter x: The amount to add to `x`. To subtract use a negative value.
     - parameter y: The amount to add to `y`. To subtract use a negative value.
     - returns: A new Self with the additions.
    */
    @inlinable
    func addingTo(x: Float, y: Float) -> Self {
        return Self(self.x + x, self.y + y, z)
    }
    
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter x: The amount to add to `x`. To subtract use a negative value.
     - parameter z: The amount to add to `z`. To subtract use a negative value.
     - returns: A new Self with the additions.
    */
    @inlinable
    func addingTo(x: Float, z: Float) -> Self {
        return Self(self.x + x, y, self.z + z)
    }
}

extension Vector3 {
    @inlinable
    public func dot<V: Vector3>(_ vector: V) -> Float {
        #if GameMathUseSIMD && canImport(simd)
        return simd_dot(self.simd, vector.simd)
        #else
        return (x * vector.x) + (y * vector.y) + (z * vector.z)
        #endif
    }
    
    @inlinable
    public func cross<V: Vector3>(_ vector: V) -> Self {
        #if GameMathUseSIMD && canImport(simd)
        return Self(simd_cross(self.simd, vector.simd))
        #else
        return Self(y * vector.z - z * vector.y,
                    z * vector.x - x * vector.z,
                    x * vector.y - y * vector.x)
        #endif
       
    }
}

extension Vector3 {
    @inlinable
    public var length: Float {
        #if GameMathUseSIMD
        return self.sum()
        #else
        return x + y + z
        #endif
    }
    
    @inlinable
    public var squaredLength: Float {
        #if GameMathUseSIMD && canImport(simd)
        return simd_length_squared(self.simd)
        #else
        return x * x + y * y + z * z
        #endif
    }
    
    @inlinable
    public var magnitude: Float {
        return squaredLength.squareRoot()
    }

    #if !GameMathUseFastInverseSquareRoot
    @inlinable
    public var normalized: Self {
        var copy = self
        copy.normalize()
        return copy
    }
    
    @inlinable
    public mutating func normalize() {
        if self != Self.zero {
            #if GameMathUseSIMD && canImport(simd)
            self.simd = simd_fast_normalize(self.simd)
            #else
            let magnitude = self.magnitude
            let factor = 1 / magnitude
            self *= factor
            #endif
        }
    }
    #endif
    
    @inlinable
    public func squareRoot() -> Self {
        #if GameMathUseSIMD && canImport(Accelerate)
        if #available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 13, *) {
            let count = 3
            let values = [Float](unsafeUninitializedCapacity: count) { buffer, initializedCount in
                vForce.sqrt(self.valuesArray(), result: &buffer)
                initializedCount = count
            }
            return Self(values)
        }else{
            return Self(x.squareRoot(), y.squareRoot(), z.squareRoot())
        }
        #else
            return Self(x.squareRoot(), y.squareRoot(), z.squareRoot())
        #endif
    }
}

extension Vector3 {
    @inlinable
    public func interpolated<V: Vector3>(to: V, _ method: InterpolationMethod) -> Self {
        var copy = self
        copy.x.interpolate(to: to.x, method)
        copy.y.interpolate(to: to.y, method)
        copy.z.interpolate(to: to.z, method)
        return copy
    }
    @inlinable
    public mutating func interpolate<V: Vector3>(to: V, _ method: InterpolationMethod) {
        self.x.interpolate(to: to.x, method)
        self.y.interpolate(to: to.y, method)
        self.z.interpolate(to: to.z, method)
    }
}

public extension Vector3 {
    @inlinable
    var max: Float {
        #if GameMathUseSIMD
        return self.max()
        #else
        return Swift.max(x, Swift.max(y, z))
        #endif
        
    }
    @inlinable
    var min: Float {
        #if GameMathUseSIMD
        return self.min()
        #else
        return Swift.min(x, Swift.min(y, z))
        #endif
    }
}

//MARK: - SIMD
public extension Vector3 {
    @inlinable
    var simd: SIMD3<Float> {
        get {
            return SIMD3<Float>(x, y, z)
        }
        set {
            x = newValue[0]
            y = newValue[1]
            z = newValue[2]
        }
    }
}

//MARK: - Operations
@inlinable
public func ceil<V: Vector3>(_ v: V) -> V {
    return V.init(ceil(v.x), ceil(v.y), ceil(v.z))
}

@inlinable
public func floor<V: Vector3>(_ v: V) -> V {
    return V.init(floor(v.x), floor(v.y), floor(v.z))
}

@inlinable
public func round<V: Vector3>(_ v: V) -> V {
    return V.init(round(v.x), round(v.y), round(v.z))
}

@inlinable
public func abs<V: Vector3>(_ v: V) -> V {
    return V.init(abs(v.x), abs(v.y), abs(v.z))
}

@inlinable
public func min<V: Vector3>(_ lhs: V, _ rhs: V) -> V {
    return V.init(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z))
}

@inlinable
public func max<V: Vector3>(_ lhs: V, _ rhs: V) -> V {
    return V.init(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z))
}

// MARK: - Self Operators
// _disfavoredOverload so a conforming types own implementation takes precedence
public extension Vector3 {
    // Addition
    @_disfavoredOverload
    @inlinable
    static func + (lhs: Self, rhs: some Vector3) -> Self {
        return Self(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    @_disfavoredOverload
    @inlinable
    static func += (lhs: inout Self, rhs: some Vector3) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] += rhs[index]
        }
        #else
        lhs.x += rhs.x
        lhs.y += rhs.y
        lhs.z += rhs.z
        #endif
    }
    
    // Subtraction
    @_disfavoredOverload
    @inlinable
    static func - (lhs: Self, rhs: some Vector3) -> Self {
        return Self(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    @_disfavoredOverload
    @inlinable
    static func -= (lhs: inout Self, rhs: some Vector3) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] -= rhs[index]
        }
        #else
        lhs.x -= rhs.x
        lhs.y -= rhs.y
        lhs.z -= rhs.z
        #endif
    }
    
    // Multiplication
    @_disfavoredOverload
    @inlinable
    static func * (lhs: Self, rhs: some Vector3) -> Self {
        return Self(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
    }
    @_disfavoredOverload
    @inlinable
    static func *= (lhs: inout Self, rhs: some Vector3) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] *= rhs[index]
        }
        #else
        lhs.x *= rhs.x
        lhs.y *= rhs.y
        lhs.z *= rhs.z
        #endif
    }
}
extension Vector3 {
    // Division
    @_disfavoredOverload
    @inlinable
    public static func / (lhs: Self, rhs: some Vector3) -> Self {
        return Self(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z)
    }
    @_disfavoredOverload
    @inlinable
    public static func /= (lhs: inout Self, rhs: some Vector3) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] /= rhs[index]
        }
        #else
        lhs.x /= rhs.x
        lhs.y /= rhs.y
        lhs.z /= rhs.z
        #endif
    }
}

//MARK: - Float Operators
extension Vector3 {
    // Addition
    @inlinable
    public static func + (lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x + rhs, lhs.y + rhs, lhs.z + rhs)
    }
    @inlinable
    public static func += (lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] += rhs
        }
        #else
        lhs.x += rhs
        lhs.y += rhs
        lhs.z += rhs
        #endif
    }
    
    // Subtraction
    @_disfavoredOverload
    @inlinable
    public static func - (lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x - rhs, lhs.y - rhs, lhs.z - rhs)
    }
    @_disfavoredOverload
    @inlinable
    public static func -= (lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] -= rhs
        }
        #else
        lhs.x -= rhs
        lhs.y -= rhs
        lhs.z -= rhs
        #endif
    }
    
    // Multiplication
    @inlinable
    public static func * (lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    @inlinable
    public static func *= (lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] *= rhs
        }
        #else
        lhs.x *= rhs
        lhs.y *= rhs
        lhs.z *= rhs
        #endif
    }
}

extension Vector3 {
    // Division
    @_disfavoredOverload
    @inlinable
    public static func / (lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    @_disfavoredOverload
    @inlinable
    public static func /= (lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 3 {
            lhs[index] /= rhs
        }
        #else
        lhs.x /= rhs
        lhs.y /= rhs
        lhs.z /= rhs
        #endif
    }
}

extension Vector3 {
    @_disfavoredOverload
    @inlinable
    public static prefix func - (rhs: Self) -> Self {
        return Self(-rhs.x, -rhs.y, -rhs.z)
    }

    @_disfavoredOverload
    @inlinable
    public static prefix func + (rhs: Self) -> Self {
        return Self(+rhs.x, +rhs.y, +rhs.z)
    }
}

//MARK: Matrix4
public extension Vector3 {
    @_disfavoredOverload
    @inlinable
    static func * (lhs: Self, rhs: Matrix4x4) -> Self {
        var x: Float = lhs.x * rhs.a
        x += lhs.y * rhs.b
        x += lhs.z * rhs.c
        x += rhs.d
        
        var y: Float = lhs.x * rhs.e
        y += lhs.y * rhs.f
        y += lhs.z * rhs.g
        y += rhs.h
        
        var z: Float = lhs.x * rhs.i
        z += lhs.y * rhs.j
        z += lhs.z * rhs.k
        z += rhs.l
        
        return Self(x, y, z)
    }
    
    @_disfavoredOverload
    @inlinable
    static func * (lhs: Matrix4x4, rhs: Self) -> Self {
        var x: Float = rhs.x * lhs.a
        x += rhs.y * lhs.e
        x += rhs.z * lhs.i
        x += lhs.m
        
        var y: Float = rhs.x * lhs.b
        y += rhs.y * lhs.f
        y += rhs.z * lhs.j
        y += lhs.n
        
        var z: Float = rhs.x * lhs.c
        z += rhs.y * lhs.g
        z += rhs.z * lhs.k
        z += lhs.o
        
        return Self(x, y, z)
    }
    
    @_disfavoredOverload
    @inlinable
    static func * (lhs: Self, rhs: Matrix3x3) -> Self {
        var vector: Self = .zero
        
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                vector[i] += lhs[j] * rhs[i][j]
            }
        }
        return vector
    }
}

extension Vector3 where Self: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y, z])
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        self.init(values[0], values[1], values[2])
    }
}

extension Vector3 {
    @inlinable
    public func valuesArray() -> [Float] {return [x, y, z]}
}

extension Array where Element: Vector3 {
    @inlinable
    public func valuesArray() -> [Float] {
        var values: [Float] = []
        values.reserveCapacity(self.count * 3)
        for value: some Vector3 in self {
            values.append(value.x)
            values.append(value.y)
            values.append(value.z)
        }
        return values
    }
}
