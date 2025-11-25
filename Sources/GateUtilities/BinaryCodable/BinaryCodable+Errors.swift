/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

enum BinaryCodableError: Swift.Error {
    case failedToDecode(_ description: String)
    case failedToEncode(_ description: String)
}
