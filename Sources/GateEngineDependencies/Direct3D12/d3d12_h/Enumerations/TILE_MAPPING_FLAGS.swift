/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies how to perform a tile-mapping operation.
public struct D3DTileMappingFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_TILE_MAPPING_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_TILE_MAPPING_FLAGS.RawValue
    public let rawValue: RawValue
    
    //Use an empty collection `[]` to represent none in Swift.
    ///// No tile-mapping flags are specified.
    //public static let none = TileMappingFlags(rawValue: WinSDK.D3D12_TILE_MAPPING_FLAG_NONE.rawValue)

    /// Unsupported, do not use.
    @available(*, unavailable, message: "Unsupported, do not use.")
    public static let noHazard = D3DTileMappingFlags(rawValue: WinSDK.D3D12_TILE_MAPPING_FLAG_NO_HAZARD.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTileMappingFlags")
public typealias D3D12_TILE_MAPPING_FLAGS = D3DTileMappingFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_TILE_MAPPING_FLAG_NONE: D3DTileMappingFlags = []

@available(*, deprecated, renamed: "D3D.noHazard")
public let D3D12_TILE_MAPPING_FLAG_NO_HAZARD = D3DTileMappingFlags(rawValue: WinSDK.D3D12_TILE_MAPPING_FLAG_NO_HAZARD.rawValue)

#endif
