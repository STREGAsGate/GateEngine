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
        @_transparent
        func isRepeatedKey(_ event: XKeyEvent) -> Bool {
            return false
            return previousKeyEvent.type == KeyRelease &&
                   previousKeyEvent.time == event.time &&
                   previousKeyEvent.keycode == event.keycode
        }
        switch event.type {
        case Expose:
            glXMakeCurrent(xDisplay, xWindow, glxContext)
            glXSwapBuffers(xDisplay, xWindow)
            XFlush(xDisplay)
        case KeyPress:
            let event: XKeyEvent = event.xkey
            
            // guard event.same_screen != 0 else {return}
            previousKeyEvent = event
            let key: KeyboardKey = keyFromEvent(event)
            let modifiers: KeyboardModifierMask = modifierKeyFromState(Int32(event.state))
            Log.info("KeyPress", event.keycode, key, modifiers)
            _ = window.delegate?.keyboardDidhandle(key: key,
                                                   character: characterFromEvent(event),
                                                   modifiers: modifiers,
                                                   isRepeat: isRepeatedKey(event),
                                                   event: .keyDown)
        case KeyRelease:
            let event: XKeyEvent = event.xkey
            // guard event.same_screen != 0 else {return}
            previousKeyEvent = event
            let key: KeyboardKey = keyFromEvent(event)
            let modifiers: KeyboardModifierMask = modifierKeyFromState(Int32(event.state))
            Log.info("KeyRelease", event.keycode, key, modifiers)
            _ = window.delegate?.keyboardDidhandle(key: key,
                                                   character: characterFromEvent(event),
                                                   modifiers: modifiers,
                                                   isRepeat: isRepeatedKey(event),
                                                   event: .keyUp)
        case EnterNotify:
            let event: XMotionEvent = event.xmotion
            guard event.same_screen != 0 else {return}
            window.delegate?.mouseChange(event: .entered, 
                                         position: Position2(Float(event.x), Float(event.y)), 
                                         delta: .zero, 
                                         window: self.window)
        case MotionNotify/*, ButtonMotionMask*/:
            let event: XMotionEvent = event.xmotion
            guard event.same_screen != 0 else {return}
            window.delegate?.mouseChange(event: .moved, 
                                         position: Position2(Float(event.x), Float(event.y)), 
                                         delta: .zero, 
                                         window: self.window)
        case LeaveNotify:
            let event: XMotionEvent = event.xmotion
            guard event.same_screen != 0 else {return}
            window.delegate?.mouseChange(event: .exited, 
                                         position: Position2(Float(event.x), Float(event.y)), 
                                         delta: .zero, 
                                         window: self.window)
        case ButtonPress:
            let event: XButtonEvent = event.xbutton
            guard event.same_screen != 0 else {return}
            let button: MouseButton = mouseButtonFromEvent(event)
            window.delegate?.mouseClick(event: .buttonDown, 
                                        button: button, 
                                        count: nil,
                                        position: Position2(Float(event.x), Float(event.y)), 
                                        delta: .zero, 
                                        window: self.window)
        case ButtonRelease:
            let event: XButtonEvent = event.xbutton
            guard event.same_screen != 0 else {return}
            let button: MouseButton = mouseButtonFromEvent(event)
            window.delegate?.mouseClick(event: .buttonUp, 
                                        button: button, 
                                        count: nil,
                                        position: Position2(Float(event.x), Float(event.y)), 
                                        delta: .zero, 
                                        window: self.window)
        default:
            Log.warn("Unhandled Event", event.type)
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
        let db: XrmDatabase? = XrmGetStringDatabase(resourceString)
        var value: XrmValue = XrmValue()
        var type: UnsafeMutablePointer<CChar>? = nil
        var dpi: Double = 0.0

        if let cResourceString: UnsafeMutablePointer<CChar> = resourceString {
            let resourceString: String = String(cString: cResourceString)
            print("Entire DB:", resourceString)
            if (XrmGetResource(db, "Xft.dpi", "String", &type, &value) == True) {
                if let addr: XPointer = value.addr {
                    dpi = atof(addr)
                }
            }
        }
        Log.info("X11 DPI:", dpi)
        return Float(dpi) 
    }

    func setMouseHidden(_ hidden: Bool) {
    
    }

    func setMousePosition(_ position: Position2) {
    
    }

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

    @inline(__always)
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
    
    @inline(__always)
    func characterFromEvent(_ event: XKeyEvent) -> Character? {
        var status: Int32 = 0
        var event: XKeyEvent = event
        var data: [CChar] = Array(repeating: 0, count: 32)
        Xutf8LookupString(self.xic, &event, &data, Int32(data.count - 1), nil, &status)
        
        if status == XLookupBoth {
            let character: String = String(cString: data)
            if character.isEmpty == false {
                return character.first
            }
        }
        return nil
    }

    let keyLookup: [KeyboardKey] = {
        let kbdDesc = XkbGetKeyboard(xDisplay, UInt32(XkbAllComponentsMask), UInt32(XkbUseCoreKbd))!.pointee
        var keys: [KeyboardKey] = Array(repeating: .unhandledPlatformKeyCode(nil, nil), count: Int(kbdDesc.max_key_code) + 1)
        
        for keyCode in Int(kbdDesc.min_key_code) ... Int(kbdDesc.max_key_code) {
            let _name = kbdDesc.names.pointee.keys[keyCode].name
            let name: String = String(cString: [_name.0, _name.1, _name.2, _name.3, 0])
            switch name {
            case "ESC":
                keys[keyCode] = .escape
            case "FK01":
                keys[keyCode] = .function(1)
            case "FK02":
                keys[keyCode] = .function(2)
            case "FK03":
                keys[keyCode] = .function(3)
            case "FK04":
                keys[keyCode] = .function(4)
            case "FK05":
                keys[keyCode] = .function(5)
            case "FK06":
                keys[keyCode] = .function(6)
            case "FK07":
                keys[keyCode] = .function(7)
            case "FK08":
                keys[keyCode] = .function(8)
            case "FK09":
                keys[keyCode] = .function(9)
            case "FK10":
                keys[keyCode] = .function(10)
            case "FK11":
                keys[keyCode] = .function(11)
            case "FK12":
                keys[keyCode] = .function(12)
            case "FK13":
                keys[keyCode] = .function(13)
            case "FK14":
                keys[keyCode] = .function(14)
            case "FK15":
                keys[keyCode] = .function(15)
            case "FK16":
                keys[keyCode] = .function(16)
            case "FK17":
                keys[keyCode] = .function(17)
            case "FK18":
                keys[keyCode] = .function(18)
            case "FK19":
                keys[keyCode] = .function(19)
            case "FK20":
                keys[keyCode] = .function(20)
            case "FK21":
                keys[keyCode] = .function(21)
            case "FK22":
                keys[keyCode] = .function(22)
            case "FK23":
                keys[keyCode] = .function(23)
            case "FK24":
                keys[keyCode] = .function(24)
            case "PRSC":
                keys[keyCode] = .printScreen
            case "SCLK":
                keys[keyCode] = .scrollLock
            case "PAUS":
                keys[keyCode] = .pauseBreak
            case "TLDE":
                keys[keyCode] = .character("`", .standard)
            case "AE01":
                keys[keyCode] = .character("1", .standard)
            case "AE02":
                keys[keyCode] = .character("2", .standard)
            case "AE03":
                keys[keyCode] = .character("3", .standard)
            case "AE04":
                keys[keyCode] = .character("4", .standard)
            case "AE05":
                keys[keyCode] = .character("5", .standard)
            case "AE06":
                keys[keyCode] = .character("6", .standard)
            case "AE07":
                keys[keyCode] = .character("7", .standard)
            case "AE08":
                keys[keyCode] = .character("8", .standard)
            case "AE09":
                keys[keyCode] = .character("9", .standard)
            case "AE10":
                keys[keyCode] = .character("0", .standard)
            case "AE11":
                keys[keyCode] = .character("-", .standard)
            case "AE12":
                keys[keyCode] = .character("=", .standard)
            case "BKSP":
                keys[keyCode] = .backspace
            case "INS":
                keys[keyCode] = .insert
            case "HOME":
                keys[keyCode] = .home
            case "PGUP":
                keys[keyCode] = .pageUp
            case "NMLK":
                keys[keyCode] = .numLock
            case "KPDV":
                keys[keyCode] = .character("/", .numberPad)
            case "KPMU":
                keys[keyCode] = .character("*", .numberPad)
            case "KPSU":
                keys[keyCode] = .character("-", .numberPad)
            case "TAB":
                keys[keyCode] = .tab
            case "AD01":
                keys[keyCode] = .character("q", .standard)
            case "AD03":
                keys[keyCode] = .character("w", .standard)
            case "AD04":
                keys[keyCode] = .character("e", .standard)
            case "AD05":
                keys[keyCode] = .character("r", .standard)
            case "AD06":
                keys[keyCode] = .character("t", .standard)
            case "AD07":
                keys[keyCode] = .character("y", .standard)
            case "AD08":
                keys[keyCode] = .character("u", .standard)
            case "AD09":
                keys[keyCode] = .character("i", .standard)
            case "AD10":
                keys[keyCode] = .character("o", .standard)
            case "AD11":
                keys[keyCode] = .character("p", .standard)
            case "AD12":
                keys[keyCode] = .character("[", .standard)
            case "AD13":
                keys[keyCode] = .character("]", .standard)
            case "BKSL":
                keys[keyCode] = .character("\\", .standard)
            case "DELE":
                keys[keyCode] = .delete
            case "END":
                keys[keyCode] = .end
            case "PGDN":
                keys[keyCode] = .pageDown
            case "KP7":
                keys[keyCode] = .character("7", .numberPad)
            case "KP8":
                keys[keyCode] = .character("8", .numberPad)
            case "KP9":
                keys[keyCode] = .character("9", .numberPad)
            case "KPAD":
                keys[keyCode] = .character("+", .numberPad)
            case "CAPS":
                keys[keyCode] = .capsLock
            case "AC01":
                keys[keyCode] = .character("a", .standard)
            case "AC02":
                keys[keyCode] = .character("s", .standard)
            case "AC03":
                keys[keyCode] = .character("d", .standard)
            case "AC04":
                keys[keyCode] = .character("f", .standard)
            case "AC05":
                keys[keyCode] = .character("g", .standard)
            case "AC06":
                keys[keyCode] = .character("h", .standard)
            case "AC07":
                keys[keyCode] = .character("j", .standard)
            case "AC08":
                keys[keyCode] = .character("k", .standard)
            case "AC09":
                keys[keyCode] = .character("l", .standard)
            case "AC10":
                keys[keyCode] = .character(";", .standard)
            case "AC11":
                keys[keyCode] = .character("'", .standard)
            case "RTRN":
                keys[keyCode] = .enter(.standard)
            case "KP4":
                keys[keyCode] = .character("4", .numberPad)
            case "KP5":
                keys[keyCode] = .character("5", .numberPad)
            case "KP6":
                keys[keyCode] = .character("6", .numberPad)
            case "LFSH":
                keys[keyCode] = .shift(.left)
            case "AB01":
                keys[keyCode] = .character("z", .standard)
            case "AB02":
                keys[keyCode] = .character("x", .standard)
            case "AB03":
                keys[keyCode] = .character("c", .standard)
            case "AB04":
                keys[keyCode] = .character("v", .standard)
            case "AB05":
                keys[keyCode] = .character("b", .standard)
            case "AB06":
                keys[keyCode] = .character("n", .standard)
            case "AB07":
                keys[keyCode] = .character("m", .standard)
            case "AB08":
                keys[keyCode] = .character(",", .standard)
            case "AB09":
                keys[keyCode] = .character(".", .standard)
            case "AB10":
                keys[keyCode] = .character("/", .standard)
            case "RTSH":
                keys[keyCode] = .shift(.right)
            case "UP":
                keys[keyCode] = .up
            case "KP01":
                keys[keyCode] = .character("1", .numberPad)
            case "KP02":
                keys[keyCode] = .character("2", .numberPad)
            case "KP03":
                keys[keyCode] = .character("3", .numberPad)
            case "KPEN":
                keys[keyCode] = .enter(.numberPad)
            case "LCTL":
                keys[keyCode] = .control(.left)
            case "LALT":
                keys[keyCode] = .alt(.left)
            case "SPCE":
                keys[keyCode] = .space
            case "RALT":
                keys[keyCode] = .alt(.right)
            case "RCTL":
                keys[keyCode] = .control(.right)
            case "LEFT":
                keys[keyCode] = .left
            case "DOWN":
                keys[keyCode] = .down
            case "RIGHT":
                keys[keyCode] = .right
            case "KP0":
                keys[keyCode] = .character("0", .numberPad)
            case "KPDL":
                keys[keyCode] = .character(".", .numberPad)
            default:
                Log.info("Unhandled key", keyCode, name)
                keys[keyCode] = .unhandledPlatformKeyCode(keyCode, nil)
            }
        }
        return keys
    }()

    func keyFromEvent(_ event: XKeyEvent) -> KeyboardKey {
        return keyLookup[Int(event.keycode)]
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
