/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the elements in a buffer to use in a unordered-access view.
public struct D3DUnorderedAccessViewBuffer {
    public typealias RawValue = WinSDK.D3D12_BUFFER_UAV
    @usableFromInline
    internal var rawValue: RawValue

    /// The zero-based index of the first element to be accessed.
    @inlinable @inline(__always)
    public var index: UInt64 {
        get {
            return rawValue.FirstElement
        }
        set {
            rawValue.FirstElement = newValue
        }
    }

    /// The number of elements in the resource. For structured buffers, this is the number of structures in the buffer.
    @inlinable @inline(__always)
    public var count: UInt32 {
        get {
            return rawValue.NumElements
        }
        set {
            rawValue.NumElements = newValue
        }
    }

    /// The size of each element in the buffer structure (in bytes) when the buffer represents a structured buffer.
    @inlinable @inline(__always)
    public var stride: UInt32 {
        get {
            return rawValue.StructureByteStride
        }
        set {
            rawValue.StructureByteStride = newValue
        }
    }

    /// The counter offset, in bytes.
    @inlinable @inline(__always)
    public var counterOffset: UInt64 {
        get {
            return rawValue.CounterOffsetInBytes
        }
        set {
            rawValue.CounterOffsetInBytes = newValue
        }
    }

    /// A D3D12_BUFFER_UAV_FLAGS-typed value that specifies the view options for the resource.
    @inlinable @inline(__always)
    public var flags: D3DBufferUnorderedAccessViewFlags {
        get {
            return D3DBufferUnorderedAccessViewFlags(rawValue.Flags)
        }
        set {
            rawValue.Flags = newValue.rawType
        }
    }

    /** Describes the elements in a buffer to use in a unordered-access view.
    - parameter index: The zero-based index of the first element to be accessed.
    - parameter count: The number of elements in the resource. For structured buffers, this is the number of structures in the buffer.
    - parameter stride: The size of each element in the buffer structure (in bytes) when the buffer represents a structured buffer.
    - parameter counterOffset: The counter offset, in bytes.
    - parameter flags: A D3D12_BUFFER_UAV_FLAGS-typed value that specifies the view options for the resource.
    */
    @inlinable @inline(__always)
    public init(index: UInt64, count: UInt32, stride: UInt32, counterOffset: UInt64, flags: D3DBufferUnorderedAccessViewFlags) {
        self.rawValue = RawValue(FirstElement: index, NumElements: count, StructureByteStride: stride, CounterOffsetInBytes: counterOffset, Flags: flags.rawType)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DUnorderedAccessViewBuffer")
public typealias D3D12_BUFFER_UAV = D3DUnorderedAccessViewBuffer 

#endif
