/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

/// An information-queue interface stores, retrieves, and filters debug messages. The queue consists of a message queue, an optional storage filter stack, and a optional retrieval filter stack.
public final class D3DInfoQueue: IUnknown {

    /// Get a message from the message queue.
    @inlinable @inline(__always)
    public func getMessage(messageIndex: UInt64, block: (D3DMessage?) -> Void) {
        perform(as: RawValue.self) { pThis in
            
            // Get just the size
            var size: WinSDK.SIZE_T = 0
            var result: HRESULT = pThis.pointee.lpVtbl.pointee.GetMessageA(pThis, messageIndex, nil, &size)
            if result.isFailure {
                block(nil)
                return
            }

            // Get the message
            let capacity: Int = Int(size) - MemoryLayout<D3D12_MESSAGE>.size
            let msg: UnsafeMutablePointer<CChar> = .allocate(capacity: capacity)
            var message: D3D12_MESSAGE = D3D12_MESSAGE(Category: WinSDK.D3D12_MESSAGE_CATEGORY(0), 
                                                       Severity: WinSDK.D3D12_MESSAGE_SEVERITY(0), 
                                                       ID: D3D12_MESSAGE_ID(0), 
                                                       pDescription: msg, 
                                                       DescriptionByteLength: size)
            result = pThis.pointee.lpVtbl.pointee.GetMessageA(pThis, messageIndex, &message, &size)
            if result.isSuccess {
                let message: D3DMessage = D3DMessage(message)
                block(message)
            }else{
                block(nil)
            }
            msg.deallocate()
        }
    }

    /// Get the number of messages currently stored in the message queue.
    @inlinable @inline(__always)
    public var storedMessageCount: UInt64 {
        return performFatally(as: RawValue.self) {pThis in
            return pThis.pointee.lpVtbl.pointee.GetNumStoredMessages(pThis)
        }
    }

    required internal init?(winSDKPointer pointer: UnsafeMutableRawPointer?, memoryManagement: MemoryManagement = .alreadyRetained) {
        super.init(winSDKPointer: pointer, memoryManagement: memoryManagement)
    }

    @inlinable @inline(__always)
    override class var interfaceID: WinSDK.IID {RawValue.interfaceID}
}

extension D3DInfoQueue {
    @usableFromInline
    typealias RawValue = WinSDK.ID3D12InfoQueue
}
extension D3DInfoQueue.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_ID3D12InfoQueue}
}

//MARK: - Original Style API
#if !Direct3D12ExcludeOriginalStyleAPI

@available(*, unavailable, renamed: "D3DInfoQueue")
public typealias ID3DInfoQueueInfoQueue = D3DInfoQueue

public extension D3DInfoQueue {
    @available(*, unavailable, renamed: "getMessage(_:)")
    func GetMessage() -> String {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }

    @available(*, unavailable, renamed: "storedMessageCount")
    func GetNumStoredMessages () -> String {
        fatalError("This API is here to make migration easier. There is no implementation.")
    }
}

#endif
