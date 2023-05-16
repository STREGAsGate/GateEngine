/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies a shader model.
public enum D3DFeatureLevel {
    public typealias RawValue = WinSDK.D3D_FEATURE_LEVEL
    
    case v1Core
    case v9_1
    case v9_2
    case v9_3
    case v10
    case v10_1
    case v11
    case v11_1
    case v12
    case v12_1

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
            case .v1Core:
                return WinSDK.D3D_FEATURE_LEVEL_1_0_CORE
            case .v9_1:
                return WinSDK.D3D_FEATURE_LEVEL_9_1
            case .v9_2:
                return WinSDK.D3D_FEATURE_LEVEL_9_2
            case .v9_3:
                return WinSDK.D3D_FEATURE_LEVEL_9_3
            case .v10:
                return WinSDK.D3D_FEATURE_LEVEL_10_0
            case .v10_1:
                return WinSDK.D3D_FEATURE_LEVEL_10_1
            case .v11:
                return WinSDK.D3D_FEATURE_LEVEL_11_0
            case .v11_1:
                return WinSDK.D3D_FEATURE_LEVEL_11_1
            case .v12:
                return WinSDK.D3D_FEATURE_LEVEL_12_0
            case .v12_1:
                return WinSDK.D3D_FEATURE_LEVEL_12_1
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DFeatureLevel")
public typealias D3D_FEATURE_LEVEL = D3DFeatureLevel


@available(*, deprecated, renamed: "D3DFeatureLevel.v1Core")
public let D3D_FEATURE_LEVEL_1_0_CORE = D3DFeatureLevel.v1Core

@available(*, deprecated, renamed: "D3DFeatureLevel.v9_1")
public let D3D_FEATURE_LEVEL_9_1 = D3DFeatureLevel.v9_1

@available(*, deprecated, renamed: "D3DFeatureLevel.v9_2")
public let D3D_FEATURE_LEVEL_9_2 = D3DFeatureLevel.v9_2

@available(*, deprecated, renamed: "D3DFeatureLevel.v9_3")
public let D3D_FEATURE_LEVEL_9_3 = D3DFeatureLevel.v9_3

@available(*, deprecated, renamed: "D3DFeatureLevel.v10")
public let D3D_FEATURE_LEVEL_10_0 = D3DFeatureLevel.v10

@available(*, deprecated, renamed: "D3DFeatureLevel.v10_1")
public let D3D_FEATURE_LEVEL_10_1 = D3DFeatureLevel.v10_1

@available(*, deprecated, renamed: "D3DFeatureLevel.v11")
public let D3D_FEATURE_LEVEL_11_0 = D3DFeatureLevel.v11

@available(*, deprecated, renamed: "D3DFeatureLevel.v11_1")
public let D3D_FEATURE_LEVEL_11_1 = D3DFeatureLevel.v11_1

@available(*, deprecated, renamed: "D3DFeatureLevel.v12")
public let D3D_FEATURE_LEVEL_12_0 = D3DFeatureLevel.v12

@available(*, deprecated, renamed: "D3DFeatureLevel.v12_1")
public let D3D_FEATURE_LEVEL_12_1 = D3DFeatureLevel.v12_1

#endif
