/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct InterpolationOptions: OptionSet, Sendable {
    public typealias RawValue = UInt8
    public let rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    /// Uses the shortest path. This will cause a quaternion to rotate using the shortest angle to the destination.
    public static let shortest = InterpolationOptions(rawValue: 1 << 0)
}

public enum InterpolationMethod<T: BinaryFloatingPoint> {
    /**
     Interpolates at a constant rate
     
     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case linear(_ factor: T)
    
    /**
     Interpolates with acceleration increasing near the destinartion
     
     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case easeIn(_ factor: T)
    
    /**
     Interpolates with acceleration increasing near the beginning
     
     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case easeOut(_ factor: T)
    
    /**
     Interpolates with acceleration increasing near the beginning, and then again at the end
     
     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case easeInOut(_ factor: T)
}


public protocol Interpolatable {
    associatedtype Factor: BinaryFloatingPoint
    
    func interpolated(to rhs: Self, _ method: InterpolationMethod<Factor>, options: InterpolationOptions) -> Self
    
    func lerped(to rhs: Self, factor: Factor) -> Self
        
    func easedIn(to rhs: Self, factor: Factor) -> Self
    
    func easedOut(to rhs: Self, factor: Factor) -> Self
    
    func easedInOut(to rhs: Self, factor: Factor) -> Self
    
    
    mutating func interpolate(to rhs: Self, _ method: InterpolationMethod<Factor>, options: InterpolationOptions)
    
    mutating func lerp(to rhs: Self, factor: Factor)
        
    mutating func easeIn(to rhs: Self, factor: Factor)
    
    mutating func easeOut(to rhs: Self, factor: Factor)
    
    mutating func easeInOut(to rhs: Self, factor: Factor)
}

public protocol SphericalInterpolatable: Interpolatable {
    func slerped(to rhs: Self, factor: Factor) -> Self
    
    mutating func slerp(to rhs: Self, factor: Factor)
}

public extension Interpolatable {
    /// Interpolates toward `to` by using `method `
    @inlinable
    func interpolated(to rhs: Self, _ method: InterpolationMethod<Factor>, options: InterpolationOptions = .shortest) -> Self {
        switch method {
        case .linear(let factor):
            return self.lerped(to: rhs, factor: factor)
        case .easeIn(let factor):
            return self.easedIn(to: rhs, factor: factor)
        case .easeOut(let factor):
            return self.easedOut(to: rhs, factor: factor)
        case .easeInOut(let factor):
            return self.easedInOut(to: rhs, factor: factor)
        }
    }
    
    /// Interpolates toward `to` by using `method `
    @inlinable
    mutating func interpolate(to rhs: Self, _ method: InterpolationMethod<Factor>, options: InterpolationOptions = .shortest) {
        switch method {
        case .linear(let factor):
            self.lerp(to: rhs, factor: factor)
        case .easeIn(let factor):
            self.easeIn(to: rhs, factor: factor)
        case .easeOut(let factor):
            self.easeOut(to: rhs, factor: factor)
        case .easeInOut(let factor):
            self.easeInOut(to: rhs, factor: factor)
        }
    }
    
    @inlinable
    mutating func lerp(to rhs: Self, factor: Factor) {
        self = self.lerped(to: rhs, factor: factor)
    }
    
    @inlinable
    mutating func easeIn(to rhs: Self, factor: Factor) {
        self = self.easedIn(to: rhs, factor: factor)
    }
    
    @inlinable
    mutating func easeOut(to rhs: Self, factor: Factor) {
        self = self.easedOut(to: rhs, factor: factor)
    }
    
    @inlinable
    mutating func easeInOut(to rhs: Self, factor: Factor) {
        self = self.easedInOut(to: rhs, factor: factor)
    }
}

#if GameMathUseSIMD && canImport(simd)
public import simd

public extension Float16 {
    @inlinable
    func lerped(to rhs: Self, factor: Self) -> Self {
        return simd_mix(self, rhs, factor)
    }
}

public extension Float32 {
    @inlinable
    func lerped(to rhs: Self, factor: Self) -> Self {
        return simd_mix(self, rhs, factor)
    }
}

public extension Float64 {
    @inlinable
    func lerped(to rhs: Self, factor: Self) -> Self {
        return simd_mix(self, rhs, factor)
    }
}
#endif

extension Float16: Interpolatable {
    public typealias Factor = Self
}
extension Float32: Interpolatable {
    public typealias Factor = Self
}
extension Float64: Interpolatable {
    public typealias Factor = Self
}

extension BinaryFloatingPoint where Self: Interpolatable, Factor == Self {
    @inlinable
    public func lerped(to rhs: Self, factor: Factor) -> Self {
        return self + (rhs - self) * factor
    }
    
    @inlinable
    public func easedIn(to rhs: Self, factor: Factor) -> Self {
        let easeInFactor: Self = 1.0 - cos((factor * Self.pi) * 0.5)
        return self.lerped(to: rhs, factor: easeInFactor)
    }
    
    @inlinable
    public func easedOut(to rhs: Self, factor: Factor) -> Self {
        let easeOutFactor: Self = sin((factor * Self.pi) * 0.5)
        return self.lerped(to: rhs, factor: easeOutFactor)
    }
    
    @inlinable
    public func easedInOut(to rhs: Self, factor: Factor) -> Self {
        let easeInOutFactor: Self = -(cos(Self.pi * factor) - 1) * 0.5
        return self.lerped(to: rhs, factor: easeInOutFactor)
    }
}
