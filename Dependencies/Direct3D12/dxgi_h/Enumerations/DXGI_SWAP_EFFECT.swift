/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK


/// Options for handling pixels in a display surface after calling IDXGISwapChain1::Present1.
public enum DGISwapEffect {
    public typealias RawValue = WinSDK.DXGI_SWAP_EFFECT 
    
    /// Use this flag to specify the flip presentation model and to specify that DXGI persist the contents of the back buffer after you call IDXGISwapChain1::Present1. This flag cannot be used with multisampling.
    case flipSequential
    /// Use this flag to specify the flip presentation model and to specify that DXGI discard the contents of the back buffer after you call IDXGISwapChain1::Present1.
    case flipDiscard

    case _unimplemented(RawValue)
    
    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .flipSequential:
            return WinSDK.DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL
        case .flipDiscard:
            return WinSDK.DXGI_SWAP_EFFECT_FLIP_DISCARD
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL:
            self = .flipSequential
        case WinSDK.DXGI_SWAP_EFFECT_FLIP_DISCARD:
            self = .flipDiscard
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGISwapEffect")
public typealias DXGI_SWAP_EFFECT = DGISwapEffect


@available(*, unavailable, message: "Not supported.")
public let DXGI_SWAP_EFFECT_DISCARD = DGISwapEffect.flipSequential

@available(*, unavailable, message: "Not supported.")
public let DXGI_SWAP_EFFECT_SEQUENTIAL = DGISwapEffect.flipSequential

@available(*, deprecated, renamed: "DGISwapEffect.aspectRatioStretch")
public let DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL = DGISwapEffect.flipSequential

@available(*, deprecated, renamed: "DGISwapEffect.flipDiscard")
public let DXGI_SWAP_EFFECT_FLIP_DISCARD = DGISwapEffect.flipDiscard

#endif
