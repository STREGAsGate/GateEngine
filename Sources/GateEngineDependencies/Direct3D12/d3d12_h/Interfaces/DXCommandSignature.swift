/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// A command signature object enables apps to specify indirect drawing, including the buffer format, command type and resource bindings to be used.
public class D3DCommandSignature: D3DPageable {
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DCommandSignature {
    typealias RawValue = WinSDK.ID3D12CommandSignature
}
extension D3DCommandSignature.RawValue {
    static var interfaceID: IID {WinSDK.IID_ID3D12CommandSignature}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCommandSignature")
public typealias ID3D12CommandSignature = D3DCommandSignature 

#endif
