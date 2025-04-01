/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the version of root signature layout.
public enum D3DRootSignatureVersion {
    public typealias RawValue = WinSDK.D3D_ROOT_SIGNATURE_VERSION
    /// Version one of root signature layout.
    case v1_0
    ///	Version 1.1 of root signature layout.
    @available(Windows, introduced: 10.0.14393)
    case v1_1

    @inlinable
    public var rawValue: RawValue {
        switch self {
            case .v1_0:
                return WinSDK.D3D_ROOT_SIGNATURE_VERSION_1_0
            case .v1_1:
                return WinSDK.D3D_ROOT_SIGNATURE_VERSION_1_1
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootSignatureVersion")
public typealias D3D_ROOT_SIGNATURE_VERSION = D3DRootSignatureVersion


@available(*, deprecated, renamed: "v1_0")
let D3D_ROOT_SIGNATURE_VERSION_1_0: D3DRootSignatureVersion = .v1_0

@available(Windows, introduced: 10.0.14393)
@available(*, deprecated, renamed: "v1_1")
let D3D_ROOT_SIGNATURE_VERSION_1_1: D3DRootSignatureVersion = .v1_1

#endif
