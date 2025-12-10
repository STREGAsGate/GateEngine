/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func cos<T: BinaryFloatingPoint>(_ x: T) -> T {
    #if canImport(Foundation)
    switch x {
    #if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
    case let x as Float16:
        return T(Foundation.cos(Float32(x)))
    #endif
    case let x as Float32:
        return T(Foundation.cos(x))
    case let x as Float64:
        return T(Foundation.cos(x))
    default:
        return T(Foundation.cos(Float64(x)))
    }
    #else
    fatalError("Unsupported platform.")
    #endif
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.cos

@_transparent
@inlinable
public func cos(_ x: Float32) -> Float32 {
    return Foundation.cos(x)
}

@_transparent
@inlinable
public func cos(_ x: Float64) -> Float64 {
    return Foundation.cos(x)
}

#endif
