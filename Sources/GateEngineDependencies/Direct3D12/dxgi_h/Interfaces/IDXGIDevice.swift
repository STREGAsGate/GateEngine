/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class DGIDevice: DGIObject {

    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension DGIDevice {
    typealias RawValue = WinSDK.IDXGIDevice
}
extension DGIDevice.RawValue {
    static var interfaceID: WinSDK.IID {WinSDK.IID_IDXGIDevice}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "DGIDevice")
public typealias IDXGIDevice = DGIDevice

public extension DGIDevice {

}

#endif
