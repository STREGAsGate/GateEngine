/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK


/// Flags indicating the method the raster uses to create an image on a surface.
public enum DGIModeScaling {
    public typealias RawValue = WinSDK.DXGI_MODE_SCALING 
    
    /// Unspecified scaling.
    case unspecified
    /// Specifies no scaling. The image is centered on the display. This flag is typically used for a fixed-dot-pitch display (such as an LED display).
    case centered
    /// Specifies stretched scaling.
    case stretched

    case _unimplemented(RawValue)
    
    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .unspecified:
            return WinSDK.DXGI_MODE_SCALING_UNSPECIFIED
        case .centered:
            return WinSDK.DXGI_MODE_SCALING_CENTERED
        case .stretched:
            return WinSDK.DXGI_MODE_SCALING_STRETCHED
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.DXGI_MODE_SCALING_UNSPECIFIED:
            self = .unspecified
        case WinSDK.DXGI_MODE_SCALING_CENTERED:
            self = .centered
        case WinSDK.DXGI_MODE_SCALING_STRETCHED:
            self = .stretched
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIModeScaling")
public typealias DXGI_MODE_SCALING = DGIModeScaling


@available(*, deprecated, renamed: "DGIModeScaling.unspecified")
public let DXGI_MODE_SCALING_UNSPECIFIED = DGIModeScaling.unspecified

@available(*, deprecated, renamed: "DGIModeScaling.progressive")
public let DXGI_MODE_SCALING_CENTERED = DGIModeScaling.centered

@available(*, deprecated, renamed: "DGIModeScaling.upperFieldFirst")
public let DXGI_MODE_SCALING_STRETCHED = DGIModeScaling.stretched

#endif
