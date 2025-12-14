/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
public import simd
#if canImport(Accelerate)
public import Accelerate
#endif

// MARK: - Float16
#if !((os(macOS) || targetEnvironment(macCatalyst)) && arch(x86_64))
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
public extension Vector3n where Scalar == Float16 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_half3 {
        return unsafeBitCast(self, to: simd_half3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() + rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() - rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() + rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() - rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() * rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() * rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(-operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return simd_dot(self.simd(), vector.simd())
    }
    
    @inlinable @_transparent
    func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar {
        return unsafeBitCast(simd_cross(self.simd(), vector.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    var length: Scalar {
        return simd_length(self.simd())
    }
    
    @inlinable @_transparent
    var squaredLength: Scalar {
        return simd_length_squared(self.simd())
    }
    
    @inlinable @_transparent
    mutating func normalize() {
        guard self != .zero else { return }
        self = unsafeBitCast(simd_normalize(self.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    func squareRoot() -> Self {
        return unsafeBitCast(self.simd().squareRoot(), to: Self.self)
    }
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Float16 {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}
#endif

// MARK: - Float32
public extension Vector3n where Scalar == Float32 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_float3 {
        return unsafeBitCast(self, to: simd_float3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() + rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() - rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() + rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() - rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() * rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() * rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(-operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return simd_dot(self.simd(), vector.simd())
    }
    
    @inlinable @_transparent
    func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar {
        return unsafeBitCast(simd_cross(self.simd(), vector.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    var length: Scalar {
        return simd_reduce_add(self.simd())
    }
    
    @inlinable @_transparent
    var squaredLength: Scalar {
        return simd_length_squared(self.simd())
    }
    
    @inlinable @_transparent
    var magnitude: Scalar {
        return simd_length(self.simd())
    }
    
    @inlinable @_transparent
    mutating func normalize() {
        guard self != .zero else { return }
        self = unsafeBitCast(simd_normalize(self.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
    
    @inlinable
    func squareRoot() -> Self {
        #if canImport(Accelerate)
        let arg = unsafeBitCast(self, to: Vector3nAccelerateBuffer<Scalar>.self)
        var buffer = arg
        vForce.sqrt(arg, result: &buffer)
        return unsafeBitCast(buffer, to: Self.self)
        #else
        return unsafeBitCast(self.simd().squareRoot(), to: Self.self)
        #endif
    }
    
    #if canImport(Accelerate)
    @inlinable
    func truncatingRemainder(dividingBy divisors: some Vector3n<Scalar>) -> Self {
        let divisors = unsafeBitCast(divisors, to: Vector3nAccelerateBuffer<Scalar>.self)
        var buffer = unsafeBitCast(self, to: Vector3nAccelerateBuffer<Scalar>.self)
        vForce.truncatingRemainder(dividends: buffer, divisors: divisors, result: &buffer)
        return unsafeBitCast(buffer, to: Self.self)
    }
    #endif
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Float32 {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}

// MARK: - Float64
public extension Vector3n where Scalar == Float64 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_double3 {
        return unsafeBitCast(self, to: simd_double3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() + rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() - rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() + rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() - rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() * rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() * rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(-operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return simd_dot(self.simd(), vector.simd())
    }
    
    @inlinable @_transparent
    func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar {
        return unsafeBitCast(simd_cross(self.simd(), vector.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    var length: Scalar {
        return simd_reduce_add(self.simd())
    }
    
    @inlinable @_transparent
    var squaredLength: Scalar {
        return simd_length_squared(self.simd())
    }
    
    @inlinable @_transparent
    var magnitude: Scalar {
        return simd_length(self.simd())
    }
    
    @inlinable @_transparent
    mutating func normalize() {
        guard self != .zero else { return }
        self = unsafeBitCast(simd_normalize(self.simd()), to: Self.self)
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
    
    @inlinable
    func squareRoot() -> Self {
        #if canImport(Accelerate)
        let arg = unsafeBitCast(self, to: Vector3nAccelerateBuffer<Scalar>.self)
        var buffer = arg
        vForce.sqrt(arg, result: &buffer)
        return unsafeBitCast(buffer, to: Self.self)
        #else
        return unsafeBitCast(self.simd().squareRoot(), to: Self.self)
        #endif
    }
    
    #if canImport(Accelerate)
    @inlinable
    func truncatingRemainder(dividingBy divisors: some Vector3n<Scalar>) -> Self {
        let divisors = unsafeBitCast(divisors, to: Vector3nAccelerateBuffer<Scalar>.self)
        var buffer = unsafeBitCast(self, to: Vector3nAccelerateBuffer<Scalar>.self)
        vForce.truncatingRemainder(dividends: buffer, divisors: divisors, result: &buffer)
        return unsafeBitCast(buffer, to: Self.self)
    }
    #endif
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Float64 {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}

// MARK: - Int8
public extension Vector3n where Scalar == Int8 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_char3 {
        return unsafeBitCast(self, to: simd_char3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Int8 {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}

// MARK: - Int16
public extension Vector3n where Scalar == Int16 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_short3 {
        return unsafeBitCast(self, to: simd_short3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Int16 {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}

// MARK: - Int32
public extension Vector3n where Scalar == Int32 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_int3 {
        return unsafeBitCast(self, to: simd_int3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Int32 {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}

// MARK: - Int64
public extension Vector3n where Scalar == Int64 {
    @inlinable @_transparent
    internal func simd() -> SIMD3<Int64> {
        return unsafeBitCast(self, to: SIMD3<Int64>.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        // No simd implementation for simd_equal. Use Swift as a fallback incase it's optimized in the future
        return lhs.simd() == rhs.simd()
    }
    
    @inlinable @_transparent
    var min: Scalar {
        // No simd implementation for simd_reduce_min. Use Swift as a fallback incase it's optimized in the future
        return self.simd().min()
    }
    
    @inlinable @_transparent
    var max: Scalar {
        // No simd implementation for simd_reduce_max. Use Swift as a fallback incase it's optimized in the future
        return self.simd().max()
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        // No simd implementation for simd_clamp. Use Swift as a fallback incase it's optimized in the future
        return unsafeBitCast(self.simd().clamped(lowerBound: lowerBound.simd(), upperBound: upperBound.simd()), to: Self.self)
    }
}

// MARK: - Int
public extension Vector3n where Scalar == Int {
    @inlinable @_transparent
    internal func simd() -> simd.simd_long3 {
        return unsafeBitCast(self, to: simd_long3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

@inlinable @_transparent
public func abs<T: Vector3n>(_ vector: T) -> T where T.Scalar == Int {
    return unsafeBitCast(simd_abs(vector.simd()), to: T.self)
}

// MARK: - UInt8
public extension Vector3n where Scalar == UInt8 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_uchar3 {
        return unsafeBitCast(self, to: simd_uchar3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

// MARK: - UInt16
public extension Vector3n where Scalar == UInt16 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_ushort3 {
        return unsafeBitCast(self, to: simd_ushort3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

// MARK: - UInt32
public extension Vector3n where Scalar == UInt32 {
    @inlinable @_transparent
    internal func simd() -> simd.simd_uint3 {
        return unsafeBitCast(self, to: simd_uint3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

// MARK: - UInt64
public extension Vector3n where Scalar == UInt64 {
    @inlinable @_transparent
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        // No simd implementation for simd_equal. Use Swift as a fallback incase it's optimized in the future
        return lhs.simd() == rhs.simd()
    }
    
    @inlinable @_transparent
    var min: Scalar {
        // No simd implementation for simd_reduce_min. Use Swift as a fallback incase it's optimized in the future
        return self.simd().min()
    }
    
    @inlinable @_transparent
    var max: Scalar {
        // No simd implementation for simd_reduce_max. Use Swift as a fallback incase it's optimized in the future
        return self.simd().max()
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        // No simd implementation for simd_clamp. Use Swift as a fallback incase it's optimized in the future
        return unsafeBitCast(self.simd().clamped(lowerBound: lowerBound.simd(), upperBound: upperBound.simd()), to: Self.self)
    }
}

// MARK: - UInt
public extension Vector3n where Scalar == UInt {
    @inlinable @_transparent
    internal func simd() -> simd.simd_ulong3 {
        return unsafeBitCast(self, to: simd_ulong3.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable @_transparent
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable @_transparent
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
    
    @inlinable @_transparent
    static func == (lhs: Self, rhs: Self) -> Bool {
        return simd_equal(lhs.simd(), rhs.simd())
    }
    
    @inlinable @_transparent
    var min: Scalar {
        return simd_reduce_min(self.simd())
    }
    
    @inlinable @_transparent
    var max: Scalar {
        return simd_reduce_max(self.simd())
    }
    
    @inlinable @_transparent
    func clamped(from lowerBound: Self, to upperBound: Self) -> Self {
        return unsafeBitCast(simd_clamp(self.simd(), lowerBound.simd(), upperBound.simd()), to: Self.self)
    }
}

#endif
