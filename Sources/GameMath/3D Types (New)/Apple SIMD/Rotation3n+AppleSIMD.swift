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
public extension Rotation3n where Scalar == Float16 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    var length: Scalar {
        return simd_length(self.simd())
    }
    
    @inlinable
    var squaredLength: Scalar {
        return simd_length_squared(self.simd())
    }
    
    @inlinable
    mutating func normalize() {
        guard self != .zero else { return }
        self = unsafeBitCast(simd_normalize(self.simd()), to: Self.self)
    }
}
#endif

// MARK: - Float32
public extension Rotation3n where Scalar == Float32 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    /**
     Initialize as degrees around `axis`
     - parameter angle: The angle to rotate
     - parameter axis: The direction to rotate around
     */
    @inlinable
    init(_ angle: some Angle, axis: Direction3n<Scalar>) {
        self = unsafeBitCast(simd_quatf(angle: Scalar(angle.rawValueAsRadians), axis: axis.simd()), to: Self.self)
    }
    
    @inlinable
    var length: Scalar {
        return simd_length(self.simd())
    }
    
    @inlinable
    var squaredLength: Scalar {
        return simd_length_squared(self.simd())
    }
    
    @inlinable
    mutating func normalize() {
        guard self != .zero else { return }
        self = unsafeBitCast(simd_normalize(self.simd()), to: Self.self)
    }
}

// MARK: - Float64
public extension Rotation3n where Scalar == Float64 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    /**
     Initialize as degrees around `axis`
     - parameter angle: The angle to rotate
     - parameter axis: The direction to rotate around
     */
    @inlinable
    init(_ angle: some Angle, axis: Direction3n<Scalar>) {
        self = unsafeBitCast(simd_quatd(angle: Scalar(angle.rawValueAsRadians), axis: axis.simd()), to: Self.self)
    }
    
    @inlinable
    var length: Scalar {
        return simd_length(self.simd())
    }
    
    @inlinable
    var squaredLength: Scalar {
        return simd_length_squared(self.simd())
    }
    
    @inlinable
    mutating func normalize() {
        guard self != .zero else { return }
        self = unsafeBitCast(simd_normalize(self.simd()), to: Self.self)
    }
}

#endif
