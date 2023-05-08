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
    let identifier: String?

    internal let hWnd: WinSDK.HWND
    private let hwndStyle: Win32WindowStyle
    @MainActor internal private(set) lazy var swapChain: DX12SwapChain = DX12SwapChain(hWnd: hWnd)
    private lazy var mouseState: MouseState = MouseState(hWnd)
    private var pressedModifiers: KeyboardModifierMask = []
    private static let windowClass: Win32WindowClass = Win32WindowClass()

    required init(identifier: String?, style: WindowStyle, window: Window) {
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
            WinSDK.GetClientRect(self.hWnd, &rect)
            return Rect(rect)
        }
        set {
            var rect = newValue.RECT()
            WinSDK.AdjustWindowRect(&rect, DWORD(hwndStyle.rawValue), hwndStyle.contains(.menuInTitleBar))
            WinSDK.SetWindowPos(self.hWnd, nil, rect.x, rect.y, rect.width, rect.height, UInt32(SWP_NOACTIVATE))
        }
    }

    var backingSize: Size2 {
        return self.frame.size
    }

    let safeAreaInsets: Insets = .zero

    private enum State {
        ///The window exists but isn't on screen
        case hidden
        ///The window is on screen
        case shown
        ///The window isn't visible and can never be shown again.
        case destroyed
    }

    private var state: State = .hidden
    /// If possible, shows the window on screen.
    func show() {
        guard state == .hidden else {return}
        _ = ShowWindow(self.hWnd, SW_SHOWDEFAULT)
    }

    @MainActor func render() {
        guard state == .shown else {return}
        self.window.vSyncCalled()
    }

    /// Makes the window hidden. To destroy the window via code allow the Win32Window to deallocate.
    func close() {
        guard state == .shown else {return}
        WinSDK.CloseWindow(self.hWnd)
    }

    deinit {
        Self.windowClass.unregister()
        WinSDK.DestroyWindow(hWnd)
    }
}

fileprivate extension Win32Window {
    class func makeHWND(withSize size: Size2, style: Win32WindowStyle) -> HWND {
        let dwExStyle: DWORD = 0
        let lpClassName = "\(type(of: Win32Window.self))".windowsUTF16
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
        guard let hWnd = WinSDK.CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam) else {
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

// Common tasks shared by manual calls and notifications
fileprivate extension Win32Window {
    @_transparent
    func performShowOperations() {
        // Win32WindowManager.shared.incrementWindowCount()
        _ = UpdateWindow(self.hWnd)
    }

    @_transparent
    func performCloseOperations() {
        // Win32WindowManager.shared.decrementWindowCount()
    }
}

//These are the notifation calls
fileprivate extension Win32Window {
    @inline(__always)
    func _msgPaint() {
        Task(priority: .high) {@MainActor in
            self.render()
        }
    }
    @inline(__always)
    func _msgResized() {
        Task(priority: .high) {@MainActor in
            self.window.framebuffer.size = self.frame.size
        }
    }

    @inline(__always)
    func _msgShow() {
        self.performShowOperations()
    }

    @inline(__always)
    func _msgRestore() {
        self.state = .shown
    }

    @inline(__always)
    func _msgHide() {
        self.state = .hidden
    }

    @inline(__always)
    func _msgClose() {
        print("close recieved")
        self.performCloseOperations()
    }

    @inline(__always)
    func _msgDestroy() {
        self.state = .destroyed
    }

    @inline(__always)
    func _msgMouseMoved(lpParam: LPARAM) {
        Task(priority: .high) {@MainActor in
            if let windowDelegate: WindowDelegate = window.delegate {
                var event: MouseChangeEvent = .moved
                if mouseState.state == .outside {
                    event = .entered
                }
                mouseState.mouseMoved(lpParam)
                windowDelegate.mouseChange(event: event, position: mouseState.position)        
            }
        }
    }

    @inline(__always)
    func _msgMouseExited() {
        Task(priority: .high) {@MainActor in
            if let windowDelegate: WindowDelegate = window.delegate {
                mouseState.mouseExited()
                windowDelegate.mouseChange(event: .exited, position: mouseState.position)        
            }
        }
    }

    //return true if input was used
    @inline(__always)
    func _msgKeyDown(_ key: WPARAM) -> Bool {
        Task(priority: .high) {@MainActor in
            if let modifiers: KeyboardModifierMask = self.modifierKeyFromWPARAM(key) {
                pressedModifiers.insert(modifiers)
            }else if let windowDelegate: WindowDelegate = window.delegate {
                let key: KeyboardKey = self.keyFromWPARAM(key)
                _ = windowDelegate.keyboardRequestedHandling(key: key, modifiers: pressedModifiers, event: .keyDown)
            }
        }
        return true
    }

    //return true if input was used
    @inline(__always)
    func _msgKeyUp(_ key: WPARAM) -> Bool {
        Task(priority: .high) {@MainActor in
            if let modifiers: KeyboardModifierMask = self.modifierKeyFromWPARAM(key) {
                pressedModifiers.remove(modifiers)
            }else if let windowDelegate: WindowDelegate = window.delegate {
                let key: KeyboardKey = self.keyFromWPARAM(key)
                _ = windowDelegate.keyboardRequestedHandling(key: key, modifiers: pressedModifiers, event: .keyUp)
            }
        }
        return true
    }

    @inline(__always)
    func _mouseDownLeft(_ lparam: LPARAM) {
        Task(priority: .high) {@MainActor in
            let position: Position2 = positionFrom(lparam)
            window.delegate?.mouseClick(event: .buttonDown, button: .button1, count: nil, position: position)
        }
    }

    @inline(__always)
    func _mouseUpLeft(_ lparam: LPARAM) {
        Task(priority: .high) {@MainActor in
            let position: Position2 = positionFrom(lparam)
            window.delegate?.mouseClick(event: .buttonUp, button: .button1, count: nil, position: position)
        }
    }

    @inline(__always)
    func _mouseDownRight(_ lparam: LPARAM) {
        Task(priority: .high) {@MainActor in
            let position = positionFrom(lparam)
            window.delegate?.mouseClick(event: .buttonDown, button: .button2, count: nil, position: position)
        }
    }

    @inline(__always)
    func _mouseUpRight(_ lparam: LPARAM) {
        Task(priority: .high) {@MainActor in
            let position: Position2 = positionFrom(lparam)
            window.delegate?.mouseClick(event: .buttonUp, button: .button2, count: nil, position: position)
        }
    }

    @inline(__always)
    func _mouseDownMiddle(_ lparam: LPARAM) {
        Task(priority: .high) {@MainActor in
            let position: Position2 = positionFrom(lparam)
            window.delegate?.mouseClick(event: .buttonDown, button: .button3, count: nil, position: position)
        }
    }

    @inline(__always)
    func _mouseUpMiddle(_ lparam: LPARAM) {
        Task(priority: .high) {@MainActor in
            let position: Position2 = positionFrom(lparam)
            window.delegate?.mouseClick(event: .buttonUp, button: .button3, count: nil, position: position)
        }
    }

    @inline(__always)
    func _mouseDownX(_ lparam: LPARAM, _ wparam: WPARAM) {
        Task(priority: .high) {@MainActor in
            let wparam: Int32 = Int32(wparam)
            let position: Position2 = positionFrom(lparam)
            if wparam & XBUTTON1 == XBUTTON1 {
                window.delegate?.mouseClick(event: .buttonDown, button: .button4, count: nil, position: position)
            }else if wparam & XBUTTON2 == XBUTTON2 {
                window.delegate?.mouseClick(event: .buttonDown, button: .button5, count: nil, position: position)
            }
        }
    }

    @inline(__always)
    func _mouseUpX(_ lparam: LPARAM, _ wparam: WPARAM) {
        Task(priority: .high) {@MainActor in
            let wparam: Int32 = Int32(wparam)
            let position: Position2 = positionFrom(lparam)
            if wparam & XBUTTON1 == XBUTTON1 {
                window.delegate?.mouseClick(event: .buttonUp, button: .button4, count: nil, position: position)
            }else if wparam & XBUTTON2 == XBUTTON2 {
                window.delegate?.mouseClick(event: .buttonUp, button: .button5, count: nil, position: position)
            }
        }
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
        var key: KeyboardKey?

        switch Int32(param) {
        case VK_ESCAPE:
            key = .escape
        case VK_BACK:
            key = .backspace
        case VK_UP:
            key = .up
        case VK_DOWN:
            key = .down
        case VK_LEFT:
            key = .left
        case VK_RIGHT:
            key = .right
        case VK_F1:
            key = .function(1)
        case VK_F2:
            key = .function(2)
        case VK_F3:
            key = .function(3)
        case VK_F4:
            key = .function(4)
        case VK_F5:
            key = .function(5)
        case VK_F6:
            key = .function(6)
        case VK_F7:
            key = .function(7)
        case VK_F8:
            key = .function(8)
        case VK_F9:
            key = .function(9)
        case VK_F10:
            key = .function(10)
        case VK_F11:
            key = .function(11)
        case VK_F12:
            key = .function(12)
        case VK_F13:
            key = .function(13)
        case VK_F14:
            key = .function(14)
        case VK_F15:
            key = .function(15)
        case VK_F16:
            key = .function(16)
        case VK_F17:
            key = .function(17)
        case VK_F18:
            key = .function(18)
        case VK_F19:
            key = .function(19)
        case VK_F20:
            key = .function(20)
        default:
            break
        }

        if key == nil {
            var keyboardState = Array<UInt8>(repeating: 0, count: 256)
            if pressedModifiers.contains(.shift) {
                keyboardState[Array<UInt8>.Index(VK_SHIFT)] = 0xff
            }
            var data: [WCHAR] = Array(repeating: 0, count: 256)
            if ToUnicode(UInt32(param), 0, keyboardState, &data, 256, 0) == 1 {
                if let character = String(windowsUTF16: data).first {
                    switch character {
                    case "\r":
                        key = .return
                    case "\t":
                        key = .tab
                    case " ":
                        key = .space
                    default:
                        key = .character(character)
                    }
                }
            }
        }

        #if DEBUG
        if key == nil {
            print("UniversalGraphics is not handling key code:", param)
        }
        #endif

        return key ?? .nothing
    }
}

fileprivate typealias WindowProc = @MainActor @convention(c) (HWND?, UINT, WPARAM, LPARAM) -> LRESULT

fileprivate func WindowProcedure(_ hWnd: HWND?, _ uMsg: UINT, _ wParam: WPARAM, _ lParam: LPARAM) -> LRESULT {
    let lpUserData: LONG_PTR = GetWindowLongPtrW(hWnd, GWLP_USERDATA)
    guard lpUserData != 0, let window: Win32Window = unsafeBitCast(lpUserData, to: AnyObject.self) as? Win32Window else {
        return DefWindowProcW(hWnd, uMsg, wParam, lParam)
    }
    
    switch Int32(uMsg) {
    case WM_PAINT:
        window._msgPaint()
        return 0
    case WM_SIZE:
        switch Int32(wParam) {
        case SIZE_RESTORED:
            window._msgRestore()
        case SIZE_MINIMIZED:
            window._msgHide()
        default:
            window._msgResized()
        }
        return 0
    case WM_MOUSEMOVE:
        window._msgMouseMoved(lpParam: lParam)
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
    var position: Position2 = .zero
    enum State {
        case outside
        case inside
    }
    private(set) var state: State = .outside

    private var tracking: Bool = false
    mutating func mouseMoved(_ lpParam: LPARAM) {
        guard tracking == false else {return}
        state = .inside

        self.position = positionFrom(lpParam)
        var event = TRACKMOUSEEVENT()
        event.cbSize = DWORD(MemoryLayout<TRACKMOUSEEVENT>.size)
        event.dwFlags = DWORD(TME_LEAVE)
        event.hwndTrack = hwnd
        TrackMouseEvent(&event);
    }
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
        let right: Int32 = Int32(size.width)
        let bottom: Int32 = Int32(size.height)
        return WinSDK.RECT(left: left, top: top, right: right, bottom: bottom)
    }

    init(_ RECT: WinSDK.RECT) {
        let position: Position2 = Position2(x: Float(RECT.x), y: Float(RECT.y))
        let size: Size2 = Size2(width: Float(RECT.width), height: Float(RECT.height))
        self.init(position: position, size: size)
    }
}

#endif
