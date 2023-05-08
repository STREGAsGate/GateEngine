/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies the predication operation to apply.
public enum D3DPredictionOperation {
    public typealias RawValue = WinSDK.D3D12_PREDICATION_OP
    ///	Enables predication if all 64-bits are zero.
    case equalZero
    ///	Enables predication if at least one of the 64-bits are not zero.
    case notEqualZero

    public var rawValue: RawValue {
        switch self {
        case .equalZero:
            return WinSDK.D3D12_PREDICATION_OP_EQUAL_ZERO
        case .notEqualZero:
            return WinSDK.D3D12_PREDICATION_OP_NOT_EQUAL_ZERO
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DPredictionOperation")
public typealias D3D12_PREDICATION_OP = D3DPredictionOperation


@available(*, deprecated, renamed: "D3DPredictionOperation.equalZero")
public let D3D12_PREDICATION_OP_EQUAL_ZERO = D3DPredictionOperation.equalZero

@available(*, deprecated, renamed: "D3DPredictionOperation.notEqualZero")
public let D3D12_PREDICATION_OP_NOT_EQUAL_ZERO = D3DPredictionOperation.notEqualZero

#endif
