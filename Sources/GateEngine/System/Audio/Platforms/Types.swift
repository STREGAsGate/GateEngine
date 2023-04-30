/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

internal enum Endianness {
    case native
    case little
    case big
}

internal struct BufferCapabilities {
    var interlieved: Bool
    var noninterlieved: Bool
}
