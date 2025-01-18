/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// A heap is an abstraction of contiguous memory allocation, used to manage physical memory. This heap can be used with ID3D12Resource objects to support placed resources or reserved resources.
public final class D3DHeap: D3DPageable {
    
    /// Gets the heap description.
    @inlinable @inline(__always)
    public var heapDescription: D3DHeapDescription {
        return performFatally(as: RawValue.self) {pThis in
            var desc: D3DHeapDescription.RawValue = D3DHeapDescription.RawValue()
            typealias GetDescABI = @convention(c) (UnsafeMutablePointer<D3DHeap.RawValue>?, UnsafeMutablePointer<D3DHeapDescription.RawValue>?) -> Void
            let pGetDesc: GetDescABI = unsafeBitCast(pThis.pointee.lpVtbl.pointee.GetDesc, to: GetDescABI.self)
            pGetDesc(pThis, &desc)
            return D3DHeapDescription(desc)
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DHeap {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12Heap
}
extension D3DHeap.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12Heap}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DHeap")
public typealias ID3D12Heap = D3DHeap

public extension D3DHeap {
    @available(*, unavailable, renamed: "heapDescription")
    func GetDevice() -> D3DHeapDescription {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
