/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class DGISwapChain: DGIDeviceSubObject {

    /** Accesses one of the swap-chain's back buffers.
    - parameter index: A zero-based buffer index.
    - returns: A pointer to a back-buffer interface.
    */
    @inlinable @inline(__always)
    public func backBuffer(at index: UInt32) throws -> D3DResource {
        return try perform(as: RawValue.self) {pThis in
            let Buffer = index
            var riid = D3DResource.interfaceID
            var ppSurface: UnsafeMutableRawPointer?
            try pThis.pointee.lpVtbl.pointee.GetBuffer(pThis, Buffer, &riid, &ppSurface).checkResult(self, #function)
            guard let v = D3DResource(winSDKPointer: ppSurface) else {throw Error(.invalidArgument)}
            return v
        }
    }

    /** Changes the swap chain's back buffer size, format, and number of buffers. This should be called when the application window is resized.
    - parameter count: The number of buffers in the swap chain (including all back and front buffers). This number can be different from the number of buffers with which you created the swap chain. This number can't be greater than DXGI_MAX_SWAP_CHAIN_BUFFERS. Set this number to zero to preserve the existing number of buffers in the swap chain. You can't specify less than two buffers for the flip presentation model.
    - parameter width: The new width of the back buffer. If you specify zero, DXGI will use the width of the client area of the target window. You can't specify the width as zero if you called the IDXGIFactory2::CreateSwapChainForComposition method to create the swap chain for a composition surface.
    - parameter height: The new height of the back buffer. If you specify zero, DXGI will use the height of the client area of the target window. You can't specify the height as zero if you called the IDXGIFactory2::CreateSwapChainForComposition method to create the swap chain for a composition surface.
    - parameter format: A DXGI_FORMAT-typed value for the new format of the back buffer. Set this value to DXGI_FORMAT_UNKNOWN to preserve the existing format of the back buffer. The flip presentation model supports a more restricted set of formats than the bit-block transfer (bitblt) model.
    - parameter flags: A combination of DXGI_SWAP_CHAIN_FLAG-typed values that are combined by using a bitwise OR operation. The resulting value specifies options for swap-chain behavior.
    */
    @inlinable @inline(__always)
    public func resizeBuffers(count: UInt32 = 0, width: UInt32 = 0, height: UInt32 = 0, format: DGIFormat = .unknown, flags: DGISwapChainFlags = [.allowModeSwitch, .allowTearing]) throws {
        try perform(as: RawValue.self) {pThis in
            let BufferCount = count
            let Width = width
            let Height = height
            let NewFormat = format.rawValue
            let SwapChainFlags = UInt32(flags.rawValue)
            try pThis.pointee.lpVtbl.pointee.ResizeBuffers(pThis, BufferCount, Width, Height, NewFormat, SwapChainFlags).checkResult(self, #function) 
        }
    }

    /// Changes the background color of the swap chain.
    @discardableResult @inlinable @inline(__always)
    public func setBackgroundColor(_ pColor: D3DColor) -> Bool {
        return perform(as: RawValue.self) {pThis in
            var pColor = WinSDK.DXGI_RGBA(r: pColor.red, g: pColor.green, b: pColor.blue, a: pColor.alpha)
            return pThis.pointee.lpVtbl.pointee.SetBackgroundColor(pThis, &pColor).isSuccess
        }
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension DGISwapChain {
    @usableFromInline
    typealias RawValue = WinSDK.IDXGISwapChain1
}
extension DGISwapChain.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_IDXGISwapChain1}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "DGISwapChain")
public typealias IDXGISwapChain = DGISwapChain

public extension DGISwapChain {
    @available(*, unavailable, renamed: "backBuffer(at:)")
    func GetBuffer(_ Buffer: Any,
                   _ riid: Any,
                   _ ppSurface: inout Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "resizeBuffers(count:width:height:format:flags:)")
    func ResizeBuffers(_ BufferCount: Any,
                       _ Width: Any,
                       _ Height: Any,
                       _ NewFormat: Any,
                       _ SwapChainFlags: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
