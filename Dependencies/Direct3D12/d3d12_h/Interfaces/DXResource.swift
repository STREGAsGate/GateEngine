/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class D3DResource: D3DPageable {
    
    /// Gets the resource description.
    @inlinable @inline(__always)
    public var resourceDescription: D3DResourceDescription {
        return performFatally(as: RawValue.self) {pThis in
            var desc: D3DResourceDescription.RawValue = D3DResourceDescription.RawValue()
            typealias GetDescABI = @convention(c) (UnsafeMutablePointer<D3DResource.RawValue>?, UnsafeMutablePointer<D3DResourceDescription.RawValue>?) -> Void
            let pGetDesc: GetDescABI = unsafeBitCast(pThis.pointee.lpVtbl.pointee.GetDesc, to: GetDescABI.self)
            pGetDesc(pThis, &desc)
            return D3DResourceDescription(desc)
        }
    }

    /// This method returns the GPU virtual address of a buffer resource.
    @inlinable @inline(__always)
    public var gpuVirtualAddress: UInt64 {
        return performFatally(as: RawValue.self) {pThis in
            return pThis.pointee.lpVtbl.pointee.GetGPUVirtualAddress(pThis)
        } 
    }

    /// Retrieves the properties of the resource heap, for placed and committed resources.
    @inlinable @inline(__always)
    public func heapProperties() throws -> (properties: D3DHeapProperties, flags: D3DHeapFlags) {
        return try perform(as: RawValue.self) {pThis in
            var pHeapProperties = D3DHeapProperties.RawValue()
            var pHeapFlags = D3DHeapFlags.RawType(rawValue: 0)
            try pThis.pointee.lpVtbl.pointee.GetHeapProperties(pThis, &pHeapProperties, &pHeapFlags).checkResult(self, #function)
            return (D3DHeapProperties(pHeapProperties), D3DHeapFlags(pHeapFlags))
        }
    }

    /** Gets a CPU pointer to the specified subresource in the resource, but may not disclose the pointer value to applications. Map also invalidates the CPU cache, when necessary, so that CPU reads to this address reflect any modifications made by the GPU.
    - parameter index: Specifies the index number of the subresource.
    - parameter range: A pointer to a D3D12_RANGE structure that describes the range of memory to access. This indicates the region the CPU might read, and the coordinates are subresource-relative. A null pointer indicates the entire subresource might be read by the CPU. It is valid to specify the CPU won't read any data by passing a range where End is less than or equal to Begin.
    */
    @inlinable @inline(__always)
    public func map(index: UInt32 = 0, range: D3DRange? = nil) throws -> UnsafeMutableRawPointer? {
        return try perform(as: RawValue.self) {pThis in
            let Subresource = index
            var ppData: UnsafeMutableRawPointer?
            
            if var pReadRange = range?.rawValue {
                try pThis.pointee.lpVtbl.pointee.Map(pThis, Subresource, &pReadRange, &ppData).checkResult(self, #function)
            }else{
                try pThis.pointee.lpVtbl.pointee.Map(pThis, Subresource, nil, &ppData).checkResult(self, #function)
            }

            return ppData
        }
    }

    /** Uses the CPU to copy data from a subresource, enabling the CPU to read the contents of most textures with undefined layouts.
    - parameter index: Specifies the index of the subresource to read from.
    - parameter srcBox: A pointer to a box that defines the portion of the destination subresource to copy the resource data from. If NULL, the data is read from the destination subresource with no offset. The dimensions of the destination must fit the destination (see D3D12_BOX). An empty box results in a no-op. A box is empty if the top value is greater than or equal to the bottom value, or the left value is greater than or equal to the right value, or the front value is greater than or equal to the back value. When the box is empty, this method doesn't perform any operation.
    - parameter data: A pointer to the destination data in memory.
    - parameter rowLength: The distance from one row of destination data to the next row.
    - parameter depthPitch: The distance from one depth slice of destination data to the next.
    */
    @inlinable @inline(__always)
    public func readFromSubresource(_ index: UInt32, srcBox: D3DBox?, toData data: UnsafeMutableRawPointer?, rowPitch: UInt32, depthPitch: UInt32) throws {
        try perform(as: RawValue.self) {pThis in
            let pDstData = data
            let DstRowPitch = rowPitch
            let DstDepthPitch = depthPitch
            let SrcSubresource = index
            if var pSrcBox = srcBox?.rawValue {
                try pThis.pointee.lpVtbl.pointee.ReadFromSubresource(pThis, pDstData, DstRowPitch, DstDepthPitch, SrcSubresource, &pSrcBox).checkResult(self, #function)
            }else{
                try pThis.pointee.lpVtbl.pointee.ReadFromSubresource(pThis, pDstData, DstRowPitch, DstDepthPitch, SrcSubresource, nil).checkResult(self, #function)
            }
        }
    }
    
    /** Invalidates the CPU pointer to the specified subresource in the resource. Unmap also flushes the CPU cache, when necessary, so that GPU reads to this address reflect any modifications made by the CPU.
    - parameter index: Specifies the index of the subresource.
    - parameter range: A pointer to a D3D12_RANGE structure that describes the range of memory to unmap. This indicates the region the CPU might have modified, and the coordinates are subresource-relative. A null pointer indicates the entire subresource might have been modified by the CPU. It is valid to specify the CPU didn't write any data by passing a range where End is less than or equal to Begin.
    */
    @inlinable @inline(__always)
    public func unmap(index: UInt32 = 0, range: D3DRange? = nil) {
        performFatally(as: RawValue.self) {pThis in
            let Subresource = index            
            if var pWrittenRange = range?.rawValue {
                pThis.pointee.lpVtbl.pointee.Unmap(pThis, Subresource, &pWrittenRange)
            }else{
                pThis.pointee.lpVtbl.pointee.Unmap(pThis, Subresource, nil)
            }
        }
    }

    /** Uses the CPU to copy data into a subresource, enabling the CPU to modify the contents of most textures with undefined layouts.
    - parameter index: Specifies the index of the subresource.
    - parameter dstBox: A pointer to a box that defines the portion of the destination subresource to copy the resource data into. If NULL, the data is written to the destination subresource with no offset. The dimensions of the source must fit the destination (see D3D12_BOX). An empty box results in a no-op. A box is empty if the top value is greater than or equal to the bottom value, or the left value is greater than or equal to the right value, or the front value is greater than or equal to the back value. When the box is empty, this method doesn't perform any operation.
    - parameter data: A pointer to the source data in memory.
    - parameter rowPitch: The distance from one row of source data to the next row.
    - parameter depthPitch: The distance from one depth slice of source data to the next.
    */
    @inlinable @inline(__always)
    public func writeToSubresource(_ index: UInt32, dstBox: D3DBox?, fromData data: UnsafeMutableRawPointer?, rowPitch: UInt32, depthPitch: UInt32) throws {
        try perform(as: RawValue.self) {pThis in
            let DstSubresource = index
            let pSrcData = data
            let SrcRowPitch = rowPitch
            let SrcDepthPitch = depthPitch
            if var pDstBox = dstBox?.rawValue {
                try pThis.pointee.lpVtbl.pointee.WriteToSubresource(pThis, DstSubresource, &pDstBox, pSrcData, SrcRowPitch, SrcDepthPitch).checkResult(self, #function)
            }else{
                try pThis.pointee.lpVtbl.pointee.WriteToSubresource(pThis, DstSubresource, nil, pSrcData, SrcRowPitch, SrcDepthPitch).checkResult(self, #function)
            }
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DResource {
    #if !Direct3D12ExcludeOriginalStyleAPI
    public typealias RawValue = WinSDK.ID3D12Resource
    #else
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12Resource
    #endif
}
extension D3DResource.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12Resource}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "D3DResource")
public typealias ID3D12Resource = D3DResource 

public extension D3DResource {
    @available(*, unavailable, renamed: "resourceDescription")
    func GetDesc() -> Any {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "gpuVirtualAddress")
    func GetGPUVirtualAddress() -> Any {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "heapProperties()")
    func GetHeapProperties(_ pHeapProperties: inout Any,
                           _ pHeapFlags: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "map(index:range:)")
    func Map(_ Subresource: Any,
             _ pReadRange: Any?,
             _ ppData: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "readFromSubresource(_:srcBox:toData:rowPitch:depthPitch:)")
    func ReadFromSubresource(_ pDstData: Any,
                             _ DstRowPitch: Any,
                             _ DstDepthPitch: Any,
                             _ SrcSubresource: Any,
                             _ pSrcBox: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "unmap(index:range:)")
    func Unmap(_ Subresource: Any,
               _ pWrittenRange: Any) {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "writeToSubresource(_:dstBox:fromData:rowPitch:depthPitch:)")
    func WriteToSubresource(_ DstSubresource: Any,
                            _ pDstBox: Any,
                            _ pSrcData: Any,
                            _ SrcRowPitch: Any,
                            _ SrcDepthPitch: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
