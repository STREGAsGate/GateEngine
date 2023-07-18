/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies heap options, such as whether the heap can contain textures, and whether resources are shared across adapters.
public struct D3DHeapFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_HEAP_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_HEAP_FLAGS.RawValue
    public let rawValue: RawValue
    //Use an empty collection `[]` to represent none in Swift.
    ///// No options are specified.
    //public static let none = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_NONE.rawValue)

    ///	The heap is shared. Refer to Shared Heaps.
    public static let shared = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_SHARED.rawValue)
    ///	The heap isn't allowed to contain buffers.
    public static let denyBuffers = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_DENY_BUFFERS.rawValue)
    ///	The heap is allowed to contain swap-chain surfaces.
    public static let allowDisplay = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_DISPLAY.rawValue)
    ///	The heap is allowed to share resources across adapters. Refer to Shared Heaps.
    public static let sharedAcrossAdapter = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_SHARED_CROSS_ADAPTER.rawValue)
    ///	The heap is not allowed to store Render Target (RT) and/or Depth-Stencil (DS) textures.
    public static let denyRenderTargetAndDepthStencilTextures = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_DENY_RT_DS_TEXTURES.rawValue)
    ///	The heap is not allowed to contain resources with D3D12_RESOURCE_DIMENSION_TEXTURE1D, D3D12_RESOURCE_DIMENSION_TEXTURE2D, or D3D12_RESOURCE_DIMENSION_TEXTURE3D unless either D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET or D3D12_RESOURCE_FLAG_ALLOW_DEPTH_STENCIL are present. Refer to D3D12_RESOURCE_DIMENSION and D3D12_RESOURCE_FLAGS.
    public static let denyNonRenderTargetAndDepthStencilTextures = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_DENY_NON_RT_DS_TEXTURES.rawValue)
    ///	Unsupported. Do not use.
    public static let hardwareProtected = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_HARDWARE_PROTECTED.rawValue)
    ///	The heap supports MEM_WRITE_WATCH functionality, which causes the system to track the pages that are written to in the committed memory region. This flag can't be combined with the D3D12_HEAP_TYPE_DEFAULT or D3D12_CPU_PAGE_PROPERTY_UNKNOWN flags. Applications are discouraged from using this flag themselves because it prevents tools from using this functionality.
    public static let allowWriteWatch = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_WRITE_WATCH.rawValue)
    /**	
    Ensures that atomic operations will be atomic on this heap's memory, according to components able to see the memory.

    Creating a heap with this flag will fail under either of these conditions.
    - The heap type is D3D12_HEAP_TYPE_DEFAULT, and the heap can be visible on multiple nodes, but the device does not support D3D12_CROSS_NODE_SHARING_TIER_3.
    - The heap is CPU-visible, but the heap type is not D3D12_HEAP_TYPE_CUSTOM.

    - Note: that heaps with this flag might be a limited resource on some systems.
    */
    public static let allowShaderAtomics = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_SHADER_ATOMICS.rawValue)
    ///	The heap is created in a non-resident state and must be made resident using ID3D12Device::MakeResident or ID3D12Device3::EnqueueMakeResident.
    /// By default, the final step of heap creation is to make the heap resident, so this flag skips this step and allows the application to decide when to do so.
    public static let createNotResident = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_CREATE_NOT_RESIDENT.rawValue)
    ///	Allows the OS to not zero the heap created. By default, committed resources and heaps are almost always zeroed upon creation. This flag allows this to be elided in some scenarios. However, it doesn't guarantee it. For example, memory coming from other processes still needs to be zeroed for data protection and process isolation. This can lower the overhead of creating the heap.
    public static let createNotZeroed = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_CREATE_NOT_ZEROED.rawValue)
    ///	The heap is allowed to store all types of buffers and/or textures. This is an alias; for more details, see "Aliases" in the Remarks section.
    public static let allowAllBuffersAndTextures = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_ALL_BUFFERS_AND_TEXTURES.rawValue)
    ///	The heap is only allowed to store buffers. This is an alias; for more details, see "Aliases" in the Remarks section.
    public static let allowOnlyBuffers = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_ONLY_BUFFERS.rawValue)
    ///	The heap is only allowed to store non-RT, non-DS textures. This is an alias; for more details, see "Aliases" in the Remarks section.
    public static let allowOnlyNonRenderTargetOrDepthStencilTextures = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_ONLY_NON_RT_DS_TEXTURES.rawValue)
    ///	The heap is only allowed to store RT and/or DS textures. This is an alias; for more details, see "Aliases" in the Remarks section.
    public static let allowOnlyRenderTargetAndDepthStencilTextures = D3DHeapFlags(rawValue: WinSDK.D3D12_HEAP_FLAG_ALLOW_ONLY_RT_DS_TEXTURES.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init(_ rawType: RawType) {
        self.rawValue = rawType.rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DHeapFlags")
public typealias D3D12_HEAP_FLAGS = D3DHeapFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_HEAP_FLAG_NONE: D3DHeapFlags = []

@available(*, deprecated, renamed: "D3DHeapFlags.shared")
public let D3D12_HEAP_FLAG_SHARED = D3DHeapFlags.shared

@available(*, deprecated, renamed: "D3DHeapFlags.denyBuffers")
public let D3D12_HEAP_FLAG_DENY_BUFFERS = D3DHeapFlags.denyBuffers

@available(*, deprecated, renamed: "D3DHeapFlags.allowDisplay")
public let D3D12_HEAP_FLAG_ALLOW_DISPLAY = D3DHeapFlags.allowDisplay

@available(*, deprecated, renamed: "D3DHeapFlags.sharedAcrossAdapter")
public let D3D12_HEAP_FLAG_SHARED_CROSS_ADAPTER = D3DHeapFlags.sharedAcrossAdapter

@available(*, deprecated, renamed: "D3DHeapFlags.denyRenderTargetAndDepthStencilTextures")
public let D3D12_HEAP_FLAG_DENY_RT_DS_TEXTURES = D3DHeapFlags.denyRenderTargetAndDepthStencilTextures

@available(*, deprecated, renamed: "D3DHeapFlags.denyNonRenderTargetAndDepthStencilTextures")
public let D3D12_HEAP_FLAG_DENY_NON_RT_DS_TEXTURES = D3DHeapFlags.denyNonRenderTargetAndDepthStencilTextures

@available(*, deprecated, renamed: "D3DHeapFlags.hardwareProtected")
public let D3D12_HEAP_FLAG_HARDWARE_PROTECTED = D3DHeapFlags.hardwareProtected

@available(*, deprecated, renamed: "D3DHeapFlags.allowWriteWatch")
public let D3D12_HEAP_FLAG_ALLOW_WRITE_WATCH = D3DHeapFlags.allowWriteWatch

@available(*, deprecated, renamed: "D3DHeapFlags.allowShaderAtomics")
public let D3D12_HEAP_FLAG_ALLOW_SHADER_ATOMICS = D3DHeapFlags.allowShaderAtomics

@available(*, deprecated, renamed: "D3DHeapFlags.createNotResident")
public let D3D12_HEAP_FLAG_CREATE_NOT_RESIDENT = D3DHeapFlags.createNotResident

@available(*, deprecated, renamed: "D3DHeapFlags.createNotZeroed")
public let D3D12_HEAP_FLAG_CREATE_NOT_ZEROED = D3DHeapFlags.createNotZeroed

@available(*, deprecated, renamed: "D3DHeapFlags.allowAllBuffersAndTextures")
public let D3D12_HEAP_FLAG_ALLOW_ALL_BUFFERS_AND_TEXTURES = D3DHeapFlags.allowAllBuffersAndTextures

@available(*, deprecated, renamed: "D3DHeapFlags.allowOnlyBuffers")
public let D3D12_HEAP_FLAG_ALLOW_ONLY_BUFFERS = D3DHeapFlags.allowOnlyBuffers

@available(*, deprecated, renamed: "D3DHeapFlags.allowOnlyNonRenderTargetOrDepthStencilTextures")
public let D3D12_HEAP_FLAG_ALLOW_ONLY_NON_RT_DS_TEXTURES = D3DHeapFlags.allowOnlyNonRenderTargetOrDepthStencilTextures

@available(*, deprecated, renamed: "D3DHeapFlags.allowOnlyRenderTargetAndDepthStencilTextures")
public let D3D12_HEAP_FLAG_ALLOW_ONLY_RT_DS_TEXTURES = D3DHeapFlags.allowOnlyRenderTargetAndDepthStencilTextures

#endif
