/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes parameters needed to allocate resources.
public struct D3DResourceAllocationInfo {
    public typealias RawValue = WinSDK.D3D12_RESOURCE_ALLOCATION_INFO
    @usableFromInline
    internal var rawValue: RawValue

    /// The size, in bytes, of the resource.
    @inlinable @inline(__always)
    public var byteCount: UInt64 {
        get {
            return rawValue.SizeInBytes
        }
        set {
            rawValue.SizeInBytes = newValue
        }
    }

    /// The alignment value for the resource; one of 4KB (4096), 64KB (65536), or 4MB (4194304) alignment.
    @inlinable @inline(__always)
    public var alignment: UInt64 {
        get {
            return rawValue.Alignment
        }
        set {
            rawValue.Alignment = newValue
        }
    }
    
    /** Describes parameters needed to allocate resources.
    - parameter byteCount: The size, in bytes, of the resource.
    - parameter alignment: The alignment value for the resource; one of 4KB (4096), 64KB (65536), or 4MB (4194304) alignment.
    */
    @inlinable @inline(__always)
    public init(byteCount: UInt64, alignment: UInt64) {
        self.rawValue = RawValue(SizeInBytes: byteCount, Alignment: alignment)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DResourceAllocationInfo")
public typealias D3D12_RESOURCE_ALLOCATION_INFO = D3DResourceAllocationInfo

#endif
