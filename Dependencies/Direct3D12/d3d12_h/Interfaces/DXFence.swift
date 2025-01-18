/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Represents a fence, an object used for synchronization of the CPU and one or more GPUs.
public final class D3DFence: D3DPageable {
    
    /// Gets the current value of the fence.
    @inlinable @inline(__always)
    public var value: UInt64 {
        return performFatally(as: RawValue.self) {pThis in
            return pThis.pointee.lpVtbl.pointee.GetCompletedValue(pThis)
        }
    }

    /** Specifies an event that should be fired when the fence reaches a certain value.
    - parameter handle: A handle to the event object.
    - parameter value: The fence value when the event is to be signaled.
    */
    @inlinable @inline(__always)
    public func setCompletionEvent(_ handle: HANDLE?, whenValueIs value: UInt64) throws {
        try perform(as: RawValue.self) {pThis in
            let Value = value
            let hEvent = handle
            try pThis.pointee.lpVtbl.pointee.SetEventOnCompletion(pThis, Value, hEvent).checkResult(self, #function)
        }
    }

    /** Sets the fence to the specified value.
    - parameter value: The value to set the fence to.
    */
    @inlinable @inline(__always)
    public func signal(_ value: UInt64) throws {
        try perform(as: RawValue.self) {pThis in
            let Value = value
            try pThis.pointee.lpVtbl.pointee.Signal(pThis, Value).checkResult(self, #function)
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {
        // if #available(Windows 10.0.16299, *) {
        //     return RawValue1.interfaceID//ID3D12Fence1
        // }else{
            return RawValue.interfaceID //ID3D12Fence
        //}
    }
}

extension D3DFence {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12Fence
}
extension D3DFence.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12Fence}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DFence")
public typealias ID3D12Fence = D3DFence

public extension D3DFence {
    @available(*, unavailable, renamed: "value")
    func GetCompletedValue() -> UInt64 {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "setCompletionEvent(_:whenValueIs:)")
    func SetEventOnCompletion(_ value: Any,
                              _ handle: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "signal(_:)")
    func Signal(_ value: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
