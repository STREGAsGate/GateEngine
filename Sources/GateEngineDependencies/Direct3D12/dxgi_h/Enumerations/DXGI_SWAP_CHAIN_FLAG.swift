/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public struct DGISwapChainFlags: OptionSet {
    public typealias RawType = WinSDK.DXGI_SWAP_CHAIN_FLAG
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.DXGI_SWAP_CHAIN_FLAG.RawValue
    public let rawValue: RawValue

    /// Set this flag to enable an application to switch modes by calling IDXGISwapChain::ResizeTarget. When switching from windowed to full-screen mode, the display mode (or monitor resolution) will be changed to match the dimensions of the application window.
    public static let allowModeSwitch = DGISwapChainFlags(rawValue: WinSDK.DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH.rawValue)

    /// Tearing support is a requirement to enable displays that support variable refresh rates to function properly when the application presents a swap chain tied to a full screen borderless window. Win32 apps can already achieve tearing in fullscreen exclusive mode by calling SetFullscreenState(TRUE), but the recommended approach for Win32 developers is to use this tearing flag instead. This flag requires the use of a DXGI_SWAP_EFFECT_FLIP_* swap effect.
    public static let allowTearing = DGISwapChainFlags(rawValue: WinSDK.DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING.rawValue)


    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init(_ rawType: RawType) {
        self.rawValue = rawType.rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGISwapChainFlags")
public typealias DXGI_SWAP_CHAIN_FLAG = DGISwapChainFlags

@available(*, deprecated, renamed: "DGISwapChainFlags.allowModeSwitch")
public let DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH = DGISwapChainFlags.allowModeSwitch

@available(*, deprecated, renamed: "DGISwapChainFlags.allowTearing")
public let DXGI_SWAP_CHAIN_FLAG_ALLOW_TEARING = DGISwapChainFlags.allowTearing

#endif
