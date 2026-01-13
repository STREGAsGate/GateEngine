/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension BinaryInteger {
    /// - returns: true is the value is divisible by 2
    var isEven: Bool {
        return (self & 1) == 0
    }
}
