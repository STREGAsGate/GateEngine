/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func floor<T: FloatingPoint>(_ x: T) -> T {
    return x.rounded(.down)
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.floor

@_transparent
@inlinable
public func floor(_ x: Float32) -> Float32 {
    return Foundation.floor(x)
}

@_transparent
@inlinable
public func floor(_ x: Float64) -> Float64 {
    return Foundation.floor(x)
}

#endif
