/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func asin<T: BinaryFloatingPoint>(_ x: T) -> T {
    #if canImport(Foundation)
    switch x {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case is Float16:
        return T(Foundation.asin(Float32(x)))
    #endif
    case is Float32:
        return T(Foundation.asin(Float32(x)))
    case is Float64:
        return T(Foundation.asin(Float64(x)))
    default:
        return T(Foundation.asin(Float64(x)))
    }
    #else
    fatalError("Unsupported platform.")
    #endif
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.asin

@_transparent
@inlinable
public func asin(_ x: Float32) -> Float32 {
    return Foundation.asin(x)
}

@_transparent
@inlinable
public func asin(_ x: Float64) -> Float64 {
    return Foundation.asin(x)
}

#endif
