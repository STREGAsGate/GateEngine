/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class DGIAdapter: DGIObject {
    @inlinable
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension DGIAdapter {
    @usableFromInline
    typealias RawValue = WinSDK.IDXGIAdapter
}
extension DGIAdapter.RawValue {
    @inlinable
    static var interfaceID: WinSDK.IID {WinSDK.IID_IDXGIAdapter}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "DGIAdapter")
public typealias IDXGIAdapter = DGIAdapter

#endif
