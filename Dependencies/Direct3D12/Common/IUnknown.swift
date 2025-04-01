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

    @inlinable
    func perform<Type, ResultType>(as type: Type.Type, body: (_ pThis: UnsafeMutablePointer<Type>) throws -> ResultType) rethrows -> ResultType {
        let pThis = pUnk.bindMemory(to: Type.self, capacity: 1)
        return try body(pThis)
    }

    @inlinable
    func performFatally<Type, ResultType>(as type: Type.Type, body: (_ pThis: UnsafeMutablePointer<Type>) throws -> ResultType) -> ResultType {
        do {
            let pThis = pUnk.bindMemory(to: Type.self, capacity: 1)
            return try body(pThis)
        }catch let error as Direct3D12.Error {
            fatalError(error.description)
        }catch{
            fatalError("\(error)")
        }
    }

    @usableFromInline
    internal enum MemoryManagement {
        case alreadyRetained
        case retain
    }

    @inlinable
    required internal init?(winSDKPointer pointer: UnsafeMutableRawPointer?, memoryManagement: MemoryManagement = .alreadyRetained) {
        guard let pointer = pointer else {return nil}
        self.pUnk = pointer
        if memoryManagement == .retain {
            self.retain()
        }
    }

    @inlinable
    internal func retain() {
        self.performFatally(as: WinSDK.IUnknown.self) {pThis in
            _ = pThis.pointee.lpVtbl.pointee.AddRef(pThis)
        }
    }

    @inlinable
    internal func release() {
        self.performFatally(as: WinSDK.IUnknown.self) {pThis in
            _ = pThis.pointee.lpVtbl.pointee.Release(pThis)
        }
    }

    @inlinable
    public func fullRelease() {
        self.performFatally(as: WinSDK.IUnknown.self) {pThis in
            while pThis.pointee.lpVtbl.pointee.Release(pThis) > 0 {}
        }
    }

    @inlinable
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
    
    @inlinable
    class var interfaceID: WinSDK.IID {preconditionFailure("Must override!")}
}

extension IUnknown {
    @usableFromInline
    typealias RawValue = WinSDK.IUnknown
}
extension IUnknown.RawValue {
    @inlinable
    static var interfaceID: WinSDK.IID {WinSDK.IID_IUnknown}
}
