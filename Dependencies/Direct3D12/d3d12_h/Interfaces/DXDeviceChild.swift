/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// An interface from which other core interfaces inherit from, including (but not limited to) ID3D12PipelineLibrary, ID3D12CommandList, ID3D12Pageable, and ID3D12RootSignature. It provides a method to get back to the device object it was created against.
public class D3DDeviceChild: D3DObject {

    /** Gets a pointer to the device that created this interface.
    - returns: A pointer to a memory block that receives a pointer to the ID3D12Device interface for the device.
    */
    @inlinable
    public func device() throws -> D3DDevice {
        return try perform(as: RawValue.self) {pThis in 
            var riid = D3DDevice.interfaceID
            var ppvDevice: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.GetDevice(pThis, &riid, &ppvDevice).checkResult(self, #function)
            guard let v = D3DDevice(winSDKPointer: ppvDevice) else {throw Error(.invalidArgument)}
            return v
        }
    }

    @inlinable
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DDeviceChild {
     @usableFromInline
    typealias RawValue = WinSDK.ID3D12DeviceChild
}
extension D3DDeviceChild.RawValue {
    @inlinable
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12DeviceChild}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "D3DDeviceChild")
public typealias ID3D12DeviceChild = D3DDeviceChild 

public extension D3DDeviceChild {
    @available(*, unavailable, renamed: "device")
    func GetDevice(_ riid: Any, 
                   _ ppvDevice: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
