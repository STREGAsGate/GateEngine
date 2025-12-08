/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@_transparent
@inlinable
public func abs<T>(_ x: T) -> T where T : Comparable, T : SignedNumeric {
    return Swift.abs(x)
}
