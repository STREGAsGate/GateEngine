/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies filtering options during texture sampling.
public struct D3DFilter: OptionSet {
    public typealias RawType = WinSDK.D3D12_FILTER
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_FILTER.RawValue
    public let rawValue: RawValue

    ///	Use point sampling for minification, magnification, and mip-level sampling.
    public static let minMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_MAG_MIP_POINT.rawValue)
    ///	Use point sampling for minification and magnification; use linear interpolation for mip-level sampling.
    public static let minMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Use point sampling for minification; use linear interpolation for magnification; use point sampling for mip-level sampling.
    public static let minPointMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_POINT_MAG_MIP_LINEAR.rawValue)
    ///	Use point sampling for minification; use linear interpolation for magnification and mip-level sampling.
    public static let minPointMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Use linear interpolation for minification; use point sampling for magnification and mip-level sampling.
    public static let minLinearMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_LINEAR_MAG_MIP_POINT.rawValue)
    ///	Use linear interpolation for minification; use point sampling for magnification; use linear interpolation for mip-level sampling.
    public static let minLinearMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Use linear interpolation for minification and magnification; use point sampling for mip-level sampling.
    public static let minMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Use linear interpolation for minification, magnification, and mip-level sampling.
    public static let minMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MIN_MAG_MIP_LINEAR.rawValue)
    ///	Use anisotropic interpolation for minification, magnification, and mip-level sampling.
    public static let anisotropic = D3DFilter(rawValue: WinSDK.D3D12_FILTER_ANISOTROPIC.rawValue)
    ///	Use point sampling for minification, magnification, and mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_MAG_MIP_POINT.rawValue)
    ///	Use point sampling for minification and magnification; use linear interpolation for mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Use point sampling for minification; use linear interpolation for magnification; use point sampling for mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinPointMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Use point sampling for minification; use linear interpolation for magnification and mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinPointMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_POINT_MAG_MIP_LINEAR.rawValue)
    ///	Use linear interpolation for minification; use point sampling for magnification and mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinLinearMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_LINEAR_MAG_MIP_POINT.rawValue)
    ///	Use linear interpolation for minification; use point sampling for magnification; use linear interpolation for mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinLinearMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Use linear interpolation for minification and magnification; use point sampling for mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Use linear interpolation for minification, magnification, and mip-level sampling. Compare the result to the comparison value.
    public static let comparisonMinMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR.rawValue)
    ///	Use anisotropic interpolation for minification, magnification, and mip-level sampling. Compare the result to the comparison value.
    public static let comparisonAnisotropic = D3DFilter(rawValue: WinSDK.D3D12_FILTER_COMPARISON_ANISOTROPIC.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_MIP_POINT and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_MAG_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_POINT_MIP_LINEAR and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinPointMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_POINT_MAG_MIP_LINEAR and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinPointMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_POINT_MAG_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_LINEAR_MAG_MIP_POINT and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinLinearMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_LINEAR_MAG_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinLinearMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_LINEAR_MIP_POINT and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_MIP_LINEAR and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumMinMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_MIN_MAG_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_ANISOTROPIC and instead of filtering them return the minimum of the texels. Texels that are weighted 0 during filtering aren't counted towards the minimum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let minimumAnisotropic = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MINIMUM_ANISOTROPIC.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_MIP_POINT and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_MAG_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_POINT_MIP_LINEAR and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinPointMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_POINT_MAG_MIP_LINEAR and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinPointMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_POINT_MAG_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_LINEAR_MAG_MIP_POINT and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinLinearMagMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_LINEAR_MAG_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinLinearMagPointMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_LINEAR_MIP_POINT and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinMagLinearMipPoint = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_MAG_LINEAR_MIP_POINT.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_MIN_MAG_MIP_LINEAR and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumMinMagMipLinear = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_MIN_MAG_MIP_LINEAR.rawValue)
    ///	Fetch the same set of texels as D3D12_FILTER_ANISOTROPIC and instead of filtering them return the maximum of the texels. Texels that are weighted 0 during filtering aren't counted towards the maximum. You can query support for this filter type from the MinMaxFiltering member in the D3D11_FEATURE_DATA_D3D11_OPTIONS1 structure.
    public static let maximumAnisotropic = D3DFilter(rawValue: WinSDK.D3D12_FILTER_MAXIMUM_ANISOTROPIC.rawValue)

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

@available(*, deprecated, renamed: "D3DFilter")
public typealias D3D12_FILTER  = D3DFilter


@available(*, deprecated, renamed: "D3DFilter.minMagMipPoint")
public let D3D12_FILTER_MIN_MAG_MIP_POINT = D3DFilter.minMagMipPoint

@available(*, deprecated, renamed: "D3DFilter.minMagPointMipLinear")
public let D3D12_FILTER_MIN_MAG_POINT_MIP_LINEAR = D3DFilter.minMagPointMipLinear

@available(*, deprecated, renamed: "D3DFilter.minPointMagMipLinear")
public let D3D12_FILTER_MIN_POINT_MAG_MIP_LINEAR = D3DFilter.minPointMagMipLinear

@available(*, deprecated, renamed: "D3DFilter.minPointMagLinearMipPoint")
public let D3D12_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT = D3DFilter.minPointMagLinearMipPoint

@available(*, deprecated, renamed: "D3DFilter.minLinearMagMipPoint")
public let D3D12_FILTER_MIN_LINEAR_MAG_MIP_POINT = D3DFilter.minLinearMagMipPoint

@available(*, deprecated, renamed: "D3DFilter.minLinearMagPointMipLinear")
public let D3D12_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR = D3DFilter.minLinearMagPointMipLinear

@available(*, deprecated, renamed: "D3DFilter.minMagLinearMipPoint")
public let D3D12_FILTER_MIN_MAG_LINEAR_MIP_POINT = D3DFilter.minMagLinearMipPoint

@available(*, deprecated, renamed: "D3DFilter.minMagMipLinear")
public let D3D12_FILTER_MIN_MAG_MIP_LINEAR = D3DFilter.minMagMipLinear

@available(*, deprecated, renamed: "D3DFilter.anisotropic")
public let D3D12_FILTER_ANISOTROPIC = D3DFilter.anisotropic

@available(*, deprecated, renamed: "D3DFilter.comparisonMinMagMipPoint")
public let D3D12_FILTER_COMPARISON_MIN_MAG_MIP_POINT = D3DFilter.comparisonMinMagMipPoint

@available(*, deprecated, renamed: "D3DFilter.comparisonMinMagPointMipLinear")
public let D3D12_FILTER_COMPARISON_MIN_MAG_POINT_MIP_LINEAR = D3DFilter.comparisonMinMagPointMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.comparisonMinPointMagLinearMipPoint")
public let D3D12_FILTER_COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = D3DFilter.comparisonMinPointMagLinearMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.comparisonMinPointMagMipLinear")
public let D3D12_FILTER_COMPARISON_MIN_POINT_MAG_MIP_LINEAR = D3DFilter.comparisonMinPointMagMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.comparisonMinLinearMagMipPoint")
public let D3D12_FILTER_COMPARISON_MIN_LINEAR_MAG_MIP_POINT = D3DFilter.comparisonMinLinearMagMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.comparisonMinLinearMagPointMipLinear")
public let D3D12_FILTER_COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = D3DFilter.comparisonMinLinearMagPointMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.comparisonMinMagLinearMipPoint")
public let D3D12_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT = D3DFilter.comparisonMinMagLinearMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.comparisonMinMagMipLinear")
public let D3D12_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR = D3DFilter.comparisonMinMagMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.comparisonAnisotropic")
public let D3D12_FILTER_COMPARISON_ANISOTROPIC = D3DFilter.comparisonAnisotropic
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinMagMipPoint")
public let D3D12_FILTER_MINIMUM_MIN_MAG_MIP_POINT = D3DFilter.minimumMinMagMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinMagPointMipLinear")
public let D3D12_FILTER_MINIMUM_MIN_MAG_POINT_MIP_LINEAR = D3DFilter.minimumMinMagPointMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinPointMagLinearMipPoint")
public let D3D12_FILTER_MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = D3DFilter.minimumMinPointMagLinearMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinPointMagMipLinear")
public let D3D12_FILTER_MINIMUM_MIN_POINT_MAG_MIP_LINEAR = D3DFilter.minimumMinPointMagMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinLinearMagMipPoint")
public let D3D12_FILTER_MINIMUM_MIN_LINEAR_MAG_MIP_POINT = D3DFilter.minimumMinLinearMagMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinLinearMagPointMipLinear")
public let D3D12_FILTER_MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = D3DFilter.minimumMinLinearMagPointMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinMagLinearMipPoint")
public let D3D12_FILTER_MINIMUM_MIN_MAG_LINEAR_MIP_POINT = D3DFilter.minimumMinMagLinearMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.minimumMinMagMipLinear")
public let D3D12_FILTER_MINIMUM_MIN_MAG_MIP_LINEAR = D3DFilter.minimumMinMagMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.minimumAnisotropic")
public let D3D12_FILTER_MINIMUM_ANISOTROPIC = D3DFilter.minimumAnisotropic
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinMagMipPoint")
public let D3D12_FILTER_MAXIMUM_MIN_MAG_MIP_POINT = D3DFilter.maximumMinMagMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinMagPointMipLinear")
public let D3D12_FILTER_MAXIMUM_MIN_MAG_POINT_MIP_LINEAR = D3DFilter.maximumMinMagPointMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinPointMagLinearMipPoint")
public let D3D12_FILTER_MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = D3DFilter.maximumMinPointMagLinearMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinPointMagMipLinear")
public let D3D12_FILTER_MAXIMUM_MIN_POINT_MAG_MIP_LINEAR = D3DFilter.maximumMinPointMagMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinLinearMagMipPoint")
public let D3D12_FILTER_MAXIMUM_MIN_LINEAR_MAG_MIP_POINT = D3DFilter.maximumMinLinearMagMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinLinearMagPointMipLinear")
public let D3D12_FILTER_MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = D3DFilter.maximumMinLinearMagPointMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinMagLinearMipPoint")
public let D3D12_FILTER_MAXIMUM_MIN_MAG_LINEAR_MIP_POINT = D3DFilter.maximumMinMagLinearMipPoint
    
@available(*, deprecated, renamed: "D3DFilter.maximumMinMagMipLinear")
public let D3D12_FILTER_MAXIMUM_MIN_MAG_MIP_LINEAR = D3DFilter.maximumMinMagMipLinear
    
@available(*, deprecated, renamed: "D3DFilter.maximumAnisotropic")
public let D3D12_FILTER_MAXIMUM_ANISOTROPIC = D3DFilter.maximumAnisotropic

#endif
