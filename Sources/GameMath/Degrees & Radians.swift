/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public protocol Angle: Sendable, RawRepresentable, Numeric, Comparable, FloatingPoint where RawValue == Float {
    var rawValue: RawValue {get set}
    
    var rawValueAsDegrees: RawValue {get}
    var rawValueAsRadians: RawValue {get}
    
    var asDegrees: Degrees {get}
    var asRadians: Radians {get}
    
    mutating func interpolate(to: some Angle, _ method: InterpolationMethod)
    func interpolated(to: some Angle, _ method: InterpolationMethod) -> Self
    
    init(_ rawValue: RawValue)
    init(rawValue: RawValue)
    init(rawValueAsRadians: RawValue)
}

public extension Angle {
    @inlinable
    var isFinite: Bool {
        return rawValue.isFinite
    }
    
    @inlinable
    mutating func interpolate(to: some Angle, _ method: InterpolationMethod) {
        self.rawValue.interpolate(to: to.rawValue, method)
    }
    
    @inlinable
    func interpolated(to: some Angle, _ method: InterpolationMethod) -> Self {
        var copy = self
        copy.interpolate(to: to, method)
        return copy
    }
}

public extension Angle {
    @inlinable
    static var zero: Self {
        return Self(rawValue: 0)
    }
    
    @inlinable
    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        assert(type(of: lhs) == type(of: rhs))
        return Self(rawValue: lhs.rawValue + rhs.rawValue)
    }
    @inlinable
    static func +(_ lhs: Self, _ rhs: some Angle) -> Self {
        return Self(rawValueAsRadians: lhs.rawValueAsRadians + rhs.rawValueAsRadians)
    }
    @inlinable
    static func +=(_ lhs: inout Self, _ rhs: some Angle) {
        lhs = lhs + rhs
    }
    @inlinable
    static func +(_ lhs: Self, _ rhs: RawValue) -> Self {
        return Self(rawValue: lhs.rawValue + rhs)
    }
    @inlinable
    static func +(_ lhs: RawValue, _ rhs: Self) -> RawValue {
        return lhs + rhs.rawValue
    }
    
    @inlinable
    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        assert(type(of: lhs) == type(of: rhs))
        return Self(rawValue: lhs.rawValue - rhs.rawValue)
    }
    @inlinable
    static func -(_ lhs: Self, _ rhs: some Angle) -> Self {
        return Self(rawValueAsRadians: lhs.rawValueAsRadians - rhs.rawValueAsRadians)
    }
    @inlinable
    static func -=(_ lhs: inout Self, _ rhs: some Angle) {
        lhs = lhs - rhs
    }
    @inlinable
    static func -(_ lhs: Self, _ rhs: RawValue) -> Self {
        return Self(rawValue: lhs.rawValue - rhs)
    }
    @inlinable
    static func -(_ lhs: RawValue, _ rhs: Self) -> RawValue {
        return lhs - rhs.rawValue
    }
    
    @inlinable
    static prefix func -(_ rhs: Self) -> Self {
        return Self(rawValue: -rhs.rawValue)
    }
    
    @inlinable
    static prefix func +(_ rhs: Self) -> Self {
        return Self(rawValue: +rhs.rawValue)
    }
}

extension Angle {
    @inlinable
    public static func *(_ lhs: Self, _ rhs: Self) -> Self {
        assert(type(of: lhs) == type(of: rhs))
        return Self(rawValue: lhs.rawValue * rhs.rawValue)
    }
    @inlinable
    public static func *(_ lhs: Self, _ rhs: some Angle) -> Self {
        return Self(rawValueAsRadians: lhs.rawValueAsRadians * rhs.rawValueAsRadians)
    }
    @inlinable
    public static func *(_ lhs: Self, _ rhs: RawValue) -> Self {
        return Self(rawValue: lhs.rawValue * rhs)
    }
    @inlinable
    public static func *(_ lhs: RawValue, _ rhs: Self) -> RawValue {
        return lhs * rhs.rawValue
    }
    
    @inlinable
    public static func *=(_ lhs: inout Self, _ rhs: Self) {
        assert(type(of: lhs) == type(of: rhs))
        lhs.rawValue *= rhs.rawValue
    }
    @inlinable
    public static func *=(_ lhs: inout Self, _ rhs: some Angle) {
        lhs.rawValue = Self(rawValueAsRadians: lhs.rawValueAsRadians * rhs.rawValueAsRadians).rawValue
    }
    @inlinable
    public static func *=(_ lhs: inout Self, _ rhs: RawValue) {
        lhs.rawValue *= rhs
    }
    @inlinable
    public static func *=(_ lhs: inout RawValue, _ rhs: Self) {
        lhs *= rhs.rawValue
    }
}


extension Angle {
    @inlinable
    public static func /(_ lhs: Self, _ rhs: Self) -> Self {
        assert(type(of: lhs) == type(of: rhs))
        return Self(rawValue: lhs.rawValue / rhs.rawValue)
    }
    @inlinable
    public static func /(_ lhs: Self, _ rhs: some Angle) -> Self {
        return Self(rawValueAsRadians: lhs.rawValueAsRadians / rhs.rawValueAsRadians)
    }
    @inlinable
    public static func /(_ lhs: Self, _ rhs: RawValue) -> Self {
        return Self(rawValue: lhs.rawValue / rhs)
    }
    @inlinable
    public static func /(_ lhs: RawValue, _ rhs: Self) -> RawValue {
        return lhs / rhs.rawValue
    }
    
    @inlinable
    public static func /=(_ lhs: inout Self, _ rhs: Self) {
        assert(type(of: lhs) == type(of: rhs))
        lhs.rawValue /= rhs.rawValue
    }
    @inlinable
    public static func /=(_ lhs: inout Self, _ rhs: some Angle) {
        lhs.rawValue = Self(rawValueAsRadians: lhs.rawValueAsRadians / rhs.rawValueAsRadians).rawValue
    }
    @inlinable
    public static func /=(_ lhs: inout Self, _ rhs: RawValue) {
        lhs.rawValue /= rhs
    }
    @inlinable
    public static func /=(_ lhs: inout RawValue, _ rhs: Self) {
        lhs /= rhs.rawValue
    }
}

public extension Angle {
    @inlinable
    static func minimum(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(.minimum(lhs.rawValue, rhs.rawValue))
    }
    @inlinable
    static func minimum(_ lhs: some Angle, _ rhs: some Angle) -> Self {
        return Self(rawValueAsRadians: .minimum(lhs.rawValueAsRadians, rhs.rawValueAsRadians))
    }
    @inlinable
    static func minimum(_ lhs: Self, _ rhs: RawValue) -> Self {
        return Self(.minimum(lhs.rawValue, rhs))
    }
    @inlinable
    static func minimum(_ lhs: RawValue, _ rhs: Self) -> Self {
        return Self(.minimum(lhs, rhs.rawValue))
    }
    
    @inlinable
    static func maximum(_ lhs: Self, _ rhs: Self) -> Self {
        return Self(.maximum(lhs.rawValue, rhs.rawValue))
    }
    @inlinable
    static func maximum(_ lhs: some Angle, _ rhs: some Angle) -> Self {
        return Self(rawValueAsRadians: .maximum(lhs.rawValueAsRadians, rhs.rawValueAsRadians))
    }
    @inlinable
    static func maximum(_ lhs: Self, _ rhs: RawValue) -> Self {
        return Self(.maximum(lhs.rawValue, rhs))
    }
    @inlinable
    static func maximum(_ lhs: RawValue, _ rhs: Self) -> Self {
        return Self(.maximum(lhs, rhs.rawValue))
    }
}

@inlinable
public func min<T: Angle>(_ lhs: T.RawValue, _ rhs: T) -> T {
    return T(Swift.min(lhs, rhs.rawValue))
}

@inlinable
public func min<T: Angle>(_ lhs: T, _ rhs: T.RawValue) -> T {
    return T(Swift.min(lhs.rawValue, rhs))
}

@inlinable
public func max<T: Angle>(_ lhs: T.RawValue, _ rhs: T) -> T {
    return T(Swift.max(lhs, rhs.rawValue))
}

@inlinable
public func max<T: Angle>(_ lhs: T, _ rhs: T.RawValue) -> T {
    return T(Swift.max(lhs.rawValue, rhs))
}

extension Angle {
    @inlinable
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    @inlinable
    public static func <(lhs: Self, rhs: some Angle) -> Bool {
        return lhs.rawValueAsRadians < rhs.rawValueAsRadians
    }
    @inlinable
    public static func <(lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue < rhs
    }
    @inlinable
    public static func <(lhs: RawValue, rhs: Self) -> Bool {
        return lhs < rhs.rawValue
    }
    
    @inlinable
    public static func >(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    @inlinable
    public static func >(lhs: Self, rhs: some Angle) -> Bool {
        return lhs.rawValueAsRadians > rhs.rawValueAsRadians
    }
    @inlinable
    public static func >(lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue > rhs
    }
    @inlinable
    public static func >(lhs: RawValue, rhs: Self) -> Bool {
        return lhs > rhs.rawValue
    }
}

extension Angle {
    @inlinable
    public static func <=(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    @inlinable
    public static func <=(lhs: Self, rhs: some Angle) -> Bool {
        return lhs.rawValueAsRadians <= rhs.rawValueAsRadians
    }
    @inlinable
    public static func <=(lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue <= rhs
    }
    @inlinable
    public static func <=(lhs: RawValue, rhs: Self) -> Bool {
        return lhs <= rhs.rawValue
    }
    
    @inlinable
    public static func >=(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    @inlinable
    public static func >=(lhs: Self, rhs: some Angle) -> Bool {
        return lhs.rawValueAsRadians >= rhs.rawValueAsRadians
    }
    @inlinable
    public static func >=(lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue >= rhs
    }
    @inlinable
    public static func >=(lhs: RawValue, rhs: Self) -> Bool {
        return lhs >= rhs.rawValue
    }
}

extension Angle {
    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        assert(type(of: lhs) == type(of: rhs))
        return lhs.rawValue == rhs.rawValue
    }
    
    @inlinable
    public static func ==(lhs: Self, rhs: RawValue) -> Bool {
        return lhs.rawValue == rhs
    }
    
    @inlinable
    public static func ==(lhs: RawValue, rhs: Self) -> Bool {
        return lhs == rhs.rawValue
    }
}

public extension Angle {
    @inlinable
    static func random<T>(in range: Range<RawValue>, using generator: inout T) -> Self where T : RandomNumberGenerator {
        return Self(RawValue.random(in: range, using: &generator))
    }
    
    @inlinable
    static func random(in range: Range<RawValue>) -> Self {
        return Self(RawValue.random(in: range))
    }

    @inlinable
    static func random<T>(in range: ClosedRange<RawValue>, using generator: inout T) -> Self where T : RandomNumberGenerator {
        return Self(RawValue.random(in: range, using: &generator))
    }

    @inlinable
    static func random(in range: ClosedRange<RawValue>) -> Self {
        return Self(RawValue.random(in: range))
    }
}

public extension Angle {
    @inlinable
    mutating func round(_ rule: FloatingPointRoundingRule) {
        rawValue.round(rule)
    }
    @inlinable
    init(sign: FloatingPointSign, exponent: RawValue.Exponent, significand: Self) {
        self.init(rawValue: RawValue(sign: sign, exponent: exponent, significand: significand.rawValue.significand))
    }
    @inlinable
    var exponent: RawValue.Exponent {
        return rawValue.exponent
    }
    @inlinable
    func distance(to other: Self) -> RawValue.Stride {
        return rawValue.distance(to: other.rawValue)
    }
    @inlinable
    func advanced(by n: RawValue.Stride) -> Self {
        return Self(rawValue: rawValue.advanced(by: n))
    }
    @inlinable
    init(signOf: Self, magnitudeOf: Self) {
        self.init(RawValue(signOf: signOf.rawValue, magnitudeOf: magnitudeOf.rawValue))
    }
    @inlinable
    init(_ value: Int) {
        self.init(RawValue(value))
    }
    @inlinable
    init<Source>(_ value: Source) where Source : BinaryInteger {
        self.init(RawValue(value))
    }
    @inlinable
    static var radix: Int {
        return RawValue.radix
    }
    @inlinable
    static var nan: Self {
        return Self(rawValue: .nan)
    }
    @inlinable
    static var signalingNaN: Self {
        return Self(rawValue: .signalingNaN)
    }
    @inlinable
    static var infinity: Self {
        return Self(rawValue: .infinity)
    }
    @inlinable
    static var greatestFiniteMagnitude: Self {
        return Self(rawValue: .greatestFiniteMagnitude)
    }
    @inlinable
    static var pi: Self {
        return Self(rawValue: .pi)
    }
    @inlinable
    var ulp: Self {
        return Self(rawValue: rawValue.ulp)
    }
    @inlinable
    static var leastNormalMagnitude: Self {
        return Self(rawValue: .leastNormalMagnitude)
    }
    @inlinable
    static var leastNonzeroMagnitude: Self {
        return Self(rawValue: .leastNonzeroMagnitude)
    }
    @inlinable
    var sign: FloatingPointSign {
        return rawValue.sign
    }
    @inlinable
    var significand: Self {
        return Self(rawValue: rawValue.significand)
    }
    @inlinable
    mutating func formRemainder(dividingBy other: Self) {
        rawValue.formRemainder(dividingBy: other.rawValue)
    }
    @inlinable
    mutating func formTruncatingRemainder(dividingBy other: Self) {
        rawValue.formTruncatingRemainder(dividingBy: other.rawValue)
    }
    @inlinable
    mutating func formSquareRoot() {
        rawValue.formSquareRoot()
    }
    @inlinable
    mutating func addProduct(_ lhs: Self, _ rhs: Self) {
        rawValue.addProduct(lhs.rawValue, rhs.rawValue)
    }
    @inlinable
    var nextUp: Self {
        return Self(rawValue: rawValue.nextUp)
    }
    @inlinable
    func isEqual(to other: Self) -> Bool {
        return rawValue.isEqual(to: other.rawValue)
    }
    @inlinable
    func isLess(than other: Self) -> Bool {
        return rawValue.isLess(than: other.rawValue)
    }
    @inlinable
    func isLessThanOrEqualTo(_ other: Self) -> Bool {
        return rawValue.isLessThanOrEqualTo(other.rawValue)
    }
    @inlinable
    func isTotallyOrdered(belowOrEqualTo other: Self) -> Bool {
        return rawValue.isTotallyOrdered(belowOrEqualTo: other.rawValue)
    }
    @inlinable
    var isNormal: Bool {
        return rawValue.isNormal
    }
    @inlinable
    var isZero: Bool {
        return rawValue.isZero
    }
    @inlinable
    var isSubnormal: Bool {
        return rawValue.isSubnormal
    }
    @inlinable
    var isInfinite: Bool {
        return rawValue.isInfinite
    }
    @inlinable
    var isNaN: Bool {
        return rawValue.isNaN
    }
    @inlinable
    var isSignalingNaN: Bool {
        rawValue.isSignalingNaN
    }
    @inlinable
    var isCanonical: Bool {
        return rawValue.isCanonical
    }
    @inlinable
    var magnitude: Magnitude {
        return Self(rawValue: rawValue.magnitude)
    }
}

/// Represents an angle in radians
public struct Radians: Angle, Hashable, Codable, Sendable {
    public typealias RawValue = Float
    public typealias Magnitude = Self
    public typealias IntegerLiteralType = RawValue
    public typealias Exponent = RawValue.Exponent
    public typealias Stride = RawValue.Stride

    public var rawValue: RawValue
    
    @inlinable
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    @inlinable
    public init(_ rawValue: RawValue) {
        self.init(rawValue: rawValue)
    }
    @inlinable
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(RawValue(source))
    }
    @inlinable
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
    @inlinable
    public init(rawValueAsRadians: Float) {
        self.init(rawValue: rawValueAsRadians)
    }
    @inlinable
    public init(_ value: some Angle) {
        self.init(rawValue: value.rawValueAsRadians)
    }
    
    @inlinable
    public var rawValueAsRadians: Float {
        return rawValue
    }
    @inlinable
    public var rawValueAsDegrees: Float {
        return rawValue * (180 / RawValue.pi)
    }
    @inlinable
    public var asDegrees: Degrees {
        return .init(rawValue: rawValueAsDegrees)
    }
    @inlinable
    public var asRadians: Radians {
        return self
    }
}

public struct Degrees: Angle, Hashable, Codable, Sendable {
    public typealias RawValue = Float
    public typealias Magnitude = Self
    public typealias IntegerLiteralType = RawValue
    public typealias Exponent = RawValue.Exponent
    public typealias Stride = RawValue.Stride

    public var rawValue: RawValue
    
    @inlinable
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    @inlinable
    public init(_ rawValue: RawValue) {
        self.init(rawValue: rawValue)
    }
    @inlinable
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(RawValue(source))
    }
    @inlinable
    public init(integerLiteral value: RawValue) {
        self.init(rawValue: value)
    }
    @inlinable
    public init(rawValueAsRadians: Float) {
        self.init(rawValue: rawValueAsRadians * (180 / RawValue.pi))
    }
    @inlinable
    public init(_ value: some Angle) {
        self.init(rawValue: value.rawValueAsDegrees)
    }
    
    @inlinable
    public var rawValueAsRadians: Float {
        return rawValue * (RawValue.pi / 180)
    }
    @inlinable
    public var rawValueAsDegrees: Float {
        return rawValue
    }
    @inlinable
    public var asDegrees: Degrees {
        return self
    }
    @inlinable
    public var asRadians: Radians {
        return .init(rawValue: rawValueAsRadians)
    }
}

public extension Degrees {
    @inlinable
    mutating func interpolate(to: Self, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) {
        self = self.interpolated(to: to, method)
    }
    
    @inlinable
    func interpolated(to: Self, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) -> Self {
        if options.contains(.shortest) {
            // Shortest distance
            let shortest = self.shortestAngle(to: to)
            return Self(self.rawValue.interpolated(to: (self + shortest).rawValue, method))
        }
        return Self(self.rawValue.interpolated(to: to.rawValue, method))
    }
    
    @inlinable
    mutating func interpolate(to: Radians, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) {
        self.interpolate(to: Self(to), method, options: options)
    }
    
    @inlinable
    func interpolated(to: Radians, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) -> Self {
        return self.interpolated(to: Self(to), method, options: options)
    }
    
    @inlinable
    static func random() -> Self {
        return .random(in: 0 ..< 360)
    }
}

extension Degrees {
    /// Returns an angle equivalent to the current angle if it rolled over when exceeding 360, or rolled back to 360 when less then zero. The value is always within 0 ... 360
    @inlinable
    public var normalized: Self {
        let scaler: RawValue = 1000000
        let degrees = (self * scaler).truncatingRemainder(dividingBy: 360 * scaler) / scaler
        if self < 0 {
            return degrees + 360°
        }
        return degrees
    }
    
    /// Makes the angle equivalent to the current angle if it rolled over when exceeding 360, or rolled back to 360 when less then zero. The value is always within 0 ... 360
    @inlinable
    public mutating func normalize() {
        self = self.normalized
    }
    
    /// Returns the shortest angle, that when added to `self.normalized` will result in `destination.normalized`
    @inlinable
    public func shortestAngle(to destination: Self) -> Self {
        var src = self.rawValue
        var dst = destination.rawValue
        
        // If from or to is a negative, we have to recalculate them.
        // For an example, if from = -45 then from(-45) + 360 = 315.
        if dst < 0 || dst >= 360 {
            dst = destination.normalized.rawValue
        }
        
        if src < 0 || src >= 360 {
            src = self.normalized.rawValue
        }
        
        // Do not rotate if from == to.
        if dst == src {
            return Self(0)
        }
        
        // Pre-calculate left and right.
        var left = (360 - dst) + src
        var right = dst - src
        // If from < to, re-calculate left and right.
        if dst < src && src > 0 {
            left = src - dst
            right = (360 - src) + dst
        }
        
        // Determine the shortest direction.
        return Self((left <= right) ? (left * -1) : right)
    }
}

postfix operator °
@inlinable
public postfix func °(lhs: Degrees.RawValue) -> Degrees {
    return Degrees(rawValue: lhs)
}

@inlinable 
@_disfavoredOverload
public postfix func °(lhs: Degrees.RawValue) -> Radians {
    return Degrees(rawValue: lhs).asRadians
}
