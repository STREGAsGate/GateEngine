/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies unordered-access view options for a buffer resource.
public struct D3DCommandQueueFlags: OptionSet {
    public typealias RawType = WinSDK.D3D12_COMMAND_QUEUE_FLAGS
    public typealias RawValue = WinSDK.D3D12_COMMAND_QUEUE_FLAGS.RawValue
    public let rawValue: RawValue

    //Use an empty collection `[]` to represent none in Swift.
    ///// Indicates a default command queue.
    //public static let none = CommandQueueFlags(rawValue: D3D12_COMMAND_QUEUE_FLAG_NONE.rawValue)

    /// Indicates that the GPU timeout should be disabled for this command queue.
    public static let disableGPUTimeout = D3DCommandQueueFlags(rawValue: WinSDK.D3D12_COMMAND_QUEUE_FLAG_DISABLE_GPU_TIMEOUT.rawValue)

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    public init() {
        self.rawValue = 0
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCommandQueueFlags")
public typealias D3D12_COMMAND_QUEUE_FLAGS = D3DCommandQueueFlags


@available(*, deprecated, message: "Use [] to represent none in Swift.")
public let D3D12_COMMAND_QUEUE_FLAG_NONE: D3DCommandQueueFlags = []

@available(*, deprecated, renamed: "D3DCommandQueueFlags.disableGPUTimeout")
public let D3D12_COMMAND_QUEUE_FLAG_DISABLE_GPU_TIMEOUT = D3DCommandQueueFlags.disableGPUTimeout

#endif
