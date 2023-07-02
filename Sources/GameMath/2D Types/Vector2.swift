/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public protocol Vector2: ExpressibleByFloatLiteral where FloatLiteralType == Float {
    var x: Float {get set}
    var y: Float {get set}
    init(_ x: Float, _ y: Float)
}

public extension Vector2 {
    @_transparent
    init(_ value: Float) {
        self.init(value, value)
    }
    
    @_transparent
    init(_ values: [Float]) {
        assert(values.count == 2, "values must have 2 elements. Use init(_: Float) to fill x,y with a single value.")
        self.init(values[0], values[1])
    }
    
    @_transparent
    init(_ values: Float...) {
        assert(values.count == 2, "values must have 2 elements. Use init(_: Float) to fill x,y with a single value.")
        self.init(values[0], values[1])
    }
    
    @_transparent
    init(floatLiteral float: Float) {
        self.init(float)
    }
}

extension Vector2 {
    @inlinable
    public init<V: Vector2>(_ value: V) {
        self = Self(value.x, value.y)
    }
    @_transparent
    public init() {
        self.init(0, 0)
    }
}

public extension Vector2 {
    @_transparent
    static var zero: Self {
        return Self(0)
    }
}

extension Vector2 {
    @_transparent
    public var isFinite: Bool {
        return x.isFinite && y.isFinite
    }
}

extension Vector2 {
    @inlinable
    public subscript (_ index: Array<Float>.Index) -> Float {
        @_transparent get {
            switch index {
            case 0: return x
            case 1: return y
            default:
                fatalError("Index \(index) out of range \(0 ..< 2) for type \(type(of: self)).")
            }
        }
        @_transparent set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            default:
                fatalError("Index \(index) out of range \(0 ..< 2) for type \(type(of: self)).")
            }
        }
    }
    
    @_transparent
    public func dot<V: Vector2>(_ vector: V) -> Float {
        return (x * vector.x) + (y * vector.y)
    }
    
    /// Returns the hypothetical Z axis
    @_transparent
    public func cross<V: Vector2>(_ vector: V) -> Float {
        return self.x * vector.y - vector.x * self.y
    }
}

extension Vector2 {
    @_transparent
    public var length: Float {
        return x + y
    }
    
    @_transparent
    public var squaredLength: Float {
        return x * x + y * y
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
        let magnitude = self.magnitude
        guard magnitude != 0 else {return}

        let factor = 1 / magnitude
        self.x *= factor
        self.y *= factor
    }
    #endif
    
    @_transparent
    public func squareRoot() -> Self {
        return Self(x.squareRoot(), y.squareRoot())
    }
}

extension Vector2 {
    @_transparent
    public func interpolated<V: Vector2>(to: V, _ method: InterpolationMethod) -> Self {
        var copy = self
        copy.x.interpolate(to: to.x, method)
        copy.y.interpolate(to: to.y, method)
        return copy
    }
    @_transparent
    public mutating func interpolate<V: Vector2>(to: V, _ method: InterpolationMethod) {
        self.x.interpolate(to: to.x, method)
        self.y.interpolate(to: to.y, method)
    }
}

public extension Vector2 {
    @_transparent
    var max: Float {
        return Swift.max(x, y)
    }
    @_transparent
    var min: Float {
        return Swift.min(x, y)
    }
}

//MARK: - SIMD
public extension Vector2 {
    @_transparent
    var simd: SIMD2<Float> {
        return SIMD2<Float>(x, y)
    }
}

//MARK: - Operations
@_transparent
public func ceil<V: Vector2>(_ v: V) -> V {
    return V.init(ceil(v.x), ceil(v.y))
}

@_transparent
public func floor<V: Vector2>(_ v: V) -> V {
    return V.init(floor(v.x), floor(v.y))
}

@_transparent
public func round<V: Vector2>(_ v: V) -> V {
    return V.init(round(v.x), round(v.y))
}

@_transparent
public func abs<V: Vector2>(_ v: V) -> V {
    return V.init(abs(v.x), abs(v.y))
}

@_transparent
public func min<V: Vector2>(_ lhs: V, _ rhs: V) -> V {
    return V.init(min(lhs.x, rhs.x), min(lhs.y, rhs.y))
}

@_transparent
public func max<V: Vector2>(_ lhs: V, _ rhs: V) -> V {
    return V.init(max(lhs.x, rhs.x), max(lhs.y, rhs.y))
}

//MARK: Operators (Self)
extension Vector2 {
    //Multiplication
    @_transparent @_disfavoredOverload
    public static func *(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x * rhs.x,
                    lhs.y * rhs.y)
    }
    @_transparent @_disfavoredOverload
    public static func *=(lhs: inout Self, rhs: some Vector2) {
        lhs.x *= rhs.x
        lhs.y *= rhs.y
    }
    
    //Addition
    @_transparent @_disfavoredOverload
    public static func +(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x + rhs.x,
                    lhs.y + rhs.y)
    }
    @_transparent @_disfavoredOverload
    public static func +=(lhs: inout Self, rhs: some Vector2) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    //Subtraction
    @_transparent @_disfavoredOverload
    public static func -(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x - rhs.x,
                    lhs.y - rhs.y)
    }
    @_transparent @_disfavoredOverload
    public static func -=(lhs: inout Self, rhs: some Vector2) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
}
extension Vector2 {
    //Division
    @_transparent @_disfavoredOverload
    public static func /(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x / rhs.x,
                    lhs.y / rhs.y)
    }
    @_transparent @_disfavoredOverload
    public static func /=(lhs: inout Self, rhs: some Vector2) {
        lhs.x /= rhs.x
        lhs.y /= rhs.y
    }
}

//MARK: Operators (Integers and Floats)
extension Vector2 {
    //Multiplication Without Casting
    @_transparent
    public static func *(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x * rhs,
                    lhs.y * rhs)
    }
    @_transparent
    public static func *=(lhs: inout Self, rhs: Float) {
        lhs.x *= rhs
        lhs.y *= rhs
    }
    
    //Addition Without Casting
    @_transparent
    public static func +(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x + rhs,
                    lhs.y + rhs)
    }
    @_transparent
    public static func +=(lhs: inout Self, rhs: Float) {
        lhs.x += rhs
        lhs.y += rhs
    }
    
    //Subtraction Without Casting
    @_transparent
    public static func -(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x - rhs,
                    lhs.y - rhs)
    }
    @_transparent
    public static func -=(lhs: inout Self, rhs: Float) {
        lhs.x -= rhs
        lhs.y -= rhs
    }
    
    @_transparent
    public static func -(lhs: Float, rhs: Self) -> Self {
        return Self(lhs - rhs.x,
                    lhs - rhs.y)
    }
    
    @_transparent
    public static func -=(lhs: Float, rhs: inout Self) {
        rhs.x = lhs - rhs.x
        rhs.y = lhs - rhs.y
    }
}

extension Vector2 {
    //Division Without Casting
    @_transparent
    public static func /(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x / rhs,
                    lhs.y / rhs)
    }
    @_transparent
    public static func /=(lhs: inout Self, rhs: Float) {
        lhs.x /= rhs
        lhs.y /= rhs
    }
    
    @_transparent
    public static func /(lhs: Float, rhs: Self) -> Self {
        return Self(lhs / rhs.x,
                    lhs / rhs.y)
    }
    @_transparent
    public static func /=(lhs: Float, rhs: inout Self) {
        rhs.x = lhs / rhs.x
        rhs.y = lhs / rhs.y
    }
}

//MARK: Matrix4
public extension Vector2 {
    @_transparent
    static func *(lhs: Self, rhs: Matrix4x4) -> Self {
        var x: Float = lhs.x * rhs.a
        x += lhs.y * rhs.b
        x += rhs.d
        
        var y: Float = lhs.x * rhs.e
        y += lhs.y * rhs.f
        y += rhs.h
        
        return Self(x, y)
    }
    
    @_transparent
    static func *(lhs: Matrix4x4, rhs: Self) -> Self {
        var x: Float = rhs.x * lhs.a
        x += rhs.y * lhs.e
        x += lhs.m
        
        var y: Float = rhs.x * lhs.b
        y += rhs.y * lhs.f
        y += lhs.n
        
        return Self(x, y)
    }
    
    @_transparent
    static func *(lhs: Self, rhs: Matrix3x3) -> Self {
        var vector: Self = .zero
        
        for i in 0 ..< 2 {
            for j in 0 ..< 2 {
                vector[i] += lhs[j] * rhs[i][j]
            }
        }
        return vector
    }
}

extension Vector2 {
    @_transparent
    public static prefix func -(rhs: Self) -> Self {
        return Self(-rhs.x, -rhs.y)
    }

    @_transparent
    public static prefix func +(rhs: Self) -> Self {
        return Self(+rhs.x, +rhs.y)
    }
}

extension Vector2 {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y])
    }
    
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        self.init(values[0], values[1])
    }
}

extension Vector2 {
    @_transparent
    public func valuesArray() -> [Float] {return [x, y]}
}
