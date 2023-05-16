/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// A descriptor heap is a collection of contiguous allocations of descriptors, one allocation for every descriptor. Descriptor heaps contain many object types that are not part of a Pipeline State Object (PSO), such as Shader Resource Views (SRVs), Unordered Access Views (UAVs), Constant Buffer Views (CBVs), and Samplers.
public final class D3DDescriptorHeap: D3DPageable {

    /// Gets the CPU descriptor handle that represents the start of the heap.
    @inlinable @inline(__always)
    public var cpuDescriptorHandleForHeapStart: D3DCPUDescriptorHandle {
        return performFatally(as: RawValue.self) {pThis in            
            //fix from @compnerd's SwiftCOM package
            var hDescriptor: D3DCPUDescriptorHandle.RawValue = D3DCPUDescriptorHandle.RawValue()
            typealias GetCPUDescriptorHandleForHeapStartABI = @convention(c) (UnsafeMutablePointer<WinSDK.ID3D12DescriptorHeap>?, UnsafeMutablePointer<D3DCPUDescriptorHandle.RawValue >?) -> Void
            let pGetCPUDescriptorHandleForHeapStart: GetCPUDescriptorHandleForHeapStartABI = unsafeBitCast(pThis.pointee.lpVtbl.pointee.GetCPUDescriptorHandleForHeapStart, to: GetCPUDescriptorHandleForHeapStartABI.self)
            pGetCPUDescriptorHandleForHeapStart(pThis, &hDescriptor)
            return D3DCPUDescriptorHandle(hDescriptor)
        }
    }

    /// Gets the descriptor heap description.
    @inlinable @inline(__always)
    public var descriptorHeapDescription: D3DDescriptorHeapDescription {
        return performFatally(as: RawValue.self) {pThis in
            let v = pThis.pointee.lpVtbl.pointee.GetDesc(pThis)
            return D3DDescriptorHeapDescription(v)
        }
    }

    /// Gets the GPU descriptor handle that represents the start of the heap.
    @inlinable @inline(__always)
    public var gpuDescriptorHandleForHeapStart: D3DGPUDescriptorHandle {
        return performFatally(as: RawValue.self) {pThis in
            //fix from @compnerd's SwiftCOM package
            var hDescriptor: D3DGPUDescriptorHandle.RawValue = D3DGPUDescriptorHandle.RawValue()
            typealias GetGPUDescriptorHandleForHeapStartABI = @convention(c) (UnsafeMutablePointer<WinSDK.ID3D12DescriptorHeap>?, UnsafeMutablePointer<D3DGPUDescriptorHandle.RawValue >?) -> Void
            let pGetGPUDescriptorHandleForHeapStart: GetGPUDescriptorHandleForHeapStartABI = unsafeBitCast(pThis.pointee.lpVtbl.pointee.GetGPUDescriptorHandleForHeapStart, to: GetGPUDescriptorHandleForHeapStartABI.self)
            pGetGPUDescriptorHandleForHeapStart(pThis, &hDescriptor)
            return D3DGPUDescriptorHandle(hDescriptor)
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DDescriptorHeap {
    typealias RawValue = WinSDK.ID3D12DescriptorHeap
}
extension D3DDescriptorHeap.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: IID {WinSDK.IID_ID3D12DescriptorHeap}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DDescriptorHeap")
public typealias ID3D12DescriptorHeap = D3DDescriptorHeap 

public extension D3DDescriptorHeap {
    @available(*, unavailable, renamed: "cpuDescriptorHandleForHeapStart")
    func GetCPUDescriptorHandleForHeapStart() -> D3DCPUDescriptorHandle {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "descriptorHeapDescription")
    func GetDesc() -> D3DDescriptorHeapDescription {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "gpuDescriptorHandleForHeapStart")
    func GetGPUDescriptorHandleForHeapStart() -> D3DGPUDescriptorHandle {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}


#endif
