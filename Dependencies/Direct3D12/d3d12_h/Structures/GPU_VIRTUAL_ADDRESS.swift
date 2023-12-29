/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public typealias D3DGPUVirtualAddress = WinSDK.D3D12_GPU_VIRTUAL_ADDRESS

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DGPUVirtualAddress")
public typealias D3D12_GPU_VIRTUAL_ADDRESS = D3DGPUVirtualAddress

#endif
