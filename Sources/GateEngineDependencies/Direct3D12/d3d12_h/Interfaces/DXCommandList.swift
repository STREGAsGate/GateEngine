/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public class D3DCommandList: D3DDeviceChild {
    /// Gets the type of the command list, such as direct, bundle, compute, or copy.
    public var commandListType: D3DCommandListType {
        return performFatally(as: RawValue.self) {
            return D3DCommandListType(rawValue: $0.pointee.lpVtbl.pointee.GetType($0))
        }
    }

    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DCommandList {
    typealias RawValue = WinSDK.ID3D12CommandList
}
extension D3DCommandList.RawValue {
    static var interfaceID: IID {WinSDK.IID_ID3D12CommandList}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "D3DCommandList")
public typealias ID3D12CommandList = D3DCommandList 

public extension D3DCommandList {
    @available(*, unavailable, renamed: "commandListType")
    func GetType() -> D3DCommandListType.RawValue {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
