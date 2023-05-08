/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Defines priority levels for a command queue.
public enum D3DCommandQueuePriority {
    public typealias RawValue = WinSDK.D3D12_COMMAND_QUEUE_PRIORITY
    
    ///	Normal priority.
    case normal
    ///	High priority.
    case high
    ///	Global realtime priority.
    case globalRealtime

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    public var rawValue: WinSDK.D3D12_COMMAND_QUEUE_PRIORITY {
        switch self {
        case .normal:
            return WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_NORMAL
        case .high:
            return WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_HIGH
        case .globalRealtime:
            return WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_GLOBAL_REALTIME
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    public init(rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_NORMAL:
            self = .normal
        case WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_HIGH:
            self = .high
        case WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_GLOBAL_REALTIME:
            self = .globalRealtime
        default:
            self = ._unimplemented(rawValue)
        }
    }

    public init(rawValue: Int32) {
        switch rawValue {
        case WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_NORMAL.rawValue:
            self = .normal
        case WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_HIGH.rawValue:
            self = .high
        case WinSDK.D3D12_COMMAND_QUEUE_PRIORITY_GLOBAL_REALTIME.rawValue:
            self = .globalRealtime
        default:
            self = ._unimplemented(WinSDK.D3D12_COMMAND_QUEUE_PRIORITY(rawValue: rawValue))
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCommandQueuePriority")
public typealias D3D12_COMMAND_QUEUE_PRIORITY = D3DCommandQueuePriority


@available(*, deprecated, renamed: "D3DCommandQueuePriority.normal")
public let D3D12_COMMAND_QUEUE_PRIORITY_NORMAL = D3DCommandQueuePriority.normal

@available(*, deprecated, renamed: "D3DCommandQueuePriority.high")
public let D3D12_COMMAND_QUEUE_PRIORITY_HIGH = D3DCommandQueuePriority.high

@available(*, deprecated, renamed: "D3DCommandQueuePriority.globalRealtime")
public let D3D12_COMMAND_QUEUE_PRIORITY_GLOBAL_REALTIME = D3DCommandQueuePriority.globalRealtime

#endif
