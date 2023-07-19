/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
import simd
#endif

public struct InterpolationOptions: OptionSet {
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
     
     - parameter factor: is progress of interpolation. 0 being the source and 1 being destination.
     - parameter options: Options for processing the interpolation.
     */
    case linear(_ factor: Float, options: InterpolationOptions = [.shortest])
    
    /**
     Interpolates with acceleration increasing near the destinartion

     - parameter factor: is progress of interpolation. 0 being the source and 1 being destination.
     - parameter options: Options for processing the interpolation.
     */
    case easeIn(_ factor: Float, options: InterpolationOptions = [.shortest])
}

public extension Float {
    /// Interpolates toward `to` by using `method `
    @_transparent
    func interpolated(to: Float, _ method: InterpolationMethod) -> Float {
        switch method {
        case let .linear(factor, _):
            return self.lerped(to: to, factor: factor)
        case let .easeIn(factor, _):
            return self.easedIn(to: to, factor: factor)
        }
    }
    
    /// Interpolates toward `to` by using `method `
    @_transparent
    mutating func interpolate(to: Float, _ method: InterpolationMethod) {
        switch method {
        case let .linear(factor, _):
            return self.lerp(to: to, factor: factor)
        case let .easeIn(factor, _):
            return self.easeIn(to: to, factor: factor)
        }
    }
}

internal extension Float {
    @usableFromInline @_transparent
    func lerped(to: Float, factor: Float) -> Float {
        #if GameMathUseSIMD && canImport(simd)
        return simd_mix(self, to, factor)
        #else
        return self + (to - self) * factor
        #endif
    }
    
    @usableFromInline @_transparent
    mutating func lerp(to: Float, factor: Float) {
        self = self.lerped(to: to, factor: factor)
    }
}

internal extension Float {
    @usableFromInline @_transparent
    func easedIn(to: Float, factor: Float) -> Float {
        return 1 - cos((factor * .pi) / 2)
    }
    
    @usableFromInline @_transparent
    mutating func easeIn(to: Float, factor: Float) {
        self = self.easedIn(to: to, factor: factor)
    }
}
