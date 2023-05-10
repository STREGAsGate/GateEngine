/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class D3DCommandQueue: D3DPageable {

    /** Copies mappings from a source reserved resource to a destination reserved resource.
    - parameter srcResource: A pointer to the source reserved resource.
    - parameter sourceRegionStartCoord: A pointer to a D3D12_TILED_RESOURCE_COORDINATE structure that describes the starting coordinates of the source reserved resource.
    - parameter dstResource: A pointer to the destination reserved resource.
    - parameter destinationRegionStartCoord: A pointer to a D3D12_TILED_RESOURCE_COORDINATE structure that describes the starting coordinates of the destination reserved resource.
    - parameter regionSize: A pointer to a D3D12_TILE_REGION_SIZE structure that describes the size of the reserved region.
    - parameter flags: One member of D3D12_TILE_MAPPING_FLAGS.
    */
    public func copyTileMappings(from srcResource: D3DResource, sourceRegionStartCoord: D3DTiledResourceCoordinate, 
                                 to dstResource: D3DResource, destinationRegionStartCoord: D3DTiledResourceCoordinate, 
                                 regionSize: D3DTileRegionSize, flags: D3DTileMappingFlags = []) {
        performFatally(as: RawValue.self) {pThis in
            let dstResource = dstResource.performFatally(as: D3DResource.RawValue.self) {$0}
            var dstCoord = destinationRegionStartCoord.rawValue
            let srcResource = srcResource.performFatally(as: D3DResource.RawValue.self) {$0}
            var srcCoord = sourceRegionStartCoord.rawValue
            var regionSize = regionSize.rawValue
            let flags = flags.rawType
            pThis.pointee.lpVtbl.pointee.CopyTileMappings(pThis, dstResource, &dstCoord, srcResource, &srcCoord, &regionSize,  flags)
        }
    }

    /** Submits an array of command lists for execution.
    - parameter commandLists: The array of ID3D12CommandList command lists to be executed.
    */
    public func executeCommandLists(_ commandLists: [D3DCommandList]) {
        performFatally(as: RawValue.self) {pThis in
            let pCommandLists = commandLists.map({$0.performFatally(as: D3DCommandList.RawValue.self){Optional($0)}})
            pThis.pointee.lpVtbl.pointee.ExecuteCommandLists(pThis, UInt32(commandLists.count), pCommandLists)
        }
    }

    /// This method samples the CPU and GPU timestamp counters at the same moment in time.
    public func clockCalibration() throws -> (cpuTimestampCount: UInt64, gpuTimestampCount: UInt64) {
        return try perform(as: RawValue.self) {pThis in
            var gpuTimestamp: UInt64 = 0
            var cpuTimestamp: UInt64 = 0
            try pThis.pointee.lpVtbl.pointee.GetClockCalibration(pThis, &gpuTimestamp, &cpuTimestamp).checkResult(self, #function)
            return (gpuTimestamp, cpuTimestamp)
        }
    }

    /// Gets the description of the command queue.
    public var commandQueueDescription: D3DCommandQueueDescription {
        return performFatally(as: RawValue.self) {pThis in
            let v = pThis.pointee.lpVtbl.pointee.GetDesc(pThis)
            return D3DCommandQueueDescription(v)
        }
    }

    /// This method is used to determine the rate at which the GPU timestamp counter increments.
    public func timestampFrequency() throws -> UInt64 {
        return try perform(as: RawValue.self) {pThis in
            var frequency: UInt64 = 0
            try pThis.pointee.lpVtbl.pointee.GetTimestampFrequency(pThis, &frequency).checkResult(self, #function)
            return frequency
        }
    }

    /** Updates a fence to a specified value.
    - parameter fence: A pointer to the ID3D12Fence object.
    - parameter value: The value to set the fence to.
    */
    public func signal(fence: D3DFence, value: UInt64) throws {
        try perform(as: RawValue.self) {pThis in
            let pFence = fence.perform(as: D3DFence.RawValue.self) {$0}
            try pThis.pointee.lpVtbl.pointee.Signal(pThis, pFence, value).checkResult(self, #function)
        }
    }

    /** Updates mappings of tile locations in reserved resources to memory locations in a resource heap.
    - parameter resource: A pointer to the reserved resource.
    - parameter coordinate: An array of D3D12_TILED_RESOURCE_COORDINATE structures that describe the starting coordinates of the reserved resource regions. The NumResourceRegions parameter specifies the number of D3D12_TILED_RESOURCE_COORDINATE structures in the array.
    - parameter size: An array of D3D12_TILE_REGION_SIZE structures that describe the sizes of the reserved resource regions. The NumResourceRegions parameter specifies the number of D3D12_TILE_REGION_SIZE structures in the array.
    - parameter rangeFlags: A pointer to an array of D3D12_TILE_RANGE_FLAGS values that describes each tile range. The NumRanges parameter specifies the number of values in the array.
    - parameter offset: An array of offsets into the resource heap. These are 0-based tile offsets, counting in tiles (not bytes).
    - parameter tileCount: An array of values that specify the number of tiles in each tile range. The NumRanges parameter specifies the number of values in the array.
    - parameter resourceHeap: A pointer to the resource heap.
    - parameter flags: A combination of D3D12_TILE_MAPPING_FLAGS values that are combined by using a bitwise OR operation.
    */
    public func updateTileMappings(for resource: D3DResource,
                                   resourceRegionStartCoordinates: [D3DTiledResourceCoordinate]?,
                                   resourceRegionSizes: [D3DTileRegionSize]?,
                                   heap: D3DHeap,
                                   rangeFlags: [D3DTileRangeFlags]?,
                                   heapRangeStartOffsets: [UInt32]?,
                                   rangeTileCounts: [UInt32]?,
                                   flags: D3DTileMappingFlags = []) {
        performFatally(as: RawValue.self) {pThis in
            let resource = resource.performFatally(as: D3DResource.RawValue.self) {$0}
            let numResourceRegions = UInt32(resourceRegionStartCoordinates?.count ?? resourceRegionSizes?.count ?? 0)
            let pResourceRegionStartCoordinates = resourceRegionStartCoordinates?.map({$0.rawValue})
            let pResourceRegionSizes = resourceRegionSizes?.map({$0.rawValue})
            let pHeap = heap.performFatally(as: D3DHeap.RawValue.self) {$0}
            let numRanges = UInt32(rangeFlags?.count ?? rangeTileCounts?.count ?? heapRangeStartOffsets?.count ?? 0)
            let pRangeFlags = rangeFlags?.map({D3DTileRangeFlags.RawType($0.rawValue)})
            let pHeapRangeStartOffsets = heapRangeStartOffsets
            let pRangeTileCounts = rangeTileCounts
            let flags = flags.rawType
            pThis.pointee.lpVtbl.pointee.UpdateTileMappings(pThis, resource, numResourceRegions, pResourceRegionStartCoordinates, pResourceRegionSizes, pHeap, numRanges, pRangeFlags, pHeapRangeStartOffsets, pRangeTileCounts, flags)
        }
    }

    /** Queues a GPU-side wait, and returns immediately. A GPU-side wait is where the GPU waits until the specified fence reaches or exceeds the specified value.
    - parameter fence: A pointer to the ID3D12Fence object.
    - parameter value: The value that the command queue is waiting for the fence to reach or exceed. So when ID3D12Fence::GetCompletedValue is greater than or equal to Value, the wait is terminated.
    */
    public func wait(fence: D3DFence, value: UInt64) throws {
        try perform(as: RawValue.self) {pThis in
            let pFence = fence.perform(as: D3DFence.RawValue.self) {$0}
            try pThis.pointee.lpVtbl.pointee.Wait(pThis, pFence, value).checkResult(self, #function)
        }
    }

    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DCommandQueue {
    typealias RawValue = WinSDK.ID3D12CommandQueue
}
extension D3DCommandQueue.RawValue {
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12CommandQueue}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "D3DCommandQueue")
public typealias ID3D12CommandQueue = D3DCommandQueue 

public extension D3DCommandQueue {
    @available(*, unavailable, message: "Not intended to be called directly. Use the PIX event runtime to insert events into a command queue.")
    func BeginEvent(_ metadata: UInt32, _ pData: UnsafeRawPointer?, _ size: UInt32) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "copyTileMappings")
    func CopyTileMappings(_ pDstResource: UnsafeMutablePointer<D3DResource.RawValue>?, _ pDstRegionStartCoordinate: UnsafeMutablePointer<D3DTiledResourceCoordinate.RawValue>?, 
                          _ pSrcResource: UnsafeMutablePointer<D3DResource.RawValue>?, _ pSrcRegionStartCoordinate: UnsafeMutablePointer<D3DTiledResourceCoordinate.RawValue>?, 
                          _ pRegionSize: UnsafePointer<D3DTileRegionSize.RawValue>, _ Flags: D3DTileMappingFlags.RawType) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, message: "Not intended to be called directly. Use the PIX event runtime to insert events into a command queue.")
    func EndEvent(_ Metadata: UInt32, _ pData: UnsafeRawPointer?, _ size: UInt32) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "executeCommandLists")
    func ExecuteCommandLists(_ NumCommandLists: UInt32, ppCommandLists: UnsafePointer<UnsafeMutablePointer<D3DCommandList>?>?) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "clockCalibration")
    func GetClockCalibration(_ pGpuTimestamp: inout UInt64, _ pCpuTimestamp: inout UInt64) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "commandQueueDescription")
    func GetDesc() -> D3DCommandQueueDescription {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "timestampFrequency")
    func GetTimestampFrequency(_ pFrequency: inout UInt64) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, message: "Not intended to be called directly. Use the PIX event runtime to insert events into a command queue.")
    func SetMarker(_ Metadata: UInt32, _ pData: UnsafeRawPointer?, _ size: UInt32) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "signal")
    func Signal(_ pFence: D3DFence, _ Value: UInt32) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "updateTileMappings")
    func UpdateTileMappings(_ pResource: UnsafeMutablePointer<D3DResource>?, 
                            _ NumResourceRegions: UInt32, 
                            _ pResourceRegionStartCoordinates: UnsafePointer<D3DTiledResourceCoordinate>?, 
                            _ pResourceRegionSizes: UnsafePointer<D3DTileRegionSize>?, 
                            _ pHeap: UnsafeMutablePointer<D3DHeap>?, 
                            _ NumRanges: UInt32,
                            _ pRangeFlags: UnsafePointer<D3DTileRangeFlags>?,
                            _ pHeapRangeStartOffsets: UnsafePointer<UInt32>?,
                            _ pRangeTileCounts: UnsafePointer<UInt32>?,
                            _ Flags: D3DTileMappingFlags) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "signal")
    func Wait(_ pFence: D3DFence, _ Value: UInt32) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
