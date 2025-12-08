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
public extension Vector3n where Scalar == Float16 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() + rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() - rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() + rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() - rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() * rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() * rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(-operand.simd(), to: Self.self)
    }
    
    @inlinable
    func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return simd_dot(self.simd(), vector.simd())
    }
    
    @inlinable
    func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar {
        return unsafeBitCast(simd_cross(self.simd(), vector.simd()), to: Self.self)
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
        self = unsafeBitCast(simd_fast_normalize(self.simd()), to: Self.self)
    }
}

// MARK: - Float32
public extension Vector3n where Scalar == Float32 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() + rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() - rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() + rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() - rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() * rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() * rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(-operand.simd(), to: Self.self)
    }
    
    @inlinable
    func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return simd_dot(self.simd(), vector.simd())
    }
    
    @inlinable
    func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar {
        return unsafeBitCast(simd_cross(self.simd(), vector.simd()), to: Self.self)
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
        self = unsafeBitCast(simd_fast_normalize(self.simd()), to: Self.self)
    }
}

// MARK: - Float64
public extension Vector3n where Scalar == Float64 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() + rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() - rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() + rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() - rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() * rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() * rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(-operand.simd(), to: Self.self)
    }
    
    @inlinable
    func dot<V: Vector3n>(_ vector: V) -> Scalar where V.Scalar == Scalar {
        return simd_dot(self.simd(), vector.simd())
    }
    
    @inlinable
    func cross<V: Vector3n>(_ vector: V) -> Self where V.Scalar == Scalar {
        return unsafeBitCast(simd_cross(self.simd(), vector.simd()), to: Self.self)
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
        self = unsafeBitCast(simd_fast_normalize(self.simd()), to: Self.self)
    }
}

// MARK: - Int8
public extension Vector3n where Scalar == Int8 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - Int16
public extension Vector3n where Scalar == Int16 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - Int32
public extension Vector3n where Scalar == Int32 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - Int64
public extension Vector3n where Scalar == Int64 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - UInt8
public extension Vector3n where Scalar == UInt8 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - UInt16
public extension Vector3n where Scalar == UInt16 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - UInt32
public extension Vector3n where Scalar == UInt32 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

// MARK: - UInt64
public extension Vector3n where Scalar == UInt64 {
    @_transparent
    @inlinable
    internal func simd() -> SIMD3<Scalar> {
        return unsafeBitCast(self, to: SIMD3<Scalar>.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func + (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &+ rhs, to: Self.self)
    }
    
    @inlinable
    static func - (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &- rhs, to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs.simd(), to: Self.self)
    }
    
    @inlinable
    static func * (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() &* rhs, to: Self.self)
    }
    
    @inlinable
    static func / (lhs: Self, rhs: some Vector3n<Scalar>) -> Self {
        return unsafeBitCast(lhs.simd() / rhs.simd(), to: Self.self)
    }

    @inlinable
    static func / (lhs: Self, rhs: Scalar) -> Self {
        return unsafeBitCast(lhs.simd() / rhs, to: Self.self)
    }
    
    @inlinable
    prefix static func - (operand: Self) -> Self {
        return unsafeBitCast(0 &- operand.simd(), to: Self.self)
    }
}

#endif
