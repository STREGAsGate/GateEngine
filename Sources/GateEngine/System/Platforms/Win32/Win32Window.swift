/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(WinSDK)
import Foundation
import Direct3D12
import WinSDK
import GameMath

final class Win32Window: WindowBacking {
    unowned let window: Window
    let style: WindowStyle
    let identifier: String

    internal let hWnd: WinSDK.HWND
    private let hwndStyle: Win32WindowStyle
    @MainActor internal private(set) lazy var swapChain: DX12SwapChain = DX12SwapChain(hWnd: hWnd)
    private lazy var mouseState: MouseState = MouseState(hWnd)
    private static let windowClass: Win32WindowClass = Win32WindowClass()

    required init(identifier: String, style: WindowStyle, window: Window) {
        self.window = window
        self.style = style
        self.identifier = identifier
        
        let size: Size2 = Size2(640, 480)

        Self.windowClass.register()
        let hWnd: WinSDK.HWND
        switch style {
        case .system:
            hWnd = Self.makeHWND(withSize: size, style: .standard)
            self.hwndStyle = .standard
        case .bestForGames:
            hWnd = Self.makeHWND(withSize: size, style: .modern)
            self.hwndStyle = .modern
        }
        
        self.hWnd = hWnd
        self.title = identifier
        SetWindowLongPtrW(hWnd, GWLP_USERDATA, unsafeBitCast(self as AnyObject, to: LONG_PTR.self))
    }

   var title: String? {
        get {
            let length = GetWindowTextLengthW(self.hWnd)
            var lpString = Array<WCHAR>(unsafeUninitializedCapacity: Int(length) + 1) {
                $1 = Int(GetWindowTextW(self.hWnd, $0.baseAddress, CInt($0.count)))
            }
            lpString.withUnsafeMutableBufferPointer() {p in
                _ = GetWindowTextW(self.hWnd, p.baseAddress!, Int32(p.count) + 1)
            }
            let string = String(windowsUTF16: lpString)
            guard string.isEmpty == false else {return nil}
            return string
        }
        set {
            _ = WinSDK.SetWindowTextW(self.hWnd, newValue?.windowsUTF16)
        }
    }

    ///The screen relative rectangle of the window
    var frame: Rect {
        get {
            var rect: RECT = RECT()
            WinSDK.GetWindowRect(self.hWnd, &rect)
            return Rect(rect)
        }
        set {
            var rect = newValue.RECT()
            WinSDK.AdjustWindowRect(&rect, DWORD(hwndStyle.rawValue), hwndStyle.contains(.menuInTitleBar))
            WinSDK.SetWindowPos(self.hWnd, nil, rect.x, rect.y, rect.width, rect.height, UInt32(SWP_NOACTIVATE))
        }
    }

    @inline(__always)
    var backingSize: Size2 {
        return self.frame.size
    }

    @inline(__always)
    var backingScaleFactor: Float {
        let dpi: UINT = GetDpiForWindow(hWnd)
        return Float(dpi) / Float(USER_DEFAULT_SCREEN_DPI)
    }

    let safeAreaInsets: Insets = .zero

    var state: Window.State = .hidden
    /// If possible, shows the window on screen.
    func show() {
        guard state == .hidden else {return}
        _ = ShowWindow(self.hWnd, SW_SHOWDEFAULT)
        _ = UpdateWindow(self.hWnd)
        self.state = .shown
    }

    @MainActor func render() {
        guard state == .shown else {return}
        self.window.vSyncCalled()
    }

    /// Makes the window hidden. To destroy the window via code allow the Win32Window to deallocate.
    @MainActor func hide() {
        guard self.state == .shown else {return}
        WinSDK.CloseWindow(self.hWnd)
    }

    @MainActor func close() {
        guard self.state != .destroyed else {return}
        Game.shared.windowManager.removeWindow(self.identifier)
    }

    @MainActor func setMouseHidden(_ hidden: Bool) {
        let count: Int32 = hidden ? -1 : 0
        while WinSDK.ShowCursor(!hidden) != count {}
    }

    @MainActor func setMousePosition(_ position: Position2) {
        var p: POINT = WinSDK.POINT(x: Int32(position.x), y: Int32(position.y))
        if WinSDK.ClientToScreen(hWnd, &p) == false {
            Log.error("Failed to set mouse position.", "Failed to obtain screen position.")
            return
        }
        if WinSDK.SetCursorPos(p.x, p.y) == false {
            Log.error("Failed to set mouse position.")
        }else{
            mouseState.setMousePosition(to: position)
        }
    }

    @MainActor func createWindowRenderTargetBackend() -> RenderTargetBackend {
        return DX12RenderTarget(windowBacking: self)
    }

    deinit {
        Task {@MainActor in
            if Game.shared.windowManager.windows.isEmpty {
                Self.windowClass.unregister()
            }
        }
        WinSDK.DestroyWindow(hWnd)
    }
}

fileprivate extension Win32Window {
    class func makeHWND(withSize size: Size2, style: Win32WindowStyle) -> HWND {
        let dwExStyle: DWORD = 0
        let lpClassName: [WCHAR] = "\(type(of: Win32Window.self))".windowsUTF16
        let lpWindowName: [WCHAR] = ProcessInfo.processInfo.processName.windowsUTF16
        let dwStyle: DWORD = DWORD(style.rawValue)
        let screen: MSRect = MSRect.mainScreenBounds()
        let X: INT = (Int32(screen.size.width) - Int32(size.width)) / 2
        let Y: INT = (Int32(screen.size.height) - Int32(size.height)) / 2
        let nWidth: INT = Int32(size.width)
        let nHeight: INT = Int32(size.height)
        let hWndParent: HWND? = nil
        let hMenu: HMENU? = nil
        let hInstance: HINSTANCE = WinSDK.GetModuleHandleW(nil)
        let lpParam: LPVOID? = nil
        guard let hWnd: HWND = WinSDK.CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam) else {
            fatalError(GetLastError().errorMessage)
        }
        return hWnd
    }
    struct Win32WindowStyle: OptionSet {
        typealias RawValue = Int32
        let rawValue: RawValue

        /// The window type. This is always required.
        static let overlapped: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_OVERLAPPED)

        /// Shows the maximize button in the titlebar
        static let maximizable: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_MAXIMIZEBOX)
        /// Shows the minimize button in the titlebar
        static let minimizable: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_MINIMIZEBOX)
        /// Allows user live resizing via draggin the window border
        static let resizable: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_THICKFRAME)

        static let popup: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: Int32(clamping: WinSDK.WS_POPUP))

        /// Shows the titlebar
        static let titleBar: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_CAPTION)
        /// Shows a thin border
        static let boarder: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_BORDER)
        /// Expects the window to have a menu in the titlebar
        static let menuInTitleBar: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_SYSMENU)
        /// Shows the titlebar and expects the window to have a menu
        static let titleBarMenu: Win32WindowStyle = [.titleBar, .menuInTitleBar]

        /// Starts the window maximized
        static let initiallyMaximized: Win32Window.Win32WindowStyle = Win32WindowStyle(rawValue: WinSDK.WS_MAXIMIZE)

        /// The default Windows 10 style. Users expect this.
        static let standard: Win32WindowStyle = [.overlapped, .titleBarMenu, .maximizable, .minimizable, .resizable]
        
        static let modern: Win32WindowStyle = [.menuInTitleBar, .maximizable, .minimizable, .resizable]
        
        init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

fileprivate class Win32WindowClass {
    let name: [WCHAR]
    let hInstance: HINSTANCE
    var value: WNDCLASSEXW
    
    init(style: UInt32 = 0) {
        var IDC_ARROW: UnsafePointer<WCHAR> {
            UnsafePointer<WCHAR>(bitPattern: 32512)!
        }
        let name: [WCHAR] = "\(type(of: Win32Window.self))".windowsUTF16
        let hInstance: HMODULE = GetModuleHandleW(nil)!
        self.name = name
        self.hInstance = hInstance
        self.value = name.withUnsafeBufferPointer {
            return WNDCLASSEXW(cbSize: UINT(MemoryLayout<WNDCLASSEXW>.size),
                               style: DWORD(CS_HREDRAW | CS_VREDRAW),
                               lpfnWndProc: WindowProcedure,
                               cbClsExtra: 0,
                               cbWndExtra: 0,
                               hInstance: hInstance,
                               hIcon: nil,
                               hCursor: LoadCursorW(nil, IDC_ARROW),
                               hbrBackground: nil,
                               lpszMenuName: nil,
                               lpszClassName: $0.baseAddress!,
                               hIconSm: nil)
        }
        register()
    }

    var atom: ATOM? = nil
    func register() {
        guard atom == nil else {return}
        self.atom = RegisterClassExW(&value)
    }
    func unregister() {
        guard atom != nil else {return}
        if UnregisterClassW(self.name, self.hInstance) {
            self.atom = nil
        }
    }

    var meodifierKeys: KeyboardModifierMask = []
}

//These are the notifation calls
fileprivate extension Win32Window {
    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgPaint() {
        self.render()
    }
    
    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgResized() {
        self.window.size = self.frame.size
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgShow() {
        self.show()
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgRestore() {
        self.state = .shown
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgHide() {
        self.hide()
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgClose() {
        self.close()
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgDestroy() {
        self.state = .destroyed
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgMouseMoved(_ lparam: LPARAM) {
        if let windowDelegate: WindowDelegate = window.delegate {
            var event: MouseChangeEvent = .moved
            if mouseState.state == .outside {
                event = .entered
            }
            mouseState.mouseMoved(lparam)
            windowDelegate.mouseChange(event: event, position: mouseState.position, delta: mouseState.delta, window: self.window)
        }
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgMouseExited() {
        if let windowDelegate: WindowDelegate = window.delegate {
            mouseState.mouseExited()
            windowDelegate.mouseChange(event: .exited, position: mouseState.position, delta: mouseState.delta, window: self.window)
        }
    }

    //return true if input was used
    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgKeyDown(_ wparam: WPARAM, _ lparam: LPARAM) -> Bool {
        if let windowDelegate: WindowDelegate = window.delegate {
            let key: KeyboardKey = self.keyFromWPARAM(wparam, lparam)
            return windowDelegate.keyboardDidhandle(key: key,
                                                    character: character(from: wparam)?.first,
                                                    modifiers: modifierKeyFromWPARAM(wparam),
                                                    isRepeat: false,
                                                    event: .keyDown)
        }
        return true
    }

    //return true if input was used
    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgKeyUp(_ wparam: WPARAM, _ lparam: LPARAM) -> Bool {
        if let windowDelegate: WindowDelegate = window.delegate {
            let key: KeyboardKey = self.keyFromWPARAM(wparam, lparam)
            return windowDelegate.keyboardDidhandle(key: key,
                                                    character: character(from: wparam)?.first,
                                                    modifiers: modifierKeyFromWPARAM(wparam),
                                                    isRepeat: false,
                                                    event: .keyUp)
        }
        return true
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseDownLeft(_ lparam: LPARAM) {
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonDown,
                                    button: .button1,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseUpLeft(_ lparam: LPARAM) {
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonUp,
                                    button: .button1,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseDownRight(_ lparam: LPARAM) {
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonDown,
                                    button: .button2,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseUpRight(_ lparam: LPARAM) {
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonUp,
                                    button: .button2,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseDownMiddle(_ lparam: LPARAM) {
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonDown,
                                    button: .button3,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseUpMiddle(_ lparam: LPARAM) {
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonUp,
                                    button: .button3,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor 
    func _mouseDownX(_ lparam: LPARAM, _ wparam: WPARAM) {
        let wparam: Int32 = Int32(wparam)
        let button: MouseButton
        if wparam & XBUTTON1 == XBUTTON1 {
            button = .button4
        }else if wparam & XBUTTON2 == XBUTTON2 {
            button = .button5
        }else{
            button = .unknown(nil)
        }
        let position = positionFrom(lparam)
        window.delegate?.mouseClick(event: .buttonDown,
                                    button: button,
                                    count: nil,
                                    position: position,
                                    delta: nil,
                                    window: self.window)
    }

    @inline(__always)
    @preconcurrency 
    @MainActor
    func _mouseUpX(_ lparam: LPARAM, _ wparam: WPARAM) {
        let wparam: Int32 = Int32(wparam)
        let button: MouseButton
        if wparam & XBUTTON1 == XBUTTON1 {
            button = .button4
        }else if wparam & XBUTTON2 == XBUTTON2 {
            button = .button5
        }else{
            button = .unknown(nil)
        }
        mouseState.mouseMoved(lparam)
        window.delegate?.mouseClick(event: .buttonUp,
                                    button: button,
                                    count: nil,
                                    position: mouseState.position,
                                    delta: mouseState.delta,
                                    window: self.window)
    }
}

extension Win32Window {
    @inline(__always)
    func modifierKeyFromWPARAM(_ param: WPARAM) -> KeyboardModifierMask {
        switch Int32(param) {
        case VK_MENU, VK_LMENU, VK_RMENU:
            return .alt
        case VK_SHIFT, VK_LSHIFT, VK_RSHIFT:
            return .shift
        case VK_CONTROL, VK_LCONTROL, VK_RCONTROL:
            return .control
        case VK_LWIN, VK_RWIN:
            return .host
        case VK_CAPITAL:
            return .capsLock
        default:
            return []
        }
    }

    @inline(__always)
    func character(from param: WPARAM) -> String? {
        var keyboardState: [UInt8] = Array<UInt8>(repeating: 0, count: 256)
        if modifierKeyFromWPARAM(param).contains(.shift) {
            keyboardState[Array<UInt8>.Index(VK_SHIFT)] = 0xff
        }
        var data: [WCHAR] = Array(repeating: 0, count: 256)
        if ToUnicode(UInt32(param), 0, keyboardState, &data, 256, 0) == 1 {
            let string: String = String(windowsUTF16: data)
            if string.isEmpty == false {
                return string
            }
        }
        return nil
    }

    @inline(__always)
    func keyFromWPARAM(_ wparam: WPARAM, _ lparam: LPARAM) -> KeyboardKey {
        let key: Int32 = Int32(wparam)

        #if GATEENGINE_DEBUG_HID
        var keyMacro: String? = nil
        #endif

        switch key {
        #if GATEENGINE_DEBUG_HID
        case VK_LBUTTON:// 0x01 Left mouse button
            keyMacro = "VK_LBUTTON"
        case VK_RBUTTON:// 0x02 Right mouse button
            keyMacro = "VK_RBUTTON"
        case VK_CANCEL:// 0x03 Control-break processing
            keyMacro = "VK_CANCEL"
        case VK_MBUTTON:// 0x04 Middle mouse button (three-button mouse)
            keyMacro = "VK_MBUTTON"
        case VK_XBUTTON1:// 0x05 X1 mouse button
            keyMacro = "VK_XBUTTON1"
        case VK_XBUTTON2:// 0x06 X2 mouse button
            keyMacro = "VK_XBUTTON2"
        case 0x07:// Undefined
            break
        #endif
        case VK_BACK:// 0x08 BACKSPACE key
            return .backspace
        case VK_TAB:// 0x09 TAB key
            return .tab
        #if GATEENGINE_DEBUG_HID
        case 0x0A...0x0B:// Reserved
            break
        #endif
        case VK_CLEAR: // 0x0C	CLEAR key
            return .clear
        case VK_RETURN: // 0x0D	ENTER key
            let isExtended = lparam & 0x1000000 != 0
            return .enter(isExtended ? .numPad : .standard)
        #if GATEENGINE_DEBUG_HID
        case 0x0E...0x0F:// Undefined
            break
        #endif
        case VK_SHIFT: // 0x10	SHIFT key
            let scancode = UInt32(lparam & 0x00ff0000) >> 16
            let key = Int32(MapVirtualKeyW(scancode, UInt32(MAPVK_VSC_TO_VK_EX)))
            switch key {
            case VK_LSHIFT:
                return .shift(.left)
            case VK_RSHIFT:
                return .shift(.right)
            default:
                #if GATEENGINE_DEBUG_HID
                keyMacro = "VK_SHIFT"
                #endif
                break
            }
        case VK_CONTROL: // 0x11	CTRL key
            let isExtended = lparam & 0x1000000 != 0
            return .control(isExtended ? .right : .left)
        case VK_MENU: // 0x12	ALT key
             let isExtended = lparam & 0x1000000 != 0
            return .alt(isExtended ? .right : .left)
        case VK_PAUSE: // 0x13	PAUSE key
            return .pauseBreak
        case VK_CAPITAL: // 0x14	CAPS LOCK key
            return .capsLock
        #if GATEENGINE_DEBUG_HID
        case VK_KANA: // 0x15	IME Kana mode
            keyMacro = "VK_KANA"
        case VK_HANGUL: // 0x15	IME Hangul mode
            keyMacro = "VK_HANGUL"
        case VK_IME_ON: // 0x16	IME On
            keyMacro = "VK_IME_ON"
        case VK_JUNJA: // 0x17	IME Junja mode
            keyMacro = "VK_JUNJA"
        case VK_FINAL: // 0x18	IME final mode
            keyMacro = "VK_FINAL"
        case VK_HANJA: // 0x19	IME Hanja mode
            keyMacro = "VK_HANJA"
        case VK_KANJI: // 0x19	IME Kanji mode
            keyMacro = "VK_KANJI"
        case VK_IME_OFF: // 0x1A	IME Off
            keyMacro = "VK_IME_OFF"
        #endif
        case VK_ESCAPE: // 0x1B	ESC key
            return .escape
        #if GATEENGINE_DEBUG_HID
        case VK_CONVERT: // 0x1C	IME convert
            keyMacro = "VK_CONVERT"
        case VK_NONCONVERT: // 0x1D	IME nonconvert
            keyMacro = "VK_NONCONVERT"
        case VK_ACCEPT: // 0x1E	IME accept
            keyMacro = "VK_ACCEPT"
        case VK_MODECHANGE: // 0x1F	IME mode change request
            keyMacro = "VK_MODECHANGE"
        #endif
        case VK_SPACE: // 0x20	SPACEBAR
            return .space
        case VK_PRIOR: // 0x21	PAGE UP key
            return .pageUp
        case VK_NEXT: // 0x22	PAGE DOWN key
            return .pageDown
        case VK_END: // 0x23	END key
            return .end
        case VK_HOME: // 0x24	HOME key
            return .home
        case VK_LEFT: // 0x25	LEFT ARROW key
            return .left
        case VK_UP: // 0x26	UP ARROW key
            return .up
        case VK_RIGHT: // 0x27	RIGHT ARROW key
            return .right
        case VK_DOWN: // 0x28	DOWN ARROW key
            return .down
        #if GATEENGINE_DEBUG_HID
        case VK_SELECT: // 0x29	SELECT key
            keyMacro = "VK_SELECT"
        case VK_PRINT: // 0x2A	PRINT key
            keyMacro = "VK_PRINT"
        case VK_EXECUTE: // 0x2B	EXECUTE key
            keyMacro = "VK_EXECUTE"
        #endif
        case VK_SNAPSHOT: // 0x2C	PRINT SCREEN key
            return .printScreen
        case VK_INSERT: // 0x2D	INS key
            return .insert
        case VK_DELETE: // 0x2E	DEL key
            return .delete
        #if GATEENGINE_DEBUG_HID
        case VK_HELP: // 0x2F	HELP key
            keyMacro = "VK_HELP"
        #endif
        case 0x30:// 0 key
            return .character("0", .standard)
        case 0x31:// 1 key
            return .character("1", .standard)
        case 0x32:// 2 key
            return .character("2", .standard)
        case 0x33:// 3 key
            return .character("3", .standard)
        case 0x34:// 4 key
            return .character("4", .standard)
        case 0x35:// 5 key
            return .character("5", .standard)
        case 0x36:// 6 key
            return .character("6", .standard)
        case 0x37:// 7 key
            return .character("7", .standard)
        case 0x38:// 8 key
            return .character("8", .standard)
        case 0x39:// 9 key
            return .character("9", .standard)
        #if GATEENGINE_DEBUG_HID
        case 0x3A...0x40:// Undefined
            break
        #endif
        case 0x41:// A key
            return .character("a", .standard)
        case 0x42:// B key
            return .character("b", .standard)
        case 0x43:// C key
            return .character("c", .standard)
        case 0x44:// D key
            return .character("d", .standard)
        case 0x45:// E key
            return .character("e", .standard)
        case 0x46:// F key
            return .character("f", .standard)
        case 0x47:// G key
            return .character("g", .standard)
        case 0x48:// H key
            return .character("h", .standard)
        case 0x49:// I key
            return .character("i", .standard)
        case 0x4A:// J key
            return .character("j", .standard)
        case 0x4B:// K key
            return .character("k", .standard)
        case 0x4C:// L key
            return .character("l", .standard)
        case 0x4D:// M key
            return .character("m", .standard)
        case 0x4E:// N key
            return .character("n", .standard)
        case 0x4F:// O key
            return .character("o", .standard)
        case 0x50:// P key
            return .character("p", .standard)
        case 0x51:// Q key
            return .character("q", .standard)
        case 0x52:// R key
            return .character("r", .standard)
        case 0x53:// S key
            return .character("s", .standard)
        case 0x54:// T key
            return .character("t", .standard)
        case 0x55:// U key
            return .character("u", .standard)
        case 0x56:// V key
            return .character("v", .standard)
        case 0x57:// W key
            return .character("w", .standard)
        case 0x58:// X key
            return .character("x", .standard)
        case 0x59:// Y key
            return .character("y", .standard)
        case 0x5A:// Z key
            return .character("z", .standard)
        case VK_LWIN: // 0x5B	Left Windows key (Natural keyboard)
            return .host(.left)
        case VK_RWIN: // 0x5C	Right Windows key (Natural keyboard)
            return .host(.right)
        case VK_APPS: // 0x5D	Applications key (Natural keyboard)
            return .contextMenu
        #if GATEENGINE_DEBUG_HID
        case 0x5E:// Reserved
            break
        case VK_SLEEP: // 0x5F	Computer Sleep key
            keyMacro = "VK_SLEEP"
        #endif
        case VK_NUMPAD0: // 0x60	Numeric keypad 0 key
            return .character("0", .numPad)
        case VK_NUMPAD1: // 0x61	Numeric keypad 1 key
            return .character("1", .numPad)
        case VK_NUMPAD2: // 0x62	Numeric keypad 2 key
            return .character("2", .numPad)
        case VK_NUMPAD3: // 0x63	Numeric keypad 3 key
            return .character("3", .numPad)
        case VK_NUMPAD4: // 0x64	Numeric keypad 4 key
            return .character("4", .numPad)
        case VK_NUMPAD5: // 0x65	Numeric keypad 5 key
            return .character("5", .numPad)
        case VK_NUMPAD6: // 0x66	Numeric keypad 6 key
            return .character("6", .numPad)
        case VK_NUMPAD7: // 0x67	Numeric keypad 7 key
            return .character("7", .numPad)
        case VK_NUMPAD8: // 0x68	Numeric keypad 8 key
            return .character("8", .numPad)
        case VK_NUMPAD9: // 0x69	Numeric keypad 9 key
            return .character("9", .numPad)
        case VK_MULTIPLY: // 0x6A	Multiply key
            return .character("*", .numPad)
        case VK_ADD: // 0x6B	Add key
            return .character("+", .numPad)
        #if GATEENGINE_DEBUG_HID
        case VK_SEPARATOR: // 0x6C	Separator key
            keyMacro = "VK_SEPARATOR"
        #endif
        case VK_SUBTRACT: // 0x6D	Subtract key
            return .character("-", .numPad)
        case VK_DECIMAL: // 0x6E	Decimal key
            return .character(".", .numPad)
        case VK_DIVIDE: // 0x6F	Divide key
            return .character("/", .numPad)
        case VK_F1...VK_F24: // 0x70 F1 key - 0x87 F24 key
            return .function(Int(key - 0x6F))
        #if GATEENGINE_DEBUG_HID
        case 0x88...0x8F: // Unassigned
            break
        #endif
        case VK_NUMLOCK: // 0x90	NUM LOCK key
            return .numLock
        case VK_SCROLL: // 0x91	SCROLL LOCK key
            return .scrollLock
        case VK_OEM_NEC_EQUAL:// '=' key on numpad
            return .character("=", .numPad)
        #if GATEENGINE_DEBUG_HID
        case 0x93...0x96: // OEM specific
            break
        case 0x97...0x9F: // Unassigned
            break
        #endif
        case VK_LSHIFT: // 0xA0	Left SHIFT key
            return .shift(.left)
        case VK_RSHIFT: // 0xA1	Right SHIFT key
            return .shift(.right)
        case VK_LCONTROL: // 0xA2	Left CONTROL key
            return .control(.left)
        case VK_RCONTROL: // 0xA3	Right CONTROL key
            return .control(.right)
        case VK_LMENU: // 0xA4	Left ALT key
            return .alt(.left)
        case VK_RMENU: // 0xA5	Right ALT key
            return .alt(.right)
        #if GATEENGINE_DEBUG_HID
        case VK_BROWSER_BACK: // 0xA6	Browser Back key
            keyMacro = "VK_BROWSER_BACK"
        case VK_BROWSER_FORWARD: // 0xA7	Browser Forward key
            keyMacro = "VK_BROWSER_FORWARD"
        case VK_BROWSER_REFRESH: // 0xA8	Browser Refresh key
            keyMacro = "VK_BROWSER_REFRESH"
        case VK_BROWSER_STOP: // 0xA9	Browser Stop key
            keyMacro = "VK_BROWSER_STOP"
        case VK_BROWSER_SEARCH: // 0xAA	Browser Search key
            keyMacro = "VK_BROWSER_SEARCH"
        case VK_BROWSER_FAVORITES: // 0xAB	Browser Favorites key
            keyMacro = "VK_BROWSER_FAVORITES"
        case VK_BROWSER_HOME: // 0xAC	Browser Start and Home key
            keyMacro = "VK_BROWSER_HOME"
        #endif
        case VK_VOLUME_MUTE: // 0xAD	Volume Mute key
            return .mute
        case VK_VOLUME_DOWN: // 0xAE	Volume Down key
            return .volumeDown
        case VK_VOLUME_UP: // 0xAF	Volume Up key
            return .volumeUp
        case VK_MEDIA_NEXT_TRACK: // 0xB0	Next Track key
            return .mediaNextTrack
        case VK_MEDIA_PREV_TRACK: // 0xB1	Previous Track key
            return .mediaPreviousTrack
        case VK_MEDIA_STOP: // 0xB2	Stop Media key
            return .mediaStop
        case VK_MEDIA_PLAY_PAUSE: // 0xB3	Play/Pause Media key
            return .mediaPlayPause
        #if GATEENGINE_DEBUG_HID
        case VK_LAUNCH_MAIL: // 0xB4	Start Mail key
            keyMacro = "VK_LAUNCH_MAIL"
        case VK_LAUNCH_MEDIA_SELECT: // 0xB5	Select Media key
            keyMacro = "VK_LAUNCH_MEDIA_SELECT"
        case VK_LAUNCH_APP1: // 0xB6	Start Application 1 key
            keyMacro = "VK_LAUNCH_APP1"
        case VK_LAUNCH_APP2: // 0xB7	Start Application 2 key
            keyMacro = "VK_LAUNCH_APP2"
        case 0xB8...0xB9:// Reserved
            break
        #endif
        case VK_OEM_1: // 0xBA	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ';:' key
            return .character(";", .standard)
        case VK_OEM_PLUS: // 0xBB	For any country/region, the '+' key
            return .character("+", .standard)
        case VK_OEM_COMMA: // 0xBC	For any country/region, the ',' key
            return .character(",", .standard)
        case VK_OEM_MINUS: // 0xBD	For any country/region, the '-' key
            return .character("-", .standard)
        case VK_OEM_PERIOD: // 0xBE	For any country/region, the '.' key
            return .character(".", .standard)
        case VK_OEM_2: // 0xBF	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '/?' key
            return .character("/", .standard)
        case VK_OEM_3: // 0xC0	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '`~' key
            return .character("`", .standard)
        #if GATEENGINE_DEBUG_HID
        case 0xC1...0xD7:// Reserved
            break
        case 0xD8...0xDA:// Unassigned
            break
        #endif
        case VK_OEM_4: // 0xDB	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '[{' key
            return .character("[", .standard)
        case VK_OEM_5: // 0xDC	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the '\|' key
            return .character("\\", .standard)
        case VK_OEM_6: // 0xDD	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ']}' key
            return .character("]", .standard)
        case VK_OEM_7: // 0xDE	Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the 'single-quote/double-quote' key
            return .character("'", .standard)
        case VK_OEM_8: // 0xDF	Used for miscellaneous characters; it can vary by keyboard.
            Log.info("VK_OEM_8")
            break
        #if GATEENGINE_DEBUG_HID
        case 0xE0:// Reserved
            break
        case 0xE1: //OEM specific
            break
        case VK_OEM_102: // 0xE2	The <> keys on the US standard keyboard, or the \\| key on the non-US 102-key keyboard
            keyMacro = "VK_OEM_102"
        case 0xE3...0xE4:// OEM specific
            break
        case VK_PROCESSKEY: // 0xE5	IME PROCESS key
            keyMacro = "VK_PROCESSKEY"
        case 0xE6:// OEM specific
                break
        case VK_PACKET: // 0xE7	Used to pass Unicode characters as if they were keystrokes. The VK_PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP
            keyMacro = "VK_PACKET"
        case 0xE8:// Unassigned
            break
        case 0xE9...0xF5: //OEM specific
            break
        case VK_ATTN: // 0xF6	Attn key
            keyMacro = "VK_ATTN"
        case VK_CRSEL: // 0xF7	CrSel key
            keyMacro = "VK_CRSEL"
        case VK_EXSEL: // 0xF8	ExSel key
            keyMacro = "VK_EXSEL"
        case VK_EREOF: // 0xF9	Erase EOF key
            keyMacro = "VK_EREOF"
        case VK_PLAY: // 0xFA	Play key
           keyMacro = "VK_PLAY"
        case VK_ZOOM: // 0xFB	Zoom key
            keyMacro = "VK_ZOOM"
        case VK_NONAME: // 0xFC	Reserved
            keyMacro = "VK_NONAME"
        case VK_PA1: // 0xFD	PA1 key
            keyMacro = "VK_PA1"
        #endif
        case VK_OEM_CLEAR: // 0xFE	Clear ke
            return .clear
        default:
            break
        }
        #if GATEENGINE_DEBUG_HID
        Log.warnOnce("Key Code \(wparam)\(keyMacro != nil ? (":" + keyMacro!) : ""):\(lparam) is unhandled!")
        #else
        Log.warnOnce("Key Code \(wparam) is unhandled!")
        #endif
        return .unhandledPlatformKeyCode(Int(wparam), character(from: wparam))
    }
}

fileprivate typealias WindowProc = @MainActor @convention(c) (HWND?, UINT, WPARAM, LPARAM) -> LRESULT

@preconcurrency fileprivate func WindowProcedure(_ hWnd: HWND?, _ uMsg: UINT, _ wParam: WPARAM, _ lParam: LPARAM) -> LRESULT {
    let lpUserData: LONG_PTR = GetWindowLongPtrW(hWnd, GWLP_USERDATA)
    guard lpUserData != 0, let window: Win32Window = unsafeBitCast(lpUserData, to: AnyObject.self) as? Win32Window else {
        return DefWindowProcW(hWnd, uMsg, wParam, lParam)
    }
    
    switch Int32(uMsg) {
    case WM_PAINT:
        break
    case WM_SIZE:
        switch Int32(wParam) {
        case SIZE_RESTORED:
            window._msgRestore()
        case SIZE_MINIMIZED:
            window._msgHide()
        default:
            break
        }
        window._msgResized()
        return 0
    case WM_MOUSEMOVE:
        window._msgMouseMoved(lParam)
        return 0
    case WM_MOUSELEAVE:
        window._msgMouseExited()
        return 0
    case WM_LBUTTONDOWN:
        window._mouseDownLeft(lParam)
        return 0
    case WM_LBUTTONUP:
        window._mouseUpLeft(lParam)
        return 0
    case WM_RBUTTONDOWN:
        window._mouseDownRight(lParam)
        return 0
    case WM_RBUTTONUP:
        window._mouseUpRight(lParam)
        return 0
    case WM_LBUTTONDOWN:
        window._mouseDownMiddle(lParam)
        return 0
    case WM_MBUTTONUP:
        window._mouseUpMiddle(lParam)
        return 0
    case WM_XBUTTONDOWN:
        window._mouseDownX(lParam, wParam)
        return 0
    case WM_XBUTTONUP:
        window._mouseUpX(lParam, wParam)
        return 0
    case WM_KEYDOWN, WM_SYSKEYDOWN:
        if window._msgKeyDown(wParam, lParam) {
            return 0
        }
    case WM_KEYUP, WM_SYSKEYUP:
        if window._msgKeyUp(wParam, lParam) {
            return 0
        }
    case WM_SHOWWINDOW:
        switch wParam {
        case WPARAM(1):
            window._msgShow()
        default:
            window._msgHide()
        }
    case WM_CLOSE:
        window._msgClose()
    case WM_DESTROY:
        window._msgDestroy()
    case WM_GETMINMAXINFO:
        if let info: UnsafeMutablePointer<MINMAXINFO> = UnsafeMutablePointer<MINMAXINFO>(bitPattern: UInt(UInt64(bitPattern: lParam))) {
            info.pointee.ptMinTrackSize.x = 256
            info.pointee.ptMinTrackSize.y = 144
            return 0
        }
    default:
        break
    }
    return DefWindowProcW(hWnd, uMsg, wParam, lParam)
}

fileprivate struct MouseState {
    let hwnd: HWND
    init(_ hwnd: HWND) {
        self.hwnd = hwnd
    }
    var deltaPosition: Position2 = .zero
    @inline(__always)
    mutating func setMousePosition(to newPosition: Position2) {
        self.deltaPosition = floor(newPosition)
    }
    var position: Position2 = .zero
    var delta: Position2 = .zero
    enum State {
        case outside
        case inside
    }
    private(set) var state: State = .outside

    private var tracking: Bool = false
    @inline(__always)
    mutating func mouseMoved(_ lpParam: LPARAM) {
        guard tracking == false else {return}
        state = .inside
        let newPosition = positionFrom(lpParam)
        self.delta = newPosition - deltaPosition
        self.position = newPosition
        var event = TRACKMOUSEEVENT()
        event.cbSize = DWORD(MemoryLayout<TRACKMOUSEEVENT>.size)
        event.dwFlags = DWORD(TME_LEAVE)
        event.hwndTrack = hwnd
        TrackMouseEvent(&event);
    }

    @inline(__always)
    mutating func mouseExited() {
        tracking = false
        state = .outside
    }
}

@_transparent
fileprivate func LOWORD<T: BinaryInteger>(_ w: T) -> WORD {
    return WORD((DWORD_PTR(w) >> 0) & 0xffff)
}

@_transparent
fileprivate func HIWORD<T: BinaryInteger>(_ w: T) -> WORD {
    return WORD((DWORD_PTR(w) >> 16) & 0xffff)
}

@_transparent
fileprivate func GET_X_LPARAM(_ lParam: LPARAM) -> WORD {
    return WORD(SHORT(LOWORD(lParam)))
}

@_transparent
fileprivate func GET_Y_LPARAM(_ lParam: LPARAM) -> WORD {
    return WORD(SHORT(HIWORD(lParam)))
}

@_transparent
fileprivate func positionFrom(_ lparam: LPARAM) -> Position2 {
    let x: WORD = GET_X_LPARAM(lparam)
    let y: WORD = GET_Y_LPARAM(lparam)
    return Position2(Float(x), Float(y))
}

fileprivate extension Rect {
    func RECT() -> WinSDK.RECT {
        let left: Int32 = Int32(position.x)
        let top: Int32 = Int32(position.y)
        let right: Int32 = Int32(position.x + size.width)
        let bottom: Int32 = Int32(position.y + size.height)
        return WinSDK.RECT(left: left, top: top, right: right, bottom: bottom)
    }

    init(_ RECT: WinSDK.RECT) {
        let position: Position2 = Position2(x: Float(RECT.left), y: Float(RECT.top))
        let size: Size2 = Size2(width: Float(RECT.width), height: Float(RECT.height))
        self.init(position: position, size: size)
    }
}

#endif
