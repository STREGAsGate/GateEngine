/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the type of heap. When resident, heaps reside in a particular physical memory pool with certain CPU cache properties.
public enum D3DHeapType {
    public typealias RawValue = WinSDK.D3D12_HEAP_TYPE
    /**	Specifies the default heap.
    This heap type experiences the most bandwidth for the GPU, but cannot provide CPU access.
    The GPU can read and write to the memory from this pool, and resource transition barriers may be changed.
    The majority of heaps and resources are expected to be located here, and are typically populated through resources in upload heaps.
    */
    case `default`
    /**
    Specifies a heap used for uploading.
    This heap type has CPU access optimized for uploading to the GPU, but does not experience the maximum amount of bandwidth for the GPU.
    This heap type is best for CPU-write-once, GPU-read-once data; but GPU-read-once is stricter than necessary.
    GPU-read-once-or-from-cache is an acceptable use-case for the data; but such usages are hard to judge due to differing GPU cache designs and sizes.
    If in doubt, stick to the GPU-read-once definition or profile the difference on many GPUs between copying the data to a _DEFAULT heap vs. reading the data from an _UPLOAD heap.

    Resources in this heap must be created with D3D12_RESOURCE_STATE_GENERIC_READ and cannot be changed away from this.
    The CPU address for such heaps is commonly not efficient for CPU reads.

    The following are typical usages for _UPLOAD heaps:
    * Initializing resources in a _DEFAULT heap with data from the CPU.
    * Uploading dynamic data in a constant buffer that is read, repeatedly, by each vertex or pixel.

    The following are likely not good usages for _UPLOAD heaps:
    * Re-initializing the contents of a resource every frame.
    * Uploading constant data which is only used every other Draw call, where each Draw uses a non-trivial amount of other data.
    */
    case upload
    /**
    Specifies a heap used for reading back.
    This heap type has CPU access optimized for reading data back from the GPU, but does not experience the maximum amount of bandwidth for the GPU.
    This heap type is best for GPU-write-once, CPU-readable data.
    The CPU cache behavior is write-back, which is conducive for multiple sub-cache-line CPU reads.

    Resources in this heap must be created with D3D12_RESOURCE_STATE_COPY_DEST, and cannot be changed away from this.
    */
    case readBack
    /**
    Specifies a custom heap.
    The application may specify the memory pool and CPU cache properties directly, which can be useful for UMA optimizations, multi-engine, multi-adapter, or other special cases.
    To do so, the application is expected to understand the adapter architecture to make the right choice.
    For more details, see D3D12_FEATURE_ARCHITECTURE, D3D12_FEATURE_DATA_ARCHITECTURE, and GetCustomHeapProperties.
    */
    case custom

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .default:
            return WinSDK.D3D12_HEAP_TYPE_DEFAULT
        case .upload:
            return WinSDK.D3D12_HEAP_TYPE_UPLOAD
        case .readBack:
            return WinSDK.D3D12_HEAP_TYPE_READBACK
        case .custom:
            return WinSDK.D3D12_HEAP_TYPE_CUSTOM
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_HEAP_TYPE_DEFAULT:
            self = .default
        case WinSDK.D3D12_HEAP_TYPE_UPLOAD:
            self = .upload
        case WinSDK.D3D12_HEAP_TYPE_READBACK:
            self = .readBack
        case WinSDK.D3D12_HEAP_TYPE_CUSTOM:
            self = .custom
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DHeapType")
public typealias D3D12_HEAP_TYPE = D3DHeapType


@available(*, deprecated, renamed: "D3DHeapType.default")
public let D3D12_HEAP_TYPE_DEFAULT = D3DHeapType.default

@available(*, deprecated, renamed: "D3DHeapType.upload")
public let D3D12_HEAP_TYPE_UPLOAD = D3DHeapType.upload

@available(*, deprecated, renamed: "D3DHeapType.readBack")
public let D3D12_HEAP_TYPE_READBACK = D3DHeapType.readBack

@available(*, deprecated, renamed: "D3DHeapType.custom")
public let D3D12_HEAP_TYPE_CUSTOM = D3DHeapType.custom

#endif
