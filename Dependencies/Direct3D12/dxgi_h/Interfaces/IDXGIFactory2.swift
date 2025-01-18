/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public extension DGIFactory {
    
    /** Creates a swap chain that is associated with an HWND handle to the output window for the swap chain.
    - parameter description: A pointer to a DXGI_SWAP_CHAIN_DESC1 structure for the swap-chain description. This parameter cannot be NULL.
    - parameter window: The HWND handle that is associated with the swap chain that CreateSwapChainForHwnd creates. This parameter cannot be NULL.
    - parameter fullScreen: A pointer to a DXGI_SWAP_CHAIN_FULLSCREEN_DESC structure for the description of a full-screen swap chain. You can optionally set this parameter to create a full-screen swap chain. Set it to NULL to create a windowed swap chain.
    - parameter commandQueue: For Direct3D 11, and earlier versions of Direct3D, this is a pointer to the Direct3D device for the swap chain. For Direct3D 12 this is a pointer to a direct command queue (refer to ID3D12CommandQueue). This parameter cannot be NULL.
    - returns: A pointer to a variable that receives a pointer to the IDXGISwapChain1 interface for the swap chain that CreateSwapChainForHwnd creates.
    */
    @inlinable @inline(__always)
    func createSwapChain(description: DGISwapChainDescription1, 
                         window: HWND,
                         fullScreen: DGISwapChainFullscreenDescription?, 
                         commandQueue: D3DCommandQueue) throws -> DGISwapChain {
        return try perform(as: RawValue.self) {pThis in 
            let pDevice = commandQueue.perform(as: IUnknown.RawValue.self) {$0}
            let hWnd = window
            var pDesc = description.rawValue
            
            var ppSwapChain: UnsafeMutablePointer<DGISwapChain.RawValue>?
            if var pFullscreenDesc = fullScreen?.rawValue {
                try pThis.pointee.lpVtbl.pointee.CreateSwapChainForHwnd(pThis, pDevice, hWnd, &pDesc, &pFullscreenDesc, nil, &ppSwapChain).checkResult(self, #function)
            }else{
                try pThis.pointee.lpVtbl.pointee.CreateSwapChainForHwnd(pThis, pDevice, hWnd, &pDesc, nil, nil, &ppSwapChain).checkResult(self, #function)
            }
            guard let v = DGISwapChain(winSDKPointer: ppSwapChain) else {throw Error(.invalidArgument)}
            return v
        }
    }

    /** Creates a swap chain that is associated with an HWND handle to the output window for the swap chain.
    - parameter window: The HWND handle that is associated with the swap chain that CreateSwapChainForHwnd creates. This parameter cannot be NULL.
    - parameter format: A DXGI_FORMAT structure that describes the display format.
    - parameter bufferCount: A value that describes the number of buffers in the swap chain. When you create a full-screen swap chain, you typically include the front buffer in this value.
    - parameter fullScreen: A pointer to a DXGI_SWAP_CHAIN_FULLSCREEN_DESC structure for the description of a full-screen swap chain. You can optionally set this parameter to create a full-screen swap chain. Set it to NULL to create a windowed swap chain.
    - parameter commandQueue: For Direct3D 11, and earlier versions of Direct3D, this is a pointer to the Direct3D device for the swap chain. For Direct3D 12 this is a pointer to a direct command queue (refer to ID3D12CommandQueue). This parameter cannot be NULL.
    - returns: A pointer to a variable that receives a pointer to the IDXGISwapChain1 interface for the swap chain that CreateSwapChainForHwnd creates.
    */
    @inlinable @inline(__always)
    func createSwapChain(window: HWND,
                         format: DGIFormat,
                         bufferCount: UInt32,
                         refreshRate: DGIRational, 
                         commandQueue: D3DCommandQueue) throws -> DGISwapChain {
        let sampleDesc = DGISampleDescription(count: 1, quality: 0)
        let description = DGISwapChainDescription1(width: 0,
                                                   height: 0,
                                                   format: format,
                                                   isStereo: false,
                                                   sampleDescription: sampleDesc,
                                                   bufferUsage: .renderTargetOutput,
                                                   bufferCount: bufferCount,
                                                   scaling: .stretch,
                                                   swapEffect: .flipDiscard,
                                                   alphaMode: .unspecified,
                                                   flags: [.allowModeSwitch, .allowTearing])
        let fullScreen = DGISwapChainFullscreenDescription(refreshRate: refreshRate)
        return try createSwapChain(description: description, window: window, fullScreen: fullScreen, commandQueue: commandQueue)
    }
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIFactory")
public typealias IDXGIFactory2 = DGIFactory 

public extension DGIFactory {
    @available(*, unavailable, renamed: "createSwapChain(destiption:window:fullScreen:commandQueue:)")
    func CreateSwapChainForHwnd(_ pDevice: Any,
                                _ hWnd: Any,
                                _ pDesc: Any,
                                _ pFullscreenDesc: Any?,
                                _ pRestrictToOutput: Any,
                                _ ppSwapChain: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
