/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(Linux)

import Foundation
import GameMath
import LinuxSupport

final class X11Window: WindowBacking {
    weak var window: Window!
    let xWindow: LinuxSupport.Window
    let glxContext: GLXContext
    let style: WindowStyle
    let identifier: String
    
    var state: Window.State = .hidden
    
    required init(identifier: String, style: WindowStyle, window: Window) {
        self.window = window
        self.identifier = identifier
        self.style = style

        let xRoot: LinuxSupport.Window = XRootWindow(Self.xDisplay, Self.xScreen)
        
        let vi: XVisualInfo = Self.visualInfo
        var swa: XSetWindowAttributes = XSetWindowAttributes()
        let cmap: Colormap = XCreateColormap(Self.xDisplay, xRoot, vi.visual, AllocNone)
        swa.colormap = cmap
        swa.event_mask = (EnterWindowMask | LeaveWindowMask | PointerMotionMask | ButtonPressMask | ButtonReleaseMask | KeyPressMask | KeyReleaseMask)
        
        self.xWindow = XCreateWindow(Self.xDisplay, xRoot, 0, 0, UInt32(640), UInt32(480), 0, vi.depth, UInt32(InputOutput), vi.visual, UInt(CWColormap | CWEventMask), &swa)
         
        glxContext = Self.sharedContext

        glXMakeCurrent(xDisplay, xWindow, glxContext)

        XStoreName(xDisplay, xWindow, identifier)
    }
    
    var xDisplay: OpaquePointer {
        return Self.xDisplay
    }
    
    lazy var xic: XIC = XCreateIC(XOpenIM(xDisplay, nil, nil, nil), xWindow)
    private var previousKeyEvent: XKeyEvent = XKeyEvent()
    
    @MainActor func processEvent(_ event: XEvent) {
        func isRepeatedKey(_ event: XKeyEvent) -> Bool {
            return previousKeyEvent.type == KeyRelease &&
                   previousKeyEvent.time == event.time &&
                   previousKeyEvent.keycode == event.keycode
        }
        if event.type == Expose {
            glXMakeCurrent(xDisplay, xWindow, glxContext)
            glXSwapBuffers(xDisplay, xWindow)
            XFlush(xDisplay)
        }else if event.type == KeyPress {
            let event: XKeyEvent = event.xkey
            guard event.same_screen != 0 else {return}
            guard isRepeatedKey(event) == false else {return}
            previousKeyEvent = event
            let key: KeyboardKey = keyFromEvent(event)
            let modifiers: KeyboardModifierMask = modifierKeyFromState(Int32(event.state))
            _ = window.delegate?.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyDown)
        }else if event.type == KeyRelease {
            let event: XKeyEvent = event.xkey
            guard event.same_screen != 0 else {return}
            guard isRepeatedKey(event) == false else {return}
            previousKeyEvent = event
            let key: KeyboardKey = keyFromEvent(event)
            let modifiers: KeyboardModifierMask = modifierKeyFromState(Int32(event.state))
            _ = window.delegate?.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyUp)
        }else if event.type == EnterNotify {
            let event: XMotionEvent = event.xmotion
            guard event.same_screen != 0 else {return}
            window.delegate?.mouseChange(event: .entered, 
                                         position: Position2(Float(event.x), Float(event.y)), 
                                         delta: .zero, 
                                         window: self.window)
        }else if event.type == MotionNotify || event.type == ButtonMotionMask {
            let event = event.xmotion
            guard event.same_screen != 0 else {return}
            window.delegate?.mouseChange(event: .moved, 
                                         position: Position2(Float(event.x), Float(event.y)), 
                                         delta: .zero, 
                                         window: self.window)
        }else if event.type == LeaveNotify {
            let event = event.xmotion
            guard event.same_screen != 0 else {return}
            window.delegate?.mouseChange(event: .exited, 
                                         position: Position2(Float(event.x), Float(event.y)), 
                                         delta: .zero, 
                                         window: self.window)
        }else if event.xbutton.type == ButtonPress {
            let event: XButtonEvent = event.xbutton
            guard event.same_screen != 0 else {return}
            let button: MouseButton = mouseButtonFromEvent(event)
            window.delegate?.mouseClick(event: .buttonDown, 
                                        button: button, 
                                        count: nil,
                                        position: Position2(Float(event.x), Float(event.y)), 
                                        delta: .zero, 
                                        window: self.window)
        }else if event.xbutton.type == ButtonRelease {
            let event: XButtonEvent = event.xbutton
            guard event.same_screen != 0 else {return}
            let button: MouseButton = mouseButtonFromEvent(event)
            window.delegate?.mouseClick(event: .buttonUp, 
                                        button: button, 
                                        count: nil,
                                        position: Position2(Float(event.x), Float(event.y)), 
                                        delta: .zero, 
                                        window: self.window)
        }else{
            print("Unhandled Event:", event.type)
        }
    }

    @MainActor func draw() {
        glXMakeCurrent(xDisplay, xWindow, glxContext)
        self.window.vSyncCalled()
        glXSwapBuffers(xDisplay, xWindow)
        XFlush(xDisplay)
    }

    func show() {
        XMapWindow(xDisplay, xWindow)
    }

    func close() {
        XDestroyWindow(xDisplay, xWindow)
        XCloseDisplay(xDisplay)
    }

    @MainActor func createWindowRenderTargetBackend() -> RenderTargetBackend {
        glXMakeCurrent(xDisplay, xWindow, glxContext)
        return OpenGLRenderTarget(windowBacking: self)
    }

    deinit {
        self.close()
        glXMakeCurrent(xDisplay, xWindow, nil)
 		glXDestroyContext(xDisplay, glxContext)
    }
}

extension X11Window {
    var title: String? {
        get {
            var optionalPointer: UnsafeMutablePointer<CChar>?
            guard XFetchName(xDisplay, xWindow, &optionalPointer) != 0 else {return nil}
            guard let pointer: UnsafeMutablePointer<CChar> = optionalPointer else {return nil}
            return String(cString: pointer)  
        }
        set {
            XStoreName(xDisplay, xWindow, newValue)
        }
    }

    var frame: Rect {
        get {
            var xwa: XWindowAttributes = XWindowAttributes()
            XGetWindowAttributes(xDisplay, xWindow, &xwa)
            return Rect(x: Float(xwa.x), y: Float(xwa.y), width: Float(xwa.width), height: Float(xwa.height))
        }
        set {
            XMoveWindow(xDisplay, xWindow, Int32(newValue.x), Int32(newValue.y))
            XResizeWindow(xDisplay, xWindow, UInt32(newValue.width), UInt32(newValue.height))
        }
    }
    var safeAreaInsets: Insets {
        get {
            return .zero
        }
    }

    var backingSize: Size2 {
        return frame.size
    }

    var backingScaleFactor: Float {
        let resourceString: UnsafeMutablePointer<CChar>? = XResourceManagerString(xDisplay)
        XrmInitialize(); /* Need to initialize the DB before calling Xrm* functions */
        let db = XrmGetStringDatabase(resourceString)
        var value: XrmValue = XrmValue()
        var type: UnsafeMutablePointer<CChar>? = nil
        var dpi: Double = 0.0

        if let cResourceString: UnsafeMutablePointer<CChar> = resourceString {
            let resourceString: String = String(cString: cResourceString)
            print("Entire DB:", resourceString)
            if (XrmGetResource(db, "Xft.dpi", "String", &type, &value) == True) {
                if let addr = value.addr {
                    dpi = atof(addr)
                }
            }
        }

        print("DPI:", dpi)
        return Float(dpi) 
    }

    func setMouseHidden(_ hidden: Bool) {
    
    }

    func setMousePosition(_ position: Position2) {
    
    }
}

extension X11Window {
    func mouseButtonFromEvent(_ event: XButtonEvent) -> MouseButton {
        switch Int32(event.button) {
        case 1:
            return .button1
        case 3:
            return .button2
        case 2:
            return .button3
        case 8:
            return .button4
        case 9:
            return .button5
        default:
            return .unknown(Int(event.button))
        }
    }

    func modifierKeyFromState(_ state: Int32) -> KeyboardModifierMask {
        var modifiers: KeyboardModifierMask = []
        if state & ShiftMask == ShiftMask {
            modifiers.insert(.shift)
        }
        if state & ControlMask == ControlMask {
            modifiers.insert(.control)
        }
        if state & Mod1Mask == Mod1Mask {
            modifiers.insert(.alt)
        }
        return modifiers
    }
    func keyFromEvent(_ event: XKeyEvent) -> KeyboardKey {
        var key: KeyboardKey?

        var status: Int32 = 0
        var keysym: KeySym = 0
        var event: XKeyEvent = event
        var data: [CChar] = Array(repeating: 0, count: 32)
        Xutf8LookupString(self.xic, &event, &data, Int32(data.count - 1), &keysym, &status)

        switch Int32(keysym) {
        case XK_Escape:
            key = .escape
        case XK_BackSpace:
            key = .backspace
        case XK_Up:
            key = .up
        case XK_Down:
            key = .down
        case XK_Left:
            key = .left
        case XK_Right:
            key = .right
        case XK_F1:
            key = .function(1)
        case XK_F2:
            key = .function(2)
        case XK_F3:
            key = .function(3)
        case XK_F4:
            key = .function(4)
        case XK_F5:
            key = .function(5)
        case XK_F6:
            key = .function(6)
        case XK_F7:
            key = .function(7)
        case XK_F8:
            key = .function(8)
        case XK_F9:
            key = .function(9)
        case XK_F10:
            key = .function(10)
        case XK_F11:
            key = .function(11)
        case XK_F12:
            key = .function(12)
        case XK_F13:
            key = .function(13)
        case XK_F14:
            key = .function(14)
        case XK_F15:
            key = .function(15)
        case XK_F16:
            key = .function(16)
        case XK_F17:
            key = .function(17)
        case XK_F18:
            key = .function(18)
        case XK_F19:
            key = .function(19)
        case XK_F20:
            key = .function(20)
        default:
            break
        }

        if key == nil && status == XLookupBoth {
            if let character: String.Element = String(cString: data).first {
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

        #if DEBUG
        if key == nil {
            print("UniversalGraphics is not handling key code:", event.keycode)
        }
        #endif

        return key ?? .unhandledPlatformKeyCode(Int(keysym), nil)
    }
}

extension X11Window {
    static let xDisplay: OpaquePointer = XOpenDisplay(nil)!
    static let xScreen: Int32 = XDefaultScreen(xDisplay)
    static let visualInfo: XVisualInfo = {
        var att: [Int32] = [GLX_RGBA, 1,
                            GLX_RED_SIZE, 8,
                            GLX_GREEN_SIZE, 8,
                            GLX_BLUE_SIZE, 8,
                            GLX_ALPHA_SIZE, 8,
                            GLX_DEPTH_SIZE, 24, 
                            GLX_DOUBLEBUFFER, 1,
                            Int32(None)]
        return glXChooseVisual(xDisplay, xScreen, &att)!.pointee
    }()
    static let sharedContext: GLXContext = {
        if X11Window.supportsARBCreate, let p = glXGetProcAddress("glXCreateContextAttribsARB") {// Supports glx 1.4
            let visual_attribs: [Int32] = [GLX_RENDER_TYPE, GLX_RGBA_BIT,
                                           GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
                                           GLX_DEPTH_SIZE, 24,
                                           GLX_DOUBLEBUFFER, 1,
                                           GLX_RED_SIZE, 8,
                                           GLX_GREEN_SIZE, 8,
                                           GLX_BLUE_SIZE, 8,
                                           GLX_ALPHA_SIZE, 8,
                                           Int32(None)]

            var num_fbc: Int32 = 0
            let configs: UnsafeMutablePointer<GLXFBConfig?> = glXChooseFBConfig(X11Window.xDisplay, X11Window.xScreen, visual_attribs, &num_fbc)!
            let height: GLXFBConfig? = Array(UnsafeBufferPointer(start: configs, count: Int(num_fbc))).first!
            let context_attribs: [Int32] = [GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
                                            GLX_CONTEXT_MINOR_VERSION_ARB, 3,
                                            GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
                                            Int32(None)]
            
            typealias glXCreateContextAttribsARBProc = @convention(c) (_ display: OpaquePointer?, _ config: GLXFBConfig?, _ share_context: GLXContext?, _ direct: Bool, _ attrib_list: UnsafePointer<Int32>) -> OpaquePointer
            let glXCreateContextAttribsARB: glXCreateContextAttribsARBProc = unsafeBitCast(p, to: glXCreateContextAttribsARBProc.self)

            return glXCreateContextAttribsARB(X11Window.xDisplay, height, nil, true, context_attribs)
        }else{
            var vi: XVisualInfo = visualInfo
            return glXCreateContext(X11Window.xDisplay, &vi, nil, GL_TRUE)
        }
    }()

    static let supportsARBCreate: Bool = {
        var major: Int32 = 0
        var minor: Int32 = 0
        glXQueryVersion(X11Window.xDisplay, &major, &minor)
        if major >= 1, minor >= 4, let extensions: UnsafePointer<CChar> = glXQueryExtensionsString(X11Window.xDisplay, X11Window.xScreen) {
            return String(cString: extensions).contains("GLX_ARB_create_context")
        }
        return false
    }()
}

#endif
