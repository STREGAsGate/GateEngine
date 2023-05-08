/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// Represents the state of all currently set shaders as well as certain fixed function state objects.
public class D3DPipelineState: D3DPageable {
    
    /// Gets the cached blob representing the pipeline state.
    public func cachedBlob() throws -> D3DBlob {
        return try perform(as: RawValue.self) {pThis in
            var ppBlob: UnsafeMutablePointer<D3DBlob.RawValue>?
            try pThis.pointee.lpVtbl.pointee.GetCachedBlob(pThis, &ppBlob).checkResult(self, #function)
            guard let v = D3DBlob(winSDKPointer: ppBlob) else {throw Error(.invalidArgument)}
            return v
        }
    }

    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DPipelineState {
    typealias RawValue = WinSDK.ID3D12PipelineState
}
extension D3DPipelineState.RawValue {
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12PipelineState}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DPipelineState")
public typealias ID3D12PipelineState = D3DPipelineState

public extension D3DPipelineState {
    @available(*, unavailable, renamed: "cachedBlob()")
    func GetCachedBlob(_ ppBlob: Any) -> HRESULT {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
