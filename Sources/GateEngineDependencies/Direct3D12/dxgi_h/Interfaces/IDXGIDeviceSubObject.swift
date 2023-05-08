/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public class DGIDeviceSubObject: DGIObject {

    /** Retrieves the device.
    - returns: The address of a pointer to the device.
    */
    public func device() throws -> DGIDevice {
        return try perform(as: RawValue.self) {pThis in
            var riid = DGIDevice.interfaceID
            var ppDevice: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.GetDevice(pThis, &riid, &ppDevice).checkResult(self, #function)
            guard let v = DGIDevice(winSDKPointer: ppDevice) else {throw Error(.invalidArgument)}
            return v
        }
    }

    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension DGIDeviceSubObject {
    typealias RawValue = WinSDK.IDXGIDeviceSubObject
}
extension DGIDeviceSubObject.RawValue {
    static var interfaceID: WinSDK.IID {WinSDK.IID_IDXGIDeviceSubObject}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "DGIDeviceSubObject")
public typealias IDXGIDeviceSubObject = DGIDeviceSubObject

public extension DGIDeviceSubObject {
    @available(*, unavailable, renamed: "device()")
    func GetDevice(_ riid: Any, ppDevice: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
