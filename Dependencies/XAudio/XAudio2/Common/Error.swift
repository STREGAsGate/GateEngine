/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

extension Error {
    public enum Kind {
        case unknown
        case hresult(WinSDK.HRESULT)
        case text(String)
    }
}

public struct Error: Swift.Error {
    @usableFromInline
    let kind: Kind
    
    @inlinable @inline(__always)
    internal init(_ kind: Kind) {
        self.kind = kind
    }

    @inlinable @inline(__always)
    internal init(_ hr: HRESULT) {
        self.kind = .hresult(hr)
    }
    
    @inlinable @inline(__always)
    internal init(_ string: String) {
        self.kind = .text(string)
    }
}

extension Error: CustomStringConvertible {
    public var description: String {
        switch kind {
        case let .hresult(hr):
            return hr.errorMessage
        case let .text(text):
            return text
        default:
            return "\(kind)"
        }
    }
}

extension Error: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

public extension HRESULT {
    // Common
    static let ok = WinSDK.S_OK
    static let fail = HRESULT(bitPattern: 0x80004005)
    static let invalidArgument = HRESULT(bitPattern: 0x80070057)
    static let outOfMemory = HRESULT(bitPattern: 0x8007000E)
    static let notImplemented = HRESULT(bitPattern: 0x80004001)
    static let `false` = WinSDK.S_FALSE

    // D3d12
    static let adapterNotFound = HRESULT(bitPattern: 0x887E0001) 
    static let driverVersionMismatch = HRESULT(bitPattern: 0x887E0002)

    // DXGI https://docs.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-error
    static let invalidCall = HRESULT(dxgiCode: 0x887A0001)
    static let wasStillDrawing = HRESULT(dxgiCode: 0x887A000A)
}

internal extension HRESULT {
    @inlinable @inline(__always)
    init(severity: UInt32, facility: UInt32, code: UInt32) {
        self.init(bitPattern:(((severity<<31) | (facility<<16) | ((code)))))
    }
    @inlinable @inline(__always)
    init(dxgiCode: UInt32) {
        let dxgiFacility: UInt32 = 0x87a
        self.init(severity: 1, facility: dxgiFacility, code: dxgiCode)
    }
}

public extension HRESULT {
    // https://docs.microsoft.com/en-us/windows/win32/api/winerror/nf-winerror-succeeded
    @inlinable @inline(__always)
    var isSuccess: Bool {
        return self >= 0 
    }
    // https://docs.microsoft.com/en-us/windows/win32/api/winerror/nf-winerror-failed
    @inlinable @inline(__always)
    var isFailure: Bool {
        return self < 0 
    }

    /// Throws Error(self) if isFailure is true
    @inlinable @inline(__always)
    func checkResult(_ source: Any?, _ function: StaticString) throws {
        if isFailure {
            if let source = source {
                throw Error("\(type(of: source)) \(function) " + self.errorMessage)
            }else{
                throw Error("\(function) " + self.errorMessage)
            }
        }
    }
}

public extension DWORD {
    @inlinable @inline(__always)
    var errorMessage: String {
        let dwFlags: DWORD = DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER) | DWORD(FORMAT_MESSAGE_FROM_SYSTEM) | DWORD(FORMAT_MESSAGE_IGNORE_INSERTS)

        var buffer: UnsafeMutablePointer<WCHAR>? = nil
        let dwResult: DWORD = withUnsafeMutablePointer(to: &buffer) {
            return $0.withMemoryRebound(to: WCHAR.self, capacity: 2) {
                return FormatMessageW(dwFlags, nil, self, DWORD((WORD(SUBLANG_DEFAULT) << 10) | WORD(LANG_NEUTRAL)), $0, 0, nil)
            }
        }
        guard dwResult > 0, let message = buffer else {
            return "HRESULT(0x\(String(self, radix: 16)))"
        }
        defer {LocalFree(buffer)}
        return "0x\(String(self, radix: 16)) - \(String(decodingCString: message, as: UTF16.self))"
    }
}

public extension HRESULT {
    @inlinable @inline(__always)
    var errorMessage: String {DWORD(bitPattern: self).errorMessage}
}
