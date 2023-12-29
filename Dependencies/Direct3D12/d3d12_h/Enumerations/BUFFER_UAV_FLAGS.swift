/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies unordered-access view options for a buffer resource.
public struct D3DBufferUnorderedAccessViewFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_BUFFER_UAV_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_BUFFER_UAV_FLAGS.RawValue
    public let rawValue: RawValue

    //Use an empty collection `[]` to represent none in Swift.
    ///// Indicates a default view.
    //public static let none = D3DBufferUnorderedAccessViewFlags(rawValue: D3D12_BUFFER_UAV_FLAG_NONE.rawValue)

    /// Resource contains raw, unstructured data. Requires the UAV format to be [DXGI_FORMAT_R32_TYPELESS](https://docs.microsoft.com/en-us/windows/desktop/api/dxgiformat/ne-dxgiformat-dxgi_format).
    /// For more info about raw viewing of buffers, see [Raw Views of Buffers](https://docs.microsoft.com/en-us/windows/desktop/direct3d11/overviews-direct3d-11-resources-intro).
    public static let raw = D3DBufferUnorderedAccessViewFlags(rawValue: WinSDK.D3D12_BUFFER_UAV_FLAG_RAW.rawValue)

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

@available(*, deprecated, renamed: "D3DBufferUnorderedAccessViewFlags")
public typealias D3D12_BUFFER_UAV_FLAG = D3DBufferUnorderedAccessViewFlags


@available(*, deprecated, message: "Use `[]` to represent none in Swift.")
public let D3D12_BUFFER_UAV_FLAG_NONE: D3DBufferUnorderedAccessViewFlags = []

@available(*, deprecated, renamed: "D3DBufferUnorderedAccessViewFlags.raw")
public let D3D12_BUFFER_UAV_FLAG_RAW = D3DBufferUnorderedAccessViewFlags.raw

#endif
