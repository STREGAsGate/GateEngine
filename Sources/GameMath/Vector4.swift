/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
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
public protocol Vector4: SIMD, Equatable, ExpressibleByFloatLiteral where FloatLiteralType == Float, Scalar == Float, MaskStorage == SIMD4<Float>.MaskStorage, ArrayLiteralElement == Scalar {
    var x: Scalar {get set}
    var y: Scalar {get set}
    var z: Scalar {get set}
    var w: Scalar {get set}
    init(_ x: Scalar, _ y: Scalar, _ z: Scalar, _ w: Scalar)
    
    static var zero: Self {get}
}
#else
public protocol Vector4: Equatable, ExpressibleByFloatLiteral where FloatLiteralType == Float {
    var x: Float {get set}
    var y: Float {get set}
    var z: Float {get set}
    var w: Float {get set}
    init(_ x: Float, _ y: Float, _ z: Float, _ w: Float)
    
    static var zero: Self {get}
}
#endif

#if GameMathUseSIMD
public extension Vector4 {
    @_transparent
    var scalarCount: Int {return 4}
    
    @_transparent
    init(_ simd: SIMD3<Float>) {
        self.init(simd[0], simd[1], simd[2], simd[3])
    }
}
#endif
 
public extension Vector4 {
    @inlinable
    subscript (_ index: Array<Float>.Index) -> Float {
        @_transparent get {
            switch index {
            case 0: return x
            case 1: return y
            case 2: return z
            case 3: return w
            default:
                fatalError("Index \(index) out of range \(0..<4) for type \(type(of: self))")
            }
        }
        @_transparent set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            case 3: w = newValue
            default:
                fatalError("Index \(index) out of range \(0..<4) for type \(type(of: self))")
            }
        }
    }
}

public extension Vector4 {
    @_transparent
    init(_ value: Float) {
        self.init(value, value, value)
    }
    
    @_transparent
    init(_ values: [Float]) {
        assert(values.count == 4, "Values must have 4 elements. Use init(_: Float) to fill w,x,y,z with a single value.")
        self.init(values[0], values[1], values[2], values[3])
    }
    
    @_transparent
    init(_ values: Float...) {
        assert(values.count == 4, "Values must have 3 elements. Use init(_: Float) to fill w,x,y,z with a single value.")
        self.init(values[0], values[1], values[2], values[3])
    }
    
    init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

//Mark: Integer Casting
extension Vector4 {
    @_transparent
    public init<V: Vector4>(_ value: V) {
        self = Self(value.x, value.y, value.z, value.w)
    }
    @_transparent
    public init() {
        self.init(0, 0, 0, 0)
    }
}

extension Vector4 {
    @_transparent
    public var isFinite: Bool {
        return x.isFinite && y.isFinite && z.isFinite && w.isFinite
    }
}

public extension Vector4 {
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter x: The amount to add to `x`. To subtract use a negatie value.
     - returns: A new Self with the additions.
    */
    @_transparent
    func addingTo(w: Float) -> Self {
        return Self(x, y, z, self.w + w)
    }
    
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter x: The amount to add to `x`. To subtract use a negatie value.
     - returns: A new Self with the additions.
    */
    @_transparent
    func addingTo(x: Float) -> Self {
        return Self(self.x + x, y, z, w)
    }
    
    /**
     Returns a new instance with `y` incremented by `value`.
     - parameter y: The amount to add to `y`. To subtract use a negatie value.
     - returns: A new Self with the additions.
    */
    @_transparent
    func addingTo(y value: Float) -> Self {
        return Self(x, y + value, z, w)
    }
    
    /**
     Returns a new instance with `z` incremented by `value`.
     - parameter value: The amount to add to `z`. To subtract use a negatie value.
     - returns: A new Self with the additions.
    */
    @_transparent
    func addingTo(z value: Float) -> Self {
        return Self(x, y, z + value, w)
    }
    
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter x: The amount to add to `x`. To subtract use a negatie value.
     - parameter y: The amount to add to `y`. To subtract use a negatie value.
     - returns: A new Self with the additions.
    */
    @_transparent
    func addingTo(x: Float, y: Float) -> Self {
        return Self(self.x + x, self.y + y, z, w)
    }
    
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter x: The amount to add to `x`. To subtract use a negatie value.
     - parameter z: The amount to add to `z`. To subtract use a negatie value.
     - returns: A new Self with the additions.
    */
    @_transparent
    func addingTo(x: Float, z: Float) -> Self {
        return Self(self.x + x, y, self.z + z, w)
    }
}

extension Vector4 {
    @_transparent
    public func dot<V: Vector4>(_ vector: V) -> Float {
        #if GameMathUseSIMD && canImport(simd)
        return simd_dot(self.simd, vector.simd)
        #else
        return (x * vector.x) + (y * vector.y) + (z * vector.z) + (w * vector.w)
        #endif
    }
}

extension Vector4 {
    @_transparent
    public var length: Float {
        #if GameMathUseSIMD
        return self.sum()
        #else
        return x + y + z + w
        #endif
    }
    
    @_transparent
    public var squaredLength: Float {
        #if GameMathUseSIMD && canImport(simd)
        return simd_length_squared(self.simd)
        #else
        return x * x + y * y + z * z + w * w
        #endif
    }
    
    @_transparent
    public var magnitude: Float {
        return squaredLength.squareRoot()
    }

    #if !GameMathUseFastInverseSquareRoot
    @_transparent
    public var normalized: Self {
        var copy = self
        copy.normalize()
        return copy
    }
    
    @_transparent
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
    
    @_transparent
    public func squareRoot() -> Self {
        #if GameMathUseSIMD && canImport(Accelerate)
        if #available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 13, *) {
            let count = 4
            let values = [Float](unsafeUninitializedCapacity: count) { buffer, initializedCount in
                vForce.sqrt(self.valuesArray(), result: &buffer)
                initializedCount = count
            }
            return Self(values)
        }else{
            return Self(x.squareRoot(), y.squareRoot(), z.squareRoot(), w.squareRoot())
        }
        #else
            return Self(x.squareRoot(), y.squareRoot(), z.squareRoot(), w.squareRoot())
        #endif
    }
}

extension Vector4 {
    @_transparent
    public func interpolated<V: Vector4>(to: V, _ method: InterpolationMethod) -> Self {
        return Self(self.x.interpolated(to: to.x, method),
                    self.y.interpolated(to: to.x, method),
                    self.z.interpolated(to: to.x, method),
                    self.w.interpolated(to: to.x, method))
    }
    @_transparent
    public mutating func interpolate<V: Vector4>(to: V, _ method: InterpolationMethod) {
        self.x.interpolate(to: to.x, method)
        self.y.interpolate(to: to.y, method)
        self.z.interpolate(to: to.z, method)
        self.w.interpolate(to: to.w, method)
    }
}

public extension Vector4 {
    @_transparent
    var max: Float {
        #if GameMathUseSIMD
        return self.max()
        #else
        return Swift.max(x, Swift.max(y, Swift.max(z, w)))
        #endif
        
    }
    @_transparent
    var min: Float {
        #if GameMathUseSIMD
        return self.min()
        #else
        return Swift.min(x, Swift.min(y, Swift.min(z, w)))
        #endif
    }
}

//MARK: - SIMD
public extension Vector4 {
    @inlinable
    var simd: SIMD4<Float> {
        @_transparent get {
            return SIMD4<Float>(x, y, z, w)
        }
        @_transparent set {
            x = newValue[0]
            y = newValue[1]
            z = newValue[2]
            w = newValue[3]
        }
    }
}

//MARK: - Operations
@_transparent
public func ceil<V: Vector4>(_ v: V) -> V {
    return V.init(ceil(v.x), ceil(v.y), ceil(v.z), ceil(v.w))
}

@_transparent
public func floor<V: Vector4>(_ v: V) -> V {
    return V.init(floor(v.x), floor(v.y), floor(v.z), floor(v.w))
}

@_transparent
public func round<V: Vector4>(_ v: V) -> V {
    return V.init(round(v.x), round(v.y), round(v.z), round(v.w))
}

@_transparent
public func abs<V: Vector4>(_ v: V) -> V {
    return V.init(abs(v.x), abs(v.y), abs(v.z), abs(v.w))
}

@_transparent
public func min<V: Vector4>(_ lhs: V, _ rhs: V) -> V {
    return V.init(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z), min(lhs.w, rhs.w))
}

@_transparent
public func max<V: Vector4>(_ lhs: V, _ rhs: V) -> V {
    return V.init(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z), max(lhs.w, rhs.w))
}

//MARK: - Self Operators
extension Vector4 {
    // Multiplication
    @_transparent @_disfavoredOverload
    public static func *(lhs: Self, rhs: some Vector4) -> Self {
        var lhs = lhs
        lhs *= rhs
        return lhs
    }
    @_transparent @_disfavoredOverload
    public static func *=(lhs: inout Self, rhs: some Vector4) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] *= rhs[index]
        }
        #else
        lhs.x *= rhs.x
        lhs.y *= rhs.y
        lhs.z *= rhs.z
        lhs.w *= rhs.w
        #endif
    }
    
    // Addition
    @_transparent @_disfavoredOverload
    public static func +(lhs: Self, rhs: some Vector4) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    @_transparent @_disfavoredOverload
    public static func +=(lhs: inout Self, rhs: some Vector4) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] += rhs[index]
        }
        #else
        lhs.x += rhs.x
        lhs.y += rhs.y
        lhs.z += rhs.z
        lhs.w += rhs.w
        #endif
    }
    
    // Subtraction
    @_transparent @_disfavoredOverload
    public static func -(lhs: Self, rhs: some Vector4) -> Self {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }
    @_transparent @_disfavoredOverload
    public static func -=(lhs: inout Self, rhs: some Vector4) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] -= rhs[index]
        }
        #else
        lhs.x -= rhs.x
        lhs.y -= rhs.y
        lhs.z -= rhs.z
        lhs.w -= rhs.w
        #endif
    }
}
extension Vector4 {
    // Division
    @_transparent @_disfavoredOverload
    public static func /(lhs: Self, rhs: some Vector4) -> Self {
        var lhs = lhs
        lhs /= rhs
        return lhs
    }
    @_transparent @_disfavoredOverload
    public static func /=(lhs: inout Self, rhs: some Vector4) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] /= rhs[index]
        }
        #else
        lhs.x /= rhs.x
        lhs.y /= rhs.y
        lhs.z /= rhs.z
        lhs.w /= rhs.w
        #endif
    }
}

//MARK: - Float Operators
extension Vector4 {
    // Multiplication
    @_transparent
    public static func *(lhs: Self, rhs: Float) -> Self {
        var lhs = lhs
        lhs *= rhs
        return lhs
    }
    @_transparent
    public static func *=(lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] *= rhs
        }
        #else
        lhs.x *= rhs
        lhs.y *= rhs
        lhs.z *= rhs
        lhs.w *= rhs
        #endif
    }
    
    // Addition
    @_transparent
    public static func +(lhs: Self, rhs: Float) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    @_transparent
    public static func +=(lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] += rhs
        }
        #else
        lhs.x += rhs
        lhs.y += rhs
        lhs.z += rhs
        lhs.w += rhs
        #endif
    }
    
    // Subtraction
    @_transparent @_disfavoredOverload
    public static func -(lhs: Self, rhs: Float) -> Self {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }
    @_transparent @_disfavoredOverload
    public static func -=(lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] -= rhs
        }
        #else
        lhs.x -= rhs
        lhs.y -= rhs
        lhs.z -= rhs
        lhs.w -= rhs
        #endif
    }
}

extension Vector4 {
    // Division
    @_transparent @_disfavoredOverload
    public static func /(lhs: Self, rhs: Float) -> Self {
        var lhs = lhs
        lhs /= rhs
        return lhs
    }
    @_transparent @_disfavoredOverload
    public static func /=(lhs: inout Self, rhs: Float) {
        #if GameMathUseLoopVectorization
        for index in 0 ..< 4 {
            lhs[index] /= rhs
        }
        #else
        lhs.x /= rhs
        lhs.y /= rhs
        lhs.z /= rhs
        lhs.w /= rhs
        #endif
    }
}

extension Vector4 {
    @_transparent @_disfavoredOverload
    public static prefix func -(rhs: Self) -> Self {
        return Self(-rhs.x, -rhs.y, -rhs.z, -rhs.w)
    }

    @_transparent @_disfavoredOverload
    public static prefix func +(rhs: Self) -> Self {
        return Self(+rhs.x, +rhs.y, +rhs.z, +rhs.w)
    }
}

//MARK: Matrix4
public extension Vector4 {
    @_transparent @_disfavoredOverload
    static func *(lhs: Self, rhs: Matrix4x4) -> Self {
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
        
        #warning("Not multiplying W")
        var w: Float = 0
        
        return Self(x, y, z, w)
    }
    
    @_transparent @_disfavoredOverload
    static func *(lhs: Matrix4x4, rhs: Self) -> Self {
        
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
        
        #warning("Not multiplying W")
        var w: Float = 0
        
        return Self(x, y, z, w)
    }
    
    @_transparent @_disfavoredOverload
    static func *(lhs: Self, rhs: Matrix3x3) -> Self {
        var vector: Self = .zero
        
        for i in 0 ..< 4 {
            for j in 0 ..< 4 {
                vector[i] += lhs[j] * rhs[i][j]
            }
        }
        return vector
    }
}

extension Vector4 where Self: Codable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y, z, w])
    }

    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        self.init(values[0], values[1], values[2], values[3])
    }
}

extension Vector4 {
    @_transparent
    public func valuesArray() -> [Float] {return [x, y, z, w]}
}
