/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

struct ShaderError: Error, CustomStringConvertible {
    let description: String
    init(_ string: String) {
        self.description = string
    }
}
