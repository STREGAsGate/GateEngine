/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import WinSDK

@_transparent
internal var QS_INPUT: DWORD {
    return DWORD(QS_MOUSE) | DWORD(QS_KEY) | DWORD(QS_RAWINPUT) | DWORD(QS_TOUCH) | DWORD(QS_POINTER)
}

@_transparent
internal var QS_ALLINPUT: DWORD {
    return QS_INPUT | DWORD(QS_POSTMESSAGE) | DWORD(QS_TIMER) | DWORD(QS_PAINT) | DWORD(QS_HOTKEY) | DWORD(QS_SENDMESSAGE)
}

@inline(__always)
func getFILETIMEoffset() -> WinSDK.LARGE_INTEGER {
    var s: SYSTEMTIME = WinSDK.SYSTEMTIME()
    var f: FILETIME = WinSDK.FILETIME()
    var t: LARGE_INTEGER = WinSDK.LARGE_INTEGER()

    s.wYear = 1970
    s.wMonth = 1
    s.wDay = 1
    s.wHour = 0
    s.wMinute = 0
    s.wSecond = 0
    s.wMilliseconds = 0
    WinSDK.SystemTimeToFileTime(&s, &f)
    t.QuadPart = WinSDK.LONGLONG(f.dwHighDateTime)
    t.QuadPart <<= 32
    t.QuadPart |= Int64(f.dwLowDateTime)
    return t
}

fileprivate var offset: WinSDK.LARGE_INTEGER = WinSDK.LARGE_INTEGER()
fileprivate var frequencyToMicroseconds: Double = 0
fileprivate var initialized: Bool = false
fileprivate var usePerformanceCounter: Bool = false
internal struct timespec { 
    var tv_sec: Double = 0
    var tv_nsec: Double = 0
}
let CLOCK_MONOTONIC_RAW = 1
@inline(__always)
internal func clock_gettime(_ X: Int, _ tv: inout timespec) -> Int {
    var t: WinSDK.LARGE_INTEGER = LARGE_INTEGER()
    var f: WinSDK.FILETIME = FILETIME()
    var microseconds: Double = 0

    if (!initialized) {
        var performanceFrequency: WinSDK.LARGE_INTEGER = WinSDK.LARGE_INTEGER()
        initialized = true
        usePerformanceCounter = WinSDK.QueryPerformanceFrequency(&performanceFrequency)
        if (usePerformanceCounter) {
            WinSDK.QueryPerformanceCounter(&offset)
            frequencyToMicroseconds = Double(performanceFrequency.QuadPart) / 1000000
        } else {
            offset = getFILETIMEoffset()
            frequencyToMicroseconds = 10
        }
    }
    if usePerformanceCounter {
        WinSDK.QueryPerformanceCounter(&t)
    }else{
        WinSDK.GetSystemTimeAsFileTime(&f)
        t.QuadPart = LONGLONG(f.dwHighDateTime)
        t.QuadPart <<= 32
        t.QuadPart |= Int64(f.dwLowDateTime)
    }

    t.QuadPart -= offset.QuadPart
    microseconds = Double(t.QuadPart) / frequencyToMicroseconds
    t.QuadPart = LONGLONG(microseconds)
    tv.tv_sec = Double(t.QuadPart) / 1000000
    tv.tv_nsec = Double(t.QuadPart).truncatingRemainder(dividingBy: 1000000)
    return 0
}

#endif
