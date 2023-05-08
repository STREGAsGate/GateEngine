/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public typealias D3DRange = ClosedRange<WinSDK.SIZE_T>
internal extension D3DRange {
    typealias RawValue = WinSDK.D3D12_RANGE
    var rawValue: RawValue {
        return RawValue(Begin: lowerBound, End: upperBound)
    }

    init(_ rawValue: RawValue) {
        self = rawValue.Begin ... rawValue.End
    }
}


//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRange")
public typealias D3D12_RANGE = D3DRange

#endif
