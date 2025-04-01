/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK


/// Specifies a shader model.
public enum DGIScaling {
    public typealias RawValue = WinSDK.DXGI_SCALING 
    
    /// Directs DXGI to make the back-buffer contents appear without any scaling when the presentation target size is not equal to the back-buffer size. The top edges of the back buffer and presentation target are aligned together. If the WS_EX_LAYOUTRTL style is associated with the HWND handle to the target output window, the right edges of the back buffer and presentation target are aligned together; otherwise, the left edges are aligned together. All target area outside the back buffer is filled with window background color.
    case none
    /// Directs DXGI to make the back-buffer contents scale to fit the presentation target size. This is the implicit behavior of DXGI when you call the IDXGIFactory::CreateSwapChain method.
    case stretch
    /// Directs DXGI to make the back-buffer contents scale to fit the presentation target size, while preserving the aspect ratio of the back-buffer. If the scaled back-buffer does not fill the presentation area, it will be centered with black borders.
    case aspectRatioStretch

    case _unimplemented(RawValue)
    
    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .none:
            return WinSDK.DXGI_SCALING_NONE
        case .stretch:
            return WinSDK.DXGI_SCALING_STRETCH
        case .aspectRatioStretch:
            return WinSDK.DXGI_SCALING_ASPECT_RATIO_STRETCH
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
       switch rawValue {
        case WinSDK.DXGI_SCALING_NONE:
            self = .none
        case WinSDK.DXGI_SCALING_STRETCH:
            self = .stretch
        case WinSDK.DXGI_SCALING_ASPECT_RATIO_STRETCH:
            self = .aspectRatioStretch
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIScaling")
public typealias DXGI_SCALING = DGIScaling


@available(*, deprecated, renamed: "DGIScaling.none")
public let DXGI_SCALING_NONE = DGIScaling.none

@available(*, deprecated, renamed: "DGIScaling.stretch")
public let DXGI_SCALING_STRETCH = DGIScaling.stretch

@available(*, deprecated, renamed: "DGIScaling.aspectRatioStretch")
public let DXGI_SCALING_ASPECT_RATIO_STRETCH = DGIScaling.aspectRatioStretch

#endif
