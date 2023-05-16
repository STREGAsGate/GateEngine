/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DVertexBufferView {
    public typealias RawValue = WinSDK.D3D12_VERTEX_BUFFER_VIEW
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

    /// Specifies the size in bytes of each vertex entry.
    @inlinable @inline(__always)
    public var byteStride: UInt32 {
        get {
            return rawValue.StrideInBytes
        }
        set {
            rawValue.StrideInBytes = newValue
        }
    }

    /** Describes a vertex buffer view.
    - parameter bufferLocation: The GPU virtual address of the index buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd synonym of UINT64.
    - parameter byteCount: The size in bytes of the index buffer.
    - parameter format: Specifies the size in bytes of each vertex entry.
    */
    @inlinable @inline(__always)
    public init(bufferLocation: D3DGPUVirtualAddress, byteCount: UInt32, byteStride: UInt32) {
        self.rawValue = RawValue()
        self.bufferLocation = bufferLocation
        self.byteCount = byteCount
        self.byteStride = byteStride
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DVertexBufferView")
public typealias D3D12_VERTEX_BUFFER_VIEW = D3DVertexBufferView

#endif
