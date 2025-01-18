/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Stores a pipeline state.
public struct D3DCachedPipelineState {
    public typealias RawValue = WinSDK.D3D12_CACHED_PIPELINE_STATE
    @usableFromInline
    internal var rawValue: RawValue

    /** Stores a pipeline state.
    - parameter cachedBlob: Specifies pointer that references the memory location of the cache.
    */
    @inlinable @inline(__always)
    public init(cachedBlob: D3DBlob) {
        let pCachedBlob = UnsafeRawPointer(cachedBlob.bufferPointer)
        let CachedBlobSizeInBytes = cachedBlob.bufferSize
        self.rawValue = RawValue(pCachedBlob: pCachedBlob, CachedBlobSizeInBytes: CachedBlobSizeInBytes)
    }

    /// Stores a pipeline state.
    @inlinable @inline(__always)
    public init() {
        self.rawValue = RawValue(pCachedBlob: nil, CachedBlobSizeInBytes: 0)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCachedPipelineState")
public typealias D3D12_CACHED_PIPELINE_STATE = D3DCachedPipelineState 

#endif
