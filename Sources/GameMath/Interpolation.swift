/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

#if GameMathUseSIMD && canImport(simd)
import simd
#endif

public enum InterpolationMethod {
    /** Interpolates at a constant rate
     `factor` is progress of interpolation. 0 being the source and 1 being destination.
     `shortest` is true if the interpolation direction is the shortest physical distance, otherwise it's the scalar numerical distance. Usful for rotations.
     */
    case linear(_ factor: Float, shortest: Bool = true)
}

public extension Float {
    /// Interpolates toward `to` by using `method `
    @_transparent
    func interpolated(to: Float, _ method: InterpolationMethod) -> Float {
        switch method {
        case let .linear(factor, _):
            return self.lerped(to: to, factor: factor)
        }
    }
    
    /// Interpolates toward `to` by using `method `
    @_transparent
    mutating func interpolate(to: Float, _ method: InterpolationMethod) {
        switch method {
        case let .linear(factor, _):
            return self.lerp(to: to, factor: factor)
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
