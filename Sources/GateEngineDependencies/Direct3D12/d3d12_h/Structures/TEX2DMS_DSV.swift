/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct D3DTexture2DMultiSampledDepthStencilView {
    public typealias RawValue = WinSDK.D3D12_TEX2DMS_DSV
    internal var rawValue: RawValue


    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTexture2DMultiSampledDepthStencilView")
public typealias D3D12_TEX2DMS_DSV = D3DTexture2DMultiSampledDepthStencilView

#endif
