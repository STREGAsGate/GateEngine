/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Identifies the type of data contained in an input slot.
public enum D3DInputClassification {
    public typealias RawValue = WinSDK.D3D12_INPUT_CLASSIFICATION
    
    ///	Input data is per-vertex data.
    case perVertexData
    ///	Input data is per-instance data.
    case perInstanceData

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    public var rawValue: RawValue {
        switch self {
        case .perVertexData:
            return WinSDK.D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA
        case .perInstanceData:
            return WinSDK.D3D12_INPUT_CLASSIFICATION_PER_INSTANCE_DATA
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA:
            self = .perVertexData
        case WinSDK.D3D12_INPUT_CLASSIFICATION_PER_INSTANCE_DATA:
            self = .perInstanceData
        default:
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DInputClassification")
public typealias D3D12_INPUT_CLASSIFICATION = D3DInputClassification


@available(*, deprecated, renamed: "D3DInputClassification.perVertexData")
public let D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA = D3DInputClassification.perVertexData

@available(*, deprecated, renamed: "D3DInputClassification.perInstanceData")
public let D3D12_INPUT_CLASSIFICATION_PER_INSTANCE_DATA = D3DInputClassification.perInstanceData

#endif
