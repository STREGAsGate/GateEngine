/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies a technique for resolving texture coordinates that are outside of the boundaries of a texture.
public enum D3DTextureAddressMode {
    public typealias RawValue = WinSDK.D3D12_TEXTURE_ADDRESS_MODE
    
    ///	Tile the texture at every (u,v) integer junction.
    /// For example, for u values between 0 and 3, the texture is repeated three times.
    case wrap
    ///	Flip the texture at every (u,v) integer junction.
    /// For u values between 0 and 1, for example, the texture is addressed normally; between 1 and 2, the texture is flipped (mirrored); between 2 and 3, the texture is normal again; and so on.
    case mirror
    ///	Texture coordinates outside the range [0.0, 1.0] are set to the texture color at 0.0 or 1.0, respectively.
    case clamp
    ///	Texture coordinates outside the range [0.0, 1.0] are set to the border color specified in D3D12_SAMPLER_DESC or HLSL code.
    case border
    ///	Similar to D3D12_TEXTURE_ADDRESS_MODE_MIRROR and D3D12_TEXTURE_ADDRESS_MODE_CLAMP.
    /// Takes the absolute value of the texture coordinate (thus, mirroring around 0), and then clamps to the maximum value.
    case mirrorOnce

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .wrap:
            return WinSDK.D3D12_TEXTURE_ADDRESS_MODE_WRAP
        case .mirror:
            return WinSDK.D3D12_TEXTURE_ADDRESS_MODE_MIRROR
        case .clamp:
            return WinSDK.D3D12_TEXTURE_ADDRESS_MODE_CLAMP
        case .border:
            return WinSDK.D3D12_TEXTURE_ADDRESS_MODE_BORDER
        case .mirrorOnce:
            return WinSDK.D3D12_TEXTURE_ADDRESS_MODE_MIRROR_ONCE
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }
    
    @inlinable @inline(__always)
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_TEXTURE_ADDRESS_MODE_WRAP:
            self = .wrap
        case WinSDK.D3D12_TEXTURE_ADDRESS_MODE_MIRROR:
            self = .mirror
        case WinSDK.D3D12_TEXTURE_ADDRESS_MODE_CLAMP:
            self = .clamp
        case WinSDK.D3D12_TEXTURE_ADDRESS_MODE_BORDER:
            self = .border
        case WinSDK.D3D12_TEXTURE_ADDRESS_MODE_MIRROR_ONCE:
            self = .mirrorOnce
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DTextureAddressMode")
public typealias D3D12_TEXTURE_ADDRESS_MODE = D3DTextureAddressMode


@available(*, deprecated, renamed: "D3DTextureAddressMode.wrap")
public let D3D12_TEXTURE_ADDRESS_MODE_WRAP = D3DTextureAddressMode.wrap

@available(*, deprecated, renamed: "D3DTextureAddressMode.mirror")
public let D3D12_TEXTURE_ADDRESS_MODE_MIRROR = D3DTextureAddressMode.mirror

@available(*, deprecated, renamed: "D3DTextureAddressMode.clamp")
public let D3D12_TEXTURE_ADDRESS_MODE_CLAMP = D3DTextureAddressMode.clamp

@available(*, deprecated, renamed: "D3DTextureAddressMode.border")
public let D3D12_TEXTURE_ADDRESS_MODE_BORDER = D3DTextureAddressMode.border

@available(*, deprecated, renamed: "D3DTextureAddressMode.mirrorOnce")
public let D3D12_TEXTURE_ADDRESS_MODE_MIRROR_ONCE = D3DTextureAddressMode.mirrorOnce

#endif
