/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension BinaryInteger {
    /// The representation of this integer as a padded binary string `00000101`
    var binaryString: String {
        let string = String(self, radix: 2)
        let padding = String(repeating: "0", count: self.bitWidth - string.count)
        return padding + string
    }
    
    /// The representation of this integer as a padded binary string `0b00000101`
    /// This is the same as `binaryString` but with a prefix `0b`
    var binaryDescription: String {
        return "0b" + binaryString
    }
}

public extension BinaryInteger {
    /// The representation of this integer as a padded hex string `00FF`
    var hexString: String {
        let string = String(self, radix: 16)
        let padding = String(repeating: "0", count: (MemoryLayout<Self>.size * 2) - string.count)
        return padding + string.uppercased()
    }
    
    /// The representation of this integer as a padded hex string `0x00FF`
    /// This is the same as `hesString` but with a prefix `0x`
    var hexDescription: String {
        return "0x" + hexString
    }
}
