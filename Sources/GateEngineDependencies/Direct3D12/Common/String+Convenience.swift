/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import WinSDK

public extension String {
    init(windowsUTF8 lpcstr: LPCSTR) {
        self = withUnsafePointer(to: lpcstr) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                return String(cString: $0)
            }
        }
    }

    var windowsUTF8: Array<CHAR> {
        return self.withCString(encodedAs: UTF8.self) {
            return $0.withMemoryRebound(to: CHAR.self, capacity: self.utf8.count + 1) {
                return Array(UnsafeBufferPointer(start: $0, count: self.utf8.count + 1))
            }
        }
    }

    init(windowsUTF16 lpcwstr: LPCWSTR) {
        self.init(decodingCString: lpcwstr, as: UTF16.self)
    }

    var windowsUTF16: Array<WCHAR> {
        return self.withCString(encodedAs: UTF16.self) {
            return $0.withMemoryRebound(to: WCHAR.self, capacity: self.utf16.count + 1) {
                return Array(UnsafeBufferPointer(start: $0, count: self.utf16.count + 1))
            }
        }
    }
}
