/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// When using triangle strip primitive topology, vertex positions are interpreted as vertices of a continuous triangle “strip”. There is a special index value that represents the desire to have a discontinuity in the strip, the cut index value. This enum lists the supported cut values.
public enum D3DIndexBufferStripCutValue {
    public typealias RawValue = WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE

    ///	Indicates that there is no cut value.
    case disabled
    ///	Indicates that 0xFFFF should be used as the cut value.
    case use0xFFFF
    ///	Indicates that 0xFFFFFFFF should be used as the cut value.
    case use0xFFFFFFFF

    /// This Swift Package had no implementation, this can happen if the Base API is expanded.
    case _unimplemented(RawValue)

    public var rawValue: RawValue {
        switch self {
        case .disabled:
            return WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_DISABLED
        case .use0xFFFF:
            return WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFF
        case .use0xFFFFFFFF:
            return WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFFFFFF
        case let ._unimplemented(rawValue):
            return rawValue
        }
    }

    public init(_ rawValue: RawValue) {
        switch rawValue {
        case WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_DISABLED:
            self = .disabled
        case WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFF:
            self = .use0xFFFF
        case WinSDK.D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFFFFFF:
            self = .use0xFFFFFFFF
        default: 
            self = ._unimplemented(rawValue)
        }
    }
}
  

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DIndexBufferStripCutValue")
public typealias D3D12_INDEX_BUFFER_STRIP_CUT_VALUE = D3DIndexBufferStripCutValue


@available(*, deprecated, renamed: "D3DIndexBufferStripCutValue.disabled")
public let D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_DISABLED = D3DIndexBufferStripCutValue.disabled

@available(*, deprecated, renamed: "D3DIndexBufferStripCutValue.use0xFFFF")
public let D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFF = D3DIndexBufferStripCutValue.use0xFFFF

@available(*, deprecated, renamed: "D3DIndexBufferStripCutValue.use0xFFFFFFFF")
public let D3D12_INDEX_BUFFER_STRIP_CUT_VALUE_0xFFFFFFFF = D3DIndexBufferStripCutValue.use0xFFFFFFFF

#endif
