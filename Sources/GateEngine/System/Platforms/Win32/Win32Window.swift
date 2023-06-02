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
    private var pressedModifiers: KeyboardModifierMask = []
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
    func _msgKeyDown(_ key: WPARAM) -> Bool {
        if let modifiers: KeyboardModifierMask = self.modifierKeyFromWPARAM(key) {
            pressedModifiers.insert(modifiers)
        }else if let windowDelegate: WindowDelegate = window.delegate {
            let key: KeyboardKey = self.keyFromWPARAM(key)
            return windowDelegate.keyboardRequestedHandling(key: key, modifiers: pressedModifiers, event: .keyDown)
        }
        return true
    }

    //return true if input was used
    @inline(__always)
    @preconcurrency 
    @MainActor
    func _msgKeyUp(_ key: WPARAM) -> Bool {
        if let modifiers: KeyboardModifierMask = self.modifierKeyFromWPARAM(key) {
            pressedModifiers.remove(modifiers)
        }else if let windowDelegate: WindowDelegate = window.delegate {
            let key: KeyboardKey = self.keyFromWPARAM(key)
            return windowDelegate.keyboardRequestedHandling(key: key, modifiers: pressedModifiers, event: .keyUp)
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
    func modifierKeyFromWPARAM(_ param: WPARAM) -> KeyboardModifierMask? {
        switch Int32(param) {
        case VK_MENU, VK_LMENU, VK_RMENU:
            return .alt
        case VK_SHIFT, VK_LSHIFT, VK_RSHIFT:
            return .shift
        case VK_CONTROL, VK_LCONTROL, VK_RCONTROL:
            return .control
        case VK_LWIN, VK_RWIN:
            return .host
        default:
            return nil
        }
    }

    @inline(__always)
    func keyFromWPARAM(_ param: WPARAM) -> KeyboardKey {
        let key = Int32(param)
        if key == WinSDK.VK_ESCAPE {
            return .escape
        }
        if key == WinSDK.VK_BACK {
            return .backspace
        }
        if key == WinSDK.VK_UP {
            return .up
        }
        if key == WinSDK.VK_DOWN {
            return .down
        }
        if key == WinSDK.VK_LEFT {
            return .left
        }
        if key == WinSDK.VK_RIGHT {
            return .right
        }
        if key == WinSDK.VK_F1 {
            return .function(1)
        }
        if key == WinSDK.VK_F2 {
            return .function(2)
        }
        if key == WinSDK.VK_F3 {
            return .function(3)
        }
        if key == WinSDK.VK_F4 {
            return .function(4)
        }
        if key == WinSDK.VK_F5 {
            return .function(5)
        }
        if key == WinSDK.VK_F6 {
            return .function(6)
        }
        if key == WinSDK.VK_F7 {
            return .function(7)
        }
        if key == WinSDK.VK_F8 {
            return .function(8)
        }
        if key == WinSDK.VK_F9 {
            return .function(9)
        }
        if key == WinSDK.VK_F10 {
            return .function(10)
        }
        if key == WinSDK.VK_F11 {
            return .function(11)
        }
        if key == WinSDK.VK_F12 {
            return .function(12)
        }
        if key == WinSDK.VK_F13 {
            return .function(13)
        }
        if key == WinSDK.VK_F14 {
            return .function(14)
        }
        if key == WinSDK.VK_F15 {
            return .function(15)
        }
        if key == WinSDK.VK_F16 {
            return .function(16)
        }
        if key == WinSDK.VK_F17 {
            return .function(17)
        }
        if key == WinSDK.VK_F18 {
            return .function(18)
        }
        if key == WinSDK.VK_F19 {
            return .function(19)
        }
        if key == WinSDK.VK_F20 {
            return .function(20)
        }

        var keyboardState = Array<UInt8>(repeating: 0, count: 256)
        if pressedModifiers.contains(.shift) {
            keyboardState[Array<UInt8>.Index(VK_SHIFT)] = 0xff
        }
        
        var data: [WCHAR] = Array(repeating: 0, count: 256)
        if ToUnicode(UInt32(param), 0, keyboardState, &data, 256, 0) == 1 {
            if let character = String(windowsUTF16: data).first {
                if character == "\r" {
                    return .return
                }
                if character == "\t" {
                    return .tab
                }
                if character == " " {
                    return .space
                }
                return .character(character)
            }
        }

        Log.warn("Key Code \(param) is unhandled!")
        
        return .unhandledPlatformKeyCode(Int(param), nil)
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
    case WM_KEYDOWN:
        if window._msgKeyDown(wParam) {
            return 0
        }
    case WM_KEYUP:
        if window._msgKeyUp(wParam) {
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
