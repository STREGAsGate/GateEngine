/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies blend factors, which modulate values for the pixel shader and render target.
public enum D3DBlendFactor {
    public typealias RawValue = WinSDK.D3D12_BLEND

    ///	The blend factor is (0, 0, 0, 0). No pre-blend operation.
    case zero
    ///	The blend factor is (1, 1, 1, 1). No pre-blend operation.
    case one
    ///	The blend factor is (Rₛ, Gₛ, Bₛ, Aₛ), that is color data (RGB) from a pixel shader. No pre-blend operation.
    case sourceColor
    ///	The blend factor is (1 - Rₛ, 1 - Gₛ, 1 - Bₛ, 1 - Aₛ), that is color data (RGB) from a pixel shader. The pre-blend operation inverts the data, generating 1 - RGB.
    case inverseSourceColor
    ///	The blend factor is (Aₛ, Aₛ, Aₛ, Aₛ), that is alpha data (A) from a pixel shader. No pre-blend operation.
    case sourceAlpha
    ///	The blend factor is ( 1 - Aₛ, 1 - Aₛ, 1 - Aₛ, 1 - Aₛ), that is alpha data (A) from a pixel shader. The pre-blend operation inverts the data, generating 1 - A.
    case inverseSourceAlpha
    ///	The blend factor is (Ad Ad Ad Ad), that is alpha data from a render target. No pre-blend operation.
    case destinationAlpha
    ///	The blend factor is (1 - Ad 1 - Ad 1 - Ad 1 - Ad), that is alpha data from a render target. The pre-blend operation inverts the data, generating 1 - A.
    case inverseDestinationAlpha
    /// The blend factor is (Rd, Gd, Bd, Ad), that is color data from a render target. No pre-blend operation.
    case destinationColor
    ///	The blend factor is (1 - Rd, 1 - Gd, 1 - Bd, 1 - Ad), that is color data from a render target. The pre-blend operation inverts the data, generating 1 - RGB.
    case inverseDestinationColor
    ///	The blend factor is (f, f, f, 1); where f = min(Aₛ, 1 - Ad). The pre-blend operation clamps the data to 1 or less.
    case sourceAlphaSaturate
    ///	The blend factor is the blend factor set with [ID3D12GraphicsCommandList::OMSetBlendFactor](https://docs.microsoft.com/en-us/windows/desktop/api/d3d12/nf-d3d12-id3d12graphicscommandlist-omsetblendfactor). No pre-blend operation.
    case blendFactor
    ///	The blend factor is the blend factor set with [ID3D12GraphicsCommandList::OMSetBlendFactor](https://docs.microsoft.com/en-us/windows/desktop/api/d3d12/nf-d3d12-id3d12graphicscommandlist-omsetblendfactor). The pre-blend operation inverts the blend factor, generating 1 - blend_factor.
    case inverseBlendFactor
    ///	The blend factor is data sources both as color data output by a pixel shader. There is no pre-blend operation. This blend factor supports dual-source color blending.
    case source1Color
    ///	The blend factor is data sources both as color data output by a pixel shader. The pre-blend operation inverts the data, generating 1 - RGB. This blend factor supports dual-source color blending.
    case inverseSource1Color
    ///	The blend factor is data sources as alpha data output by a pixel shader. There is no pre-blend operation. This blend factor supports dual-source color blending.
    case source1Alpha
    ///	The blend factor is data sources as alpha data output by a pixel shader. The pre-blend operation inverts the data, generating 1 - A. This blend factor supports dual-source color blending.
    case inverseSource1Alpha

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .zero:
            return WinSDK.D3D12_BLEND_ZERO
        case .one:
            return WinSDK.D3D12_BLEND_ONE
        case .sourceColor:
            return WinSDK.D3D12_BLEND_SRC_COLOR
        case .inverseSourceColor:
            return WinSDK.D3D12_BLEND_INV_SRC_COLOR
        case .sourceAlpha:
            return WinSDK.D3D12_BLEND_SRC_ALPHA
        case .inverseSourceAlpha:
            return WinSDK.D3D12_BLEND_INV_SRC_ALPHA
        case .destinationAlpha:
            return WinSDK.D3D12_BLEND_DEST_ALPHA
        case .inverseDestinationAlpha:
            return WinSDK.D3D12_BLEND_INV_DEST_ALPHA
        case .destinationColor:
            return WinSDK.D3D12_BLEND_DEST_COLOR
        case .inverseDestinationColor:
            return WinSDK.D3D12_BLEND_INV_DEST_COLOR
        case .sourceAlphaSaturate:
            return WinSDK.D3D12_BLEND_SRC_ALPHA_SAT
        case .blendFactor:
            return WinSDK.D3D12_BLEND_BLEND_FACTOR
        case .inverseBlendFactor:
            return WinSDK.D3D12_BLEND_INV_BLEND_FACTOR
        case .source1Color:
            return WinSDK.D3D12_BLEND_SRC1_COLOR
        case .inverseSource1Color:
            return WinSDK.D3D12_BLEND_INV_SRC1_COLOR
        case .source1Alpha:
            return WinSDK.D3D12_BLEND_SRC1_ALPHA
        case .inverseSource1Alpha:
            return WinSDK.D3D12_BLEND_INV_SRC1_ALPHA
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_BLEND_ZERO:
            self = .zero
        case WinSDK.D3D12_BLEND_ONE:
            self = .one
        case WinSDK.D3D12_BLEND_SRC_COLOR:
            self = .sourceColor
        case WinSDK.D3D12_BLEND_INV_SRC_COLOR:
            self = .inverseSourceColor
        case WinSDK.D3D12_BLEND_SRC_ALPHA:
            self = .sourceAlpha
        case WinSDK.D3D12_BLEND_INV_SRC_ALPHA:
            self = .inverseSourceAlpha
        case WinSDK.D3D12_BLEND_DEST_ALPHA:
            self = .destinationAlpha
        case WinSDK.D3D12_BLEND_INV_DEST_ALPHA:
            self = .inverseDestinationAlpha
        case WinSDK.D3D12_BLEND_DEST_COLOR:
            self = .destinationColor
        case WinSDK.D3D12_BLEND_INV_DEST_COLOR:
            self = .inverseDestinationColor
        case WinSDK.D3D12_BLEND_SRC_ALPHA_SAT:
            self = .sourceAlphaSaturate
        case WinSDK.D3D12_BLEND_BLEND_FACTOR:
            self = .blendFactor
        case WinSDK.D3D12_BLEND_INV_BLEND_FACTOR:
            self = .inverseBlendFactor
        case WinSDK.D3D12_BLEND_SRC1_COLOR:
            self = .source1Color
        case WinSDK.D3D12_BLEND_INV_SRC1_COLOR:
            self = .inverseSource1Color
        case WinSDK.D3D12_BLEND_SRC1_ALPHA:
            self = .source1Alpha
        case WinSDK.D3D12_BLEND_INV_SRC1_ALPHA:
            self = .inverseSource1Alpha
        default:
            self = ._unimplemented(rawValue)
        }
    }
} 


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DBlendFactor.D3DBlendFactor")
public typealias D3D12_BLEND = D3DBlendFactor


@available(*, deprecated, renamed: "D3DBlendFactor.zero")
public let D3D12_BLEND_ZERO = D3DBlendFactor.zero

@available(*, deprecated, renamed: "D3DBlendFactor.one")
public let D3D12_BLEND_ONE = D3DBlendFactor.one

@available(*, deprecated, renamed: "D3DBlendFactor.sourceColor")
public let D3D12_BLEND_SRC_COLOR = D3DBlendFactor.sourceColor

@available(*, deprecated, renamed: "D3DBlendFactor.inverseSourceColor")
public let D3D12_BLEND_INV_SRC_COLOR = D3DBlendFactor.inverseSourceColor

@available(*, deprecated, renamed: "D3DBlendFactor.sourceAlpha")
public let D3D12_BLEND_SRC_ALPHA = D3DBlendFactor.sourceAlpha

@available(*, deprecated, renamed: "D3DBlendFactor.inverseSourceAlpha")
public let D3D12_BLEND_INV_SRC_ALPHA = D3DBlendFactor.inverseSourceAlpha

@available(*, deprecated, renamed: "D3DBlendFactor.destinationAlpha")
public let D3D12_BLEND_DEST_ALPHA = D3DBlendFactor.destinationAlpha

@available(*, deprecated, renamed: "D3DBlendFactor.inverseDestinationAlpha")
public let D3D12_BLEND_INV_DEST_ALPHA = D3DBlendFactor.inverseDestinationAlpha

@available(*, deprecated, renamed: "D3DBlendFactor.destinationColor")
public let D3D12_BLEND_DEST_COLOR = D3DBlendFactor.destinationColor

@available(*, deprecated, renamed: "D3DBlendFactor.inverseDestinationColor")
public let D3D12_BLEND_INV_DEST_COLOR = D3DBlendFactor.inverseDestinationColor

@available(*, deprecated, renamed: "D3DBlendFactor.sourceAlphaSaturate")
public let D3D12_BLEND_SRC_ALPHA_SAT = D3DBlendFactor.sourceAlphaSaturate

@available(*, deprecated, renamed: "D3DBlendFactor.blendFactor")
public let D3D12_BLEND_BLEND_FACTOR = D3DBlendFactor.blendFactor

@available(*, deprecated, renamed: "D3DBlendFactor.inverseBlendFactor")
public let D3D12_BLEND_INV_BLEND_FACTOR = D3DBlendFactor.inverseBlendFactor

@available(*, deprecated, renamed: "D3DBlendFactor.source1Color")
public let D3D12_BLEND_SRC1_COLOR = D3DBlendFactor.source1Color

@available(*, deprecated, renamed: "D3DBlendFactor.inverseSource1Color")
public let D3D12_BLEND_INV_SRC1_COLOR = D3DBlendFactor.inverseSource1Color

@available(*, deprecated, renamed: "D3DBlendFactor.source1Alpha")
public let D3D12_BLEND_SRC1_ALPHA = D3DBlendFactor.source1Alpha

@available(*, deprecated, renamed: "D3DBlendFactor.inverseSource1Alpha")
public let D3D12_BLEND_INV_SRC1_ALPHA = D3DBlendFactor.inverseSource1Alpha

#endif
