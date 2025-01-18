/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public extension DGISwapChain {
    
    /** Presents a frame on the display screen.
    - parameter syncInterval: An integer that specifies how to synchronize presentation of a frame with the vertical blank.
    - parameter flags: An integer value that contains swap-chain presentation options. These options are defined by the DXGI_PRESENT constants.
    - parameter parameters: A pointer to a DXGI_PRESENT_PARAMETERS structure that describes updated rectangles and scroll information of the frame to present.
    */
    @inlinable @inline(__always)
    func present(withSyncInterval syncInterval: UInt32 = 1,
                 flags: DGIPresentFlags = [],
                 parameters: DGIPresentParameters = .fullFrame) throws {
        try perform(as: RawValue.self) {pThis in 
            let SyncInterval = syncInterval
            let PresentFlags = flags.rawValue
            var pPresentParameters = parameters.rawValue
            try pThis.pointee.lpVtbl.pointee.Present1(pThis, SyncInterval, PresentFlags, &pPresentParameters).checkResult(self, #function)
        }
    }
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "DGISwapChain")
public typealias IDXGISwapChain1 = DGISwapChain

public extension DGISwapChain {
    @available(*, unavailable, renamed: "present(withSyncInterval:flags:parameters:)")
    func Present1(_ SyncInterval: Any,
                  _ PresentFlags: Any,
                  _ pPresentParameters: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
