/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
public import simd

// MARK: - Float16
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public extension Position3n where Scalar == Float16 {
    /** The distance between `from` and `self`
     - parameter from: A value representing the source position.
     */
    func distance(from: Self) -> Scalar {
        return simd_distance(self.simd(), from.simd())
    }
    
    @inlinable
    func squaredDistance(from: Self) -> Scalar {
        return simd_distance_squared(self.simd(), from.simd())
    }
}

// MARK: - Float32
public extension Position3n where Scalar == Float32 {
    /** The distance between `from` and `self`
     - parameter from: A value representing the source position.
     */
    func distance(from: Self) -> Scalar {
        return simd_distance(self.simd(), from.simd())
    }
    
    @inlinable
    func squaredDistance(from: Self) -> Scalar {
        return simd_distance_squared(self.simd(), from.simd())
    }
}

// MARK: - Float64
public extension Position3n where Scalar == Float64 {
    /** The distance between `from` and `self`
     - parameter from: A value representing the source position.
     */
    func distance(from: Self) -> Scalar {
        return simd_distance(self.simd(), from.simd())
    }
    
    @inlinable
    func squaredDistance(from: Self) -> Scalar {
        return simd_distance_squared(self.simd(), from.simd())
    }
}

#endif
