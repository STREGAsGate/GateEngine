/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
public import simd

// MARK: - Float16
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public extension Direction3n where Scalar == Float16 {
    @inlinable
    func reflected(off normal: Self) -> Self {
        return unsafeBitCast(simd_reflect(self.simd(), normal.simd()), to: Self.self)
    }

    @inlinable
    mutating func normalize() {
        guard self != Self.zero else { return }
        self = unsafeBitCast(simd_fast_normalize(self.simd()), to: Self.self)
    }
}
#endif

// MARK: - Float32
public extension Direction3n where Scalar == Float32 {
    @inlinable
    func reflected(off normal: Self) -> Self {
        return unsafeBitCast(simd_reflect(self.simd(), normal.simd()), to: Self.self)
    }

    @inlinable
    mutating func normalize() {
        guard self != Self.zero else { return }
        self = unsafeBitCast(simd_fast_normalize(self.simd()), to: Self.self)
    }
}

// MARK: - Float64
public extension Direction3n where Scalar == Float64 {
    @inlinable
    func reflected(off normal: Self) -> Self {
        return unsafeBitCast(simd_reflect(self.simd(), normal.simd()), to: Self.self)
    }

    @inlinable
    mutating func normalize() {
        guard self != Self.zero else { return }
        self = unsafeBitCast(simd_fast_normalize(self.simd()), to: Self.self)
    }
}

#endif
