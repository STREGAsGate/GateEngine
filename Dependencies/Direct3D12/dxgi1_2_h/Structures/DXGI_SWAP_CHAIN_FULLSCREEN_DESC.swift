/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes full-screen mode for a swap chain.
public struct DGISwapChainFullscreenDescription {
    public typealias RawValue = WinSDK.DXGI_SWAP_CHAIN_FULLSCREEN_DESC
    @usableFromInline
    internal var rawValue: RawValue

    /// A DXGI_RATIONAL structure that describes the refresh rate in hertz.
    @inlinable @inline(__always)
    public var refreshRate: DGIRational {
        get {
            return DGIRational(rawValue.RefreshRate)
        }
        set {
            rawValue.RefreshRate = newValue.rawValue
        }
    }

    /// A member of the DXGI_MODE_SCANLINE_ORDER enumerated type that describes the scan-line drawing mode.
    @inlinable @inline(__always)
    public var scanlineOrdering: DGIModeScanlineOrder {
        get {
            return DGIModeScanlineOrder(rawValue.ScanlineOrdering)
        }
        set {
            rawValue.ScanlineOrdering = newValue.rawValue
        }
    }

    /// A member of the DXGI_MODE_SCALING enumerated type that describes the scaling mode.
    @inlinable @inline(__always)
    public var scaling: DGIModeScaling {
        get {
            return DGIModeScaling(rawValue.Scaling)
        }
        set {
            rawValue.Scaling = newValue.rawValue
        }
    }

    /// A Boolean value that specifies whether the swap chain is in windowed mode. TRUE if the swap chain is in windowed mode; otherwise, FALSE.
    @inlinable @inline(__always)
    public var isWindowed: Bool {
        get {
            return rawValue.Windowed.boolValue
        }
        set {
            rawValue.Windowed = WindowsBool(booleanLiteral: newValue)
        }
    }

    /** Describes full-screen mode for a swap chain.
    - parameter refreshRate: A DXGI_RATIONAL structure that describes the refresh rate in hertz.
    - parameter scanlineOrdering: A member of the DXGI_MODE_SCANLINE_ORDER enumerated type that describes the scan-line drawing mode.
    - parameter scaling: A member of the DXGI_MODE_SCALING enumerated type that describes the scaling mode.
    - parameter isWindowed: A Boolean value that specifies whether the swap chain is in windowed mode. TRUE if the swap chain is in windowed mode; otherwise, FALSE.
    */
    @inlinable @inline(__always)
    public init(refreshRate: DGIRational,
                scanlineOrdering: DGIModeScanlineOrder = .unspecified,
                scaling: DGIModeScaling = .unspecified,
                isWindowed: Bool = true) {
        self.rawValue = RawValue()
        self.refreshRate = refreshRate
        self.scanlineOrdering = scanlineOrdering
        self.scaling = scaling
        self.isWindowed = isWindowed
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGISwapChainFullscreenDescription")
public typealias DXGI_SWAP_CHAIN_FULLSCREEN_DESC = DGISwapChainFullscreenDescription

#endif
