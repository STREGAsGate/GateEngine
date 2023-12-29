/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes the index buffer to view.
public struct D3DIndexBufferView {
    public typealias RawValue = WinSDK.D3D12_INDEX_BUFFER_VIEW
    @usableFromInline
    internal var rawValue: RawValue

    /// The GPU virtual address of the index buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd synonym of UINT64.
    @inlinable @inline(__always)
    public var bufferLocation: D3DGPUVirtualAddress {
        get {
            return rawValue.BufferLocation
        }
        set {
            rawValue.BufferLocation = newValue
        }
    }

    /// The size in bytes of the index buffer.
    @inlinable @inline(__always)
    public var byteCount: UInt32 {
        get {
            return rawValue.SizeInBytes
        }
        set {
            rawValue.SizeInBytes = newValue
        }
    }

    /// A DXGI_FORMAT-typed value for the index-buffer format.
    @inlinable @inline(__always)
    public var format: DGIFormat {
        get {
            return DGIFormat(rawValue.Format)
        }
        set {
            rawValue.Format = newValue.rawValue
        }
    }

    /** Describes the index buffer to view.
    - parameter bufferLocation: The GPU virtual address of the index buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd synonym of UINT64.
    - parameter byteCount: The size in bytes of the index buffer.
    - parameter format: A DXGI_FORMAT-typed value for the index-buffer format.
    */
    @inlinable @inline(__always)
    public init(bufferLocation: D3DGPUVirtualAddress, byteCount: UInt32, format: DGIFormat) {
        self.rawValue = RawValue(BufferLocation: bufferLocation, SizeInBytes: byteCount, Format: format.rawValue)
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DIndexBufferView")
public typealias D3D12_INDEX_BUFFER_VIEW = D3DIndexBufferView

#endif
