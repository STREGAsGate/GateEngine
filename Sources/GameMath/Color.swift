/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if canImport(Foundation)
import Foundation
#endif

public typealias Colour = Color

public struct Color {
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float
    
    @inlinable
    public init(red: Float, green: Float, blue: Float, alpha: Float = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    @_transparent
    public init(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float = 1) {
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    @_transparent
    public init(_ array: [Float]) {
        self.init(array[0], array[1], array[2], array.count > 3 ? array[3] : 1)
    }
    
    @inlinable
    public init(eightBitRed red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = .max) {
        let m: Float = 1.0 / Float(UInt8.max)
        self.red = m * Float(red)
        self.green = m * Float(green)
        self.blue = m * Float(blue)
        self.alpha = m * Float(alpha)
    }
    
    @inlinable
    public init(eightBitValues array: [UInt8]) {
        let m: Float = 1.0 / Float(UInt8.max)
        self.red = m * Float(array[0])
        self.green = m * Float(array[1])
        self.blue = m * Float(array[2])
        if array.indices.contains(3) {
            self.alpha = m * Float(array[3])
        }else{
            self.alpha = 1
        }
    }
    
    @_transparent
    public init(hexValue: UInt32) {
        self.init(eightBitRed: UInt8((hexValue >> 16) & 0xFF),
                  green: UInt8((hexValue >> 8) & 0xFF),
                  blue: UInt8(hexValue & 0xFF))
    }
    
    #if canImport(Foundation)
    @inlinable
    public init?(hexValue: String) {
        let hexString = hexValue.replacingOccurrences(of: "0x", with: "").replacingOccurrences(of: "#", with: "")
        guard hexValue.count >= 6 && hexValue.count <= 8 else {return nil}
       
        var hexValue: UInt64 = 0
        let scanner = Scanner(string: hexString)
        guard scanner.scanHexInt64(&hexValue) else {return nil}
        
        self.init(eightBitRed: UInt8((hexValue >> 24) & 0xFF),
                  green: UInt8((hexValue >> 16) & 0xFF),
                  blue: UInt8((hexValue >> 8) & 0xFF),
                  alpha: UInt8(hexValue & 0xFF))
    }
    #endif

    @_transparent
    public init(white: Float, alpha: Float = 1) {
        self.init(red: white, green: white, blue: white, alpha: alpha)
    }

    @_transparent
    public func withAlpha(_ alpha: Float) -> Color {
        return Self(self.red, self.green, self.blue, alpha)
    }
}

public extension Color {
    @_transparent
    var simd: SIMD4<Float> {
        return SIMD4<Float>(red, green, blue, alpha)
    }

    @_transparent
    func valuesArray() -> [Float] {
        return [red, green, blue, alpha]
    }
    
    @_transparent
    var eightBitRed: UInt8 {
        return UInt8(clamping: Int(Float(UInt8.max) * red))
    }
    @_transparent
    var eightBitGreen: UInt8 {
        return UInt8(clamping: Int(Float(UInt8.max) * green))
    }
    @_transparent
    var eightBitBlue: UInt8 {
        return UInt8(clamping: Int(Float(UInt8.max) * blue))
    }
    @_transparent
    var eightBitAlpha: UInt8 {
        return UInt8(clamping: Int(Float(UInt8.max) * alpha))
    }
    
    @_transparent
    func eightBitValuesArray() -> [UInt8] {
        return [eightBitRed, eightBitGreen, eightBitBlue, eightBitAlpha]
    }
    
    @_transparent
    var eightBitHexValue: UInt32 {
        let r = UInt32(eightBitRed) << 24
        let g = UInt32(eightBitGreen) << 16
        let b = UInt32(eightBitBlue) << 8
        let a = UInt32(eightBitAlpha) << 0
        return r | g | b | a
    }
}

public extension Color {
    @_transparent
    static func +(lhs: Color, rhs: Color) -> Color {
        return Color(lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue, lhs.alpha + rhs.alpha)
    }
    @_transparent
    static func +=(lhs: inout Color, rhs: Color) {
        lhs.red += rhs.red
        lhs.green += rhs.green
        lhs.blue += rhs.blue
        lhs.alpha += rhs.alpha
    }
    
    @_transparent
    static func -(lhs: Color, rhs: Color) -> Color {
        return Color(lhs.red - rhs.red, lhs.green - rhs.green, lhs.blue - rhs.blue, lhs.alpha - rhs.alpha)
    }
    @_transparent
    static func -=(lhs: inout Color, rhs: Color) {
        lhs.red -= rhs.red
        lhs.green -= rhs.green
        lhs.blue -= rhs.blue
        lhs.alpha -= rhs.alpha
    }
    
    @_transparent
    static func *(lhs: Color, rhs: Color) -> Color {
        return Color(lhs.red * rhs.red, lhs.green * rhs.green, lhs.blue * rhs.blue, lhs.alpha * rhs.alpha)
    }
    @_transparent
    static func *=(lhs: inout Color, rhs: Color) {
        lhs.red *= rhs.red
        lhs.green *= rhs.green
        lhs.blue *= rhs.blue
        lhs.alpha *= rhs.alpha
    }
    
    @_transparent
    static func /(lhs: Color, rhs: Color) -> Color {
        return Color(lhs.red / rhs.red, lhs.green / rhs.green, lhs.blue / rhs.blue, lhs.alpha / rhs.alpha)
    }
    @_transparent
    static func /=(lhs: inout Color, rhs: Color) {
        lhs.red /= rhs.red
        lhs.green /= rhs.green
        lhs.blue /= rhs.blue
        lhs.alpha /= rhs.alpha
    }
}

public extension Color {
    @_transparent
    static func +(lhs: Color, rhs: Float) -> Color {
        return Color(lhs.red + rhs, lhs.green + rhs, lhs.blue + rhs, lhs.alpha + rhs)
    }
    @_transparent
    static func +=(lhs: inout Color, rhs: Float) {
        lhs.red += rhs
        lhs.green += rhs
        lhs.blue += rhs
        lhs.alpha += rhs
    }

    @_transparent
    static func -(lhs: Color, rhs: Float) -> Color {
        return Color(lhs.red - rhs, lhs.green - rhs, lhs.blue - rhs, lhs.alpha - rhs)
    }
    @_transparent
    static func -=(lhs: inout Color, rhs: Float) {
        lhs.red -= rhs
        lhs.green -= rhs
        lhs.blue -= rhs
        lhs.alpha -= rhs
    }

    @_transparent
    static func *(lhs: Color, rhs: Float) -> Color {
        return Color(lhs.red * rhs, lhs.green * rhs, lhs.blue * rhs, lhs.alpha * rhs)
    }
    @_transparent
    static func *=(lhs: inout Color, rhs: Float) {
        lhs.red *= rhs
        lhs.green *= rhs
        lhs.blue *= rhs
        lhs.alpha *= rhs
    }
    
    @_transparent
    static func /(lhs: Color, rhs: Float) -> Color {
        return Color(lhs.red / rhs, lhs.green / rhs, lhs.blue / rhs, lhs.alpha / rhs)
    }
    @_transparent
    static func /=(lhs: inout Color, rhs: Float) {
        lhs.red /= rhs
        lhs.green /= rhs
        lhs.blue /= rhs
        lhs.alpha /= rhs
    }
}

public extension Color {
    /// Returns the lesser of the two given values.
    ///
    /// This method returns the minimum of two values, preserving order and
    /// eliminating NaN when possible. For two values `x` and `y`, the result of
    /// `minimum(x, y)` is `x` if `x <= y`, `y` if `y < x`, or whichever of `x`
    /// or `y` is a number if the other is a quiet NaN. If both `x` and `y` are
    /// NaN, or either `x` or `y` is a signaling NaN, the result is NaN.
    ///
    ///     Double.minimum(10.0, -25.0)
    ///     // -25.0
    ///     Double.minimum(10.0, .nan)
    ///     // 10.0
    ///     Double.minimum(.nan, -25.0)
    ///     // -25.0
    ///     Double.minimum(.nan, .nan)
    ///     // nan
    ///
    /// The `minimum` method implements the `minNum` operation defined by the
    /// [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - x: A floating-point value.
    ///   - y: Another floating-point value.
    /// - Returns: The minimum of `x` and `y`, or whichever is a number if the
    ///   other is NaN.
    @_transparent
    static func minimum(_ lhs: Color, _ rhs: Color) -> Color {
        return Color(.minimum(lhs.red, rhs.red), .minimum(lhs.green, rhs.green), .minimum(lhs.blue, rhs.blue), .minimum(lhs.alpha, rhs.alpha))
    }
    
    /// Returns the greater of the two given values.
    ///
    /// This method returns the maximum of two values, preserving order and
    /// eliminating NaN when possible. For two values `x` and `y`, the result of
    /// `maximum(x, y)` is `x` if `x > y`, `y` if `x <= y`, or whichever of `x`
    /// or `y` is a number if the other is a quiet NaN. If both `x` and `y` are
    /// NaN, or either `x` or `y` is a signaling NaN, the result is NaN.
    ///
    ///     Double.maximum(10.0, -25.0)
    ///     // 10.0
    ///     Double.maximum(10.0, .nan)
    ///     // 10.0
    ///     Double.maximum(.nan, -25.0)
    ///     // -25.0
    ///     Double.maximum(.nan, .nan)
    ///     // nan
    ///
    /// The `maximum` method implements the `maxNum` operation defined by the
    /// [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - x: A floating-point value.
    ///   - y: Another floating-point value.
    /// - Returns: The greater of `x` and `y`, or whichever is a number if the
    ///   other is NaN.
    @_transparent
    static func maximum(_ lhs: Color, _ rhs: Color) -> Color {
        return Color(.maximum(lhs.red, rhs.red), .maximum(lhs.green, rhs.green), .maximum(lhs.blue, rhs.blue), .maximum(lhs.alpha, rhs.alpha))
    }
}

/// Returns the lesser of two comparable values.
///
/// - Parameters:
///   - x: A value to compare.
///   - y: Another value to compare.
/// - Returns: The lesser of `x` and `y`. If `x` is equal to `y`, returns `x`.
@_transparent
public func min(_ lhs: Color, _ rhs: Color) -> Color {
    return Color(min(lhs.red, rhs.red), min(lhs.green, rhs.green), min(lhs.blue, rhs.blue), min(lhs.alpha, rhs.alpha))
}

/// Returns the greater of two comparable values.
///
/// - Parameters:
///   - x: A value to compare.
///   - y: Another value to compare.
/// - Returns: The greater of `x` and `y`. If `x` is equal to `y`, returns `y`.
@_transparent
public func max(_ lhs: Color, _ rhs: Color) -> Color {
    return Color(max(lhs.red, rhs.red), max(lhs.green, rhs.green), max(lhs.blue, rhs.blue), max(lhs.alpha, rhs.alpha))
}

extension Color: _ExpressibleByColorLiteral {
    @_transparent
    public init(_colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        self.init(red, green, blue, alpha)
    }
}

public extension Color {
    static let clear: Color         = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    
    static let white: Color         = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let lightGray: Color     = #colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    static let gray: Color          = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    static let darkGray: Color      = #colorLiteral(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
    static let black: Color         = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    static let lightRed: Color      = #colorLiteral(red: 1.0, green: 0.25, blue: 0.25, alpha: 1.0)
    static let lightGreen: Color    = #colorLiteral(red: 0.25, green: 1.0, blue: 0.25, alpha: 1.0)
    static let lightBlue: Color     = #colorLiteral(red: 0.25, green: 0.25, blue: 1.0, alpha: 1.0)

    static let red: Color           = #colorLiteral(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let green: Color         = #colorLiteral(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
    static let blue: Color          = #colorLiteral(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    
    static let darkRed: Color       = #colorLiteral(red: 0.25, green: 0.05, blue: 0.05, alpha: 1.0)
    static let darkGreen: Color     = #colorLiteral(red: 0.05, green: 0.25, blue: 0.05, alpha: 1.0)
    static let darkBlue: Color      = #colorLiteral(red: 0.05, green: 0.05, blue: 0.25, alpha: 1.0)
    
    static let cyan: Color          = #colorLiteral(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let magenta: Color       = #colorLiteral(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
    static let yellow: Color        = #colorLiteral(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    static let orange: Color        = #colorLiteral(red: 1.0, green: 0.64453125, blue: 0.0, alpha: 1.0)
    static let purple: Color        = #colorLiteral(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        
    static let vertexColors = Color(red: -1001, green: -2002, blue: -3003, alpha: -4004)
    static let defaultDiffuseMapColor = Color(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    static let defaultNormalMapColor = Color(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
    static let defaultRoughnessMapColor = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let defaultPointLightColor = Color(red: 1.0, green: 1.0, blue: 0.9, alpha: 1.0)
    static let defaultSpotLightColor = Color(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
    static let defaultDirectionalLightColor = Color(red: 0.7, green: 0.7, blue: 1.0, alpha: 1.0)
}

public extension Color {
    @_transparent
    mutating func interpolate(to: Self, _ method: InterpolationMethod) {
        self.red.interpolate(to: to.red, method)
        self.green.interpolate(to: to.green, method)
        self.blue.interpolate(to: to.blue, method)
        self.alpha.interpolate(to: to.alpha, method)
    }
    
    @_transparent
    func interpolated(to: Self, _ method: InterpolationMethod) -> Self {
        return Self(self.red.interpolated(to: to.red, method),
                    self.green.interpolated(to: to.green, method),
                    self.blue.interpolated(to: to.blue, method),
                    self.alpha.interpolated(to: to.alpha, method))
    }
}

extension Color: Equatable {}
extension Color: Hashable {}

extension Color: Codable {
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([red, green, blue, alpha])
    }

    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let values = try container.decode(Array<Float>.self)
        self.init(values[0], values[1], values[2], values[3])
    }
}
