/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// A command signature object enables apps to specify indirect drawing, including the buffer format, command type and resource bindings to be used.
public final class D3DCommandSignature: D3DPageable {
    @inlinable
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DCommandSignature {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12CommandSignature
}
extension D3DCommandSignature.RawValue {
    @inlinable
    static var interfaceID: IID {WinSDK.IID_ID3D12CommandSignature}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCommandSignature")
public typealias ID3D12CommandSignature = D3DCommandSignature 

#endif
