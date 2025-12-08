/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func atan2<T: BinaryFloatingPoint>(_ lhs: T, _ rhs: T) -> T {
    #if canImport(Foundation)
    switch lhs {
    case is Float16:
        return T(Foundation.atan2(Float32(lhs), Float32(rhs)))
    case is Float32:
        return T(Foundation.atan2(Float32(lhs), Float32(rhs)))
    case is Float64:
        return T(Foundation.atan2(Float64(lhs), Float64(rhs)))
    default:
        return T(Foundation.atan2(Float64(lhs), Float64(rhs)))
    }
    #else
    fatalError("Unsupported platform.")
    #endif
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.atan2

@_transparent
@inlinable
public func atan2(_ lhs: Float32, _ rhs: Float32) -> Float32 {
    return Foundation.atan2(lhs, rhs)
}

@_transparent
@inlinable
public func atan2(_ lhs: Float64, _ rhs: Float64) -> Float64 {
    return Foundation.atan2(lhs, rhs)
}

#endif
