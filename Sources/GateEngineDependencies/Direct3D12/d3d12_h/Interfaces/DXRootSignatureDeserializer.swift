/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public class D3DRootSignatureDeserializer: IUnknown {
        
    public var rootSignatureDescription: D3DRootSignatureDescription {
        return performFatally(as: RawValue.self) {pThis in
            // let v = pThis.pointee.lpVtbl.pointee.GetRootSignatureDesc(pThis)
            // return D3DRootSignatureDescription(v!.pointee)
            fatalError("\(type(of: self)) \(#function) not implemented.")
        }
    }

    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DRootSignatureDeserializer {
    public typealias RawValue = WinSDK.ID3D12RootSignatureDeserializer
}
extension D3DRootSignatureDeserializer.RawValue {
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12RootSignatureDeserializer}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, deprecated, renamed: "D3DRootSignatureDeserializer")
public typealias ID3D12RootSignatureDeserializer = D3DRootSignatureDeserializer

public extension D3DRootSignatureDeserializer {
    @available(*, unavailable, renamed: "rootSignatureDescription")
    func GetRootSignatureDesc() -> Any {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
