/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Vector2: Sendable, ExpressibleByFloatLiteral where FloatLiteralType == Float {
    var x: Float {get set}
    var y: Float {get set}
    init(x: Float, y: Float)
}

public extension Vector2 {
    @inlinable
    init(_ x: Float, _ y: Float) {
        self.init(x: x, y: y)
    }
    
    @inlinable
    init(_ value: Float) {
        self.init(value, value)
    }
    
    @inlinable
    init(_ values: [Float]) {
        assert(values.count == 2, "values must have 2 elements. Use init(_: Float) to fill x,y with a single value.")
        self.init(values[0], values[1])
    }
    
    // Alternative init for any collection, including subranges
    @_disfavoredOverload
    @inlinable
    init<C: RandomAccessCollection>(_ values: C) where C.Element == Float {
        assert(values.count == 2, "Values must have 2 elements. Use init(_: Float) to fill x,y,z with a single value.")
        let index0 = values.startIndex
        let index1 = values.index(after: index0)
        self.init(values[index0], values[index1])
    }
    
    @_disfavoredOverload
    @inlinable
    init(_ values: Float...) {
        self.init(values)
    }
    
    @inlinable
    init(floatLiteral float: Float) {
        self.init(float)
    }
}

extension Vector2 {
    @inlinable
    public init<V: Vector2>(_ value: V) {
        self = Self(value.x, value.y)
    }
    @inlinable
    public init() {
        self.init(0, 0)
    }
}

public extension Vector2 {
    @inlinable
    static var zero: Self {
        return Self(0)
    }
}

extension Vector2 {
    @inlinable
    public var isFinite: Bool {
        return x.isFinite && y.isFinite
    }
}

public extension Vector2 {
    /**
     Returns a new instance with `x` incremented by `value`.
     - parameter value: The amount to add to `x`. To subtract use a negative value.
     - returns: A new Self with `x` incremented by `value`.
    */
    @inlinable
    func addingTo(x: Float) -> Self {
        return Self(self.x + x, y)
    }
    
    /**
     Returns a new instance with `y` incremented by `value`.
     - parameter value: The amount to add to `y`. To subtract use a negative value.
     - returns: A new Self with `y` incremented by `value`.
    */
    @inlinable
    func addingTo(y value: Float) -> Self {
        return Self(x, y + value)
    }
}

extension Vector2 {
    @inlinable
    public subscript (_ index: Int) -> Float {
        get {
            switch index {
            case 0: return x
            case 1: return y
            default:
                fatalError("Index \(index) out of range \(0 ..< 2) for type \(type(of: self)).")
            }
        }
        set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            default:
                fatalError("Index \(index) out of range \(0 ..< 2) for type \(type(of: self)).")
            }
        }
    }
    
    @inlinable
    public func dot<V: Vector2>(_ vector: V) -> Float {
        return (x * vector.x) + (y * vector.y)
    }
    
    /// Returns the hypothetical Z axis
    @inlinable
    public func cross<V: Vector2>(_ vector: V) -> Float {
        return self.x * vector.y - vector.x * self.y
    }
}

extension Vector2 {
    @inlinable
    public var length: Float {
        return x + y
    }
    
    @inlinable
    public var squaredLength: Float {
        return x * x + y * y
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
        let magnitude = self.magnitude
        guard magnitude != 0 else {return}

        let factor = 1 / magnitude
        self.x *= factor
        self.y *= factor
    }
    #endif
    
    @inlinable
    public func squareRoot() -> Self {
        return Self(x.squareRoot(), y.squareRoot())
    }
}

extension Vector2 {
    @inlinable
    public func interpolated<V: Vector2>(to: V, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) -> Self {
        var copy = self
        copy.x.interpolate(to: to.x, method, options: options)
        copy.y.interpolate(to: to.y, method, options: options)
        return copy
    }
    @inlinable
    public mutating func interpolate<V: Vector2>(to: V, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) {
        self.x.interpolate(to: to.x, method, options: options)
        self.y.interpolate(to: to.y, method, options: options)
    }
}

public extension Vector2 {
    @inlinable
    var max: Float {
        return Swift.max(x, y)
    }
    @inlinable
    var min: Float {
        return Swift.min(x, y)
    }
}

//MARK: - SIMD
public extension Vector2 {
    @inlinable
    var simd: SIMD2<Float> {
        return SIMD2<Float>(x, y)
    }
}

//MARK: - Operations
@inlinable
public func ceil<V: Vector2>(_ v: V) -> V {
    return V.init(ceil(v.x), ceil(v.y))
}

@inlinable
public func floor<V: Vector2>(_ v: V) -> V {
    return V.init(floor(v.x), floor(v.y))
}

@inlinable
public func round<V: Vector2>(_ v: V) -> V {
    return V.init(round(v.x), round(v.y))
}

@inlinable
public func abs<V: Vector2>(_ v: V) -> V {
    return V.init(abs(v.x), abs(v.y))
}

@inlinable
public func min<V: Vector2>(_ lhs: V, _ rhs: V) -> V {
    return V.init(min(lhs.x, rhs.x), min(lhs.y, rhs.y))
}

@inlinable
public func max<V: Vector2>(_ lhs: V, _ rhs: V) -> V {
    return V.init(max(lhs.x, rhs.x), max(lhs.y, rhs.y))
}

public extension Vector2 {
    @inlinable
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
}

//MARK: Operators (Self)
extension Vector2 {
    //Multiplication
    @inlinable
    @_disfavoredOverload
    public static func *(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x * rhs.x,
                    lhs.y * rhs.y)
    }
    @inlinable
    @_disfavoredOverload
    public static func *=(lhs: inout Self, rhs: some Vector2) {
        lhs.x *= rhs.x
        lhs.y *= rhs.y
    }
    
    //Addition
    @inlinable
    @_disfavoredOverload
    public static func +(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x + rhs.x,
                    lhs.y + rhs.y)
    }
    @inlinable
    @_disfavoredOverload
    public static func +=(lhs: inout Self, rhs: some Vector2) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    //Subtraction
    @inlinable
    @_disfavoredOverload
    public static func -(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x - rhs.x,
                    lhs.y - rhs.y)
    }
    @inlinable
    @_disfavoredOverload
    public static func -=(lhs: inout Self, rhs: some Vector2) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
}
extension Vector2 {
    //Division
    @inlinable
    @_disfavoredOverload
    public static func /(lhs: Self, rhs: some Vector2) -> Self {
        return Self(lhs.x / rhs.x,
                    lhs.y / rhs.y)
    }
    @inlinable
    @_disfavoredOverload
    public static func /=(lhs: inout Self, rhs: some Vector2) {
        lhs.x /= rhs.x
        lhs.y /= rhs.y
    }
}

//MARK: Operators (Integers and Floats)
extension Vector2 {
    //Multiplication Without Casting
    @inlinable
    public static func *(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x * rhs,
                    lhs.y * rhs)
    }
    @inlinable
    public static func *=(lhs: inout Self, rhs: Float) {
        lhs.x *= rhs
        lhs.y *= rhs
    }
    
    //Addition Without Casting
    @inlinable
    public static func +(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x + rhs,
                    lhs.y + rhs)
    }
    @inlinable
    public static func +=(lhs: inout Self, rhs: Float) {
        lhs.x += rhs
        lhs.y += rhs
    }
    
    //Subtraction Without Casting
    @inlinable
    public static func -(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x - rhs,
                    lhs.y - rhs)
    }
    @inlinable
    public static func -=(lhs: inout Self, rhs: Float) {
        lhs.x -= rhs
        lhs.y -= rhs
    }
    
    @inlinable
    public static func -(lhs: Float, rhs: Self) -> Self {
        return Self(lhs - rhs.x,
                    lhs - rhs.y)
    }
    
    @inlinable
    public static func -=(lhs: Float, rhs: inout Self) {
        rhs.x = lhs - rhs.x
        rhs.y = lhs - rhs.y
    }
}

extension Vector2 {
    //Division Without Casting
    @inlinable
    public static func /(lhs: Self, rhs: Float) -> Self {
        return Self(lhs.x / rhs,
                    lhs.y / rhs)
    }
    @inlinable
    public static func /=(lhs: inout Self, rhs: Float) {
        lhs.x /= rhs
        lhs.y /= rhs
    }
    
    @inlinable
    public static func /(lhs: Float, rhs: Self) -> Self {
        return Self(lhs / rhs.x,
                    lhs / rhs.y)
    }
    @inlinable
    public static func /=(lhs: Float, rhs: inout Self) {
        rhs.x = lhs / rhs.x
        rhs.y = lhs / rhs.y
    }
}

//MARK: Matrix4
public extension Vector2 {
    @inlinable
    static func *(lhs: Self, rhs: Matrix4x4) -> Self {
        var x: Float = lhs.x * rhs.a
        x += lhs.y * rhs.b
        x += rhs.d
        
        var y: Float = lhs.x * rhs.e
        y += lhs.y * rhs.f
        y += rhs.h
        
        return Self(x, y)
    }
    
    @inlinable
    static func *(lhs: Matrix4x4, rhs: Self) -> Self {
        var x: Float = rhs.x * lhs.a
        x += rhs.y * lhs.e
        x += lhs.m
        
        var y: Float = rhs.x * lhs.b
        y += rhs.y * lhs.f
        y += lhs.n
        
        return Self(x, y)
    }
    
    @inlinable
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
    @inlinable
    public static prefix func -(rhs: Self) -> Self {
        return Self(-rhs.x, -rhs.y)
    }

    @inlinable
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
    @inlinable
    public func valuesArray() -> [Float] {return [x, y]}
}

extension Array where Element: Vector2 {
    @inlinable
    public func valuesArray() -> [Float] {
        var values: [Float] = []
        values.reserveCapacity(self.count * 2)
        for value: some Vector2 in self {
            values.append(value.x)
            values.append(value.y)
        }
        return values
    }
}
