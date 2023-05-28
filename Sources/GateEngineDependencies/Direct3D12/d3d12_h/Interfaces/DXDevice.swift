/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK
import WinSDK.DirectX

public final class D3DDevice: D3DObject {

    /// Gets the reason that the device was removed.
    @inlinable @inline(__always)
    public func checkDeviceRemovedReason() throws {
        try perform(as: RawValue.self) {pThis in
            try pThis.pointee.lpVtbl.pointee.GetDeviceRemovedReason(pThis).checkResult(self, #function)
        }
    }
    
    /** Gets information about the features that are supported by the current graphics driver.
    - parameter feature: A constant from the D3D12_FEATURE enumeration describing the feature(s) that you want to query for support.
    - parameter A pointer to a data structure that corresponds to the value of the Feature parameter. To determine the corresponding data structure for each constant, see D3D12_FEATURE.
    */
    @inlinable @inline(__always)
    public func supports<T>(_ feature: D3DFeature, _ structure: T) -> Bool {
        return performFatally(as: RawValue.self) {pThis in
            let size = UInt32(MemoryLayout<T>.size)
            var structure = structure
            return pThis.pointee.lpVtbl.pointee.CheckFeatureSupport(pThis, feature.rawValue, &structure, size).isSuccess
        }
    }

    /** Copies descriptors from a source to a destination.
        Both the source and destination descriptor heaps must have the same type, else the debug layer will emit an error.
    - parameter destRangeStarts: An array of D3D12_CPU_DESCRIPTOR_HANDLE objects to copy to. All the destination and source descriptors must be in heaps of the same D3D12_DESCRIPTOR_HEAP_TYPE.
    - parameter destRangeSizes: An array of destination descriptor range sizes to copy to.
    - parameter srcRangeStarts: An array of D3D12_CPU_DESCRIPTOR_HANDLE objects to copy from. All elements in the pSrcDescriptorRangeStarts parameter must be in a non shader-visible descriptor heap.
    - parameter srcRangeSizes: An array of source descriptor range sizes to copy from.
    - parameter type: The D3D12_DESCRIPTOR_HEAP_TYPE-typed value that specifies the type of descriptor heap to copy with. This is required as different descriptor types may have different sizes.
    */
    @inlinable @inline(__always)
    public func copyDescriptors(destRangeStarts: [D3DCPUDescriptorHandle],
                                destRangeSizes: [UInt32],
                                srcRangeStarts: [D3DCPUDescriptorHandle],
                                srcRangeSizes: [UInt32],
                                type: D3DDescriptorHeapType) {
        performFatally(as: RawValue.self) {pThis in
            let NumDestDescriptorRanges = UInt32(destRangeStarts.count)
            let pDestDescriptorRangeStarts = destRangeStarts.map({$0.rawValue})
            let pDestDescriptorRangeSizes = destRangeSizes
            let NumSrcDescriptorRanges = UInt32(srcRangeStarts.count)
            let pSrcDescriptorRangeStarts = srcRangeStarts.map({$0.rawValue})
            let pSrcDescriptorRangeSizes = srcRangeSizes
            let DescriptorHeapsType = type.rawValue
            pThis.pointee.lpVtbl.pointee.CopyDescriptors(pThis, 
                                                         NumDestDescriptorRanges, pDestDescriptorRangeStarts, pDestDescriptorRangeSizes,
                                                         NumSrcDescriptorRanges, pSrcDescriptorRangeStarts, pSrcDescriptorRangeSizes,
                                                         DescriptorHeapsType)
        }
    }

    /** Copies descriptors from a source to a destination.
    - parameter destRangeStart: A D3D12_CPU_DESCRIPTOR_HANDLE that describes the destination descriptors to start to copy to.
    - parameter srcRangeStart: A D3D12_CPU_DESCRIPTOR_HANDLE that describes the source descriptors to start to copy from. All elements in the pSrcDescriptorRangeStarts parameter must be in a non shader-visible descriptor heap.
    - parameter count: The number of descriptors to copy.
    - parameter type: The D3D12_DESCRIPTOR_HEAP_TYPE-typed value that specifies the type of descriptor heap to copy with. This is required as different descriptor types may have different sizes.
    */
    @inlinable @inline(__always)
    public func copyDescriptors(from destRangeStart: D3DCPUDescriptorHandle,
                                to srcRangeStart: D3DCPUDescriptorHandle,
                                count: UInt32,
                                type: D3DDescriptorHeapType) {
        performFatally(as: RawValue.self) {pThis in
            let NumDescriptors = count
            let pDestDescriptorRangeStarts = destRangeStart.rawValue
            let pSrcDescriptorRangeStarts = srcRangeStart.rawValue
            let DescriptorHeapsType = type.rawValue
            pThis.pointee.lpVtbl.pointee.CopyDescriptorsSimple(pThis, 
                                                               NumDescriptors, 
                                                               pDestDescriptorRangeStarts, pSrcDescriptorRangeStarts,
                                                               DescriptorHeapsType)
        }
    }

    /** Creates a command allocator object.
    - parameter type: A D3D12_COMMAND_LIST_TYPE-typed value that specifies the type of command allocator to create. The type of command allocator can be the type that records either direct command lists or bundles.
    */
    @inlinable @inline(__always)
    public func createCommandAllocator(type: D3DCommandListType) throws -> D3DCommandAllocator {
        return try perform(as: RawValue.self) {pThis in
            var ppCommandAllocator: UnsafeMutableRawPointer?
            var riid = D3DCommandAllocator.interfaceID
            try pThis.pointee.lpVtbl.pointee.CreateCommandAllocator(pThis, type.rawValue, &riid, &ppCommandAllocator).checkResult(self, #function)
            guard let v = D3DCommandAllocator(winSDKPointer: ppCommandAllocator) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a command list.
    - parameter multipleAdapterNodeMask: For single-GPU operation, set this to zero. If there are multiple GPU nodes, then set a bit to identify the node (the device's physical adapter) for which to create the command list. Each bit in the mask corresponds to a single node. Only one bit must be set. Also see Multi-adapter systems.
    - parameter type: Specifies the type of command list to create.
    - parameter commandAllocator: A pointer to the command allocator object from which the device creates command lists.
    - parameter initialState: An optional pointer to the pipeline state object that contains the initial pipeline state for the command list. If it is nulltpr, then the runtime sets a dummy initial pipeline state, so that drivers don't have to deal with undefined state. The overhead for this is low, particularly for a command list, for which the overall cost of recording the command list likely dwarfs the cost of a single initial state setting. So there's little cost in not setting the initial pipeline state parameter, if doing so is inconvenient. For bundles, on the other hand, it might make more sense to try to set the initial state parameter (since bundles are likely smaller overall, and can be reused frequently).
    */
    @inlinable @inline(__always)
    public func createCommandList(multipleAdapterNodeMask: UInt32 = 0,
                           type: D3DCommandListType,
                           commandAllocator: D3DCommandAllocator,
                           initialState: D3DPipelineState? = nil) throws -> D3DCommandList {
        return try perform(as: RawValue.self) {pThis in
            let nodeMask = multipleAdapterNodeMask
            let type = type.rawValue
            let pCommandAllocator = commandAllocator.perform(as: D3DCommandAllocator.RawValue.self){$0}
            var ppCommandList: UnsafeMutableRawPointer?
            let pInitialState = initialState?.perform(as: D3DPipelineState.RawValue.self){$0}
            var riid = D3DCommandList.interfaceID
            try pThis.pointee.lpVtbl.pointee.CreateCommandList(pThis, nodeMask, type, pCommandAllocator, pInitialState, &riid, &ppCommandList).checkResult(self, #function)
            guard let v = D3DCommandList(winSDKPointer: ppCommandList) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a command list.
    - parameter multipleAdapterNodeMask: For single-GPU operation, set this to zero. If there are multiple GPU nodes, then set a bit to identify the node (the device's physical adapter) for which to create the command list. Each bit in the mask corresponds to a single node. Only one bit must be set. Also see Multi-adapter systems.
    - parameter type: Specifies the type of command list to create.
    - parameter commandAllocator: A pointer to the command allocator object from which the device creates command lists.
    - parameter initialState: An optional pointer to the pipeline state object that contains the initial pipeline state for the command list. If it is nulltpr, then the runtime sets a dummy initial pipeline state, so that drivers don't have to deal with undefined state. The overhead for this is low, particularly for a command list, for which the overall cost of recording the command list likely dwarfs the cost of a single initial state setting. So there's little cost in not setting the initial pipeline state parameter, if doing so is inconvenient. For bundles, on the other hand, it might make more sense to try to set the initial state parameter (since bundles are likely smaller overall, and can be reused frequently).
    */
    @inlinable @inline(__always)
    public func createGraphicsCommandList(multipleAdapterNodeMask: UInt32 = 0,
                                          type: D3DCommandListType,
                                          commandAllocator: D3DCommandAllocator,
                                          initialState: D3DPipelineState? = nil) throws -> D3DGraphicsCommandList {
        return try perform(as: RawValue.self) {pThis in
            let nodeMask = multipleAdapterNodeMask
            let type = type.rawValue
            let pCommandAllocator = commandAllocator.perform(as: D3DCommandAllocator.RawValue.self){$0}
            var ppCommandList: UnsafeMutableRawPointer?
            let pInitialState = initialState?.perform(as: D3DPipelineState.RawValue.self){$0}
            var riid = D3DGraphicsCommandList.interfaceID
            try pThis.pointee.lpVtbl.pointee.CreateCommandList(pThis, nodeMask, type, pCommandAllocator, pInitialState, &riid, &ppCommandList).checkResult(self, #function)
            guard let v = D3DGraphicsCommandList(winSDKPointer: ppCommandList) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a command queue.
    - parameter description: Specifies a D3D12_COMMAND_QUEUE_DESC that describes the command queue.
    */
    @inlinable @inline(__always)
    public func createCommandQueue(description: D3DCommandQueueDescription) throws -> D3DCommandQueue {
        return try perform(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            var riid = D3DCommandQueue.interfaceID
            var ppCommandQueue: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateCommandQueue(pThis, &pDesc, &riid, &ppCommandQueue).checkResult(self, #function)
            guard let v = D3DCommandQueue(winSDKPointer: ppCommandQueue) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }
    
    /** Creates a command queue.
    - parameter type: Specifies one member of D3D12_COMMAND_LIST_TYPE.
    - parameter priority: The priority for the command queue, as a D3D12_COMMAND_QUEUE_PRIORITYenumeration constant to select normal or high priority.
    - parameter flags: Specifies any flags from the D3D12_COMMAND_QUEUE_FLAGS enumeration.
    - parameter multipleAdapterNodeMask: For single GPU operation, set this to zero. If there are multiple GPU nodes, set a bit to identify the node (the device's physical adapter) to which the command queue applies. Each bit in the mask corresponds to a single node. Only 1 bit must be set. Refer to Multi-adapter systems.
    */
    @inlinable @inline(__always)
    public func createCommandQueue(type: D3DCommandListType, priority: D3DCommandQueuePriority = .normal, flags: D3DCommandQueueFlags = [], multipleAdapterNodeMask: UInt32 = 0)  throws -> D3DCommandQueue {
        let queueDescription = D3DCommandQueueDescription(type: type, priority: priority, flags: flags, multipleAdapterNodeMask: multipleAdapterNodeMask)
        return try createCommandQueue(description: queueDescription)
    } 

    /** This method creates a command signature.
    - parameter description: Describes the command signature to be created with the D3D12_COMMAND_SIGNATURE_DESC structure.
    - parameter rootSignature: Specifies the ID3D12RootSignature that the command signature applies to. The root signature is required if any of the commands in the signature will update bindings on the pipeline. If the only command present is a draw or dispatch, the root signature parameter can be set to NULL.
    */
    @inlinable @inline(__always)
    public func createCommandSignature(description: D3DCommandSignatureDescription, rootSignature: D3DRootSignature?) throws -> D3DCommandSignature {
        return try perform(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            let pRootSignature = rootSignature?.perform(as: D3DRootSignature.RawValue.self) {$0}
            var riid = D3DCommandSignature.interfaceID
            var ppCommandSignature: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateCommandSignature(pThis, &pDesc, pRootSignature, &riid, &ppCommandSignature).checkResult(self, #function)
            guard let v = D3DCommandSignature(winSDKPointer: ppCommandSignature) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates both a resource and an implicit heap, such that the heap is big enough to contain the entire resource, and the resource is mapped to the heap.
    - parameter description: A pointer to a D3D12_RESOURCE_DESC structure that describes the resource.
    - parameter properties: A pointer to a D3D12_HEAP_PROPERTIES structure that provides properties for the resource's heap.
    - parameter flags: Heap options, as a bitwise-OR'd combination of D3D12_HEAP_FLAGS enumeration constants.
    - parameter state: The initial state of the resource, as a bitwise-OR'd combination of D3D12_RESOURCE_STATES enumeration constants. When you create a resource together with a D3D12_HEAP_TYPE_UPLOAD heap, you must set InitialResourceState to D3D12_RESOURCE_STATE_GENERIC_READ. When you create a resource together with a D3D12_HEAP_TYPE_READBACK heap, you must set InitialResourceState to D3D12_RESOURCE_STATE_COPY_DEST.
    - parameter clearValue: Specifies a D3D12_CLEAR_VALUE structure that describes the default value for a clear color.
    */
    @inlinable @inline(__always)
    public func createCommittedResource(description: D3DResourceDescription,
                                        properties: D3DHeapProperties,
                                        flags: D3DHeapFlags = [],
                                        state: D3DResourceStates,
                                        clearValue: D3DClearValue? = nil) throws -> D3DResource {
        return try perform(as: RawValue.self) {pThis in
            var pHeapProperties = properties.rawValue
            let HeapFlags = flags.rawType
            var pDesc = description.rawValue
            let InitialResourceState = D3DResourceStates.RawType(state.rawValue)
            var riidResource = D3DResource.interfaceID
            var ppvResource: UnsafeMutableRawPointer?
            if var pOptimizedClearValue = clearValue?.rawValue {
                try pThis.pointee.lpVtbl.pointee.CreateCommittedResource(pThis, &pHeapProperties, HeapFlags, &pDesc, InitialResourceState, &pOptimizedClearValue, &riidResource, &ppvResource).checkResult(self, #function)
            }else{
                try pThis.pointee.lpVtbl.pointee.CreateCommittedResource(pThis, &pHeapProperties, HeapFlags, &pDesc, InitialResourceState, nil, &riidResource, &ppvResource).checkResult(self, #function)
            }
            guard let v = D3DResource(winSDKPointer: ppvResource) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a compute pipeline state object.
    - parameter description: A pointer to a D3D12_COMPUTE_PIPELINE_STATE_DESC structure that describes compute pipeline state.
    */
    @inlinable @inline(__always)
    public func createComputePipelineState(description: D3DComputePipelineStateDescription) throws -> D3DPipelineState {
        return try perform(as: RawValue.self) {pThis in
            return try description.withUnsafeRawValue {pDesc in
                var pDesc = pDesc
                var riid = D3DPipelineState.interfaceID
                var ppComputePipelineState: UnsafeMutableRawPointer?
                try pThis.pointee.lpVtbl.pointee.CreateComputePipelineState(pThis, &pDesc, &riid, &ppComputePipelineState).checkResult(self, #function)
                guard let v = D3DPipelineState(winSDKPointer: ppComputePipelineState) else {throw Error(.invalidArgument)}
                #if DEBUG
                try v.setDebugName("\(Swift.type(of: self)).\(#function)")
                #endif
                return v
            }
        }
    }

    /** Creates a constant-buffer view for accessing resource data.
    - parameter description: A pointer to a D3D12_CONSTANT_BUFFER_VIEW_DESC structure that describes the constant-buffer view.
    - parameter destination: Describes the CPU descriptor handle that represents the start of the heap that holds the constant-buffer view.
    */
    @inlinable @inline(__always)
    public func createConstantBufferView(description: D3DConstantBufferViewDescription, destination: D3DCPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            pThis.pointee.lpVtbl.pointee.CreateConstantBufferView(pThis, &pDesc, destination.rawValue)
        }
    }

    /** Creates a depth-stencil view for accessing resource data.
    - parameter resource: A pointer to the ID3D12Resource object that represents the depth stencil. At least one of pResource or pDesc must be provided. A null pResource is used to initialize a null descriptor, which guarantees D3D11-like null binding behavior (reading 0s, writes are discarded), but must have a valid pDesc in order to determine the descriptor type.
    - parameter description: A pointer to a D3D12_DEPTH_STENCIL_VIEW_DESC structure that describes the depth-stencil view. A null pDesc is used to initialize a default descriptor, if possible. This behavior is identical to the D3D11 null descriptor behavior, where defaults are filled in. This behavior inherits the resource format and dimension (if not typeless) and DSVs target the first mip and all array slices. Not all resources support null descriptor initialization.
    - parameter destination: Describes the CPU descriptor handle that represents the start of the heap that holds the depth-stencil view.
    */
    @inlinable @inline(__always)
    public func createDepthStencilView(resource: D3DResource, description: D3DDepthStencilViewDescription, destination: D3DCPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            var pDesc = description.rawValue
            pThis.pointee.lpVtbl.pointee.CreateDepthStencilView(pThis, pResource, &pDesc, destination.rawValue)
        }
    }

    /** Creates a descriptor heap object.
    - parameter description: A pointer to a D3D12_DESCRIPTOR_HEAP_DESC structure that describes the heap.
    */
    @inlinable @inline(__always)
    public func createDescriptorHeap(description: D3DDescriptorHeapDescription) throws -> D3DDescriptorHeap {
        return try perform(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            var riid = D3DDescriptorHeap.interfaceID
            var pp: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateDescriptorHeap(pThis, &pDesc, &riid, &pp).checkResult(self, #function)
            guard let v = D3DDescriptorHeap(winSDKPointer: pp) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a fence object.
    - parameter initialValue: The initial value for the fence.
    - parameter flags: A combination of D3D12_FENCE_FLAGS-typed values that are combined by using a bitwise OR operation. The resulting value specifies options for the fence.
    */
    @inlinable @inline(__always)
    public func createFence(initialValue: UInt64 = 0, flags: D3DFenceFlags = []) throws -> D3DFence {
        return try perform(as: RawValue.self) {pThis in
            let InitialValue = initialValue
            let Flags = flags.rawType
            var riid = D3DFence.interfaceID
            var pp: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateFence(pThis, InitialValue, Flags, &riid, &pp).checkResult(self, #function)
            guard let v = D3DFence(winSDKPointer: pp) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a graphics pipeline state object.
    - parameter description: A pointer to a D3D12_GRAPHICS_PIPELINE_STATE_DESC structure that describes graphics pipeline state.
    */
    @inlinable @inline(__always)
    public func createGraphicsPipelineState(description: D3DGraphicsPipelineStateDescription) throws -> D3DPipelineState {
        return try perform(as: RawValue.self) {pThis in
            return try description.withUnsafeRawValue {pDesc in
                var pDesc = pDesc
                var riid = D3DPipelineState.interfaceID
                var pp: UnsafeMutableRawPointer?
                try pThis.pointee.lpVtbl.pointee.CreateGraphicsPipelineState(pThis, &pDesc, &riid, &pp).checkResult(self, #function)
                guard let v = D3DPipelineState(winSDKPointer: pp) else {throw Error(.invalidArgument)}
                #if DEBUG
                try v.setDebugName("\(Swift.type(of: self)).\(#function)")
                #endif
                return v
            }
        }
    }

    /** Creates a heap that can be used with placed resources and reserved resources.
    - parameter description: A pointer to a constant D3D12_HEAP_DESC structure that describes the heap.
    */
    @inlinable @inline(__always)
    public func createHeap(description: D3DHeapDescription) throws -> D3DHeap {
        return try perform(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            var riid = D3DHeap.interfaceID
            var pp: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateHeap(pThis, &pDesc, &riid, &pp).checkResult(self, #function)
            guard let v = D3DHeap(winSDKPointer: pp) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a resource that is placed in a specific heap. Placed resources are the lightest weight resource objects available, and are the fastest to create and destroy.
    - parameter heap: A pointer to the ID3D12Heap interface that represents the heap in which the resource is placed.
    - parameter offset: The offset, in bytes, to the resource. The HeapOffset must be a multiple of the resource's alignment, and HeapOffset plus the resource size must be smaller than or equal to the heap size. GetResourceAllocationInfo must be used to understand the sizes of texture resources.
    - parameter description: A pointer to a D3D12_RESOURCE_DESC structure that describes the resource.
    - parameter initialState: The initial state of the resource, as a bitwise-OR'd combination of D3D12_RESOURCE_STATES enumeration constants. When a resource is created together with a D3D12_HEAP_TYPE_UPLOAD heap, InitialState must be D3D12_RESOURCE_STATE_GENERIC_READ. When a resource is created together with a D3D12_HEAP_TYPE_READBACK heap, InitialState must be D3D12_RESOURCE_STATE_COPY_DEST.
    - parameter clearValue: Specifies a D3D12_CLEAR_VALUE that describes the default value for a clear color.
    */
    @available(Windows, deprecated: 10.0.19041, message: "Use description type ResourceDescription1")
    @inlinable @inline(__always)
    public func createPlacedResource(heap: D3DHeap,
                                     offset: UInt64, 
                                     description: D3DResourceDescription,
                                     initialState: D3DResourceStates,
                                     clearValue: D3DClearValue) throws -> D3DResource {
        return try perform(as: RawValue.self) {pThis in
            let pHeap = heap.perform(as: D3DHeap.RawValue.self) {$0}
            let HeapOffset = offset
            var pDesc = description.rawValue
            let InitialState = D3DResourceStates.RawType(initialState.rawValue)
            var pOptimizedClearValue = clearValue.rawValue
            var riid = D3DResource.interfaceID
            var pp: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreatePlacedResource(pThis, pHeap, HeapOffset, &pDesc, InitialState, &pOptimizedClearValue, &riid, &pp).checkResult(self, #function)
            guard let v = D3DResource(winSDKPointer: pp) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a query heap. A query heap contains an array of queries.
    - parameter description: Specifies the query heap in a D3D12_QUERY_HEAP_DESC structure.
    */
    @inlinable @inline(__always)
    public func createQueryHeap(description: D3DQueryHeapDescription) throws -> D3DQueryHeap {
       return try perform(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            var riid = D3DQueryHeap.interfaceID
            var pp: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateQueryHeap(pThis, &pDesc, &riid, &pp).checkResult(self, #function)
            guard let v = D3DQueryHeap(winSDKPointer: pp) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a render-target view for accessing resource data.
    - paramter resource: A pointer to the ID3D12Resource object that represents the render target. At least one of pResource or pDesc must be provided. A null pResource is used to initialize a null descriptor, which guarantees D3D11-like null binding behavior (reading 0s, writes are discarded), but must have a valid pDesc in order to determine the descriptor type.
    - parameter description: A pointer to a D3D12_RENDER_TARGET_VIEW_DESC structure that describes the render-target view.
    - parameter destination: Describes the CPU descriptor handle that represents the destination where the newly-created render target view will reside.
    */
    @inlinable @inline(__always)
    public func createRenderTargetView(resource: D3DResource, description: D3DRenderTargetViewDescription?, destination: D3DCPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            if var pDesc = description?.rawValue {
                pThis.pointee.lpVtbl.pointee.CreateRenderTargetView(pThis, pResource, &pDesc, destination.rawValue)
            }else{
                pThis.pointee.lpVtbl.pointee.CreateRenderTargetView(pThis, pResource, nil, destination.rawValue)
            }
        }
    }

    /** Creates a resource that is reserved, and not yet mapped to any pages in a heap.
    - parameter description: A pointer to a D3D12_RESOURCE_DESC structure that describes the resource.
    - parameter initialState: The initial state of the resource, as a bitwise-OR'd combination of D3D12_RESOURCE_STATES enumeration constants.
    - parameter clearValue: Specifies a D3D12_CLEAR_VALUE structure that describes the default value for a clear color.
    */
    @inlinable @inline(__always)
    public func createReservedResource(description: D3DResourceDescription,
                                       initialState: D3DResourceStates,
                                       clearValue: D3DClearValue) throws -> D3DResource {
        return try perform(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            let InitialState = D3DResourceStates.RawType(initialState.rawValue)
            var pOptimizedClearValue = clearValue.rawValue
            var riid = D3DResource.interfaceID
            var pp: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateReservedResource(pThis, &pDesc, InitialState, &pOptimizedClearValue, &riid, &pp).checkResult(self, #function)
            guard let v = D3DResource(winSDKPointer: pp) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Creates a root signature layout.
    - parameter multipleAdapterNodeMask: For single GPU operation, set this to zero. If there are multiple GPU nodes, set bits to identify the nodes (the device's physical adapters) to which the root signature is to apply. Each bit in the mask corresponds to a single node. Refer to Multi-adapter systems.
    - parameter description: The description of the root signature, as a pointer to a D3D12_ROOT_SIGNATURE_DESC structure.
    - parameter version: A D3D_ROOT_SIGNATURE_VERSION-typed value that specifies the version of root signature.
    */
    @inlinable @inline(__always)
    public func createRootSignature(multipleAdapterNodeMask: UInt32 = 0,
                                    description: D3DRootSignatureDescription,
                                    version: D3DRootSignatureVersion) throws -> D3DRootSignature {
        return try perform(as: RawValue.self) {pThis in
            let ppBlob = try serializeRootSignature(description, version: version)
            var riid = D3DRootSignature.interfaceID
            var ppCommandSignature: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateRootSignature(pThis, multipleAdapterNodeMask, ppBlob.bufferPointer, ppBlob.bufferSize, &riid, &ppCommandSignature).checkResult(self, #function)
            guard let v = D3DRootSignature(winSDKPointer: ppCommandSignature) else {throw Error(.invalidArgument)}
            #if DEBUG
            try v.setDebugName("\(Swift.type(of: self)).\(#function)")
            #endif
            return v
        }
    }

    /** Create a sampler object that encapsulates sampling information for a texture.
    - parameter description: A pointer to a D3D12_SAMPLER_DESC structure that describes the sampler.
    - parameter destination: Describes the CPU descriptor handle that represents the start of the heap that holds the sampler.
    */
    @inlinable @inline(__always)
    public func createSampler(description: D3DSamplerDescription, destination: D3DCPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            var pDesc = description.rawValue
            pThis.pointee.lpVtbl.pointee.CreateSampler(pThis, &pDesc, destination.rawValue)
        }
    }

    /** Creates a shader-resource view for accessing data in a resource.
    - parameter resource: A pointer to the ID3D12Resource object that represents the shader resource. At least one of pResource or pDesc must be provided. A null pResource is used to initialize a null descriptor, which guarantees D3D11-like null binding behavior (reading 0s, writes are discarded), but must have a valid pDesc in order to determine the descriptor type.
    - parameter description: A pointer to a D3D12_SHADER_RESOURCE_VIEW_DESC structure that describes the shader-resource view.
    - parameter destination: Describes the CPU descriptor handle that represents the shader-resource view. This handle can be created in a shader-visible or non-shader-visible descriptor heap.
    */
    @inlinable @inline(__always)
    public func createShaderResourceView(resource: D3DResource, description: D3DShaderResourceViewDescription, destination: D3DCPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            var pDesc = description.rawValue
            pThis.pointee.lpVtbl.pointee.CreateShaderResourceView(pThis, pResource, &pDesc, destination.rawValue)
        }
    }

    //TODO: Add SECURITY_ATTRIBUTES
    /** Creates a shared handle to an heap, resource, or fence object.
    - parameter object: A pointer to the ID3D12DeviceChild interface that represents the heap, resource, or fence object to create for sharing. The following interfaces (derived from ID3D12DeviceChild) are supported:
    - parameter name: A NULL-terminated UNICODE string that contains the name to associate with the shared heap. The name is limited to MAX_PATH characters. Name comparison is case-sensitive. If Name matches the name of an existing resource, CreateSharedHandle fails with DXGI_ERROR_NAME_ALREADY_EXISTS. This occurs because these objects share the same namespace. The name can have a "Global" or "Local" prefix to explicitly create the object in the global or session namespace. The remainder of the name can contain any character except the backslash character (\). For more information, see Kernel Object Namespaces. Fast user switching is implemented using Terminal Services sessions. Kernel object names must follow the guidelines outlined for Terminal Services so that applications can support multiple users.
    */
    @inlinable @inline(__always)
    public func createSharedHandle(object: D3DDeviceChild, name: String) throws -> UnsafeMutableRawPointer {
        return try perform(as: RawValue.self) {pThis in
            let pObject = object.perform(as: D3DDeviceChild.RawValue.self) {$0}
            let pAttributes: UnsafeMutablePointer<SECURITY_ATTRIBUTES>? = nil
            let ACCESS = DWORD(WinSDK.GENERIC_ALL)
            let Name = name.windowsUTF16
            var handle: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.CreateSharedHandle(pThis, pObject, pAttributes, ACCESS, Name, &handle).checkResult(self, #function)
            guard let handle = handle else {throw Error(.invalidArgument)}
            return handle
        }
    }

    /** Creates a view for unordered accessing.
    - parameter resource: A pointer to the ID3D12Resource object that represents the unordered access.
    - parameter counter: The ID3D12Resource for the counter (if any) associated with the UAV. If pCounterResource is not specified, then the CounterOffsetInBytes member of the D3D12_BUFFER_UAV structure must be 0.
    - parameter description: A pointer to a D3D12_UNORDERED_ACCESS_VIEW_DESC structure that describes the unordered-access view.
    - parameter destination: Describes the CPU descriptor handle that represents the start of the heap that holds the unordered-access view.
    */
    @inlinable @inline(__always)
    public func createUnorderedAccessView(resource: D3DResource, counter: D3DResource, description: D3DUnorderedAccessViewDescription, destination: D3DCPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            let pCounterResource = counter.performFatally(as: D3DResource.RawValue.self) {$0}
            var pDesc = description.rawValue
            pThis.pointee.lpVtbl.pointee.CreateUnorderedAccessView(pThis, pResource, pCounterResource, &pDesc, destination.rawValue)
        }
    }

    /** Enables the page-out of data, which precludes GPU access of that data.
    - parameter objects: A pointer to a memory block that contains an array of ID3D12Pageable interface pointers for the objects. Even though most D3D12 objects inherit from ID3D12Pageable, residency changes are only supported on the following objects: Descriptor Heaps, Heaps, Committed Resources, and Query Heaps
    */
    @inlinable @inline(__always)
    public func evict(_ objects: [D3DPageable]) throws {
        try perform(as: RawValue.self) {pThis in 
            let NumObjects = UInt32(objects.count)
            var ppObjects = objects.map({$0.perform(as: D3DPageable.RawValue.self) {Optional($0)}})
            try pThis.pointee.lpVtbl.pointee.Evict(pThis, NumObjects, &ppObjects).checkResult(self, #function)
        }
    }

    /** Gets the size and alignment of memory required for a collection of resources on this adapter.
    - parameter multipleAdapterNodeMask: For single-GPU operation, set this to zero. If there are multiple GPU nodes, then set bits to identify the nodes (the device's physical adapters). Each bit in the mask corresponds to a single node. Also see Multi-adapter systems.
    - parameter descriptors: An array of D3D12_RESOURCE_DESC structures that described the resources to get info about.
    */
    @inlinable @inline(__always)
    public func resourceAllocationInfo(multipleAdapterNodeMask: UInt32 = 0,
                                       descriptors: [D3DResourceDescription]) -> D3DResourceAllocationInfo {
        return performFatally(as: RawValue.self) {pThis in
            let visibleMask = multipleAdapterNodeMask
            let numResourceDescs = UInt32(descriptors.count)
            let pResourceDescs: [D3DResourceDescription.RawValue] = descriptors.map({$0.rawValue})
            var info: D3DResourceAllocationInfo.RawValue = D3DResourceAllocationInfo.RawValue()
            typealias GetResourceAllocationInfoABI = @convention(c) (UnsafeMutablePointer<ID3D12Device5>?, UnsafeMutablePointer<D3DResourceAllocationInfo.RawValue>?, UInt32, UInt32, UnsafePointer<D3DResourceDescription.RawValue>?) -> Void
            let pGetResourceAllocationInfo: GetResourceAllocationInfoABI = unsafeBitCast(pThis.pointee.lpVtbl.pointee.GetResourceAllocationInfo, to: GetResourceAllocationInfoABI.self)
            pGetResourceAllocationInfo(pThis, &info, visibleMask, numResourceDescs, pResourceDescs)
            return D3DResourceAllocationInfo(info)
        }
    }

    @inlinable @inline(__always)
    public func resourceTiling(for resource: D3DResource, start: UInt32, count: UInt32) -> (tilesNeeded: UInt32, 
                                                                                            mipInfo: D3DPackedMipInfo, 
                                                                                            shape: D3DTileShape,
                                                                                            retrieved: UInt32, 
                                                                                            tiling: D3DSubresourceTiling) {
        // https://docs.microsoft.com/en-us/windows/win32/api/d3d12/nf-d3d12-id3d12device-getresourcetiling
        fatalError("no implementation")
    }

    /// Gets a locally unique identifier for the current device (adapter).
    @inlinable @inline(__always)
    public var adapterLUID: WinSDK.LUID {
        return performFatally(as: RawValue.self) {pThis in
            var luid: WinSDK.LUID = WinSDK.LUID()
            typealias GetAdapterLuidABI = @convention(c) (UnsafeMutablePointer<D3DDevice.RawValue>?, UnsafeMutablePointer<WinSDK.LUID>?) -> Void
            let pGetAdapterLuid: GetAdapterLuidABI = unsafeBitCast(pThis.pointee.lpVtbl.pointee.GetAdapterLuid, to: GetAdapterLuidABI.self)
            pGetAdapterLuid(pThis, &luid)
            return luid
        }
    }

    /** Gets a resource layout that can be copied. Helps the app fill-in D3D12_PLACED_SUBRESOURCE_FOOTPRINT and D3D12_SUBRESOURCE_FOOTPRINT when suballocating space in upload heaps.
    - parameter description: A description of the resource, as a pointer to a D3D12_RESOURCE_DESC structure.
    - parameter firstIndex: Index of the first subresource in the resource. The range of valid values is 0 to D3D12_REQ_SUBRESOURCES.
    - parameter count: The number of subresources in the resource. The range of valid values is 0 to (D3D12_REQ_SUBRESOURCES - FirstSubresource).
    - parameter offset: The offset, in bytes, to the resource.
    - parameter layouts: A pointer to an array (of length NumSubresources) of D3D12_PLACED_SUBRESOURCE_FOOTPRINT structures, to be filled with the description and placement of each subresource.
    - returns rowCounts: A pointer to an array (of length NumSubresources) of integer variables, to be filled with the number of rows for each subresource.
    - returns rowSizes: A pointer to an array (of length NumSubresources) of integer variables, each entry to be filled with the unpadded size in bytes of a row, of each subresource. For example, if a Texture2D resource has a width of 32 and bytes per pixel of 4, then pRowSizeInBytes returns 128. pRowSizeInBytes should not be confused with row pitch, as examining pLayouts and getting the row pitch from that will give you 256 as it is aligned to D3D12_TEXTURE_DATA_PITCH_ALIGNMENT.
    - returns totalByteSize: A pointer to an integer variable, to be filled with the total size, in bytes.
    */
    @available(Windows, deprecated: 10.0.19041, message: "Use description type ResourceDescription1.")
    @inlinable @inline(__always)
    func copyableFootprints(description: D3DResourceDescription,
                            firstIndex: UInt32,
                            count: UInt32,
                            offset: UInt64,
                            layouts: D3DPlacedSubresourceFootprint) -> (rowCounts: [UInt32], rowSizes: [UInt64], totalByteSize: UInt64) {
        performFatally(as: RawValue.self) {pThis in 
            var pResourceDesc = description.rawValue
            let FirstSubresource = firstIndex
            let NumSubresources = count
            let BaseOffset = offset
            var pLayouts = layouts.rawValue

            var pNumRows: [UInt32] = Array(repeating: 0, count: Int(count))
            var pRowSizeInBytes: [UInt64] = Array(repeating: 0, count: Int(count))
            var pTotalBytes: UInt64 = 0
            pThis.pointee.lpVtbl.pointee.GetCopyableFootprints(pThis, &pResourceDesc, FirstSubresource, NumSubresources, BaseOffset, &pLayouts, &pNumRows, &pRowSizeInBytes, &pTotalBytes)
            return (pNumRows, pRowSizeInBytes, pTotalBytes)
        }
    }

    /** Gets the size of the handle increment for the given type of descriptor heap. This value is typically used to increment a handle into a descriptor array by the correct amount.
    - parameter type: The D3D12_DESCRIPTOR_HEAP_TYPE-typed value that specifies the type of descriptor heap to get the size of the handle increment for.
    */
    @inlinable @inline(__always)
    public func descriptorHandleIncrementSize(for type: D3DDescriptorHeapType) -> UInt32 {
        return performFatally(as: RawValue.self) {pThis in 
            return pThis.pointee.lpVtbl.pointee.GetDescriptorHandleIncrementSize(pThis, type.rawValue)
        }
    }

    /** Makes objects resident for the device.
    - parameter objects: A pointer to a memory block that contains an array of ID3D12Pageable interface pointers for the objects. Even though most D3D12 objects inherit from ID3D12Pageable, residency changes are only supported on the following objects: Descriptor Heaps, Heaps, Committed Resources, and Query Heaps
    */
    @inlinable @inline(__always)
    public func makeResident(_ objects: [D3DPageable]) throws {
        try perform(as: RawValue.self) {pThis in 
            let NumObjects = UInt32(objects.count)
            var ppObjects = objects.map({$0.perform(as: D3DPageable.RawValue.self) {Optional($0)}})
            try pThis.pointee.lpVtbl.pointee.MakeResident(pThis, NumObjects, &ppObjects).checkResult(self, #function)
        }
    }

    /** Opens a handle for shared resources, shared heaps, and shared fences, by using HANDLE and REFIID.
    - parameter handle: The handle that was output by the call to ID3D12Device::CreateSharedHandle.
    - parameter type: The globally unique identifier (GUID) for one of the following interfaces: ID3D12Heap, ID3D12Resource, ID3D12Fence
    - returns: The REFIID, or GUID, of the interface can be obtained by using the __uuidof() macro. For example, __uuidof(ID3D12Heap) will get the GUID of the interface to a resource.
    */
    @inlinable @inline(__always)
    public func openSharedHandle<T: D3DPageable>(_ handle: UnsafeMutableRawPointer, for type: T.Type) throws -> T {
        return try perform(as: RawValue.self) {pThis in
            var riid: WinSDK.IID = try {
                if type == D3DHeap.self {
                    return D3DHeap.interfaceID
                }else if type == D3DResource.self {
                    return D3DResource.interfaceID
                }else if type == D3DFence.self {
                    return D3DFence.interfaceID
                }else{
                    throw Error(.invalidArgument)
                }
            }()
            var p: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.OpenSharedHandle(pThis, handle, &riid, &p).checkResult(self, #function)
            guard let p = p else {throw Error(.invalidArgument)}
            if type == D3DHeap.self {
                return D3DHeap(winSDKPointer: p) as! T
            }else if type == D3DResource.self {
                return D3DResource(winSDKPointer: p) as! T
            }else if type == D3DFence.self {
                return D3DFence(winSDKPointer: p) as! T
            }else{
                throw Error(.invalidArgument)
            }
        }
    }

    /** Opens a handle for shared resources, shared heaps, and shared fences, by using Name and Access.
    - parameter name: The name that was optionally passed as the Name parameter in the call to ID3D12Device::CreateSharedHandle.
    - returns: Pointer to the shared handle.
    */
    @inlinable @inline(__always)
    public func openSharedHandle(byName name: String) throws -> UnsafeMutableRawPointer {
        return try perform(as: RawValue.self) {pThis in
            let Name = name.windowsUTF16
            let Access = DWORD(WinSDK.GENERIC_ALL)
            var p: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.OpenSharedHandleByName(pThis, Name, Access, &p).checkResult(self, #function)
            guard let p = p else {throw Error(.invalidArgument)}
            return p
        }
    }

    /** A development-time aid for certain types of profiling and experimental prototyping.
    - parameter enabled: Specifies a BOOL that turns the stable power state on or off.
    */
    @inlinable @inline(__always)
    public func setStablePowerState(enabled: Bool) throws {
        try perform(as: RawValue.self) {pThis in
            let Enable = WindowsBool(booleanLiteral: enabled)
            try pThis.pointee.lpVtbl.pointee.SetStablePowerState(pThis, Enable).checkResult(self, #function)
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {
        // if #available(Windows 10.0.19041, *) {
        //     //Device7 and Device8 were relased at the same time. Always use Device8.
        //     return RawValue8.interfaceID //ID3D12Device8
        //   //return RawValue7.interfaceID //ID3D12Device7
        // }else if #available(Windows 10.0.18362, *) {
        //     return RawValue6.interfaceID //ID3D12Device6
        // }else if #available(Windows 10.0.17763, *) {
        //     return RawValue5.interfaceID //ID3D12Device5
        // }else if #available(Windows 10.0.17134, *) {
        //     return RawValue4.interfaceID //ID3D12Device4
        // }else if #available(Windows 10.0.16299, *) {
        //     return RawValue3.interfaceID //ID3D12Device3
        // }else if #available(Windows 10.0.15063, *) {
        //     return RawValue2.interfaceID //ID3D12Device2
        // }else if #available(Windows 10.0.14393, *) {
        //     return RawValue1.interfaceID //ID3D12Device1
        // }else{
            return RawValue.interfaceID  //ID3D12Device
        // }
    }

    @inlinable @inline(__always)
    public init(adapter: DGIAdapter? = nil, minimumFeatureLevel featureLevel: D3DFeatureLevel = .v11) throws {
        let pAdapter = adapter?.perform(as: IUnknown.RawValue.self) {$0}
        let MinimumFeatureLevel = featureLevel.rawValue
        var riid = D3DDevice.interfaceID
        var ppDevice: UnsafeMutableRawPointer?
        try WinSDK.D3D12CreateDevice(pAdapter, MinimumFeatureLevel, &riid, &ppDevice).checkResult(Self.self, #function)
        guard let p = ppDevice else {throw Error(.invalidArgument)}
        super.init(winSDKPointer: p)!
    }

    @inlinable @inline(__always)
    required init?(winSDKPointer pointer: UnsafeMutableRawPointer?, memoryManagment: IUnknown.MemoryManagment = .alreadyRetained) {
        super.init(winSDKPointer: pointer, memoryManagment: memoryManagment)
    }
}

extension D3DDevice {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12Device5
}
extension D3DDevice.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: IID {WinSDK.IID_ID3D12Device5}
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDevice")
public typealias ID3D12Device = D3DDevice 

public extension D3DDevice {
    @available(*, unavailable, renamed: "commandListType")
    func GetType() -> D3DCommandListType.RawValue {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "supports")
    func CheckFeatureSupport(_ Feature: D3DFeature, _ pFeatureSupportData: UnsafeMutableRawPointer?, _ FeatureSupportDataSize: UInt32) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyDescriptors")
    func CopyDescriptors(_ NumDestDescriptorRanges: UInt32,
                         _ pDestDescriptorRangeStarts: UnsafePointer<D3DCPUDescriptorHandle>?,
                         _ pDestDescriptorRangeSizes: UnsafePointer<UInt32>,
                         _ NumSrcDescriptorRanges: UInt32,
                         _ pSrcDescriptorRangeStarts: UnsafePointer<D3DCPUDescriptorHandle>?,
                         _ pSrcDescriptorRangeSizes: UnsafeMutablePointer<UInt32>?,
                         _ DescriptorHeapsType: D3DDescriptorHeapType) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyDescriptors")
    func CopyDescriptorsSimple(_ NumDestDescriptors: UInt32,
                               _ pDestDescriptorRangeStart: D3DCPUDescriptorHandle,
                               _ pSrcDescriptorRangeStart: D3DCPUDescriptorHandle,
                               _ DescriptorHeapsType: D3DDescriptorHeapType) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createCommandAllocator")
    func CreateCommandAllocator(_ type: D3DCommandListType, _ riid: UnsafePointer<WinSDK.IID>?, _ ppCommandAllocator: UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createCommandList")
    func CreateCommandList(_ nodeMask: UInt32,
                           _ type: D3DCommandListType,
                           _ pCommandAllocator: UnsafeMutablePointer<D3DCommandAllocator>,
                           _ pInitialState: UnsafeMutablePointer<D3DPipelineState>?,
                           _ riid: UnsafePointer<WinSDK.IID>?,
                           _ ppCommandList: UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createCommandQueue")
    func CreateCommandQueue(_ pDesc: UnsafePointer<D3DCommandQueueDescription>, 
                            _ riid: UnsafePointer<WinSDK.IID>?, 
                            _ ppCommandQueue: UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createCommandSignature")
    func CreateCommandSignature(_ pDesc: UnsafePointer<D3DCommandSignatureDescription>, 
                                _ pRootSignature: UnsafeMutablePointer<D3DRootSignature>,
                                _ riid: UnsafePointer<WinSDK.IID>?,
                                _ ppvCommandSignature: UnsafeMutablePointer<UnsafeMutableRawPointer?>?) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createCommittedResource")
    func CreateCommittedResource(_ pHeapProperties: Any,
                                 _ HeapFlags: Any,
                                 _ pDesc: Any,
                                 _ InitialResourceState: Any,
                                 _ pOptimizedClearValue: Any,
                                 _ riidResource: Any,
                                 _ ppvResource: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createComputePipelineState")
    func CreateComputePipelineState(_ pDesc: Any,
                                    _ riidResource: Any,
                                    _ ppvResource: inout Any?) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createConstantBufferView")
    func CreateConstantBufferView(_ pDesc: Any,
                                  _ DestDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createDepthStencilView")
    func CreateDepthStencilView(_ pResource: Any,
                                _ pDesc: Any,
                                _ DestDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createDescriptorHeap")
    func CreateDescriptorHeap(_ pDesc: Any,
                              _ riid: Any,
                              _ ppvHeap: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createFence")
    func CreateFence(_ InitialValue: Any,
                     _ Flags: Any,
                     _ riid: Any,
                     _ ppFence: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createGraphicsPipelineState")
    func CreateGraphicsPipelineState(_ pDesc: Any,
                                     _ riid: Any,
                                     _ ppPipelineState: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createHeap")
    func CreateHeap(_ pDesc: Any,
                    _ riid: Any,
                    _ ppvHeap: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createPlacedResource")
    func CreatePlacedResource(_ pHeap: Any,
                              _ HeapOffset: Any,
                              _ pDesc: Any,
                              _ InitialState: Any,
                              _ pOptimizedClearValue: Any,
                              _ riid: Any,
                              _ ppvResource: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createQueryHeap")
    func CreateQueryHeap(_ pDesc: Any,
                         _ riid: Any,
                         _ ppvHeap: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createRenderTargetView")
    func CreateRenderTargetView(_ pResource: Any,
                                _ pDesc: Any,
                                _ DestDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createReservedResource")
    func CreateReservedResource(_ pDesc: Any,
                              _ InitialState: Any,
                              _ pOptimizedClearValue: Any,
                              _ riid: Any,
                              _ ppvResource: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createRootSignature")
    func CreateRootSignature(_ nodeMask: Any,
                             _ pBlobWithRootSignature: Any,
                             _ blobLengthInBytes: Any,
                             _ riid: Any,
                             _ ppvRootSignature: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createSampler")
    func CreateSampler(_ pDesc: Any,
                       _ DestDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createShaderResourceView")
    func CreateShaderResourceView(_ pResource: Any,
                                  _ pDesc: Any,
                                  _ DestDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createSharedHandle")
    func CreateSharedHandle(_ pObject: Any,
                            _ pAttributes: Any,
                            _ Access: Any,
                            _ Name: Any,
                            _ pHandle: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "createUnorderedAccessView")
    func CreateUnorderedAccessView(_ pResource: Any,
                                   _ pCounterResource: Any,
                                   _ pDesc: Any,
                                   _ DestDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "evict")
    func Evict(_ NumObjects: Any,
               _ ppObjects: inout Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "resourceAllocationInfo")
    func GetResourceAllocationInfo(_ visibleMask: Any,
                                   _ numResourceDescs: inout Any,
                                   _ pResourceDescs: inout Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "resourceTiling")
    func GetResourceTiling(_ pTiledResource: Any,
                           _ pNumTilesForEntireResource: inout Any,
                           _ pPackedMipDesc: inout Any,
                           _ pStandardTileShapeForNonPackedMips: inout Any,
                           _ pNumSubresourceTilings: Any,
                           _ FirstSubresourceTilingToGet: Any,
                           _ pSubresourceTilingsForNonPackedMips: inout Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "adapterLUID")
    func GetAdapterLuid() -> WinSDK.LUID {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyableFootprints")
    func GetCopyableFootprints(_ pResourceDesc: Any,
                               _ FirstSubresource: Any,
                               _ NumSubresources: Any,
                               _ BaseOffset: Any,
                               _ pLayouts: Any,
                               _ pNumRows: inout Any?,
                               _ pRowSizeInBytes: inout Any?,
                                _ pTotalBytes: inout Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "makeResident")
    func MakeResident(_ NumObjects: Any,
                      _ ppObjects: inout Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "openSharedHandle")
    func OpenSharedHandle(_ pObject: Any,
                          _ riid: Any,
                          _ ppvObj: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "openSharedHandle(byName:)")
    func OpenSharedHandleByName(_ Name: Any,
                                _ Access: Any,
                                _ pNTHandle: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setStablePowerState(enabled:)")
    func SetStablePowerState(_ Enable: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
