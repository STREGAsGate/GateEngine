/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK
import struct Foundation.Data
public struct D3DMessage: Swift.Error, CustomStringConvertible {
    public typealias RawValue = WinSDK.D3D12_MESSAGE
    internal var rawValue: RawValue

    @inlinable @inline(__always)
    public var description: String {
        let buffer: UnsafeRawBufferPointer = UnsafeRawBufferPointer(start: rawValue.pDescription, count: Int(rawValue.DescriptionByteLength))
        return String(bytes: buffer, encoding: .utf8) ?? String(bytes: buffer, encoding: .ascii) ?? String(cString: rawValue.pDescription)
    }

    @inlinable @inline(__always)
    public var sevarity: D3DMessageSeverity {
        return D3DMessageSeverity(rawValue: rawValue.Severity)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}
