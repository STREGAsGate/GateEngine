/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public enum D3DMessageSeverity {
    public typealias RawValue = WinSDK.D3D12_MESSAGE_SEVERITY

    case corruption
    case error
    case warning
    case info
    case message
    case unknown(RawValue)

    @inlinable @inline(__always)
    var rawValue: RawValue {
        switch self {
        case .corruption:
            return WinSDK.D3D12_MESSAGE_SEVERITY_CORRUPTION
        case .error:
            return WinSDK.D3D12_MESSAGE_SEVERITY_ERROR
        case .warning:
            return WinSDK.D3D12_MESSAGE_SEVERITY_WARNING
        case .info:
            return WinSDK.D3D12_MESSAGE_SEVERITY_INFO
        case .message:
            return WinSDK.D3D12_MESSAGE_SEVERITY_MESSAGE
        case .unknown(let rawValue):
            return rawValue
        }
    }

    @inlinable @inline(__always)
    init(rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_MESSAGE_SEVERITY_CORRUPTION:
            self = .corruption 
        case WinSDK.D3D12_MESSAGE_SEVERITY_ERROR:
            self = .error 
        case WinSDK.D3D12_MESSAGE_SEVERITY_WARNING:
            self = .warning 
        case WinSDK.D3D12_MESSAGE_SEVERITY_INFO:
            self = .info 
        case WinSDK.D3D12_MESSAGE_SEVERITY_MESSAGE:
            self = .message
        default:
            self = .unknown(rawValue)
        }
    }
}
