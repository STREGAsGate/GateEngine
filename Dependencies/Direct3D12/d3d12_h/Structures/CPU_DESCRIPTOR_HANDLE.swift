/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a CPU descriptor handle.
public struct D3DCPUDescriptorHandle {
    public typealias RawValue = WinSDK.D3D12_CPU_DESCRIPTOR_HANDLE
    @usableFromInline
    internal var rawValue: RawValue

    /// The address of the descriptor.
    @inlinable @inline(__always)
    public var pointer: UInt64 {
        get {
            return rawValue.ptr
        }
        set {
            self.rawValue.ptr = newValue
        }
    }

    /** Describes a CPU descriptor handle.
    - parameter pointer: The address of the descriptor.
    */
    @inlinable @inline(__always)
    public init(pointer: UInt64) {
        self.rawValue = RawValue()
        self.pointer = pointer
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCPUDescriptorHandle")
public typealias D3D12_CPU_DESCRIPTOR_HANDLE = D3DCPUDescriptorHandle 

#endif
