/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
public import simd
#endif

public struct InterpolationOptions: OptionSet, Sendable {
    public typealias RawValue = UInt
    public let rawValue: RawValue
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    /// Uses the shortest path. This will cause a quaternion to rotate using the shortest angle to the destination.
    public static let shortest = InterpolationOptions(rawValue: 1 << 1)
}

public enum InterpolationMethod {
    /**
     Interpolates at a constant rate
     
     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case linear(_ factor: Float)
    
    /**
     Interpolates with acceleration increasing near the destinartion

     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case easeIn(_ factor: Float)
    
    /**
     Interpolates with acceleration increasing near the beginning

     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case easeOut(_ factor: Float)
    
    /**
     Interpolates with acceleration increasing near the beginning, and then again at the end

     - parameter factor: The progress of interpolation. 0 being the source and 1 being destination.
     */
    case easeInOut(_ factor: Float)
}

public extension Float {
    /// Interpolates toward `to` by using `method `
    @inlinable
    func interpolated(to: Float, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) -> Float {
        switch method {
        case .linear(let factor):
            return self.lerped(to: to, factor: factor)
        case .easeIn(let factor):
            return self.easedIn(to: to, factor: factor)
        case .easeOut(let factor):
            return self.easedOut(to: to, factor: factor)
        case .easeInOut(let factor):
            return self.easedInOut(to: to, factor: factor)
        }
    }
    
    /// Interpolates toward `to` by using `method `
    @inlinable
    mutating func interpolate(to: Float, _ method: InterpolationMethod, options: InterpolationOptions = .shortest) {
        switch method {
        case .linear(let factor):
            return self.lerp(to: to, factor: factor)
        case .easeIn(let factor):
            return self.easeIn(to: to, factor: factor)
        case .easeOut(let factor):
            return self.easeOut(to: to, factor: factor)
        case .easeInOut(let factor):
            return self.easeInOut(to: to, factor: factor)
        }
    }
}

internal extension Float {
    @inlinable
    func lerped(to: Float, factor: Float) -> Float {
        #if GameMathUseSIMD && canImport(simd)
        return simd_mix(self, to, factor)
        #else
        return self + (to - self) * factor
        #endif
    }
    
    @inlinable
    mutating func lerp(to: Float, factor: Float) {
        self = self.lerped(to: to, factor: factor)
    }
}

internal extension Float {
    @inlinable
    func easedIn(to: Float, factor: Float) -> Float {
        let easeInFactor = 1 - cos((factor * .pi) / 2)
        return self.lerped(to: to, factor: easeInFactor)
    }
    
    @inlinable
    mutating func easeIn(to: Float, factor: Float) {
        self = self.easedIn(to: to, factor: factor)
    }
}

internal extension Float {
    @inlinable
    func easedOut(to: Float, factor: Float) -> Float {
        let easeOutFactor = sin((factor * .pi) / 2)
        return self.lerped(to: to, factor: easeOutFactor)
    }
    
    @inlinable
    mutating func easeOut(to: Float, factor: Float) {
        self = self.easedOut(to: to, factor: factor)
    }
}

internal extension Float {
    @inlinable
    func easedInOut(to: Float, factor: Float) -> Float {
        let easeInOutFactor = -(cos(.pi * factor) - 1) / 2
        return self.lerped(to: to, factor: easeInOutFactor)
    }
    
    @inlinable
    mutating func easeInOut(to: Float, factor: Float) {
        self = self.easedInOut(to: to, factor: factor)
    }
}
