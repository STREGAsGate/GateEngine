/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Set {
    @_transparent
    init(minimumCapacity: Int) {
        self = []
        self.reserveCapacity(minimumCapacity)
    }
}
