/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension BinaryInteger {
    /// The representation of this integer as a padded binary string `0b00000101`
    var binaryDescription: String {
        let string = String(self, radix: 2)
        let padding = String(repeating: "0", count: self.bitWidth - string.count)
        return "0b" + padding + string
    }
    
    /// The representation of this integer as a padded hex string `0x00FF`
    var hexDescription: String {
        let string = String(self, radix: 16)
        let padding = String(repeating: "0", count: (MemoryLayout<Self>.size * 2) - string.count)
        return "0x" + padding + string.uppercased()
    }
}
