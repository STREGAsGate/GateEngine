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

    @_transparent
    func keysymFromEvent(_ event: XKeyEvent) -> KeySym {
        var event: XKeyEvent = event
        var keysym: KeySym = 0
        Xutf8LookupString(self.xic, &event, nil, 0, &keysym, nil)
        return keysym
    }
    
    func keyFromEvent(_ event: XKeyEvent) -> KeyboardKey {
        var key: KeyboardKey?

        switch Int32(event.keycode) {
        case 9://# Esc
            key = .escape
        case 21:
            key = .character("=", .numberPad)
        case 67...76://# F1 - F10
            key = .function(Int(event.keycode - 66))
        case 95:
            key = .function(11)
        case 96:
            key = .function(12)
        case 111://# PrintScrn
            key = .printScreen
        case 78://# Scroll Lock
            key = .scrollLock
        case 110://# Pause
            key = .pauseBreak
        case 49://# `
            key = .character("`", .standard)
        case 10...18://# 1 - 9
            key = .character(Character("\(Int(event.keycode - 9))"), .standard)
        case 19://# 0
            key = .character("0", .standard)
        case 20://# -
            key = .character("-", .standard)
        case 21://# =
            key = .character("=", .standard)
        case 22://# Backspace
            key = .backspace
        case 106://# Insert
            key = .insert
        case 97://# Home
            key = .home
        case 99://# Page Up
            key = .pageUp
        case 77://# Num Lock
            key = .numLock
        case 112://# KP /
            key = .character("/", .numberPad)
        case 63://# KP *
            key = .character("*", .numberPad)
        case 82://# KP -
            key = .character("-", .numberPad)
        case 23://# Tab
            key = .tab
        case 24://# Q
            key = .character("q", .standard)
        case 25://# W
            key = .character("w", .standard)
        case 26://# E
            key = .character("e", .standard)
        case 27://# R
            key = .character("r", .standard)
        case 28://# T
            key = .character("t", .standard)
        case 29://# Y
            key = .character("y", .standard)
        case 30://# U
            key = .character("u", .standard)
        case 31://# I
            key = .character("i", .standard)
        case 32://# O
            key = .character("o", .standard)
        case 33://# P
            key = .character("p", .standard)
        case 34://# [
            key = .character("[", .standard)
        case 35://# ]
            key = .character("]", .standard)
        case 36://# key =
            key = .enter(.standard)
        case 107://# Delete
            key = .delete
        case 103://# End
            key = .end
        case 105://# Page Down
            key = .pageDown
        case 79://# KP 7
            key = .character("7", .numberPad)
        case 80://# KP 8
            key = .character("8", .numberPad)
        case 81://# KP 9
            key = .character("9", .numberPad)
        case 86://# KP +
            key = .character("+", .numberPad)
        case 66://# Caps Lock
            key = .capsLock
        case 38://# A
            key = .character("a", .standard)
        case 39://# S
            key = .character("s", .standard)
        case 40://# D
            key = .character("d", .standard)
        case 41://# F
            key = .character("f", .standard)
        case 42://# G
            key = .character("g", .standard)
        case 43://# H
            key = .character("h", .standard)
        case 44://# J
            key = .character("j", .standard)
        case 45://# K
            key = .character("k", .standard)
        case 46://# L
            key = .character("l", .standard)
        case 47://# ;
            key = .character(";", .standard)
        case 48://# '
            key = .character("'", .standard)
        case 83://# KP 4
            key = .character("4", .numberPad)
        case 84://# KP 5
            key = .character("5", .numberPad)
        case 85://# KP 6
            key = .character("6", .numberPad)
        case 50://# Shift Left
            key = .shift(.leftSide)
        #if GATEENGINE_DEBUG_HID
        case 94://# International
            break
        #endif
        case 52://# Z
            key = .character("z", .standard)
        case 53://# X
            key = .character("x", .standard)
        case 54://# C
            key = .character("c", .standard)
        case 55://# V
            key = .character("v", .standard)
        case 56://# B
            key = .character("b", .standard)
        case 57://# N
            key = .character("n", .standard)
        case 58://# M
            key = .character("m", .standard)
        case 59://# ,
            key = .character(",", .standard)
        case 60://# .
            key = .character(".", .standard)
        case 61://# /
            key = .character("/", .standard)
        case 62://# Shift Right
            key = .shift(.rightSide)
        case 51://# \
            key = .character("\\", .standard)
        case 87://# KP 1
            key = .character("1", .numberPad)
        case 88://# KP 2
            key = .character("2", .numberPad)
        case 89://# KP 3
            key = .character("3", .numberPad)
        case 108://# KP Enter
            key = .enter(.numberPad)
        case 37://# Ctrl Left
            key = .control(.leftSide)
        case 115://# Logo Left (-> Option)
            key = .host(.leftSide)
        case 64://# Alt Left (-> Command)
            key = .alt(.leftSide)
        case 65://# Space
            key = .space
        case 113://# Alt Right (-> Command)
            key = .alt(.rightSide)
        case 116://# Logo Right (-> Option)
            key = .host(.rightSide)
        case 117://# Menu (-> International)
            key = .contextMenu
        case 109://# Ctrl Right
            key = .control(.rightSide)
        case 90://# KP 0
            key = .character("0", .numberPad)
        case 91://# KP .
            key = .character(".", .numberPad)
        case 98:
            key = .up
        case 100:
            key = .left
        case 102:
            key = .right
        case 104:
            key = .down
        default:
            key = nil
        }

        #if GATEENGINE_DEBUG_HID
        if key == nil {
            Log.warnOnce("Key", event.keycode, characterFromEvent(event) ?? "", "is unhandled!")
        }
        #endif
        if let key: KeyboardKey = key {
            return key
        }
        return .unhandledPlatformKeyCode(Int(event.keycode), characterFromEvent(event))
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
