/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes heap properties.
public struct D3DHeapProperties {
    public typealias RawValue = WinSDK.D3D12_HEAP_PROPERTIES
    @usableFromInline
    internal var rawValue: RawValue

    /// A D3D12_HEAP_TYPE-typed value that specifies the type of heap.
    @inlinable @inline(__always)
    public var `type`: D3DHeapType {
        get {
            return D3DHeapType(rawValue.Type)
        }
        set {
            rawValue.Type = newValue.rawValue
        }
    }

    /// A D3D12_CPU_PAGE_PROPERTY-typed value that specifies the CPU-page properties for the heap.
    @inlinable @inline(__always)
    public var cpuPageProperty: D3DCPUPageProperty {
        get {
            return D3DCPUPageProperty(rawValue.CPUPageProperty)
        }
        set {
            rawValue.CPUPageProperty = newValue.rawValue
        }
    }

    /// A D3D12_MEMORY_POOL-typed value that specifies the memory pool for the heap.
    @inlinable @inline(__always)
    public var memoryPoolPreference: D3DMemoryPool {
        get {
            return D3DMemoryPool(rawValue.MemoryPoolPreference)
        }
        set {
            rawValue.MemoryPoolPreference = newValue.rawValue
        }
    }

    /**
        For multi-adapter operation, this indicates the node where the resource should be created.

        Exactly one bit of this UINT must be set. See Multi-adapter systems.

        Passing zero is equivalent to passing one, in order to simplify the usage of single-GPU adapters.
    */
    @inlinable @inline(__always)
    public var multiAdapterCreationNodeMask: UInt32 {
        get {
            return rawValue.CreationNodeMask
        }
        set {
            rawValue.CreationNodeMask = newValue
        }
    }

    /**
        For multi-adapter operation, this indicates the set of nodes where the resource is visible.

        VisibleNodeMask must have the same bit set that is set in CreationNodeMask. VisibleNodeMask can also have additional bits set for cross-node resources, but doing so can potentially reduce performance for resource accesses, so you should do so only when needed.

        Passing zero is equivalent to passing one, in order to simplify the usage of single-GPU adapters.
    */
    @inlinable @inline(__always)
    public var multiAdapterVisibleNodeMask: UInt32 {
        get {
            return rawValue.VisibleNodeMask
        }
        set {
            rawValue.VisibleNodeMask = newValue
        }
    }

    /** Describes heap properties.
    - parameter type: A D3D12_HEAP_TYPE-typed value that specifies the type of heap.
    - parameter cpuPageProperty: A D3D12_CPU_PAGE_PROPERTY-typed value that specifies the CPU-page properties for the heap.
    - parameter memoryPoolPreference: A D3D12_MEMORY_POOL-typed value that specifies the memory pool for the heap.
    - parameter creationNodeMask: Passing zero is equivalent to passing one, in order to simplify the usage of single-GPU adapters.
    - parameter visibleNodeMask: Passing zero is equivalent to passing one, in order to simplify the usage of single-GPU adapters.
    */
    @inlinable @inline(__always)
    public init(type: D3DHeapType,
                cpuPageProperty: D3DCPUPageProperty = .unknown,
                memoryPoolPreference: D3DMemoryPool = .unknown,
                multiAdapterCreationNodeMask: UInt32 = 1,
                visibleNodeMask: UInt32 = 1) {
        self.rawValue = RawValue(Type: type.rawValue, 
                                 CPUPageProperty: cpuPageProperty.rawValue, 
                                 MemoryPoolPreference: memoryPoolPreference.rawValue, 
                                 CreationNodeMask: multiAdapterCreationNodeMask, 
                                 VisibleNodeMask: visibleNodeMask)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    @inlinable @inline(__always)
    public static var forBuffer: D3DHeapProperties {
        return D3DHeapProperties(type: .upload, cpuPageProperty: .unknown, memoryPoolPreference: .unknown)
    }

    @inlinable @inline(__always)
    public static var forTexture: D3DHeapProperties {D3DHeapProperties(type: .default)}
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DHeapProperties")
public typealias D3D12_HEAP_PROPERTIES = D3DHeapProperties

#endif
