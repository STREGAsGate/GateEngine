/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func tan<T: BinaryFloatingPoint>(_ x: T) -> T {
    #if canImport(Foundation)
    switch x {
    case let x as Float16:
        return T(Foundation.tan(Float32(x)))
    case let x as Float32:
        return T(Foundation.tan(x))
    case let x as Float64:
        return T(Foundation.tan(x))
    default:
        return T(Foundation.tan(Float64(x)))
    }
    #else
    fatalError("Unsupported platform.")
    #endif
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.tan

@_transparent
@inlinable
public func tan(_ x: Float32) -> Float32 {
    return Foundation.tan(x)
}

@_transparent
@inlinable
public func tan(_ x: Float64) -> Float64 {
    return Foundation.tan(x)
}

#endif
