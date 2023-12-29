/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the type of query.
public enum D3DQueryType {
    public typealias RawValue = WinSDK.D3D12_QUERY_TYPE
    ///	Indicates the query is for depth/stencil occlusion counts.
    case occlusion
    ///	Indicates the query is for a binary depth/stencil occlusion statistics.
    /// 
    /// This new query type acts like D3D12_QUERY_TYPE_OCCLUSION except that it returns simply a binary 0/1 result: 0 indicates that no samples passed depth and stencil testing, 1 indicates that at least one sample passed depth and stencil testing. This enables occlusion queries to not interfere with any GPU performance optimization associated with depth/stencil testing.
    case binaryOcclusion
    ///	Indicates the query is for high definition GPU and CPU timestamps.
    case timestamp
    ///	Indicates the query type is for graphics pipeline statistics, refer to D3D12_QUERY_DATA_PIPELINE_STATISTICS.
    case pipelineStatistics
    ///	Stream 0 output statistics. In Direct3D 12 there is no single stream output (SO) overflow query for all the output streams. Apps need to issue multiple single-stream queries, and then correlate the results. Stream output is the ability of the GPU to write vertices to a buffer. The stream output counters monitor progress.
    case streamOutput0Statistics
    ///	Stream 1 output statistics.
    case streamOutput1Statistics
    ///	Stream 2 output statistics.
    case streamOutput2Statistics
    ///	Stream 3 output statistics.
    case streamOutput3Statistics
    /**
    Video decode statistics. Refer to D3D12_QUERY_DATA_VIDEO_DECODE_STATISTICS.

    Use this query type to determine if a video was successfully decoded. If decoding fails due to insufficient BitRate or FrameRate parameters set during creation of the decode heap, then the status field of the query is set to D3D12_VIDEO_DECODE_STATUS_RATE_EXCEEDED and the query also contains new BitRate and FrameRate values that would succeed.

    This query type can only be performed on video decode command lists (D3D12_COMMAND_LIST_TYPE_VIDEO_DECODE). This query type does not use ID3D12VideoDecodeCommandList::BeginQuery, only ID3D12VideoDecodeCommandList::EndQuery. Statistics are recorded only for the most recent ID3D12VideoDecodeCommandList::DecodeFrame call in the same command list.

    Decode status structures are defined by the codec specification.
    */
    case videoDecodeStatistics

    @inlinable @inline(__always)
    public var rawValue: RawValue {
        switch self {
        case .occlusion:
            return WinSDK.D3D12_QUERY_TYPE_OCCLUSION
        case .binaryOcclusion:
            return WinSDK.D3D12_QUERY_TYPE_BINARY_OCCLUSION
        case .timestamp:
            return WinSDK.D3D12_QUERY_TYPE_TIMESTAMP
        case .pipelineStatistics:
            return WinSDK.D3D12_QUERY_TYPE_PIPELINE_STATISTICS
        case .streamOutput0Statistics:
            return WinSDK.D3D12_QUERY_TYPE_SO_STATISTICS_STREAM0
        case .streamOutput1Statistics:
            return WinSDK.D3D12_QUERY_TYPE_SO_STATISTICS_STREAM1
        case .streamOutput2Statistics:
            return WinSDK.D3D12_QUERY_TYPE_SO_STATISTICS_STREAM2
        case .streamOutput3Statistics:
            return WinSDK.D3D12_QUERY_TYPE_SO_STATISTICS_STREAM3
        case .videoDecodeStatistics:
            return WinSDK.D3D12_QUERY_TYPE_VIDEO_DECODE_STATISTICS
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DQueryType")
public typealias D3D12_QUERY_TYPE = D3DQueryType


@available(*, deprecated, renamed: "D3DQueryType.occlusion")
public let D3D12_QUERY_TYPE_OCCLUSION = D3DQueryType.occlusion

@available(*, deprecated, renamed: "D3DQueryType.binaryOcclusion")
public let D3D12_QUERY_TYPE_BINARY_OCCLUSION = D3DQueryType.binaryOcclusion

@available(*, deprecated, renamed: "D3DQueryType.timestamp")
public let D3D12_QUERY_TYPE_TIMESTAMP = D3DQueryType.timestamp

@available(*, deprecated, renamed: "D3DQueryType.pipelineStatistics")
public let D3D12_QUERY_TYPE_PIPELINE_STATISTICS = D3DQueryType.pipelineStatistics

@available(*, deprecated, renamed: "D3DQueryType.streamOutput0Statistics")
public let D3D12_QUERY_TYPE_SO_STATISTICS_STREAM0 = D3DQueryType.streamOutput0Statistics

@available(*, deprecated, renamed: "D3DQueryType.streamOutput1Statistics")
public let D3D12_QUERY_TYPE_SO_STATISTICS_STREAM1 = D3DQueryType.streamOutput1Statistics

@available(*, deprecated, renamed: "D3DQueryType.streamOutput2Statistics")
public let D3D12_QUERY_TYPE_SO_STATISTICS_STREAM2 = D3DQueryType.streamOutput2Statistics

@available(*, deprecated, renamed: "D3DQueryType.streamOutput3Statistics")
public let D3D12_QUERY_TYPE_SO_STATISTICS_STREAM3 = D3DQueryType.streamOutput3Statistics

@available(*, deprecated, renamed: "D3DQueryType.videoDecodeStatistics")
public let D3D12_QUERY_TYPE_VIDEO_DECODE_STATISTICS = D3DQueryType.videoDecodeStatistics


#endif
