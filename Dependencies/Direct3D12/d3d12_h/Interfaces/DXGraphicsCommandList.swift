/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Encapsulates a list of graphics commands for rendering. Includes APIs for instrumenting the command list execution, and for setting and clearing the pipeline state.
public final class D3DGraphicsCommandList: D3DCommandList {

    /** Starts a query running.
    - parameter type: Specifies one member of D3D12_QUERY_TYPE.
    - parameter heap: Specifies the ID3D12QueryHeap containing the query.
    - parameter index: Specifies the index of the query within the query heap.
    */
    @inlinable @inline(__always)
    public func beginQuery(_ type: D3DQueryType, on heap: D3DQueryHeap, atIndex index: UInt32 = 0) {
        performFatally(as: RawValue.self) {pThis in
            let pQueryHeap = heap.performFatally(as: D3DQueryHeap.RawValue.self) {$0}
            let Type = type.rawValue
            let Index = index
            pThis.pointee.lpVtbl.pointee.BeginQuery(pThis, pQueryHeap, Type, Index)
        }
    }

    /** Clears the depth-stencil resource.
    - parameter view: Describes the CPU descriptor handle that represents the start of the heap for the depth stencil to be cleared.
    - parameter flags: A combination of D3D12_CLEAR_FLAGS values that are combined by using a bitwise OR operation. The resulting value identifies the type of data to clear (depth buffer, stencil buffer, or both).
    - parameter depthValue: A value to clear the depth buffer with. This value will be clamped between 0 and 1.
    - parameter stencilValue: A value to clear the stencil buffer with.
    - parameter regions: An array of D3D12_RECT structures for the rectangles in the resource view to clear. If NULL, ClearDepthStencilView clears the entire resource view.
    */
    @inlinable @inline(__always)
    public func clearDepthStencilView(_ view: D3DCPUDescriptorHandle,
                                      flags: D3DClearFlags,
                                      depthValue: Float = 1,
                                      stencilValue: UInt8 = 0,
                                      regions: [D3DRect]? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let DepthStencilView = view.rawValue
            let ClearFlags = D3DClearFlags.RawType(flags.rawValue)
            let Depth = depthValue
            let Stencil = stencilValue
            let NumRects = UInt32(regions?.count ?? 0)
            let pRects = regions?.map({$0.RECT()})
            pThis.pointee.lpVtbl.pointee.ClearDepthStencilView(pThis, DepthStencilView, ClearFlags, Depth, Stencil, NumRects, pRects)
        }
    }

    /** Sets all the elements in a render target to one value.
    - parameter view: Specifies a D3D12_CPU_DESCRIPTOR_HANDLE structure that describes the CPU descriptor handle that represents the start of the heap for the render target to be cleared.
    - parameter clearColor: A 4-component array that represents the color to fill the render target with.
    - parameter regions: An array of D3D12_RECT structures for the rectangles in the resource view to clear. If NULL, ClearRenderTargetView clears the entire resource view.
    */
    @inlinable @inline(__always)
    public func clearRenderTargetView(_ view: D3DCPUDescriptorHandle,
                                      withColor clearColor: D3DColor,
                                      regions: [D3DRect]? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let RenderTargetView = view.rawValue
            let ColorRGBA = clearColor.rawValue
            let NumRects = UInt32(regions?.count ?? 0)
            let pRects = regions?.map({$0.RECT()})
            pThis.pointee.lpVtbl.pointee.ClearRenderTargetView(pThis, RenderTargetView, ColorRGBA, NumRects, pRects)
        }
    }

    /** Resets the state of a direct command list back to the state it was in when the command list was created.
    - parameters state: A pointer to the ID3D12PipelineState object that contains the initial pipeline state for the command list.
    It is invalid to call ClearState on a bundle. If an app calls ClearState on a bundle, the call to Close will return E_FAIL.

    When ClearState is called, all currently bound resources are unbound. The primitive topology is set to D3D_PRIMITIVE_TOPOLOGY_UNDEFINED. Viewports, scissor rectangles, stencil reference value, and the blend factor are set to empty values (all zeros). Predication is disabled.

    The app-provided pipeline state object becomes bound as the currently set pipeline state object.
    */
    @inlinable @inline(__always)
    public func clearState(usingInitialPipelineState state: D3DPipelineState) {
        performFatally(as: RawValue.self) {pThis in
            let pPipelineState = state.performFatally(as: D3DPipelineState.RawValue.self) {$0}
            pThis.pointee.lpVtbl.pointee.ClearState(pThis, pPipelineState)
        }
    }

    /** Sets all of the elements in an unordered-access view (UAV) to the specified float values.
    - parameter gpuHandle: A D3D12_GPU_DESCRIPTOR_HANDLE that references an initialized descriptor for the unordered-access view (UAV) that is to be cleared. This descriptor must be in a shader-visible descriptor heap, which must be set on the command list via SetDescriptorHeaps.
    - parameter cpuHandle: A D3D12_CPU_DESCRIPTOR_HANDLE in a non-shader visible descriptor heap that references an initialized descriptor for the unordered-access view (UAV) that is to be cleared. This descriptor must not be in a shader-visible descriptor heap. This is to allow drivers thath implement the clear as fixed-function hardware (rather than via a dispatch) to efficiently read from the descriptor, as shader-visible heaps may be created in WRITE_BACK memory (similar to D3D12_HEAP_TYPE_UPLOAD heap types), and CPU reads from this type of memory are prohibitively slow.
    - parameter resource: A pointer to the ID3D12Resource interface that represents the unordered-access-view (UAV) resource to clear.
    - parameter values: A 4-component array that containing the values to fill the unordered-access-view resource with.
    - parameter regions: An array of D3D12_RECT structures for the rectangles in the resource view to clear. If NULL, ClearUnorderedAccessViewFloat clears the entire resource view.
    */
    @inlinable @inline(__always)
    public func clearUnorderedAccessView(gpuHandle: D3DGPUDescriptorHandle,
                                         cpuHandle: D3DCPUDescriptorHandle,
                                         resource: D3DResource,
                                         floatValues values: [Float],
                                         regions: [D3DRect]? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let ViewGPUHandleInCurrentHeap = gpuHandle.rawValue
            let ViewCPUHandle = cpuHandle.rawValue
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            let Values = values
            let NumRects = UInt32(regions?.count ?? 0)
            let pRects = regions?.map({$0.RECT()})
            pThis.pointee.lpVtbl.pointee.ClearUnorderedAccessViewFloat(pThis, ViewGPUHandleInCurrentHeap, ViewCPUHandle, pResource, Values, NumRects, pRects)
        }
    }

    /** Sets all of the elements in an unordered-access view (UAV) to the specified float values.
    - parameter gpuHandle: A D3D12_GPU_DESCRIPTOR_HANDLE that references an initialized descriptor for the unordered-access view (UAV) that is to be cleared. This descriptor must be in a shader-visible descriptor heap, which must be set on the command list via SetDescriptorHeaps.
    - parameter cpuHandle: A D3D12_CPU_DESCRIPTOR_HANDLE in a non-shader visible descriptor heap that references an initialized descriptor for the unordered-access view (UAV) that is to be cleared. This descriptor must not be in a shader-visible descriptor heap. This is to allow drivers thath implement the clear as fixed-function hardware (rather than via a dispatch) to efficiently read from the descriptor, as shader-visible heaps may be created in WRITE_BACK memory (similar to D3D12_HEAP_TYPE_UPLOAD heap types), and CPU reads from this type of memory are prohibitively slow.
    - parameter resource: A pointer to the ID3D12Resource interface that represents the unordered-access-view (UAV) resource to clear.
    - parameter values: A 4-component array that containing the values to fill the unordered-access-view resource with.
    - parameter regions: An array of D3D12_RECT structures for the rectangles in the resource view to clear. If NULL, ClearUnorderedAccessViewFloat clears the entire resource view.
    */
    @inlinable @inline(__always)
    public func clearUnorderedAccessView(gpuHandle: D3DGPUDescriptorHandle,
                                         cpuHandle: D3DCPUDescriptorHandle,
                                         resource: D3DResource,
                                         uintValues values: [UInt32],
                                         regions: [D3DRect]? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let ViewGPUHandleInCurrentHeap = gpuHandle.rawValue
            let ViewCPUHandle = cpuHandle.rawValue
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            let Values = values
            let NumRects = UInt32(regions?.count ?? 0)
            let pRects = regions?.map({$0.RECT()})
            pThis.pointee.lpVtbl.pointee.ClearUnorderedAccessViewUint(pThis, ViewGPUHandleInCurrentHeap, ViewCPUHandle, pResource, Values, NumRects, pRects)
        }
    }

    /** Indicates that recording to the command list has finished.
    The runtime will validate that the command list has not previously been closed. If an error was encountered during recording, the error code is returned here. The runtime won't call the close device driver interface (DDI) in this case.
    */
    @inlinable @inline(__always)
    public func close() throws {
        try perform(as: RawValue.self) {pThis in
            try pThis.pointee.lpVtbl.pointee.Close(pThis).checkResult(self, #function)
        }
    }

    /** Copies a region of a buffer from one resource to another.
    - parameter source: Specifies the source ID3D12Resource.
    - parameter srcOffset: Specifies a UINT64 offset (in bytes) into the source resource, to start the copy from.
    - parameter destination: Specifies the destination ID3D12Resource.
    - parameter dstOffset: Specifies a UINT64 offset (in bytes) into the destination resource.
    - parameter count: Specifies the number of bytes to copy.
    */
    @inlinable @inline(__always)
    public func copyBufferRegion(from source: D3DResource, at srcOffset: UInt64 = 0, to destination: D3DResource, at dstOffset: UInt64 = 0, count: UInt64) {
        performFatally(as: RawValue.self) {pThis in
            let pDstBuffer = destination.performFatally(as: D3DResource.RawValue.self) {$0}
            let DstOffset = dstOffset
            let pSrcBuffer = source.performFatally(as: D3DResource.RawValue.self) {$0}
            let SrcOffset = srcOffset
            let NumBytes = count
            pThis.pointee.lpVtbl.pointee.CopyBufferRegion(pThis, pDstBuffer, DstOffset, pSrcBuffer, SrcOffset, NumBytes)
        }
    }

    /** Copies the entire contents of the source resource to the destination resource.
    - parameter source: A pointer to the ID3D12Resourceinterface that represents the source resource.
    - parameter destination: A pointer to the ID3D12Resourceinterface that represents the destination resource.
    */
    @inlinable @inline(__always)
    public func copyResource(_ source: D3DResource, to destination: D3DResource) {
        performFatally(as: RawValue.self) {pThis in
            let pDstBuffer = destination.performFatally(as: D3DResource.RawValue.self) {$0}
            let pSrcBuffer = source.performFatally(as: D3DResource.RawValue.self) {$0}
            pThis.pointee.lpVtbl.pointee.CopyResource(pThis, pDstBuffer, pSrcBuffer)
        }
    }

    /** This method uses the GPU to copy texture data between two locations. Both the source and the destination may reference texture data located within either a buffer resource or a texture resource.
    - parameter region: Specifies an optional D3D12_BOX that sets the size of the source texture to copy.
    - parameter source: Specifies the source D3D12_TEXTURE_COPY_LOCATION. The subresource referred to must be in the D3D12_RESOURCE_STATE_COPY_SOURCE state.
    - parameter destination: Specifies the destination D3D12_TEXTURE_COPY_LOCATION. The subresource referred to must be in the D3D12_RESOURCE_STATE_COPY_DEST state.
    - parameter x: The x-coordinate of the upper left corner of the destination region.
    - parameter y: The y-coordinate of the upper left corner of the destination region. For a 1D subresource, this must be zero.
    - parameter z: The z-coordinate of the upper left corner of the destination region. For a 1D or 2D subresource, this must be zero.
    The source box must be within the size of the source resource. The destination offsets, (x, y, and z), allow the source box to be offset when writing into the destination resource; however, the dimensions of the source box and the offsets must be within the size of the resource. If you try and copy outside the destination resource or specify a source box that is larger than the source resource, the behavior of CopyTextureRegion is undefined. If you created a device that supports the debug layer, the debug output reports an error on this invalid CopyTextureRegion call. Invalid parameters to CopyTextureRegion cause undefined behavior and might result in incorrect rendering, clipping, no copy, or even the removal of the rendering device.

    If the resources are buffers, all coordinates are in bytes; if the resources are textures, all coordinates are in texels.

    CopyTextureRegion performs the copy on the GPU (similar to a memcpy by the CPU). As a consequence, the source and destination resources:

    * Must be different subresources (although they can be from the same resource).
    * Must have compatible DXGI_FORMATs (identical or from the same type group). For example, a DXGI_FORMAT_R32G32B32_FLOAT texture can be copied to an DXGI_FORMAT_R32G32B32_UINT texture since both of these formats are in the DXGI_FORMAT_R32G32B32_TYPELESS group. CopyTextureRegion can copy between a few format types. For more info, see Format Conversion using Direct3D 10.1.
    CopyTextureRegion only supports copy; it does not support any stretch, color key, or blend. CopyTextureRegion can reinterpret the resource data between a few format types.
    Note that for a depth-stencil buffer, the depth and stencil planes are separate subresources within the buffer.

    To copy an entire resource, rather than just a region of a subresource, we recommend to use CopyResource instead.
    */
    @inlinable @inline(__always)
    public func copyTextureRegion(_ region: D3DBox,
                                 from source: D3DTextureCopyLocation, 
                                 to destination: D3DTextureCopyLocation, 
                                 atX x: UInt32 = 0, y: UInt32 = 0, z: UInt32 = 0) {
        performFatally(as: RawValue.self) {pThis in
            var pDst = destination.rawValue
            let DstX = x
            let DstY = y
            let DstZ = z
            var pSrc = source.rawValue
            var pSrcBox = region.rawValue
            pThis.pointee.lpVtbl.pointee.CopyTextureRegion(pThis, &pDst, DstX, DstY, DstZ, &pSrc, &pSrcBox)
        }
    }

    /** Copies tiles from buffer to tiled resource or vice versa.
    - parameter tiledResource: A pointer to a tiled resource.
    - parameter start: A pointer to a D3D12_TILED_RESOURCE_COORDINATE structure that describes the starting coordinates of the tiled resource.
    - parameter size: A pointer to a D3D12_TILE_REGION_SIZE structure that describes the size of the tiled region.
    - parameter buffer: A pointer to an ID3D12Resource that represents a default, dynamic, or staging buffer.
    - parameter offset: The offset in bytes into the buffer at pBuffer to start the operation.
    - perameter flags: A combination of D3D12_TILE_COPY_FLAGS-typed values that are combined by using a bitwise OR operation and that identifies how to copy tiles.
    */
    @inlinable @inline(__always)
    public func copyTiles(from tiledResource: D3DResource, at start: D3DTiledResourceCoordinate, size: D3DTileRegionSize,
                          buffer: D3DResource, offset: UInt64,
                          flags: D3DTileCopyFlags) {
        performFatally(as: RawValue.self) {pThis in
            let pTiledResource = tiledResource.performFatally(as: D3DResource.RawValue.self) {$0}
            var pTileRegionStartCoordinate = start.rawValue
            var pTileRegionSize = size.rawValue
            let pBuffer = buffer.performFatally(as: D3DResource.RawValue.self) {$0}
            let BufferStartOffsetInBytes = offset
            let Flags = D3DTileCopyFlags.RawType(flags.rawValue)
            pThis.pointee.lpVtbl.pointee.CopyTiles(pThis, pTiledResource, &pTileRegionStartCoordinate, &pTileRegionSize, pBuffer, BufferStartOffsetInBytes, Flags)
        }
    }

    /** Indicates that the contents of a resource don't need to be preserved. The function may re-initialize resource metadata in some cases.
    - parameter resource: A pointer to the ID3D12Resource interface for the resource to discard.
    - parameter region: A pointer to a D3D12_DISCARD_REGION structure that describes details for the discard-resource operation.
    */
    @inlinable @inline(__always)
    public func discardResource(_ resource: D3DResource, region: D3DDiscardRegion? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let pResource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            if var pRegion = region?.rawValue {
                pThis.pointee.lpVtbl.pointee.DiscardResource(pThis, pResource, &pRegion)
            }else{
                pThis.pointee.lpVtbl.pointee.DiscardResource(pThis, pResource, nil)
            }
        }
    }

    /** Executes a command list from a thread group.
    - parameter countX: The number of groups dispatched in the x direction. ThreadGroupCountX must be less than or equal to D3D11_CS_DISPATCH_MAX_THREAD_GROUPS_PER_DIMENSION (65535).
    - parameter countY: The number of groups dispatched in the y direction. ThreadGroupCountY must be less than or equal to D3D11_CS_DISPATCH_MAX_THREAD_GROUPS_PER_DIMENSION (65535).
    - parameter countZ: The number of groups dispatched in the z direction. ThreadGroupCountZ must be less than or equal to D3D11_CS_DISPATCH_MAX_THREAD_GROUPS_PER_DIMENSION (65535). In feature level 10 the value for ThreadGroupCountZ must be 1.
    */
    @inlinable @inline(__always)
    public func dispatch(countX: UInt32, countY: UInt32 = 1, countZ: UInt32 = 1) {
        performFatally(as: RawValue.self) {pThis in
            pThis.pointee.lpVtbl.pointee.Dispatch(pThis, countX, countY, countZ)
        }
    }

    /** Draws indexed, instanced primitives.
    - parameter instanceCount: Number of instances to draw.
    - parameter instanceStartIndex: A value added to each index before reading per-instance data from a vertex buffer.
    - parameter indexCount: Number of indices read from the index buffer for each instance.
    - parameter startIndex: The location of the first index read by the GPU from the index buffer.
    - parameter baseVertexLocation: A value added to each index before reading a vertex from the vertex buffer.
    */
    @inlinable @inline(__always)
    public func drawIndexedInstanced(indexCountPerInstance: UInt32,
                                     instanceCount: UInt32,
                                     startIndexLocation: UInt32,
                                     baseVertexLocation: Int32,
                                     startInstanceLocation: UInt32) {
        performFatally(as: RawValue.self) {pThis in
            let IndexCountPerInstance = indexCountPerInstance
            let InstanceCount = instanceCount
            let StartIndexLocation = startIndexLocation
            let BaseVertexLocation = baseVertexLocation
            let StartInstanceLocation = startInstanceLocation
            pThis.pointee.lpVtbl.pointee.DrawIndexedInstanced(pThis, IndexCountPerInstance, InstanceCount, StartIndexLocation, BaseVertexLocation, StartInstanceLocation)
        }
    }

    /** Draws non-indexed, instanced primitives.
    - parameter vertexCountPerInstance: Number of vertices to draw.
    - parameter instanceCount: Number of instances to draw.
    - parameter startVertexLocation: Index of the first vertex.
    - parameter startInstanceLocation: A value added to each index before reading per-instance data from a vertex buffer.
    */
    @inlinable @inline(__always)
    public func drawInstanced(vertexCountPerInstance: UInt32,
                              instanceCount: UInt32, 
                              startVertexLocation: UInt32, 
                              startInstanceLocation: UInt32) {
        performFatally(as: RawValue.self) {pThis in
            let VertexCountPerInstance = vertexCountPerInstance
            let InstanceCount = instanceCount
            let StartVertexLocation = startVertexLocation
            let StartInstanceLocation = startInstanceLocation
            pThis.pointee.lpVtbl.pointee.DrawInstanced(pThis, VertexCountPerInstance, InstanceCount, StartVertexLocation, StartInstanceLocation)
        }
    }

    /** Ends a running query.
    - parameter queryHeap: Specifies the ID3D12QueryHeap containing the query.
    - parameter type: Specifies one member of D3D12_QUERY_TYPE.
    - parameter index: Specifies the index of the query in the query heap.
    */
    @inlinable @inline(__always)
    public func endQuery(_ queryHeap: D3DQueryHeap, type: D3DQueryType, index: UInt32 = 0) {
        performFatally(as: RawValue.self) {pThis in
            let pQueryHeap = queryHeap.performFatally(as: D3DQueryHeap.RawValue.self) {$0}
            let Type = type.rawValue
            let Index = index
            pThis.pointee.lpVtbl.pointee.EndQuery(pThis, pQueryHeap, Type, Index)
        }
    }
    
    /** Executes a bundle.
    - parameter bundle: Specifies the ID3D12GraphicsCommandList that determines the bundle to be executed.
    */
    @inlinable @inline(__always)
    public func executeBundle(_ bundle: D3DGraphicsCommandList) {
        performFatally(as: RawValue.self) {pThis in
            let pCommandList = bundle.performFatally(as: D3DGraphicsCommandList.RawValue.self) {$0}
            pThis.pointee.lpVtbl.pointee.ExecuteBundle(pThis, pCommandList)
        }
    }

    /** Apps perform indirect draws/dispatches using the ExecuteIndirect method.
    - parameter signature: Specifies a ID3D12CommandSignature. The data referenced by pArgumentBuffer will be interpreted depending on the contents of the command signature. Refer to Indirect Drawing for the APIs that are used to create a command signature.
    - parameter maxCount: There are two ways that command counts can be specified: If pCountBuffer is not NULL, then MaxCommandCount specifies the maximum number of operations which will be performed. The actual number of operations to be performed are defined by the minimum of this value, and a 32-bit unsigned integer contained in pCountBuffer (at the byte offset specified by CountBufferOffset). If pCountBuffer is NULL, the MaxCommandCount specifies the exact number of operations which will be performed.
    - parameter argumentBuffer: Specifies one or more ID3D12Resource objects, containing the command arguments.
    - parameter argumentBufferOffset: Specifies an offset into pArgumentBuffer to identify the first command argument.
    - parameter countBuffer: Specifies a pointer to a ID3D12Resource.
    - parameter countBufferOffset: Specifies a UINT64 that is the offset into pCountBuffer, identifying the argument count.
    */
    @inlinable @inline(__always)
    public func executeIndirect(signature: D3DCommandSignature,
                                maxCount: UInt32,
                                argumentBuffer: D3DResource,
                                argumentBufferOffset: UInt64,
                                countBuffer: D3DResource,
                                countBufferOffset: UInt64) {
        performFatally(as: RawValue.self) {pThis in
            let pCommandSignature = signature.performFatally(as: D3DCommandSignature.RawValue.self) {$0}
            let MaxCommandCount = maxCount
            let pArgumentBuffer = argumentBuffer.performFatally(as: D3DResource.RawValue.self) {$0}
            let ArgumentBufferOffset = argumentBufferOffset
            let pCountBuffer = countBuffer.performFatally(as: D3DResource.RawValue.self) {$0}
            let CountBufferOffset = countBufferOffset
            pThis.pointee.lpVtbl.pointee.ExecuteIndirect(pThis, pCommandSignature, MaxCommandCount, pArgumentBuffer, ArgumentBufferOffset, pCountBuffer, CountBufferOffset)
        }
    }

    /** Sets the view for the index buffer.
    - parameter view: The view specifies the index buffer's address, size, and DXGI_FORMAT, as a pointer to a D3D12_INDEX_BUFFER_VIEW structure.
    */
    @inlinable @inline(__always)
    public func setIndexBuffer(_ view: D3DIndexBufferView) {
        performFatally(as: RawValue.self) {pThis in
            var pView = view.rawValue
            pThis.pointee.lpVtbl.pointee.IASetIndexBuffer(pThis, &pView)
        }
    }

    /** Bind information about the primitive type, and data order that describes input data for the input assembler stage.
    - parameter primitiveTopology: The type of primitive and ordering of the primitive data (see D3D_PRIMITIVE_TOPOLOGY).
    */
    @inlinable @inline(__always)
    public func setPrimitiveTopology(_ primitiveTopology: D3DPrimitiveTopology) {
        performFatally(as: RawValue.self) {pThis in
            let PrimitiveTopology = primitiveTopology.rawValue
            pThis.pointee.lpVtbl.pointee.IASetPrimitiveTopology(pThis, PrimitiveTopology)
        }
    }

    /** Sets a CPU descriptor handle for the vertex buffers.
    - parameter buffers: Specifies the vertex buffer views in an array of D3D12_VERTEX_BUFFER_VIEW structures.
    - parameter startSlot: Sets a CPU descriptor handle for the vertex buffers.
    */
    @inlinable @inline(__always)
    public func setVertexBuffers(_ buffers: [D3DVertexBufferView], startingAt startSlot: UInt32) {
       performFatally(as: RawValue.self) {pThis in
            let StartSlot = startSlot
            let NumViews = UInt32(buffers.count)
            let pViews = buffers.map({$0.rawValue})
            pThis.pointee.lpVtbl.pointee.IASetVertexBuffers(pThis, StartSlot, NumViews, pViews)
        }
    }

    /** Sets the blend factor that modulate values for a pixel shader, render target, or both.
    - parameter red: Array of blend factors, one for each RGBA component.
    - parameter green: Array of blend factors, one for each RGBA component.
    - parameter blue: Array of blend factors, one for each RGBA component.
    - parameter alpha: Array of blend factors, one for each RGBA component.
    */
    @inlinable @inline(__always)
    public func setBlendFactor(red: Float, green: Float, blue: Float, alpha: Float) {
       performFatally(as: RawValue.self) {pThis in
            let BlendFactor = [red, green, blue, alpha]
            pThis.pointee.lpVtbl.pointee.OMSetBlendFactor(pThis, BlendFactor)
        }
    }
    
    /** Sets the blend factor that modulate values for a pixel shader, render target, or both.
    - parameter blendFactor: Array of blend factors, one for each RGBA component.
    */
    @inlinable @inline(__always)
    public func setBlendFactor(_ blendFactor: [Float]) throws {
        try perform(as: RawValue.self) {pThis in
            guard blendFactor.count == 4 else {throw Error(.invalidArgument)}
            let BlendFactor = blendFactor
            pThis.pointee.lpVtbl.pointee.OMSetBlendFactor(pThis, BlendFactor)
        }
    }

    /** Sets CPU descriptor handles for the render targets and depth stencil.
    - parameter renderTargets: Specifies an array of D3D12_CPU_DESCRIPTOR_HANDLE structures that describe the CPU descriptor handles that represents the start of the heap of render target descriptors. If this parameter is NULL and NumRenderTargetDescriptors is 0, no render targets are bound.
    - parameter depthStencil: A pointer to a D3D12_CPU_DESCRIPTOR_HANDLE structure that describes the CPU descriptor handle that represents the start of the heap that holds the depth stencil descriptor. If this parameter is NULL, no depth stencil descriptor is bound.
    */
    @inlinable @inline(__always)
    public func setRenderTargets(_ renderTargets: [D3DCPUDescriptorHandle], depthStencil: D3DCPUDescriptorHandle? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let NumRenderTargetDescriptors = UInt32(renderTargets.count)
            let pRenderTargetDescriptors = renderTargets.map({$0.rawValue})
            let RTsSingleHandleToDescriptorRange = WindowsBool(booleanLiteral: true) //We just made sure they are contiguous
            if var pDepthStencilDescriptor = depthStencil?.rawValue {
                pThis.pointee.lpVtbl.pointee.OMSetRenderTargets(pThis, NumRenderTargetDescriptors, pRenderTargetDescriptors, RTsSingleHandleToDescriptorRange, &pDepthStencilDescriptor)
            }else{
                pThis.pointee.lpVtbl.pointee.OMSetRenderTargets(pThis, NumRenderTargetDescriptors, pRenderTargetDescriptors, RTsSingleHandleToDescriptorRange, nil)
            }
        }
    }

    /** Sets the reference value for depth stencil tests.
    - parameter reference: Reference value to perform against when doing a depth-stencil test.
    */
    @inlinable @inline(__always)
    public func setStencilReference(_ reference: UInt32) {
        performFatally(as: RawValue.self) {pThis in
            let StencilRef = reference
            pThis.pointee.lpVtbl.pointee.OMSetStencilRef(pThis, StencilRef)
        }
    }

    /** Resets a command list back to its initial state as if a new command list was just created.
    - parameter commandAllocator: A pointer to the ID3D12CommandAllocator object that the device creates command lists from.
    - parameter state: A pointer to the ID3D12PipelineState object that contains the initial pipeline state for the command list. This is optional and can be NULL. If NULL, the runtime sets a dummy initial pipeline state so that drivers don't have to deal with undefined state. The overhead for this is low, particularly for a command list, for which the overall cost of recording the command list likely dwarfs the cost of one initial state setting. So there is little cost in not setting the initial pipeline state parameter if it isn't convenient. For bundles on the other hand, it might make more sense to try to set the initial state parameter since bundles are likely smaller overall and can be reused frequently.
    */
    @inlinable @inline(__always)
    public func reset(usingOriginalAllocator commandAllocator: D3DCommandAllocator, withInitialState state: D3DPipelineState?) throws {
        try perform(as: RawValue.self) {pThis in
            let pAllocator = commandAllocator.perform(as: D3DCommandAllocator.RawValue.self) {$0}
            if let pInitialState = state?.perform(as: D3DPipelineState.RawValue.self, body: {$0}) {
                try pThis.pointee.lpVtbl.pointee.Reset(pThis, pAllocator, pInitialState).checkResult(self, #function)
            }else{
                try pThis.pointee.lpVtbl.pointee.Reset(pThis, pAllocator, nil).checkResult(self, #function)
            }
        }
    }

    /** Extracts data from a query. ResolveQueryData works with all heap types (default, upload, and readback).
    - parameter query: Specifies the ID3D12QueryHeap containing the queries to resolve.
    - parameter type: Specifies the type of query, one member of D3D12_QUERY_TYPE.
    - parameter startIndex: Specifies an index of the first query to resolve.
    - parameter count: Specifies the number of queries to resolve.
    - parameter destination: Specifies an ID3D12Resource destination buffer, which must be in the state D3D12_RESOURCE_STATE_COPY_DEST.
    - parameter offset: Specifies an alignment offset into the destination buffer. Must be a multiple of 8 bytes.
    */
    @inlinable @inline(__always)
    public func resolveQueryData(fromHeap query: D3DQueryHeap, ofType type: D3DQueryType, at startIndex: UInt32, count: UInt32, toResource destination: D3DResource, at offset: UInt64) {
        performFatally(as: RawValue.self) {pThis in
            let pQueryHeap = query.performFatally(as: D3DQueryHeap.RawValue.self) {$0}
            let Type = type.rawValue
            let StartIndex = startIndex
            let NumQueries = count
            let pDestinationBuffer = destination.performFatally(as: D3DResource.RawValue.self) {$0}
            let AlignedDestinationBufferOffset = offset
            pThis.pointee.lpVtbl.pointee.ResolveQueryData(pThis, pQueryHeap, Type, StartIndex, NumQueries, pDestinationBuffer, AlignedDestinationBufferOffset)
        }
    }

    /** Copy a multi-sampled resource into a non-multi-sampled resource.
    - parameter source: Source resource. Must be multisampled.
    - parameter srcIndex: The source subresource of the source resource.
    - parameter destination: Destination resource. Must be a created on a D3D12_HEAP_TYPE_DEFAULT heap and be single-sampled. See ID3D12Resource.
    - parameter dstIndex: A zero-based index, that identifies the destination subresource. Use D3D12CalcSubresource to calculate the subresource index if the parent resource is complex.
    - parameter format: A DXGI_FORMAT that indicates how the multisampled resource will be resolved to a single-sampled resource. See remarks.
    */
    @inlinable @inline(__always)
    public func resolveSubresource(from source: D3DResource, at srcIndex: UInt32, to destination: D3DResource, at dstIndex: UInt32, format: DGIFormat) {
        performFatally(as: RawValue.self) {pThis in
            let pDstResource = destination.performFatally(as: D3DResource.RawValue.self) {$0}
            let DstSubresource = dstIndex
            let pSrcResource = source.performFatally(as: D3DResource.RawValue.self) {$0}
            let SrcSubresource = srcIndex
            let Format = format.rawValue
            pThis.pointee.lpVtbl.pointee.ResolveSubresource(pThis, pDstResource, DstSubresource, pSrcResource, SrcSubresource, Format)
        }
    }

    /** Notifies the driver that it needs to synchronize multiple accesses to resources.
    - parameter barriers: Pointer to an array of barrier descriptions.
    */
    @inlinable @inline(__always)
    public func resourceBarrier(_ barriers: [D3DResourceBarrier]) {
        performFatally(as: RawValue.self) {pThis in
            let NumBarriers = UInt32(barriers.count)
            let pBarriers = barriers.map({$0.rawValue})
            pThis.pointee.lpVtbl.pointee.ResourceBarrier(pThis, NumBarriers, pBarriers)
        }
    }

    /** Binds an array of scissor rectangles to the rasterizer stage.
    - parameter rects: An array of scissor rectangles.
    */
    @inlinable @inline(__always)
    public func setScissorRects(_ rects: [D3DRect]) {
        performFatally(as: RawValue.self) {pThis in
            let NumRects = UInt32(rects.count)
            let pRects = rects.map({$0.RECT()})
            pThis.pointee.lpVtbl.pointee.RSSetScissorRects(pThis, NumRects, pRects)
        }
    }

    /** Bind an array of viewports to the rasterizer stage of the pipeline.
    - parameter viewports: An array of D3D12_VIEWPORT structures to bind to the device.
    */
    @inlinable @inline(__always)
    public func setViewports(_ viewports: [D3DViewport]) {
        performFatally(as: RawValue.self) {pThis in
            let NumViewports = UInt32(viewports.count)
            let pViewports = viewports.map({$0.rawValue})
            pThis.pointee.lpVtbl.pointee.RSSetViewports(pThis, NumViewports, pViewports)
        }
    }

    /** Sets a constant in the compute root signature.
    - parameter index: The slot number for binding.
    - parameter data: The source data for the constant to set.
    - parameter offset: The offset, in 32-bit values, to set the constant in the root signature.
    */
    @inlinable @inline(__always)
    public func setComputeRoot32BitConstant(at index: UInt32, data: UInt32, offset: UInt32) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = index
            let SrcData = data
            let DestOffsetIn32BitValues = offset
            pThis.pointee.lpVtbl.pointee.SetComputeRoot32BitConstant(pThis, RootParameterIndex, SrcData, DestOffsetIn32BitValues)
        }
    }

    /** Sets a constant in the compute root signature.
    - parameter index: The slot number for binding.
    - parameter data: The source data for the group of constants to set.
    - parameter offset: The offset, in 32-bit values, to set the constant in the root signature.
    */
    @inlinable @inline(__always)
    public func setComputeRoot32BitConstants(at index: UInt32, data: [UInt32], offset: UInt32) {
       performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = index
            let Num32BitValuesToSet = UInt32(data.count)
            let SrcData = data
            let DestOffsetIn32BitValues = offset
            pThis.pointee.lpVtbl.pointee.SetComputeRoot32BitConstants(pThis, RootParameterIndex, Num32BitValuesToSet, SrcData, DestOffsetIn32BitValues)
        }
    }

    /** Sets a CPU descriptor handle for the constant buffer in the compute root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter gpuBufferLocation: Specifies the D3D12_GPU_VIRTUAL_ADDRESS of the constant buffer.
    */
    @inlinable @inline(__always)
    public func setComputeRootConstantBufferView(parameterIndex: UInt32, gpuBufferLocation: D3DGPUVirtualAddress) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BufferLocation = gpuBufferLocation
            pThis.pointee.lpVtbl.pointee.SetComputeRootConstantBufferView(pThis, RootParameterIndex, BufferLocation)
        }
    }

    /** Sets a descriptor table into the compute root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter descriptor: A GPU_descriptor_handle object for the base descriptor to set.
    */
    @inlinable @inline(__always)
    public func setComputeRootDescriptorTable(parameterIndex: UInt32, descriptor: D3DGPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BaseDescriptor = descriptor.rawValue
            pThis.pointee.lpVtbl.pointee.SetComputeRootDescriptorTable(pThis, RootParameterIndex, BaseDescriptor)
        }
    }

    /** Sets a CPU descriptor handle for the shader resource in the compute root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter gpuBufferLocation: The GPU virtual address of the buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd alias of UINT64.
    */
    @inlinable @inline(__always)
    public func setComputeRootShaderResourceView(parameterIndex: UInt32, gpuBufferLocation: D3DGPUVirtualAddress) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BufferLocation = gpuBufferLocation
            pThis.pointee.lpVtbl.pointee.SetComputeRootShaderResourceView(pThis, RootParameterIndex, BufferLocation)
        }
    }

    /** Sets the layout of the compute root signature.
    - paramerter rootSignature: A pointer to the ID3D12RootSignature object.
    */
    @inlinable @inline(__always)
    public func setComputeRootSignature(_ rootSignature: D3DRootSignature) {
        performFatally(as: RawValue.self) {pThis in
            let pRootSignature = rootSignature.performFatally(as: D3DRootSignature.RawValue.self) {$0}
            pThis.pointee.lpVtbl.pointee.SetComputeRootSignature(pThis, pRootSignature)
        }
    }

    /** Sets a CPU descriptor handle for the unordered-access-view resource in the compute root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter gpuBufferLocation: The GPU virtual address of the buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd alias of UINT64.
    */
    @inlinable @inline(__always)
    public func setComputeRootUnorderedAccessView(parameterIndex: UInt32, gpuBufferLocation: D3DGPUVirtualAddress) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BufferLocation = gpuBufferLocation
            pThis.pointee.lpVtbl.pointee.SetComputeRootUnorderedAccessView(pThis, RootParameterIndex, BufferLocation)
        }
    }

    /** Changes the currently bound descriptor heaps that are associated with a command list.
    - parameter heaps: A pointer to an array of ID3D12DescriptorHeap objects for the heaps to set on the command list. You can only bind descriptor heaps of type D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV and D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER. Only one descriptor heap of each type can be set at one time, which means a maximum of 2 heaps (one sampler, one CBV/SRV/UAV) can be set at one time.
    */
    @inlinable @inline(__always)
    public func setDescriptorHeaps(_ heaps: [D3DDescriptorHeap]) {
        performFatally(as: RawValue.self) {pThis in
            let NumDescriptorHeaps = UInt32(heaps.count)
            let ppDescriptorHeaps = heaps.map({$0.performFatally(as: D3DDescriptorHeap.RawValue.self) {Optional($0)}})
            pThis.pointee.lpVtbl.pointee.SetDescriptorHeaps(pThis, NumDescriptorHeaps, ppDescriptorHeaps)
        }
    }

    /** Sets a constant in the graphics root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter data: The source data for the constant to set.
    - parameter offset: The offset, in 32-bit values, to set the constant in the root signature.
    */
    @inlinable @inline(__always)
    public func setGraphicsRoot32BitConstant(parameterIndex: UInt32, data: UInt32, offset: UInt32) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let SrcData = data
            let DestOffsetIn32BitValues = offset
            pThis.pointee.lpVtbl.pointee.SetGraphicsRoot32BitConstant(pThis, RootParameterIndex, SrcData, DestOffsetIn32BitValues)
        }
    }

    /** Sets a constant in the graphics root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter data: The source data for the group of constants to set.
    - parameter offset: The offset, in 32-bit values, to set the constant in the root signature.
    */
    @inlinable @inline(__always)
    public func setGraphicsRoot32BitConstant(parameterIndex: UInt32, data: [UInt32], offset: UInt32) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let Num32BitValuesToSet = UInt32(data.count)
            let SrcData = data
            let DestOffsetIn32BitValues = offset
            pThis.pointee.lpVtbl.pointee.SetGraphicsRoot32BitConstants(pThis, RootParameterIndex, Num32BitValuesToSet, SrcData, DestOffsetIn32BitValues)
        }
    }

    /** Sets a CPU descriptor handle for the constant buffer in the graphics root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter gpuBufferLocation: The GPU virtual address of the buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd alias of UINT64.
    */
    @inlinable @inline(__always)
    public func setGraphicsRootConstantBufferView(parameterIndex: UInt32, gpuBufferLocation: D3DGPUVirtualAddress) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BufferLocation = gpuBufferLocation
            pThis.pointee.lpVtbl.pointee.SetGraphicsRootConstantBufferView(pThis, RootParameterIndex, BufferLocation)
        }
    }

    /** Sets a descriptor table into the graphics root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter baseDescriptor: A GPU_descriptor_handle object for the base descriptor to set.
    */
    @inlinable @inline(__always)
    public func setGraphicsRootDescriptorTable(parameterIndex: UInt32, baseDescriptor: D3DGPUDescriptorHandle) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BaseDescriptor = baseDescriptor.rawValue
            pThis.pointee.lpVtbl.pointee.SetGraphicsRootDescriptorTable(pThis, RootParameterIndex, BaseDescriptor)
        }
    }

    /** Sets a CPU descriptor handle for the constant buffer in the graphics root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter gpuBufferLocation: The GPU virtual address of the buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd alias of UINT64.
    */
    @inlinable @inline(__always)
    public func setGraphicsRootShaderResourceView(parameterIndex: UInt32, gpuBufferLocation: D3DGPUVirtualAddress) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BufferLocation = gpuBufferLocation
            pThis.pointee.lpVtbl.pointee.SetGraphicsRootShaderResourceView(pThis, RootParameterIndex, BufferLocation)
        }
    }

    /** Sets the layout of the graphics root signature.
    - paramerter rootSignature: A pointer to the ID3D12RootSignature object.
    */
    @inlinable @inline(__always)
    public func setGraphicsRootSignature(_ rootSignature: D3DRootSignature) {
        performFatally(as: RawValue.self) {pThis in
            let pRootSignature = rootSignature.performFatally(as: D3DRootSignature.RawValue.self) {$0}
            pThis.pointee.lpVtbl.pointee.SetGraphicsRootSignature(pThis, pRootSignature)
        }
    }
    
    /** Sets a CPU descriptor handle for the unordered-access-view resource in the graphics root signature.
    - parameter parameterIndex: The slot number for binding.
    - parameter gpuBufferLocation: The GPU virtual address of the buffer. D3D12_GPU_VIRTUAL_ADDRESS is a typedef'd alias of UINT64.
    */
    @inlinable @inline(__always)
    public func setGraphicsRootUnorderedAccessView(parameterIndex: UInt32, gpuBufferLocation: D3DGPUVirtualAddress) {
        performFatally(as: RawValue.self) {pThis in
            let RootParameterIndex = parameterIndex
            let BufferLocation = gpuBufferLocation
            pThis.pointee.lpVtbl.pointee.SetGraphicsRootUnorderedAccessView(pThis, RootParameterIndex, BufferLocation)
        }
    }

    /** Sets all shaders and programs most of the fixed-function state of the graphics processing unit (GPU) pipeline.
    - parameter pipelineState: Pointer to the ID3D12PipelineState containing the pipeline state data.
    */
    @inlinable @inline(__always)
    public func setPipelineState(_ pipelineState: D3DPipelineState) {
       performFatally(as: RawValue.self) {pThis in
            let pPipelineState = pipelineState.performFatally(as: D3DPipelineState.RawValue.self) {$0}
            pThis.pointee.lpVtbl.pointee.SetPipelineState(pThis, pPipelineState)
        }
    }

    /** Sets a rendering predicate.
    - parameter buffer: The buffer, as an ID3D12Resource, which must be in the D3D12_RESOURCE_STATE_PREDICATION or D3D21_RESOURCE_STATE_INDIRECT_ARGUMENT state (both values are identical, and provided as aliases for clarity), or NULL to disable predication.
    - parameter offset: The aligned buffer offset, as a UINT64.
    - parameter operation: Specifies a D3D12_PREDICATION_OP, such as D3D12_PREDICATION_OP_EQUAL_ZERO or D3D12_PREDICATION_OP_NOT_EQUAL_ZERO.
    */
    @inlinable @inline(__always)
    public func setPredication(_ buffer: D3DResource, offset: UInt64, operation: D3DPredictionOperation) {
        performFatally(as: RawValue.self) {pThis in
            let pBuffer = buffer.performFatally(as: D3DResource.RawValue.self) {$0}
            let AlignedBufferOffset = offset
            let Operation = operation.rawValue
            pThis.pointee.lpVtbl.pointee.SetPredication(pThis, pBuffer, AlignedBufferOffset, Operation)
        }
    }

    /** Sets the stream output buffer views.
    - parameter views: Index into the device's zero-based array to begin setting stream output buffers.
    - parameter startIndex: Specifies an array of D3D12_STREAM_OUTPUT_BUFFER_VIEW structures.
    */
    @inlinable @inline(__always)
    public func setTargets(_ views: [D3DStreamOutputBufferView], at startIndex: UInt32 = 0) {
       performFatally(as: RawValue.self) {pThis in
            let StartSlot = startIndex
            let NumViews = UInt32(views.count)
            let pViews = views.map({$0.rawValue})
            pThis.pointee.lpVtbl.pointee.SOSetTargets(pThis, StartSlot, NumViews, pViews)
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {
        // if #available(Windows 10.0.15063, *) {
        //     return RawValue1.interfaceID//ID3D12GraphicsCommandList1
        // }else{
            return RawValue.interfaceID //ID3D12GraphicsCommandList
        // }
    }
}

extension D3DGraphicsCommandList {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12GraphicsCommandList
}
extension D3DGraphicsCommandList.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12GraphicsCommandList}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DGraphicsCommandList")
public typealias ID3D12GraphicsCommandList = D3DGraphicsCommandList

public extension D3DGraphicsCommandList {
    @available(*, unavailable, message: "Not intended to be called directly. Use the PIX event runtime to insert events into a command queue.")
    func BeginEvent(_ Metadata: Any, _ pData: Any, _ Size: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "beginQuery(_:on:atIndex:)")
    func BeginQuery(_ pQueryHeap: Any, _ Type: Any, _ Index: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "clearDepthStencilView")
    func ClearDepthStencilView(_ DepthStencilView: Any, 
                               _ ClearFlags: Any, 
                               _ Depth: Any,
                               _ Stencil: Any,
                               _ NumRects: Any,
                               _ pRects: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "clearRenderTargetView")
    func ClearRenderTargetView(_ RenderTargetView: Any, 
                               _ ColorRGBA: Any, 
                               _ NumRects: Any,
                               _ pRects: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "clearState(usingInitialPipelineState:)")
    func ClearState(_ pPipelineState: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "clearUnorderedAccessView(gpuHandle:cpuHandle:resource:floatValues:regions:)")
    func ClearUnorderedAccessViewFloat(_ ViewGPUHandleInCurrentHeap: Any, 
                                       _ ViewCPUHandle: Any, 
                                       _ pResource: Any,
                                       _ Values: Any,
                                       _ NumRects: Any,
                                       _ pRects: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "clearUnorderedAccessView(gpuHandle:cpuHandle:resource:uintValues:regions:)")
    func ClearUnorderedAccessViewUint(_ ViewGPUHandleInCurrentHeap: Any, 
                                      _ ViewCPUHandle: Any, 
                                      _ pResource: Any,
                                      _ Values: Any,
                                      _ NumRects: Any,
                                      _ pRects: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "close()")
    func Close() -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyBufferRegion(from:at:to:at:count:)")
    func CopyBufferRegion(_ pDstBuffer: Any, 
                          _ DstOffset: Any, 
                          _ pSrcBuffer: Any,
                          _ SrcOffset: Any,
                          _ NumBytes: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyResource(from:to:)")
    func CopyResource(_ pDstResource: Any,
                      _ pSrcResource: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyTextureRegion(_:from:to:atX:y:z:)")
    func CopyTextureRegion(_ pDst: Any,
                           _ DstX: Any,
                           _ DstY: Any,
                           _ DstZ: Any,
                           _ pSrc: Any,
                           _ pSrcBox: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyTiles(from:at:size:buffer:offset:flags:)")
    func CopyTiles(_ pTiledResource: Any,
                   _ pTileRegionStartCoordinate: Any,
                   _ pTileRegionSize: Any,
                   _ pBuffer: Any,
                   _ BufferStartOffsetInBytes: Any,
                   _ Flags: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "discardResource(_:region:)")
    func DiscardResource(_ pResource: Any,
                         _ pRegion: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "dispatch(countX:countY:countZ:)")
    func Dispatch(_ ThreadGroupCountX: Any,
                  _ ThreadGroupCountY: Any,
                  _ ThreadGroupCountZ: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "drawIndexedInstanced(indexCountPerInstance:instanceCount:startIndexLocation:baseVertexLocation:startInstanceLocation:)")
    func DrawIndexedInstanced(_ IndexCountPerInstance: Any,
                              _ InstanceCount: Any,
                              _ StartIndexLocation: Any,
                              _ BaseVertexLocation: Any,
                              _ StartInstanceLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "drawInstanced(vertexCountPerInstance:instanceCount:startVertexLocation:startInstanceLocation:)")
    func DrawInstanced(_ VertexCountPerInstance: Any,
                       _ InstanceCount: Any,
                       _ StartVertexLocation: Any,
                       _ StartInstanceLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, message: "Not intended to be called directly. Use the PIX event runtime to insert events into a command queue.")
    func EndEvent(_ Metadata: Any, _ pData: Any, _ Size: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "endQuery(_:type:index:)")
    func EndQuery(_ pQueryHeap: Any, _ Type: Any, _ Index: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "executeBundle(_:)")
    func ExecuteBundle(_ pCommandList: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "executeIndirect(signature:maxCount:argumentBuffer:offset:countBuffer:offset:)")
    func ExecuteIndirect(_ pCommandSignature: Any,
                         _ MaxCommandCount: Any,
                         _ pArgumentBuffer: Any,
                         _ ArgumentBufferOffset: Any,
                         _ pCountBuffer: Any?,
                         _ CountBufferOffset: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setIndexBuffer(_:)")
    func IASetIndexBuffer(_ pView: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setPrimitiveTopology(_:)")
    func IASetPrimitiveTopology(_ PrimitiveTopology: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
    
    @available(*, unavailable, renamed: "setVertexBuffers(_:startingAt:)")
    func IASetVertexBuffers(_ StartSlot: Any,
                            _ NumViews: Any,
                            _ pViews: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setBlendFactor(_:)")
    func OMSetBlendFactor(_ BlendFactor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setRenderTargets(_:depthStencilDescriptor:)")
    func OMSetRenderTargets(_ NumRenderTargetDescriptors: Any,
                            _ pRenderTargetDescriptors: Any,
                            _ RTsSingleHandleToDescriptorRange: Any,
                            _ pDepthStencilDescriptor: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setStencilReference(_:)")
    func OMSetStencilRef(_ StencilRef: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "reset(usingOriginalAllocator:withInitialState:)")
    func RESET(_ pAllocator: Any,
               _ pInitialState: Any?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "resolveQueryData(fromHeap:ofType:at:count:toResource:at:)")
    func ResolveQueryData(_ pQueryHeap: Any,
                          _ Type: Any,
                          _ StartIndex: Any,
                          _ NumQueries: Any,
                          _ pDestinationBuffer: Any,
                          _ AlignedDestinationBufferOffset: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "resolveSubresource(from:at:to:at:format:)")
    func ResolveSubresource(_ pDstResource: Any,
                            _ DstSubresource: Any,
                            _ pSrcResource: Any,
                            _ SrcSubresource: Any,
                            _ Format: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "resourceBarrier(_:)")
    func ResourceBarrier(_ NumBarriers: Any,
                         _ pBarriers: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setScissorRects(_:)")
    func RSSetScissorRects(_ NumRects: Any,
                           _ pRects: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setViewports(_:)")
    func RSSetViewports(_ NumViewports: Any,
                        _ pViewports: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setComputeRoot32BitConstants(at:data:offset:)")
    func SetComputeRoot32BitConstants(_ RootParameterIndex: Any,
                                     _ Num32BitValuesToSet: Any,
                                     _ SrcData: Any,
                                     _ DestOffsetIn32BitValues: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setComputeRootConstantBufferView(parameterIndex:gpuBufferLocation:)")
    func SetComputeRootConstantBufferView(_ RootParameterIndex: Any,
                                          _ BufferLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setComputeRootDescriptorTable(parameterIndex:descriptor:)")
    func SetComputeRootDescriptorTable(_ RootParameterIndex: Any,
                                       _ BaseDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setComputeRootShaderResourceView(parameterIndex:gpuBufferLocation:)")
    func SetComputeRootShaderResourceView(_ RootParameterIndex: Any,
                                          _ BufferLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setComputeRootSignature(_:)")
    func SetComputeRootSignature(_ pRootSignature: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setComputeRootUnorderedAccessView(parameterIndex:gpuBufferLocation:)")
    func SetComputeRootUnorderedAccessView(_ RootParameterIndex: Any,
                                           _ BufferLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setDescriptorHeaps(_:)")
    func SetDescriptorHeaps(_ NumDescriptorHeaps: Any,
                            _ ID3D12DescriptorHeap: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRoot32BitConstant(parameterIndex:data:offset:)")
    func SetGraphicsRoot32BitConstant(_ RootParameterIndex: Any,
                                      _ SrcData: Any,
                                      _ DestOffsetIn32BitValues: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRoot32BitConstants(parameterIndex:data:offset:)")
    func SetGraphicsRoot32BitConstants(_ RootParameterIndex: Any,
                                      _ Num32BitValuesToSet: Any,
                                      _ SrcData: [Any],
                                      _ DestOffsetIn32BitValues: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRootConstantBufferView(parameterIndex:gpuBufferLocation:)")
    func SetGraphicsRootConstantBufferView(_ RootParameterIndex: Any,
                                           _ BufferLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRootDescriptorTable(parameterIndex:baseDescriptor:)")
    func SetGraphicsRootDescriptorTable(_ RootParameterIndex: Any,
                                        _ BaseDescriptor: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRootShaderResourceView(parameterIndex:gpuBufferLocation:)")
    func SetGraphicsRootShaderResourceView(_ RootParameterIndex: Any,
                                           _ BufferLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRootSignature(_:)")
    func SetGraphicsRootSignature(_ pRootSignature: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setGraphicsRootUnorderedAccessView(parameterIndex:gpuBufferLocation:)")
    func SetGraphicsRootUnorderedAccessView(_ RootParameterIndex: Any,
                                           _ BufferLocation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, message: "Not intended to be called directly.  Use the PIX event runtime to insert events into a command list.")
    func SetMarker(_ Metadata: Any,
                   _ pData: Any,
                   _ Size: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }  

    @available(*, unavailable, renamed: "setPipelineState(_:)")
    func SetPipelineState(_ pPipelineState: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setPredication(_:offset:operation:)")
    func SetPredication(_ pBuffer: Any,
                        _ AlignedBufferOffset: Any,
                        _ Operation: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setTargets(_:at:)")
    func SOSetTargets(_ StartSlot: Any,
                      _ NumViews: Any,
                      _ pViews: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
