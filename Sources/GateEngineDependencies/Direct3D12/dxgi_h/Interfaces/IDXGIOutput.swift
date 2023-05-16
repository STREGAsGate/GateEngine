/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public final class DGIOutput: DGIObject {
    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension DGIOutput {
    @usableFromInline
    typealias RawValue = WinSDK.IDXGIOutput
}
extension DGIOutput.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_IDXGIOutput}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "DGIOutput")
public typealias IDXGIOutput = DGIOutput

#endif
