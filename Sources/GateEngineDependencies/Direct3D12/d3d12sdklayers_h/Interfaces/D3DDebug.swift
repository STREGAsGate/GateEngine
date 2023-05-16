/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// An interface used to turn on the debug layer. See EnableDebugLayer for more information.
public final class D3DDebug: IUnknown {

    /// Enables the debug layer.
    @inlinable @inline(__always)
    public func enableDebugLayer() {
        performFatally(as: RawValue.self) {pThis in
            pThis.pointee.lpVtbl.pointee.EnableDebugLayer(pThis)
        }
    }

    /// Gets a debug interface.
    public init() throws {
        var riid = Self.interfaceID
        var ppvDebug: UnsafeMutableRawPointer?
        try WinSDK.D3D12GetDebugInterface(&riid, &ppvDebug).checkResult(Self.self, #function)
        super.init(winSDKPointer: ppvDebug!)!
    }

    required internal init?(winSDKPointer pointer: UnsafeMutableRawPointer?, memoryManagment: MemoryManagment = .alreadyRetained) {
        super.init(winSDKPointer: pointer, memoryManagment: memoryManagment)
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DDebug {
    typealias RawValue = WinSDK.ID3D12Debug
}
extension D3DDebug.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12Debug}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "D3DDebug")
public typealias ID3D12Debug = D3DDebug

@available(*, unavailable, renamed: "D3DDebug.init()")
public func D3D12GetDebugInterface() {
    fatalError("This API is here to make migration easier. There is no implementation.")
}

public extension D3DDebug {
    @available(*, unavailable, renamed: "enableDebugLayer()")
    func EnableDebugLayer() {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
