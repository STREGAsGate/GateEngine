/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the type of query heap to create.
public enum D3DQueryHeapType {
    public typealias RawValue = WinSDK.D3D12_QUERY_HEAP_TYPE

    ///	This returns a binary 0/1 result: 0 indicates that no samples passed depth and stencil testing, 1 indicates that at least one sample passed depth and stencil testing. This enables occlusion queries to not interfere with any GPU performance optimization associated with depth/stencil testing.
    case occlusion
    ///	Indicates that the heap is for high-performance timing data.
    case timestamp
    ///	Indicates the heap is to contain pipeline data. Refer to D3D12_QUERY_DATA_PIPELINE_STATISTICS.
    case pipelineStatistics
    ///	Indicates the heap is to contain stream output data. Refer to D3D12_QUERY_DATA_SO_STATISTICS.
    case streamOutputStatistics
    /**
    Indicates the heap is to contain video decode statistics data. Refer to D3D12_QUERY_DATA_VIDEO_DECODE_STATISTICS.

    Video decode statistics can only be queried from video decode command lists (D3D12_COMMAND_LIST_TYPE_VIDEO_DECODE). See D3D12_QUERY_TYPE_DECODE_STATISTICS for more details.
    */
    case videoDecodeStatistics
    /**	
    Indicates the heap is to contain timestamp queries emitted exclusively by copy command lists. Copy queue timestamps can only be queried from a copy command list, and a copy command list can not emit to a regular timestamp query Heap.

    Support for this query heap type is not universal. You must use CheckFeatureSupport with D3D12_FEATUREWinSDK_OPTIONS3 to determine whether the adapter supports copy queue timestamp queries.
    */
    case copyQueueTimestamps

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    @inlinable
    public var rawValue: RawValue {
        switch self {
        case .occlusion:
            return WinSDK.D3D12_QUERY_HEAP_TYPE_OCCLUSION
        case .timestamp:
            return WinSDK.D3D12_QUERY_HEAP_TYPE_TIMESTAMP
        case .pipelineStatistics:
            return WinSDK.D3D12_QUERY_HEAP_TYPE_PIPELINE_STATISTICS
        case .streamOutputStatistics:
            return WinSDK.D3D12_QUERY_HEAP_TYPE_SO_STATISTICS
        case .videoDecodeStatistics:
            return WinSDK.D3D12_QUERY_HEAP_TYPE_VIDEO_DECODE_STATISTICS
        case .copyQueueTimestamps:
            return WinSDK.D3D12_QUERY_HEAP_TYPE_COPY_QUEUE_TIMESTAMP
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    @inlinable
    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_QUERY_HEAP_TYPE_OCCLUSION:
            self = .occlusion
        case WinSDK.D3D12_QUERY_HEAP_TYPE_TIMESTAMP:
            self = .timestamp
        case WinSDK.D3D12_QUERY_HEAP_TYPE_PIPELINE_STATISTICS:
            self = .pipelineStatistics
        case WinSDK.D3D12_QUERY_HEAP_TYPE_SO_STATISTICS:
            self = .streamOutputStatistics
        case WinSDK.D3D12_QUERY_HEAP_TYPE_VIDEO_DECODE_STATISTICS:
            self = .videoDecodeStatistics
        case WinSDK.D3D12_QUERY_HEAP_TYPE_COPY_QUEUE_TIMESTAMP:
            self = .copyQueueTimestamps
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DQueryHeapType")
public typealias D3D12_QUERY_HEAP_TYPE = D3DQueryHeapType


@available(*, deprecated, renamed: "D3DQueryHeapType.occlusion")
public let D3D12_QUERY_HEAP_TYPE_OCCLUSION = D3DQueryHeapType.occlusion

@available(*, deprecated, renamed: "D3DQueryHeapType.timestamp")
public let D3D12_QUERY_HEAP_TYPE_TIMESTAMP = D3DQueryHeapType.timestamp

@available(*, deprecated, renamed: "D3DQueryHeapType.pipelineStatistics")
public let D3D12_QUERY_HEAP_TYPE_PIPELINE_STATISTICS = D3DQueryHeapType.pipelineStatistics

@available(*, deprecated, renamed: "D3DQueryHeapType.streamOutputStatistics")
public let D3D12_QUERY_HEAP_TYPE_SO_STATISTICS = D3DQueryHeapType.streamOutputStatistics

@available(*, deprecated, renamed: "D3DQueryHeapType.videoDecodeStatistics")
public let D3D12_QUERY_HEAP_TYPE_VIDEO_DECODE_STATISTICS = D3DQueryHeapType.videoDecodeStatistics

@available(*, deprecated, renamed: "D3DQueryHeapType.copyQueueTimestamps")
public let D3D12_QUERY_HEAP_TYPE_COPY_QUEUE_TIMESTAMP = D3DQueryHeapType.copyQueueTimestamps

#endif
