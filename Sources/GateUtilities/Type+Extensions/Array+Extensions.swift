/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Array {
    @_transparent
    init(minimumCapacity: Int) {
        self = []
        self.reserveCapacity(minimumCapacity)
    }
}
