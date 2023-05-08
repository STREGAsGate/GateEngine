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

#endif
