/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Floats

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func ceil<T: FloatingPoint>(_ x: T) -> T {
    return x.rounded(.up)
}

// MARK: - Native

#if canImport(Foundation)
public import func Foundation.ceil

@_transparent
@inlinable
public func ceil(_ x: Float32) -> Float32 {
    return Foundation.ceil(x)
}

@_transparent
@inlinable
public func ceil(_ x: Float64) -> Float64 {
    return Foundation.ceil(x)
}

#endif
