/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes a sampler state.
public struct D3DSamplerDescription {
    public typealias RawValue = WinSDK.D3D12_SAMPLER_DESC
    @usableFromInline
    internal var rawValue: RawValue

    /// A D3D12_FILTER-typed value that specifies the filtering method to use when sampling a texture.
    @inlinable @inline(__always)
    public var filter: D3DFilter {
        get {
            return D3DFilter(rawValue.Filter)
        }
        set {
            rawValue.Filter = newValue.rawType
        }
    }

    /// A D3D12_TEXTURE_ADDRESS_MODE-typed value that specifies the method to use for resolving a u texture coordinate that is outside the 0 to 1 range.
    @inlinable @inline(__always)
    public var addressU: D3DTextureAddressMode {
        get {
            return D3DTextureAddressMode(rawValue.AddressU)
        }
        set {
            rawValue.AddressU = newValue.rawValue
        }
    }

    /// A D3D12_TEXTURE_ADDRESS_MODE-typed value that specifies the method to use for resolving a v texture coordinate that is outside the 0 to 1 range.
    @inlinable @inline(__always)
    public var addressV: D3DTextureAddressMode {
        get {
            return D3DTextureAddressMode(rawValue.AddressV)
        }
        set {
            rawValue.AddressV = newValue.rawValue
        }
    }

    /// A D3D12_TEXTURE_ADDRESS_MODE-typed value that specifies the method to use for resolving a w texture coordinate that is outside the 0 to 1 range.
    @inlinable @inline(__always)
    public var addressW: D3DTextureAddressMode {
        get {
            return D3DTextureAddressMode(rawValue.AddressW)
        }
        set {
            rawValue.AddressW = newValue.rawValue
        }
    }

    /// Offset from the calculated mipmap level. For example, if the runtime calculates that a texture should be sampled at mipmap level 3 and MipLODBias is 2, the texture will be sampled at mipmap level 5.
    @inlinable @inline(__always)
    public var mipLODBias: Float {
        get {
            return rawValue.MipLODBias
        }
        set {
            rawValue.MipLODBias = newValue
        }
    }

    /// Clamping value used if D3D12_FILTER_ANISOTROPIC or D3D12_FILTER_COMPARISON_ANISOTROPIC is specified in Filter. Valid values are between 1 and 16.
    @inlinable @inline(__always)
    public var maxAnisotropy: UInt32 {
        get {
            return rawValue.MaxAnisotropy
        }
        set {
            rawValue.MaxAnisotropy = newValue
        }
    }

    /// A D3D12_COMPARISON_FUNC-typed value that specifies a function that compares sampled data against existing sampled data.    
    @inlinable @inline(__always)
    public var comparisonFunction: D3DComparisonFunction {
        get {
            return D3DComparisonFunction(rawValue.ComparisonFunc)
        }
        set {
            rawValue.ComparisonFunc = newValue.rawValue
        }
    }

    /// Border color to use if D3D12_TEXTURE_ADDRESS_MODE_BORDER is specified for AddressU, AddressV, or AddressW. Range must be between 0.0 and 1.0 inclusive.
    @inlinable @inline(__always)
    public var borderColor: D3DColor {
        get {
            return D3DColor(rawValue.BorderColor)
        }
        set {
            rawValue.BorderColor = newValue.tuple
        }
    }

    /// Lower end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed.
    @inlinable @inline(__always)
    public var minLOD: Float {
        get {
            return rawValue.MinLOD
        }
        set {
            rawValue.MinLOD = newValue
        }
    }

    /// Upper end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed. This value must be greater than or equal to MinLOD. To have no upper limit on LOD, set this member to a large value.
    @inlinable @inline(__always)
    public var maxLOD: Float {
        get {
            return rawValue.MaxLOD
        }
        set {
            rawValue.MaxLOD = newValue
        }
    }

    /** Describes a sampler state.
    - parameter filter: A D3D12_FILTER-typed value that specifies the filtering method to use when sampling a texture.
    - parameter addressU: A D3D12_TEXTURE_ADDRESS_MODE-typed value that specifies the method to use for resolving a u texture coordinate that is outside the 0 to 1 range.
    - parameter addressV: A D3D12_TEXTURE_ADDRESS_MODE-typed value that specifies the method to use for resolving a v texture coordinate that is outside the 0 to 1 range.
    - parameter addressW: A D3D12_TEXTURE_ADDRESS_MODE-typed value that specifies the method to use for resolving a w texture coordinate that is outside the 0 to 1 range.
    - parameter mipLODBias: Offset from the calculated mipmap level. For example, if the runtime calculates that a texture should be sampled at mipmap level 3 and MipLODBias is 2, the texture will be sampled at mipmap level 5.
    - parameter maxAnisotropy: Clamping value used if D3D12_FILTER_ANISOTROPIC or D3D12_FILTER_COMPARISON_ANISOTROPIC is specified in Filter. Valid values are between 1 and 16.
    - parameter comparisonFunction: A D3D12_COMPARISON_FUNC-typed value that specifies a function that compares sampled data against existing sampled data.
    - parameter borderColor: Border color to use if D3D12_TEXTURE_ADDRESS_MODE_BORDER is specified for AddressU, AddressV, or AddressW. Range must be between 0.0 and 1.0 inclusive.
    - parameter minLOD: Lower end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed.
    - parameter maxLOD: Upper end of the mipmap range to clamp access to, where 0 is the largest and most detailed mipmap level and any level higher than that is less detailed. This value must be greater than or equal to MinLOD. To have no upper limit on LOD, set this member to a large value.
    */
    @inlinable @inline(__always)
    public init(filter: D3DFilter,
                addressU: D3DTextureAddressMode,
                addressV: D3DTextureAddressMode,
                addressW: D3DTextureAddressMode,
                mipLODBias: Float = 0,
                maxAnisotropy: UInt32 = 0,
                comparisonFunction: D3DComparisonFunction = .alwaysSucceed,
                borderColor: D3DColor = .clear,
                minLOD: Float = 0,
                maxLOD: Float = 1000) {
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
    }

    @inlinable @inline(__always)
    internal init(_ rawValue:RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DSamplerDescription")
public typealias D3D12_SAMPLER_DESC = D3DSamplerDescription

#endif
