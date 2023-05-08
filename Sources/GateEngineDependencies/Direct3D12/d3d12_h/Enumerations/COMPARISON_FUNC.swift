/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Specifies comparison options.
public enum D3DComparisonFunction {
    public typealias RawValue = WinSDK.D3D12_COMPARISON_FUNC
    ///	Never pass the comparison.
    case neverSucceed
    ///	If the source data is less than the destination data, the comparison passes.
    case lessThan
    ///	If the source data is equal to the destination data, the comparison passes.
    case equalTo
    ///	If the source data is less than or equal to the destination data, the comparison passes.
    case lessThanOrEqualTo
    ///	If the source data is greater than the destination data, the comparison passes.
    case greaterThan
    ///	If the source data is not equal to the destination data, the comparison passes.
    case notEqualTo
    ///	If the source data is greater than or equal to the destination data, the comparison passes.
    case greaterThanOrEqualTo
    ///	Always pass the comparison.
    case alwaysSucceed

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    public var rawValue: RawValue {
        switch self {
        case .neverSucceed:
            return WinSDK.D3D12_COMPARISON_FUNC_NEVER
        case .lessThan:
            return WinSDK.D3D12_COMPARISON_FUNC_LESS
        case .equalTo:
            return WinSDK.D3D12_COMPARISON_FUNC_EQUAL
        case .lessThanOrEqualTo:
            return WinSDK.D3D12_COMPARISON_FUNC_LESS_EQUAL
        case .greaterThan:
            return WinSDK.D3D12_COMPARISON_FUNC_GREATER
        case .notEqualTo:
            return WinSDK.D3D12_COMPARISON_FUNC_NOT_EQUAL
        case .greaterThanOrEqualTo:
            return WinSDK.D3D12_COMPARISON_FUNC_GREATER_EQUAL
        case .alwaysSucceed:
            return WinSDK.D3D12_COMPARISON_FUNC_ALWAYS
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_COMPARISON_FUNC_NEVER:
            self = .neverSucceed
        case WinSDK.D3D12_COMPARISON_FUNC_LESS:
            self = .lessThan
        case WinSDK.D3D12_COMPARISON_FUNC_EQUAL:
            self = .equalTo
        case WinSDK.D3D12_COMPARISON_FUNC_LESS_EQUAL:
            self = .lessThanOrEqualTo
        case WinSDK.D3D12_COMPARISON_FUNC_GREATER:
            self = .greaterThan
        case WinSDK.D3D12_COMPARISON_FUNC_NOT_EQUAL:
            self = .notEqualTo
        case WinSDK.D3D12_COMPARISON_FUNC_GREATER_EQUAL:
            self = .greaterThanOrEqualTo
        case WinSDK.D3D12_COMPARISON_FUNC_ALWAYS:
            self = .alwaysSucceed
        default:
            self = ._unimplemented(rawValue)
        }
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DComparisonFunction")
public typealias D3D12_COMPARISON_FUNC = D3DComparisonFunction


@available(*, deprecated, renamed: "D3DComparisonFunction.neverSucceed")
public let D3D12_COMPARISON_FUNC_NEVER = D3DComparisonFunction.neverSucceed

@available(*, deprecated, renamed: "D3DComparisonFunction.lessThan")
public let D3D12_COMPARISON_FUNC_LESS = D3DComparisonFunction.lessThan

@available(*, deprecated, renamed: "D3DComparisonFunction.equalTo")
public let D3D12_COMPARISON_FUNC_EQUAL = D3DComparisonFunction.equalTo

@available(*, deprecated, renamed: "D3DComparisonFunction.lessThanOrEqualTo")
public let D3D12_COMPARISON_FUNC_LESS_EQUAL = D3DComparisonFunction.lessThanOrEqualTo

@available(*, deprecated, renamed: "D3DComparisonFunction.greaterThan")
public let D3D12_COMPARISON_FUNC_GREATER = D3DComparisonFunction.greaterThan

@available(*, deprecated, renamed: "D3DComparisonFunction.notEqualTo")
public let D3D12_COMPARISON_FUNC_NOT_EQUAL = D3DComparisonFunction.notEqualTo

@available(*, deprecated, renamed: "D3DComparisonFunction.greaterThanOrEqualTo")
public let D3D12_COMPARISON_FUNC_GREATER_EQUAL = D3DComparisonFunction.greaterThanOrEqualTo

@available(*, deprecated, renamed: "D3DComparisonFunction.alwaysSucceed")
public let D3D12_COMPARISON_FUNC_ALWAYS = D3DComparisonFunction.alwaysSucceed

#endif
