/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a swap chain.
public struct DGISwapChainDescription1 {
    public typealias RawValue = WinSDK.DXGI_SWAP_CHAIN_DESC1
    @usableFromInline
    internal var rawValue: RawValue

    /// A value that describes the resolution width. If you specify the width as zero when you call the IDXGIFactory2::CreateSwapChainForHwnd method to create a swap chain, the runtime obtains the width from the output window and assigns this width value to the swap-chain description. You can subsequently call the IDXGISwapChain1::GetDesc1 method to retrieve the assigned width value. You cannot specify the width as zero when you call the IDXGIFactory2::CreateSwapChainForComposition method.
    @inlinable @inline(__always)
    public var width: UInt32 {
        get {
            return rawValue.Width
        }
        set {
            rawValue.Width = newValue
        }
    }

    /// A value that describes the resolution height. If you specify the height as zero when you call the IDXGIFactory2::CreateSwapChainForHwnd method to create a swap chain, the runtime obtains the height from the output window and assigns this height value to the swap-chain description. You can subsequently call the IDXGISwapChain1::GetDesc1 method to retrieve the assigned height value. You cannot specify the height as zero when you call the IDXGIFactory2::CreateSwapChainForComposition method.
    @inlinable @inline(__always)
    public var height: UInt32 {
        get {
            return rawValue.Height
        }
        set {
            rawValue.Height = newValue
        }
    }

    /// A DXGI_FORMAT structure that describes the display format.
    @inlinable @inline(__always)
    public var format: DGIFormat {
        get {
            return DGIFormat(rawValue.Format)
        }
        set {
            rawValue.Format = newValue.rawValue
        }
    }

    /// Specifies whether the full-screen display mode or the swap-chain back buffer is stereo. TRUE if stereo; otherwise, FALSE. If you specify stereo, you must also specify a flip-model swap chain (that is, a swap chain that has the DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL value set in the SwapEffect member).
    @inlinable @inline(__always)
    public var isStereo: Bool {
        get {
            return rawValue.Stereo.boolValue
        }
        set {
            rawValue.Stereo = WindowsBool(booleanLiteral: newValue)
        }
    }

    /// A DXGI_SAMPLE_DESC structure that describes multi-sampling parameters. This member is valid only with bit-block transfer (bitblt) model swap chains.
    @inlinable @inline(__always)
    public var sampleDescription: DGISampleDescription {
        get {
            return DGISampleDescription(rawValue.SampleDesc)
        }
        set {
            rawValue.SampleDesc = newValue.rawValue
        }
    }

    /// A DXGI_USAGE-typed value that describes the surface usage and CPU access options for the back buffer. The back buffer can be used for shader input or render-target output.
    @inlinable @inline(__always)
    public var bufferUsage: DGIUsage {
        get {
            return DGIUsage(rawValue: rawValue.BufferUsage)
        }
        set {
            rawValue.BufferUsage = newValue.rawValue
        }
    }

    /// A value that describes the number of buffers in the swap chain. When you create a full-screen swap chain, you typically include the front buffer in this value.
    @inlinable @inline(__always)
    public var bufferCount: UInt32 {
        get {
            return rawValue.BufferCount
        }
        set {
            rawValue.BufferCount = newValue
        }
    }

    /// A DXGI_SCALING-typed value that identifies resize behavior if the size of the back buffer is not equal to the target output.
    @inlinable @inline(__always)
    public var scaling: DGIScaling {
        get {
            return DGIScaling(rawValue.Scaling)
        }
        set {
            rawValue.Scaling = newValue.rawValue
        }
    }

    /// A DXGI_SWAP_EFFECT-typed value that describes the presentation model that is used by the swap chain and options for handling the contents of the presentation buffer after presenting a surface. You must specify the DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL value when you call the IDXGIFactory2::CreateSwapChainForComposition method because this method supports only flip presentation model.
    @inlinable @inline(__always)
    public var swapEffect: DGISwapEffect {
        get {
            return DGISwapEffect(rawValue.SwapEffect)
        }
        set {
            rawValue.SwapEffect = newValue.rawValue
        }
    }

    /// A DXGI_ALPHA_MODE-typed value that identifies the transparency behavior of the swap-chain back buffer.
    @inlinable @inline(__always)
    public var alphaMode: DGIAlphaMode {
        get {
            return DGIAlphaMode(rawValue.AlphaMode)
        }
        set {
            rawValue.AlphaMode = newValue.rawValue
        }
    }

    /// A combination of DXGI_SWAP_CHAIN_FLAG-typed values that are combined by using a bitwise OR operation. The resulting value specifies options for swap-chain behavior.
    @inlinable @inline(__always)
    public var flags: DGISwapChainFlags {
        get {
            return DGISwapChainFlags(rawValue: Int32(rawValue.Flags))
        }
        set {
            rawValue.Flags = UInt32(newValue.rawValue)
        }
    }

    /** Describes a swap chain.
    - parameter width: A value that describes the resolution width. If you specify the width as zero when you call the IDXGIFactory2::CreateSwapChainForHwnd method to create a swap chain, the runtime obtains the width from the output window and assigns this width value to the swap-chain description. You can subsequently call the IDXGISwapChain1::GetDesc1 method to retrieve the assigned width value. You cannot specify the width as zero when you call the IDXGIFactory2::CreateSwapChainForComposition method.
    - parameter height: A value that describes the resolution height. If you specify the height as zero when you call the IDXGIFactory2::CreateSwapChainForHwnd method to create a swap chain, the runtime obtains the height from the output window and assigns this height value to the swap-chain description. You can subsequently call the IDXGISwapChain1::GetDesc1 method to retrieve the assigned height value. You cannot specify the height as zero when you call the IDXGIFactory2::CreateSwapChainForComposition method.
    - parameter format: A DXGI_FORMAT structure that describes the display format.
    - parameter isStereo: Specifies whether the full-screen display mode or the swap-chain back buffer is stereo. TRUE if stereo; otherwise, FALSE. If you specify stereo, you must also specify a flip-model swap chain (that is, a swap chain that has the DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL value set in the SwapEffect member).
    - parameter sampleDescription: A DXGI_SAMPLE_DESC structure that describes multi-sampling parameters. This member is valid only with bit-block transfer (bitblt) model swap chains.
    - parameter bufferUsage: A DXGI_USAGE-typed value that describes the surface usage and CPU access options for the back buffer. The back buffer can be used for shader input or render-target output.
    - parameter bufferCount: A value that describes the number of buffers in the swap chain. When you create a full-screen swap chain, you typically include the front buffer in this value.
    - parameter scaling: A DXGI_SCALING-typed value that identifies resize behavior if the size of the back buffer is not equal to the target output.
    - parameter swapEffect: A DXGI_SWAP_EFFECT-typed value that describes the presentation model that is used by the swap chain and options for handling the contents of the presentation buffer after presenting a surface. You must specify the DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL value when you call the IDXGIFactory2::CreateSwapChainForComposition method because this method supports only flip presentation model.
    - parameter alphaMode: A DXGI_ALPHA_MODE-typed value that identifies the transparency behavior of the swap-chain back buffer.
    - parameter flags: A combination of DXGI_SWAP_CHAIN_FLAG-typed values that are combined by using a bitwise OR operation. The resulting value specifies options for swap-chain behavior.
    */
    @inlinable @inline(__always)
    public init(width: UInt32,
                height: UInt32,
                format: DGIFormat,
                isStereo: Bool,
                sampleDescription: DGISampleDescription,
                bufferUsage: DGIUsage,
                bufferCount: UInt32,
                scaling: DGIScaling,
                swapEffect: DGISwapEffect,
                alphaMode: DGIAlphaMode,
                flags: DGISwapChainFlags) {
        self.rawValue = RawValue()
        self.width = width
        self.height = height
        self.format = format
        self.isStereo = isStereo
        self.sampleDescription = sampleDescription
        self.bufferUsage = bufferUsage
        self.bufferCount = bufferCount
        self.scaling = scaling
        self.swapEffect = swapEffect
        self.alphaMode = alphaMode
        self.flags = flags
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGISwapChainDescription1")
public typealias DXGI_SWAP_CHAIN_DESC1 = DGISwapChainDescription1

#endif
