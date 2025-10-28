/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GateUtilities

public protocol BinaryCoder: BinaryEncoder & BinaryDecoder where CodableType: BinaryCodable { }

public protocol BinaryEncoder {
    associatedtype CodableType: BinaryCodable
    func encode(_ value: CodableType) throws(GateEngineError) -> Data
}

public protocol BinaryDecoder {
    associatedtype CodableType: BinaryCodable
    func decode(_ data: Data) throws(GateEngineError) -> CodableType
}
