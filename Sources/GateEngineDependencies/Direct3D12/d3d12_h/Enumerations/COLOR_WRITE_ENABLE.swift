/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies which components of each pixel of a render target are writable during blending.
public struct D3DColorWriteEnable: OptionSet {
    public typealias RawType = WinSDK.D3D12_COLOR_WRITE_ENABLE
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_COLOR_WRITE_ENABLE.RawValue
    public let rawValue: RawValue

    /// Allow data to be stored in the red component.
    public static let red = D3DColorWriteEnable(rawValue: WinSDK.D3D12_COLOR_WRITE_ENABLE_RED.rawValue)

    /// Allow data to be stored in the green component.
    public static let green = D3DColorWriteEnable(rawValue: WinSDK.D3D12_COLOR_WRITE_ENABLE_GREEN.rawValue)

    /// Allow data to be stored in the blue component.
    public static let blue = D3DColorWriteEnable(rawValue: WinSDK.D3D12_COLOR_WRITE_ENABLE_BLUE.rawValue)

    /// Allow data to be stored in the alpha component.
    public static let alpha = D3DColorWriteEnable(rawValue: WinSDK.D3D12_COLOR_WRITE_ENABLE_ALPHA.rawValue)

    /// Allow data to be stored in all components.
    public static let all = D3DColorWriteEnable(rawValue: WinSDK.D3D12_COLOR_WRITE_ENABLE_ALL.rawValue)

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

@available(*, deprecated, renamed: "D3DColorWriteEnable")
public typealias D3D12_COLOR_WRITE_ENABLE = D3DColorWriteEnable


@available(*, deprecated, renamed: "D3DColorWriteEnable.red")
public let D3D12_COLOR_WRITE_ENABLE_RED = D3DColorWriteEnable.red

@available(*, deprecated, renamed: "D3DColorWriteEnable.green")
public let D3D12_COLOR_WRITE_ENABLE_GREEN = D3DColorWriteEnable.green

@available(*, deprecated, renamed: "D3DColorWriteEnable.blue")
public let D3D12_COLOR_WRITE_ENABLE_BLUE = D3DColorWriteEnable.blue

@available(*, deprecated, renamed: "D3DColorWriteEnable.alpha")
public let D3D12_COLOR_WRITE_ENABLE_ALPHA = D3DColorWriteEnable.alpha

@available(*, deprecated, renamed: "D3DColorWriteEnable.all")
public let D3D12_COLOR_WRITE_ENABLE_ALL = D3DColorWriteEnable.all

#endif
