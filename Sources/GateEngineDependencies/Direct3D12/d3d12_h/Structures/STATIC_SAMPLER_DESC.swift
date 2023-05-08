/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a static sampler.
public struct D3DStaticSamplerDescription {
    public typealias RawValue =  WinSDK.D3D12_STATIC_SAMPLER_DESC
    internal var rawValue: RawValue

    /// The filtering method to use when sampling a texture, as a D3D12_FILTER enumeration constant.
    public var filter: D3DFilter {
        get {
            return D3DFilter(rawValue.Filter)
        }
        set {
            rawValue.Filter = newValue.rawType
        }
    }

    /// Specifies the D3D12_TEXTURE_ADDRESS_MODE mode to use for resolving a u texture coordinate that is outside the 0 to 1 range.
    public var addressU: D3DTextureAddressMode {
        get {
            return D3DTextureAddressMode(rawValue.AddressU)
        }
        set {
            rawValue.AddressU = newValue.rawValue
        }
    }

    /// Specifies the D3D12_TEXTURE_ADDRESS_MODE mode to use for resolving a v texture coordinate that is outside the 0 to 1 range.
    public var addressV: D3DTextureAddressMode {
        get {
            return D3DTextureAddressMode(rawValue.AddressV)
        }
        set {
            rawValue.AddressV = newValue.rawValue
        }
    }

    /// Specifies the D3D12_TEXTURE_ADDRESS_MODE mode to use for resolving a w texture coordinate that is outside the 0 to 1 range.
    public var addressW: D3DTextureAddressMode {
        get {
            return D3DTextureAddressMode(rawValue.AddressW)
        }
        set {
            rawValue.AddressW = newValue.rawValue
        }
    }

    /// Offset from the calculated mipmap level. For example, if Direct3D calculates that a texture should be sampled at mipmap level 3 and MipLODBias is 2, then the texture will be sampled at mipmap level 5.
    public var mipLODBias: Float {
        get {
            return rawValue.MipLODBias
        }
        set {
            rawValue.MipLODBias = newValue
        }
    }

    /// Clamping value used if D3D12_FILTER_ANISOTROPIC or D3D12_FILTER_COMPARISON_ANISOTROPIC is specified as the filter. Valid values are between 1 and 16.
    public var maxAnisotropy: UInt32 {
        get {
            return rawValue.MaxAnisotropy
        }
        set {
            rawValue.MaxAnisotropy = newValue
        }
    }

    /// A function that compares sampled data against existing sampled data. The function options are listed in D3D12_COMPARISON_FUNC.
    public var comparisonFunction: D3DComparisonFunction {
        get {
            return D3DComparisonFunction(rawValue.ComparisonFunc)
        }
        set {
            rawValue.ComparisonFunc = newValue.rawValue
        }
    }

    /// One member of D3D12_STATIC_BORDER_COLOR, the border color to use if D3D12_TEXTURE_ADDRESS_MODE_BORDER is specified for AddressU, AddressV, or AddressW. Range must be between 0.0 and 1.0 inclusive.
    public var borderColor: D3DStaticBorderColor {
        get {
            return D3DStaticBorderColor(rawValue.BorderColor)
        }
        set {
            rawValue.BorderColor = newValue.rawValue
        }
    }

    /// Lower end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed.
    public var minLOD: Float {
        get {
            return rawValue.MinLOD
        }
        set {
            rawValue.MinLOD = newValue
        }
    }

    /// Upper end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed. This value must be greater than or equal to MinLOD. To have no upper limit on LOD set this to a large value such as D3D12_FLOAT32_MAX.
    public var maxLOD: Float {
        get {
            return rawValue.MaxLOD
        }
        set {
            rawValue.MaxLOD = newValue
        }
    }

    /**
    The ShaderRegister and RegisterSpace parameters correspond to the binding syntax of HLSL. 
    For example, in HLSL:
    `Texture2D<float4> a : register(t2, space3);`
    This corresponds to a ShaderRegister of 2 (indicating the type is SRV), and RegisterSpace is 3.
    The ShaderRegister and RegisterSpace pair is needed to establish correspondence between shader resources and runtime heap descriptors, using the root signature data structure.
    */
    public var shaderRegister: UInt32 {
        get {
            return rawValue.ShaderRegister
        }
        set {
            rawValue.ShaderRegister = newValue
        }
    }

    /**
    The ShaderRegister and RegisterSpace parameters correspond to the binding syntax of HLSL.
    For example, in HLSL:
    `Texture2D<float4> a : register(t2, space3);`
    This corresponds to a ShaderRegister of 2 (indicating the type is SRV), and RegisterSpace is 3.
    The ShaderRegister and RegisterSpace pair is needed to establish correspondence between shader resources and runtime heap descriptors, using the root signature data structure.
    */
    public var registerSpace: UInt32 {
        get {
            return rawValue.RegisterSpace
        }
        set {
            rawValue.RegisterSpace = newValue
        }
    }

    /// Specifies the visibility of the sampler to the pipeline shaders, one member of D3D12_SHADER_VISIBILITY.
    public var shaderVisibility: D3DShaderVisibility {
        get {
            return D3DShaderVisibility(rawValue.ShaderVisibility)
        }
        set {
            rawValue.ShaderVisibility = newValue.rawValue
        }
    }

    /** Describes a static sampler.
    - parameter filter: The filtering method to use when sampling a texture, as a D3D12_FILTER enumeration constant.
    - parameter addressU: Specifies the D3D12_TEXTURE_ADDRESS_MODE mode to use for resolving a u texture coordinate that is outside the 0 to 1 range.
    - parameter addressV: Specifies the D3D12_TEXTURE_ADDRESS_MODE mode to use for resolving a v texture coordinate that is outside the 0 to 1 range.
    - parameter addressW: Specifies the D3D12_TEXTURE_ADDRESS_MODE mode to use for resolving a w texture coordinate that is outside the 0 to 1 range.
    - parameter mipLODBias: Offset from the calculated mipmap level. For example, if Direct3D calculates that a texture should be sampled at mipmap level 3 and MipLODBias is 2, then the texture will be sampled at mipmap level 5.
    - parameter maxAnisotropy: Clamping value used if D3D12_FILTER_ANISOTROPIC or D3D12_FILTER_COMPARISON_ANISOTROPIC is specified as the filter. Valid values are between 1 and 16.
    - parameter comparisonFunction: A function that compares sampled data against existing sampled data. The function options are listed in D3D12_COMPARISON_FUNC.
    - parameter borderColor: One member of D3D12_STATIC_BORDER_COLOR, the border color to use if D3D12_TEXTURE_ADDRESS_MODE_BORDER is specified for AddressU, AddressV, or AddressW. Range must be between 0.0 and 1.0 inclusive.
    - parameter minLOD: Lower end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed.
    - parameter maxLOD: Upper end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed. This value must be greater than or equal to MinLOD. To have no upper limit on LOD set this to a large value such as D3D12_FLOAT32_MAX.
    - parameter shaderRegister The ShaderRegister and RegisterSpace parameters correspond to the binding syntax of HLSL.
    - parameter registerSpace: The ShaderRegister and RegisterSpace parameters correspond to the binding syntax of HLSL.
    - parameter shaderVisibility: Specifies the visibility of the sampler to the pipeline shaders, one member of D3D12_SHADER_VISIBILITY.
    */
    public init(filter: D3DFilter,
                addressU: D3DTextureAddressMode = .border,
                addressV: D3DTextureAddressMode = .border,
                addressW: D3DTextureAddressMode = .border,
                mipLODBias: Float = 0,
                maxAnisotropy: UInt32 = 0,
                comparisonFunction: D3DComparisonFunction = .neverSucceed,
                borderColor: D3DStaticBorderColor = .transparentBlack,
                minLOD: Float = 0,
                maxLOD: Float = D3D12_FLOAT32_MAX,
                shaderRegister: UInt32,
                registerSpace: UInt32 = 0,
                shaderVisibility: D3DShaderVisibility = .all) {
        self.rawValue = RawValue()
        self.filter = filter
        self.addressU = addressU
        self.addressV = addressV
        self.addressW = addressW
        self.mipLODBias = mipLODBias
        self.maxAnisotropy = maxAnisotropy
        self.comparisonFunction = comparisonFunction
        self.borderColor = borderColor
        self.minLOD = minLOD
        self.maxLOD = maxLOD
        self.shaderRegister = shaderRegister
        self.shaderVisibility = shaderVisibility
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DStaticSamplerDescription")
public typealias D3D12_STATIC_SAMPLER_DESC = D3DStaticSamplerDescription

#endif
