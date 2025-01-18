/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public class IUnknown {
    @usableFromInline
    internal let pUnk: UnsafeMutableRawPointer

    @inlinable @inline(__always)
    func perform<Type, ResultType>(as type: Type.Type, body: (_ pThis: UnsafeMutablePointer<Type>) throws -> ResultType) rethrows -> ResultType {
        let pThis = pUnk.bindMemory(to: Type.self, capacity: 1)
        return try body(pThis)
    }

    @inlinable @inline(__always)
    func performFatally<Type, ResultType>(as type: Type.Type, body: (_ pThis: UnsafeMutablePointer<Type>) throws -> ResultType) -> ResultType {
        do {
            let pThis = pUnk.bindMemory(to: Type.self, capacity: 1)
            return try body(pThis)
        }
        // catch let error as XAudio2.Error {
        //     fatalError(error.description)
        // }
        catch{
            fatalError("\(error)")
        }
    }

    @usableFromInline
    internal enum MemoryManagement {
        case alreadyRetained
        case retain
    }

    @inlinable @inline(__always)
    required internal init?(winSDKPointer pointer: UnsafeMutableRawPointer?, memoryManagement: MemoryManagement = .alreadyRetained) {
        guard let pointer = pointer else {return nil}
        self.pUnk = pointer
        if memoryManagement == .retain {
            self.retain()
        }
    }

    @inlinable @inline(__always)
    internal func retain() {
        self.performFatally(as: WinSDK.IUnknown.self) {pThis in
            _ = pThis.pointee.lpVtbl.pointee.AddRef(pThis)
        }
    }

    @inlinable @inline(__always)
    internal func release() {
        self.performFatally(as: WinSDK.IUnknown.self) {pThis in
            _ = pThis.pointee.lpVtbl.pointee.Release(pThis)
        }
    }

    @inlinable @inline(__always)
    public func fullRelease() {
        self.performFatally(as: WinSDK.IUnknown.self) {pThis in
            while pThis.pointee.lpVtbl.pointee.Release(pThis) > 0 {}
        }
    }

    @inlinable @inline(__always)
    public func queryInterface<T: IUnknown>(_ type: T.Type) -> T? {
        return self.perform(as: WinSDK.IUnknown.self) { pThis in
            var pointer: UnsafeMutableRawPointer? = nil
            var iid: IID = type.interfaceID
            let result: HRESULT = pThis.pointee.lpVtbl.pointee.QueryInterface(pThis, &iid, &pointer)
            
            if result.isSuccess, let pointer: UnsafeMutableRawPointer = pointer {
                return type.init(winSDKPointer: pointer, memoryManagement: .retain)
            }
            return nil
        }
    }

    deinit {
        self.release()
    }
    
    @inlinable @inline(__always)
    class var interfaceID: WinSDK.IID {preconditionFailure("Must override!")}
}

extension IUnknown {
    @usableFromInline
    typealias RawValue = WinSDK.IUnknown
}
extension IUnknown.RawValue {
    @inlinable @inline(__always)
    static var interfaceID: WinSDK.IID {WinSDK.IID_IUnknown}
}
