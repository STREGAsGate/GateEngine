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
    var s = WinSDK.SYSTEMTIME()
    var f = WinSDK.FILETIME()
    var t = WinSDK.LARGE_INTEGER()

    s.wYear = 1970
    s.wMonth = 1
    s.wDay = 1
    s.wHour = 0
    s.wMinute = 0
    s.wSecond = 0
    s.wMilliseconds = 0
    WinSDK.SystemTimeToFileTime(&s, &f)
    t.QuadPart = f.dwHighDateTime
    t.QuadPart <<= 32
    t.QuadPart |= f.dwLowDateTime
    return t
}

fileprivate var offset = WinSDK.LARGE_INTEGER()
fileprivate var frequencyToMicroseconds: Double = 0
fileprivate var initialized = false
fileprivate var usePerformanceCounter = false
@inline(__always)
internal func clock_gettime(_ X: Int, tv: inout WinSDK.timeval) -> Int {
    var t = LARGE_INTEGER()
    var f = FILETIME()
    var microseconds: Double = 0

    if (!initialized) {
        var performanceFrequency = WinSDK.LARGE_INTEGER()
        initialized = true
        usePerformanceCounter = WinSDK.QueryPerformanceFrequency(&performanceFrequency) != 0
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
        t.QuadPart = f.dwHighDateTime
        t.QuadPart <<= 32
        t.QuadPart |= f.dwLowDateTime
    }

    t.QuadPart -= offset.QuadPart
    microseconds = Double(t.QuadPart) / frequencyToMicroseconds
    t.QuadPart = microseconds
    tv->tv_sec = t.QuadPart / 1000000
    tv->tv_usec = t.QuadPart % 1000000
    return 0
}

#endif
