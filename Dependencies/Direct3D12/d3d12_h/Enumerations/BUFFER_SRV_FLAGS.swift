/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies how to view a buffer resource.
public struct D3DBufferShaderResourceViewFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_BUFFER_SRV_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_BUFFER_SRV_FLAGS.RawValue
    public let rawValue: RawValue

    //Use an empty collection `[]` to represent none in Swift.
    ///// Indicates a default view.
    //public static let none = D3DBufferShaderResourceViewFlags(rawValue: D3D12_BUFFER_SRV_FLAG_NONE.rawValue)

    ///	View the buffer as raw. For more info about raw viewing of buffers, see [Raw Views of Buffers](https://docs.microsoft.com/en-us/windows/desktop/direct3d11/overviews-direct3d-11-resources-intro).
    public static let raw = D3DBufferShaderResourceViewFlags(rawValue: WinSDK.D3D12_BUFFER_SRV_FLAG_RAW.rawValue)

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

@available(*, deprecated, renamed: "D3DBufferShaderResourceViewFlags")
public typealias D3D12_BUFFER_SRV_FLAG = D3DBufferShaderResourceViewFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_BUFFER_SRV_FLAG_NONE: D3DBufferShaderResourceViewFlags = []

@available(*, deprecated, renamed: "D3DBufferShaderResourceViewFlags.raw")
public let D3D12_BUFFER_SRV_FLAG_RAW = D3DBufferShaderResourceViewFlags.raw

#endif
