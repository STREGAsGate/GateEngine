/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Flags for surface and resource creation options.
public struct DGIUsage: OptionSet {
    public typealias RawValue = WinSDK.DXGI_USAGE
    public let rawValue: RawValue

    // public static let cpuAccessNone = DGIUsage(rawValue: DXGI_CPU_ACCESS_NONE)
    // public static let cpuAccessDynamic = DGIUsage(rawValue: DXGI_CPU_ACCESS_DYNAMIC)
    // public static let cpuAccessReadWrite = DGIUsage(rawValue: DXGI_CPU_ACCESS_READ_WRITE)
    // public static let cpuAccessScratch = DGIUsage(rawValue: DXGI_CPU_ACCESS_SCRATCH)
    // public static let cpuAccessField = DGIUsage(rawValue: DXGI_CPU_ACCESS_FIELD)
    public static let shaderInput = DGIUsage(rawValue: DXGI_USAGE_SHADER_INPUT)
    public static let renderTargetOutput = DGIUsage(rawValue: DXGI_USAGE_RENDER_TARGET_OUTPUT)
    public static let backBuffer = DGIUsage(rawValue: DXGI_USAGE_BACK_BUFFER)
    public static let shared = DGIUsage(rawValue: DXGI_USAGE_SHARED)
    public static let readOnly = DGIUsage(rawValue: DXGI_USAGE_READ_ONLY)
    public static let discardOnPresent = DGIUsage(rawValue: DXGI_USAGE_DISCARD_ON_PRESENT)
    public static let unorderedAccess = DGIUsage(rawValue: DXGI_USAGE_UNORDERED_ACCESS)

    @inlinable @inline(__always)
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    @inlinable @inline(__always)
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "DGIUsage")
public typealias DXGI_USAGE = DGIUsage

#endif
