/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct DGIPresentParameters {
    public typealias RawValue = WinSDK.DXGI_PRESENT_PARAMETERS
    @usableFromInline
    internal var rawValue: RawValue

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }

    @_transparent
    public static var `fullFrame`: DGIPresentParameters {
        var params = WinSDK.DXGI_PRESENT_PARAMETERS()
        params.DirtyRectsCount = 0
        params.pDirtyRects = nil
        params.pScrollRect = nil
        params.pScrollOffset = nil
        return DGIPresentParameters(params)
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIPresentParameters")
public typealias DXGI_PRESENT_PARAMETERS = DGIPresentParameters

#endif
