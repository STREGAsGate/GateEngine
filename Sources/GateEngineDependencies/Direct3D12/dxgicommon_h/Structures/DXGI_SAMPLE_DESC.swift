/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Describes multi-sampling parameters for a resource.
public struct DGISampleDescription {
    public typealias RawValue = WinSDK.DXGI_SAMPLE_DESC
    internal var rawValue: RawValue

    /// The number of multisamples per pixel.
    @inlinable @inline(__always)
    public var count: UInt32 {
        get {
            return rawValue.Count
        }
        set {
            rawValue.Count = newValue
        }
    }

    /// The image quality level. The higher the quality, the lower the performance. The valid range is between zero and one less than the level returned by ID3D10Device::CheckMultisampleQualityLevels for Direct3D 10 or ID3D11Device::CheckMultisampleQualityLevels for Direct3D 11.
    /// For Direct3D 10.1 and Direct3D 11, you can use two special quality level values. For more information about these quality level values, see Remarks.
    @inlinable @inline(__always)
    public var quality: UInt32 {
        get {
            return rawValue.Quality
        }
        set {
            rawValue.Quality = newValue
        }
    }

    /** Describes multi-sampling parameters for a resource.
    - parameter count: The number of multisamples per pixel.
    - parameter quality: The image quality level. The higher the quality, the lower the performance. The valid range is between zero and one less than the level returned by ID3D10Device::CheckMultisampleQualityLevels for Direct3D 10 or ID3D11Device::CheckMultisampleQualityLevels for Direct3D 11.
    */
    @inlinable @inline(__always)
    public init(count: UInt32, quality: UInt32) {
        self.rawValue = RawValue(Count: count, Quality: quality)
    }

    @inlinable @inline(__always)
    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGISampleDescription")
public typealias DXGI_SAMPLE_DESC = DGISampleDescription

#endif
