/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

// Accuracy appropriate for simd_fast_normalize results

public extension Float16 {
    static let accuracy: Self = 0.005
}

public extension Float32 {
    static let accuracy: Self = 0.00005
}

public extension Float64 {
    static let accuracy: Self = 0.0000005
}
