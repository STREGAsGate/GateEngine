/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class D3DQueryHeap: D3DPageable {
    @inlinable
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DQueryHeap {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12QueryHeap
}
extension D3DQueryHeap.RawValue {
    @inlinable
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12QueryHeap}
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DQueryHeap")
public typealias ID3D12QueryHeap = D3DQueryHeap 

#endif
