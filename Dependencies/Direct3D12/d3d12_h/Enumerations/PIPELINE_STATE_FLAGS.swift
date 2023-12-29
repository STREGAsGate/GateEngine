/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Flags to control pipeline state.
public struct D3DPipelineStateFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_PIPELINE_STATE_FLAGS
    public var rawType: RawType {RawType(rawValue)}
    public typealias RawValue = WinSDK.D3D12_PIPELINE_STATE_FLAGS.RawValue
    public let rawValue: RawValue

    //Use an empty collection `[]` to represent none in Swift.
    ///// Indicates no flags.
    //public static let none = PipelineStateFlags(rawValue: WinSDK.D3D12_PIPELINE_STATE_FLAG_NONE.rawValue)

    /// Indicates that the pipeline state should be compiled with additional information to assist debugging.
    /// This can only be set on WARP devices.
    public static let toolDebug = D3DPipelineStateFlags(rawValue: WinSDK.D3D12_PIPELINE_STATE_FLAG_TOOL_DEBUG.rawValue)

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

@available(*, deprecated, renamed: "D3DPipelineStateFlags")
public typealias D3D12_PIPELINE_STATE_FLAGS = D3DPipelineStateFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_PIPELINE_STATE_FLAG_NONE: D3DPipelineStateFlags = []

@available(*, deprecated, renamed: "D3DPipelineStateFlags.toolDebug")
public let D3D12_PIPELINE_STATE_FLAG_TOOL_DEBUG = D3DPipelineStateFlags.toolDebug

#endif
