/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// MARK: - Integers

@inlinable
internal func _pow_recursive<T: FixedWidthInteger, E: FixedWidthInteger>(_ base: T, _ exponent: E) -> T {
    if exponent == 0 {
        return 1
    }
    let half_power: T = _pow_recursive(base, exponent / 2)
    if exponent % 2 == 0 {
        return half_power * half_power
    }
    return base * half_power * half_power
}

@inlinable
public func pow<T: FixedWidthInteger, E: FixedWidthInteger & SignedInteger>(_ base: T, _ exponent: E) -> T {
    if exponent < 0 {
        return 1 / _pow_recursive(base, -exponent)
    }
    return _pow_recursive(base, exponent)
}

@inlinable
public func pow<T: FixedWidthInteger, E: FixedWidthInteger & UnsignedInteger>(_ base: T, _ exponent: E) -> T {
    return _pow_recursive(base, exponent)
}


// MARK: - Floats

@inlinable
internal func _pow_recursive<T: FloatingPoint, E: FixedWidthInteger>(_ base: T, _ exponent: E) -> T {
    if exponent == 0 {
        return 1
    }
    let half_power: T = _pow_recursive(base, exponent / 2)
    if exponent % 2 == 0 {
        return half_power * half_power
    }
    return base * half_power * half_power
}

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func pow<T: FloatingPoint, E: FixedWidthInteger & SignedInteger>(_ base: T, _ exponent: E) -> T {
    if exponent < 0 {
        return 1 / _pow_recursive(base, -exponent)
    }
    return _pow_recursive(base, exponent)
}

@_disfavoredOverload // <- prefer native overloads
@inlinable
public func pow<T: FloatingPoint, E: FixedWidthInteger & UnsignedInteger>(_ base: T, _ exponent: E) -> T {
    return _pow_recursive(base, exponent)
}


// MARK: - Native

#if canImport(Foundation)
public import func Foundation.pow

@_transparent
@inlinable
public func pow(_ base: Float32, _ exponent: Float32) -> Float32 {
    return Foundation.pow(base, exponent)
}

@_transparent
@inlinable
public func pow(_ base: Float64, _ exponent: Float64) -> Float64 {
    return Foundation.pow(base, exponent)
}
#endif
