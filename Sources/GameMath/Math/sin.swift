/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func sin<T: BinaryFloatingPoint>(_ x: T) -> T {
    #if canImport(Foundation)
    switch x {
    case let x as Float16:
        return T(Foundation.sin(Float32(x)))
    case let x as Float32:
        return T(Foundation.sin(x))
    case let x as Float64:
        return T(Foundation.sin(x))
    default:
        return T(Foundation.sin(Float64(x)))
    }
    #else
    fatalError("Unsupported platform.")
    #endif
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.sin

@_transparent
@inlinable
public func sin(_ x: Float32) -> Float32 {
    return Foundation.sin(x)
}

@_transparent
@inlinable
public func sin(_ x: Float64) -> Float64 {
    return Foundation.sin(x)
}

#endif
