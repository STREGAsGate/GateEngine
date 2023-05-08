/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// A shader resource view (SRV) structure for storing a raytracing acceleration structure.
public struct D3DRaytracingAccelerationStructureShaderResourceView {
    public typealias RawValue = WinSDK.D3D12_RAYTRACING_ACCELERATION_STRUCTURE_SRV
    internal var rawValue: RawValue

    /// The GPU virtual address of the SRV.
    public var location: UInt64 {
        get {
            return rawValue.Location
        }
        set {
            rawValue.Location = newValue
        }
    }

    /** A shader resource view (SRV) structure for storing a raytracing acceleration structure.
    - parameter location: The GPU virtual address of the SRV.
    */
    public init(location: UInt64) {
        self.rawValue = RawValue(Location: location)
    }

    internal init(_ rawValue: RawValue) {
        self.rawValue = rawValue
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRaytracingAccelerationStructureShaderResourceView")
public typealias D3D12_RAYTRACING_ACCELERATION_STRUCTURE_SRV = D3DRaytracingAccelerationStructureShaderResourceView

#endif
