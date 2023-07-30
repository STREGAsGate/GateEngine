/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the type of a command list.
public enum D3DCommandListType {
    ///	Specifies a command buffer that the GPU can execute. A direct command list doesn't inherit any GPU state.
    case direct
    ///	Specifies a command buffer that can be executed only directly via a direct command list. A bundle command list inherits all GPU state (except for the currently set pipeline state object and primitive topology).
    case bundle
    ///	Specifies a command buffer for computing.
    case compute
    ///	Specifies a command buffer for copying.
    case copy
    ///	Specifies a command buffer for video decoding.
    case videoDecode
    ///	Specifies a command buffer for video processing.
    case videoProcess
    ///	Specifies a command buffer for video encoding.
    case videoEncode

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)
}

extension D3DCommandListType: RawRepresentable {
    public typealias RawValue = WinSDK.D3D12_COMMAND_LIST_TYPE
    
    @inlinable @inline(__always)
    public var rawValue: WinSDK.D3D12_COMMAND_LIST_TYPE {
        switch self {
        case .direct:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_DIRECT
        case .bundle:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_BUNDLE
        case .compute:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_COMPUTE
        case .copy:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_COPY
        case .videoDecode:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_VIDEO_DECODE
        case .videoProcess:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_VIDEO_PROCESS
        case .videoEncode:
            return WinSDK.D3D12_COMMAND_LIST_TYPE_VIDEO_ENCODE
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }
    
    @inlinable @inline(__always)
    public init(rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_COMMAND_LIST_TYPE_DIRECT:
            self = .direct
        case WinSDK.D3D12_COMMAND_LIST_TYPE_BUNDLE:
            self = .bundle
        case WinSDK.D3D12_COMMAND_LIST_TYPE_COMPUTE:
            self = .compute
        case WinSDK.D3D12_COMMAND_LIST_TYPE_COPY:
            self = .copy
        case WinSDK.D3D12_COMMAND_LIST_TYPE_VIDEO_DECODE:
            self = .videoDecode
        case WinSDK.D3D12_COMMAND_LIST_TYPE_VIDEO_PROCESS:
            self = .videoProcess
        case WinSDK.D3D12_COMMAND_LIST_TYPE_VIDEO_ENCODE:
            self = .videoEncode
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DCommandListType")
public typealias D3D12_COMMAND_LIST_TYPE = D3DCommandListType


@available(*, deprecated, renamed: "D3DCommandListType.direct")
public let D3D12_COMMAND_LIST_TYPE_DIRECT = D3DCommandListType.direct

@available(*, deprecated, renamed: "D3DCommandListType.bundle")
public let D3D12_COMMAND_LIST_TYPE_BUNDLE = D3DCommandListType.bundle

@available(*, deprecated, renamed: "D3DCommandListType.compute")
public let D3D12_COMMAND_LIST_TYPE_COMPUTE = D3DCommandListType.compute

@available(*, deprecated, renamed: "D3DCommandListType.copy")
public let D3D12_COMMAND_LIST_TYPE_COPY = D3DCommandListType.copy

@available(*, deprecated, renamed: "D3DCommandListType.videoDecode")
public let D3D12_COMMAND_LIST_TYPE_VIDEO_DECODE = D3DCommandListType.videoDecode

@available(*, deprecated, renamed: "D3DCommandListType.videoProcess")
public let D3D12_COMMAND_LIST_TYPE_VIDEO_PROCESS = D3DCommandListType.videoProcess

@available(*, deprecated, renamed: "D3DCommandListType.videoEncode")
public let D3D12_COMMAND_LIST_TYPE_VIDEO_ENCODE = D3DCommandListType.videoEncode

#endif
