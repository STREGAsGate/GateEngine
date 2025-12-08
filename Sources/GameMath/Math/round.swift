/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func round<T: FloatingPoint>(_ x: T) -> T {
    return x.rounded(.toNearestOrAwayFromZero)
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.round

@_transparent
@inlinable
public func round(_ x: Float32) -> Float32 {
    return Foundation.round(x)
}

@_transparent
@inlinable
public func round(_ x: Float64) -> Float64 {
    return Foundation.round(x)
}

#endif
