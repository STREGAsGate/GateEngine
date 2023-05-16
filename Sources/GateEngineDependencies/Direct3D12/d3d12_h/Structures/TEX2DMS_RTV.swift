/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DTexture2DMultiSampledRenderTargetView {
    public typealias RawValue = WinSDK.D3D12_TEX2DMS_RTV
    internal var rawValue: RawValue

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture2DMultiSampledRenderTargetView")
public typealias D3D12_TEX2DMS_RTV = D3DTexture2DMultiSampledRenderTargetView

#endif
