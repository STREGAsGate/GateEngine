/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DColor {
    public typealias RawValue = Array<Float>
    internal var rawValue: RawValue

    public var red: Float {
        get {
            return rawValue[0]
        }
        set {
            rawValue[0] = newValue
        }
    }

    public var green: Float {
        get {
            return rawValue[1]
        }
        set {
            rawValue[1] = newValue
        }
    }

    public var blue: Float {
        get {
            return rawValue[2]
        }
        set {
            rawValue[2] = newValue
        }
    }

    public var alpha: Float {
        get {
            return rawValue[3]
        }
        set {
            rawValue[3] = newValue
        }
    }

    public subscript(_ index: Int) -> Float {
        get {
            return rawValue[index]
        }
        set {
            rawValue[index] = newValue
        }
    }

    internal var tuple: (Float, Float, Float, Float) {
        return (rawValue[0], rawValue[1], rawValue[2], rawValue[3])
    }

    internal init(_ tuple: (Float, Float, Float, Float)) {
        self.rawValue = [tuple.0, tuple.1, tuple.2, tuple.3]
    }

    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.rawValue = [red, green, blue, alpha]
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static var black: D3DColor {D3DColor(red: 0, green: 0, blue: 0, alpha: 1)}
    public static var white: D3DColor {D3DColor(red: 1, green: 1, blue: 1, alpha: 1)}
    public static var clear: D3DColor {D3DColor(red: 1, green: 1, blue: 1, alpha: 0)}

    public static var red: D3DColor {D3DColor(red: 1, green: 0, blue: 0, alpha: 1)}
    public static var green: D3DColor {D3DColor(red: 0, green: 1, blue: 0, alpha: 1)}
    public static var blue: D3DColor {D3DColor(red: 0, green: 0, blue: 1, alpha: 1)}
}
