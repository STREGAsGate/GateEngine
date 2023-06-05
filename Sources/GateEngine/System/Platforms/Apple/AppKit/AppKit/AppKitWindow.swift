/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)

import Foundation
import GameMath
import AppKit
import MetalKit

final class AppKitWindow: WindowBacking {
    weak var window: Window!
    let nsWindowController: NSWindowController
    let style: WindowStyle
    let identifier: String
    
    var state: Window.State = .hidden
    
    required init(identifier: String, style: WindowStyle, window: Window) {
        self.window = window
        self.style = style
        self.identifier = identifier
        
        let styleMask: NSWindow.StyleMask
        switch style {
        case .bestForGames:
            styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        case .system:
            styleMask = [.titled, .closable, .miniaturizable, .resizable]
        }
        
        let size = Size2(640, 480)
        
        let nsWindow = UGNSWindow(window: window,
                                  contentRect: NSMakeRect(0, 0, CGFloat(size.width), CGFloat(size.height)),
                                  styleMask: styleMask,
                                  backing: .buffered,
                                  defer: false)
        self.nsWindowController = NSWindowController(window: nsWindow)
        nsWindow.isReleasedWhenClosed = false
        if style == .bestForGames {
            nsWindow.titlebarAppearsTransparent = true
            nsWindow.titleVisibility = .hidden
        }
        
        nsWindow.contentViewController = AppKitViewController(window: self)

        nsWindow.center()
        nsWindow.setFrameAutosaveName(identifier)
        if #available(macOS 10.12, *) {
            nsWindow.tabbingMode = .disallowed
        }
        
        nsWindow.title = identifier
        
        self.setupNotifications()
    }
        
    private func restoreSizeAndPosition(ofWindow nsWindow: NSWindow) {
        //restore size and relative position
        nsWindow.setFrameUsingName(identifier)
        
        //restore screen position
        let screenID = CGDirectDisplayID(UserDefaults.standard.integer(forKey: "ScreenID_\(identifier)"))
        for screen in NSScreen.screens {
            if screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID == screenID {
                var frame = nsWindow.frame
                frame.origin.x += screen.frame.origin.x
                frame.origin.y += screen.frame.origin.y
                nsWindow.setFrame(frame, display: true)
                break
            }
        }

        // Enter full screen if no preference, otherwise restore user preference
        if UserDefaults.standard.value(forKey: "\(identifier)-WasFullScreen") == nil || UserDefaults.standard.bool(forKey: "\(identifier)-WasFullScreen") {
            nsWindowController.window?.toggleFullScreen(nil)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillMiniaturize(_:)), name: NSWindow.willMiniaturizeNotification, object: nsWindowController.window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidDeminiaturize(_:)), name: NSWindow.didDeminiaturizeNotification, object: nsWindowController.window)
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.willCloseNotification, object: nsWindowController.window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidChangeScreen(_:)), name: NSWindow.didChangeScreenNotification, object: nsWindowController.window)
    }
    
    @MainActor @objc func windowDidDeminiaturize(_ notification: Notification) {
        self.state = .shown
    }

    @MainActor @objc func windowWillMiniaturize(_ notification: Notification) {
        self.state = .hidden
    }
    
    @MainActor @objc func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.set(nsWindowController.window?.styleMask.contains(.fullScreen) == true, forKey: "\(identifier)-WasFullScreen")
        UserDefaults.standard.synchronize()
        self.state = .destroyed
        Game.shared.windowManager.removeWindow(self.identifier)
    }
    
    @MainActor @objc func windowDidChangeScreen(_ notification: Notification) {
        if let screenID = self.nsWindowController.window?.screen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
            UserDefaults.standard.set(screenID, forKey: "ScreenID_\(identifier)")
            UserDefaults.standard.synchronize()
        }
        
        if MetalRenderer.isSupported {
            // Update to the best GPU
            if #available(macOS 10.15, *) {
                if let metalView = nsWindowController.contentViewController?.view as? MTKView {
                    if let device = metalView.preferredDevice {
                        Game.shared.renderer.device = device
                        metalView.device = device
                    }
                }
            }else if let screenID = self.nsWindowController.window?.screen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
                if let device = CGDirectDisplayCopyCurrentMetalDevice(screenID) {
                    Game.shared.renderer.device = device
                    (nsWindowController.contentViewController!.view as! MTKView).device = device
                }
            }
        }
    }
    
    lazy var displayLink: CVDisplayLink = {
        var displayLink: CVDisplayLink?
        // Create a display link capable of being used with all active displays
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        
        func displayLinkOutputCallback(_ displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            return unsafeBitCast(displayLinkContext, to: AppKitWindow.self).getFrameForTime(now: inNow.pointee, outputTime: inOutputTime.pointee)
        }
        
        // Set the renderer output callback function
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(mutating: Unmanaged.passUnretained(self).toOpaque()))
                
        return displayLink!
    }()
    
    func getFrameForTime(now: CVTimeStamp, outputTime: CVTimeStamp) -> CVReturn {
        DispatchQueue.main.sync {
            if let view = self.nsWindowController.window?.contentViewController?.view {
                view.setNeedsDisplay(view.bounds)
            }
        }
        return kCVReturnSuccess
    }
    
    @MainActor func show() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(30)) {
            self.restoreSizeAndPosition(ofWindow: self.nsWindowController.window!)
            if UserDefaults.standard.bool(forKey: "\(self.identifier)-WasFullScreen") {
                self.nsWindowController.window!.toggleFullScreen(NSApp)
            }
        }
        
        nsWindowController.showWindow(NSApp)
        self.nsWindowController.window?.makeKeyAndOrderFront(nil)
        
        if CVDisplayLinkIsRunning(self.displayLink) == false {
            CVDisplayLinkStart(self.displayLink)
        }
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        self.state = .shown
    }
    
    @inline(__always)
    var backingSize: Size2 {
        guard let layer = self.nsWindowController.window?.contentView?.layer ?? self.nsWindowController.contentViewController?.view.layer else {fatalError()}
        return Size2(layer.bounds.size) * Float(layer.contentsScale)
    }
    
    @inline(__always)
    var backingScaleFactor: Float {
        guard let layer = self.nsWindowController.window?.contentView?.layer ?? self.nsWindowController.contentViewController?.view.layer else {fatalError()}
        return Float(layer.contentsScale)
    }
    
    public func close() {
        if CVDisplayLinkIsRunning(self.displayLink) {
            CVDisplayLinkStop(self.displayLink)
        }
        nsWindowController.close()
        self.state = .destroyed
    }

    @MainActor func createWindowRenderTargetBackend() -> RenderTargetBackend {
        #if GATEENGINE_FORCE_OPNEGL_APPLE
            return OpenGLRenderTarget(windowBacking: self)
        #else
        #if canImport(GLKit) && !targetEnvironment(macCatalyst)
        if MetalRenderer.isSupported == false {
            return OpenGLRenderTarget(windowBacking: self)
        }
        #endif
        return MetalRenderTarget(windowBacking: self)
        #endif
    }
    
    deinit {
        if CVDisplayLinkIsRunning(self.displayLink) {
            CVDisplayLinkStop(self.displayLink)
        }
    }
}


extension AppKitWindow {
    var title: String? {
        get {
            if let title = nsWindowController.window?.title, title.isEmpty == false {
                return title
            }
            return nil
        }
        set {
            nsWindowController.window?.title = newValue ?? ""
        }
    }
    var frame: Rect {
        get {
            if let frame = nsWindowController.window?.frame {
                return Rect(frame)
            }
            return .zero
        }
        set {
            nsWindowController.window?.setFrame(newValue.cgRect, display: false)
        }
    }
    var safeAreaInsets: Insets {
        get {
            if #available(macOS 11.0, *) {
                if let insets = nsWindowController.window?.contentViewController?.view.safeAreaInsets {
                    return Insets(top: Float(insets.top),
                                  leading: Float(insets.left),
                                  bottom: Float(insets.bottom),
                                  trailing: Float(insets.right))
                }
                return .zero
            }else{
                return .zero
            }
        }
    }
    
    func setMouseHidden(_ hidden: Bool) {
        if hidden {
            CGDisplayHideCursor(kCGNullDirectDisplay)
        }else{
            CGDisplayShowCursor(kCGNullDirectDisplay)
        }
    }
    
    func setMousePosition(_ position: Position2) {
        guard let nsWindow = self.nsWindowController.window else {return}
        guard let nsScreen = nsWindow.screen else {return}
        let position = position / Size2(Float(nsWindow.backingScaleFactor))
        var mousePosition: CGPoint = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))

        mousePosition.y = nsWindow.frame.height - mousePosition.y
        mousePosition.x += nsWindow.frame.origin.x
        mousePosition.y += nsWindow.frame.minY
        
        // Adjust for titlebar
        mousePosition.y -= nsWindow.frame.height - nsWindow.frame.size.height
        
        mousePosition.y = nsScreen.frame.height - mousePosition.y
        CGWarpMouseCursorPosition(mousePosition)
    }
}

final class UGNSWindow: AppKit.NSWindow {
    weak var window: Window!

    init(window: Window, contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        self.window = window
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }

    //MARK: - Mouse

    @inline(__always)
    func positionFromEvent(_ event: NSEvent) -> Position2? {
        if let contentView = self.contentView ?? self.contentViewController?.view {
            let cgPoint = contentView.convert(event.locationInWindow, from: nil)
            let position = Position2(cgPoint) * Size2(Float(self.backingScaleFactor))
            return position
        }
        return nil
    }
    
    @inline(__always)
    func deltaPositionFromEvent(_ event: NSEvent) -> Position2 {
        guard event.type == .mouseMoved || event.type == .mouseEntered || event.type == .mouseExited else {return .zero}
        return Position2(Float(event.deltaX), Float(event.deltaY)) * Size2(Float(self.backingScaleFactor))
    }

    @inline(__always)
    func mouseButtonFromEvent(_ event: NSEvent) -> MouseButton {
        switch event.buttonNumber {
        case 0:
            return .button1
        case 1:
            return .button2
        case 2:
            return .button3
        case 3:
            return .button4
        case 4:
            return .button5
        default:
            return .unknown(event.buttonNumber)
        }
    }

    override func mouseDown(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonDown,
                                      button: .button1,
                                      count: event.clickCount,
                                      position: positionFromEvent(event),
                                      delta: deltaPositionFromEvent(event),
                                      window: window)
        }
        super.mouseDown(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonUp,
                                      button: .button1,
                                      count: event.clickCount,
                                      position: positionFromEvent(event),
                                      delta: deltaPositionFromEvent(event),
                                      window: window)
        }
        super.mouseUp(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonDown,
                                      button: .button2,
                                      count: event.clickCount,
                                      position: positionFromEvent(event),
                                      delta: deltaPositionFromEvent(event),
                                      window: window)
        }
        super.rightMouseDown(with: event)
    }

    override func rightMouseUp(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonUp,
                                      button: .button2,
                                      count: event.clickCount,
                                      position: positionFromEvent(event),
                                      delta: deltaPositionFromEvent(event),
                                      window: window)
        }
        super.rightMouseUp(with: event)
    }

    override func otherMouseDown(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            let button: MouseButton = mouseButtonFromEvent(event)
            windowDelegate.mouseClick(event: .buttonDown,
                                      button: button,
                                      count: event.clickCount,
                                      position: positionFromEvent(event),
                                      delta: deltaPositionFromEvent(event),
                                      window: window)
        }
        super.otherMouseDown(with: event)
    }

    override func otherMouseUp(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            let button: MouseButton = mouseButtonFromEvent(event)
            windowDelegate.mouseClick(event: .buttonUp,
                                      button: button,
                                      count: event.clickCount,
                                      position: positionFromEvent(event),
                                      delta: deltaPositionFromEvent(event),
                                      window: window)
        }
        super.otherMouseUp(with: event)
    }

    override func mouseEntered(with event: NSEvent) {
        if let windowDelegate = window.delegate, let position = positionFromEvent(event) {
            windowDelegate.mouseChange(event: .entered,
                                       position: position,
                                       delta: deltaPositionFromEvent(event),
                                       window: window)
        }
        super.mouseEntered(with: event)
    }
    override func mouseMoved(with event: NSEvent) {
        if let windowDelegate = window.delegate, let position = positionFromEvent(event) {
            windowDelegate.mouseChange(event: .moved,
                                       position: position,
                                       delta: deltaPositionFromEvent(event),
                                       window: window)
        }
        super.mouseMoved(with: event)
    }
    override func mouseDragged(with event: NSEvent) {
        if let windowDelegate = window.delegate, let position = positionFromEvent(event) {
            windowDelegate.mouseChange(event: .moved,
                                       position: position,
                                       delta: deltaPositionFromEvent(event),
                                       window: window)
        }
        super.mouseDown(with: event)
    }
    override func rightMouseDragged(with event: NSEvent) {
        if let windowDelegate = window.delegate, let position = positionFromEvent(event) {
            windowDelegate.mouseChange(event: .moved,
                                       position: position,
                                       delta: deltaPositionFromEvent(event),
                                       window: window)
        }
        super.rightMouseDragged(with: event)
    }
    override func otherMouseDragged(with event: NSEvent) {
        if let windowDelegate = window.delegate, let position = positionFromEvent(event) {
            windowDelegate.mouseChange(event: .moved,
                                       position: position,
                                       delta: deltaPositionFromEvent(event),
                                       window: window)
        }
        super.otherMouseDragged(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        if let windowDelegate = window.delegate, let position = positionFromEvent(event) {
            windowDelegate.mouseChange(event: .exited,
                                       position: position,
                                       delta: deltaPositionFromEvent(event),
                                       window: window)
        }
        super.mouseExited(with: event)
    }

    //MARK: - Touches
    private var touchesIDs: [ObjectIdentifier:UUID] = [:]
    private func type(for touch: NSTouch) -> TouchKind {
        switch touch.type {
        case .direct:
            return .physical
        default:
            return .unknown
        }
    }

    func locationOfTouch(_ touch: NSTouch, from event: NSEvent) -> Position2? {
        switch touch.type {
        case .direct:
            let cgPoint = touch.location(in: nil)
            return Position2(Float(cgPoint.x), Float(cgPoint.y))
        case .indirect:
            let cgPoint = touch.normalizedPosition
            return Position2(Float(cgPoint.x), Float(1 - cgPoint.y))
        default:
            return nil
        }
    }

    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)

        if let windowDelegate = window.delegate {
            let touches = event.touches(matching: .began, in: nil)

            for touch in touches {
                let id = UUID()
                touchesIDs[ObjectIdentifier(touch.identity)] = id
                let type = type(for: touch)
                if let position = locationOfTouch(touch, from: event) {
                    switch touch.type {
                    case .direct:
                        windowDelegate.screenTouchChange(id: id, kind: type, event: .began, position: position)
                    case .indirect:
                        if let device = touch.device as? AnyObject {
                            windowDelegate.surfaceTouchChange(id: id, event: .began, surfaceID: ObjectIdentifier(device), normalizedPosition: position)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    override func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)
        if let windowDelegate = window.delegate {
            let touches = event.touches(matching: .moved, in: nil)

            for touch in touches {
                guard let id = touchesIDs[ObjectIdentifier(touch.identity)] else {continue}
                let type = type(for: touch)
                if let position = locationOfTouch(touch, from: event) {
                    switch touch.type {
                    case .direct:
                        windowDelegate.screenTouchChange(id: id, kind: type, event: .moved, position: position)
                    case .indirect:
                        if let device = touch.device as? AnyObject {
                            windowDelegate.surfaceTouchChange(id: id, event: .moved, surfaceID: ObjectIdentifier(device), normalizedPosition: position)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)

        if let windowDelegate = window.delegate {
            let touches = event.touches(matching: .ended, in: nil)

            for touch in touches {
                guard let id = touchesIDs[ObjectIdentifier(touch.identity)] else {continue}
                let type = type(for: touch)
                if let position = locationOfTouch(touch, from: event) {
                    switch touch.type {
                    case .direct:
                        windowDelegate.screenTouchChange(id: id, kind: type, event: .ended, position: position)
                    case .indirect:
                        if let device = touch.device as? AnyObject {
                            windowDelegate.surfaceTouchChange(id: id, event: .ended, surfaceID: ObjectIdentifier(device), normalizedPosition: position)
                        }
                    default:
                        break
                    }
                }
                touchesIDs[ObjectIdentifier(touch)] = nil
            }
        }
    }

    override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)

        if let windowDelegate = window.delegate {
            let touches = event.touches(matching: .cancelled, in: nil)

            for touch in touches {
                guard let id = touchesIDs[ObjectIdentifier(touch.identity)] else {continue}
                let type = type(for: touch)
                if let position = locationOfTouch(touch, from: event) {
                    switch touch.type {
                    case .direct:
                        windowDelegate.screenTouchChange(id: id, kind: type, event: .canceled, position: position)
                    case .indirect:
                        if let device = touch.device as? AnyObject {
                            windowDelegate.surfaceTouchChange(id: id, event: .canceled, surfaceID: ObjectIdentifier(device), normalizedPosition: position)
                        }
                    default:
                        break
                    }
                }
                touchesIDs[ObjectIdentifier(touch)] = nil
            }
        }
    }

    // MARK: - Keyboard
    func keyFromEvent(_ event: NSEvent) -> KeyboardKey {
        let keyCode = Int(event.keyCode)
        switch keyCode {
        case 0:// A
            return .character("a", .fromMain)
        case 1:// S
            return .character("s", .fromMain)
        case 2:// D
            return .character("d", .fromMain)
        case 3:// F
            return .character("f", .fromMain)
        case 4:// H
            return .character("h", .fromMain)
        case 5:// G
            return .character("g", .fromMain)
        case 6:// Z
            return .character("z", .fromMain)
        case 7:// X
            return .character("x", .fromMain)
        case 8:// C
            return .character("c", .fromMain)
        case 9:// V
            return .character("v", .fromMain)
        case 10:// ??
            break;
        case 11:// B
            return .character("b", .fromMain)
        case 12:// Q
            return .character("q", .fromMain)
        case 13:// W
            return .character("w", .fromMain)
        case 14:// E
            return .character("e", .fromMain)
        case 15:// R
            return .character("r", .fromMain)
        case 16:// Y
            return .character("y", .fromMain)
        case 17:// T
            return .character("t", .fromMain)
        case 18:// 1
            return .character("1", .fromMain)
        case 19:// 2
            return .character("2", .fromMain)
        case 20:// 3
            return .character("3", .fromMain)
        case 21:// 4
            return .character("4", .fromMain)
        case 22:// 6
            return .character("6", .fromMain)
        case 23:// 5
            return .character("5", .fromMain)
        case 24:// =
            return .character("=", .fromMain)
        case 25:// 9
            return .character("9", .fromMain)
        case 26:// 7
            return .character("7", .fromMain)
        case 27:// -
            return .character("-", .fromMain)
        case 28:// 8
            return .character("8", .fromMain)
        case 29:// 0
            return .character("0", .fromMain)
        case 30:// ]
            return .character("]", .fromMain)
        case 31:// O
            return .character("o", .fromMain)
        case 32:// U
            return .character("u", .fromMain)
        case 33:// [
            return .character("[", .fromMain)
        case 34:// I
            return .character("i", .fromMain)
        case 35:// P
            return .character("p", .fromMain)
        case 36:// return
            return .enter(.fromMain)
        case 37:// L
            return .character("l", .fromMain)
        case 38:// J
            return .character("j", .fromMain)
        case 39:// '
            return .character("'", .fromMain)
        case 40:// K
            return .character("k", .fromMain)
        case 41:// ;
            return .character(";", .fromMain)
        case 42:// \
            return .character("\\", .fromMain)
        case 43:// ,
            return .character(",", .fromMain)
        case 44:// /
            return .character("/", .fromMain)
        case 45:// N
            return .character("n", .fromMain)
        case 46:// M
            return .character("m", .fromMain)
        case 47:// .
            return .character(".", .fromMain)
        case 48:// \t
            return .tab
        case 49:// space
            return .space
        case 50:// `
            return .character("`", .fromMain)
        case 51:// delete
            return .backspace
        case 52:// ??
            break
        case 53:// esc
            return .escape
        case 54:// r-cmd
            return .host(.right)
        case 55:// l-cmd
            return .host(.left)
        case 56:// l-shift
            return .shift(.left)
        case 57:// capslock
            return .capsLock
        case 58:// l-alt
            return .alt(.left)
        case 59:// l-ctrl
            return .control(.left)
        case 60:// r-shift
            return .shift(.right)
        case 61:// r-alt
            return .alt(.right)
        case 62:// r-ctrl
            return .control(.right)
        case 63:// Fn
            return .fn
        case 64:// F17
            return .function(17)
        case 65:// .
            return .character(".", .fromNumberPad)
        case 66:// ??
            break
        case 67:// *
            return .character("*", .fromNumberPad)
        case 68:// ??
            break
        case 69:// +
            return .character("+", .fromNumberPad)
        case 70:// ??
            break
        case 71:// clear/numlock
            return .clear
        case 72...74:// ??
            break
        case 75:// /
            return .character("/", .fromNumberPad)
        case 76:// enter
            return .enter(.fromNumberPad)
        case 77:// ??
            break
        case 78:// -
            return .character("-", .fromNumberPad)
        case 79:// F18
            return .function(18)
        case 80:// F19
            return .function(19)
        case 81:// =
            return .character("=", .fromNumberPad)
        case 82:// 0
            return .character("0", .fromNumberPad)
        case 83:// 1
            return .character("1", .fromNumberPad)
        case 84:// 2
            return .character("2", .fromNumberPad)
        case 85:// 3
            return .character("3", .fromNumberPad)
        case 86:// 4
            return .character("4", .fromNumberPad)
        case 87:// 5
            return .character("5", .fromNumberPad)
        case 88:// 6
            return .character("6", .fromNumberPad)
        case 89:// 7
            return .character("7", .fromNumberPad)
        case 90:// F20
            return .function(20)
        case 91:// 8
            return .character("8", .fromNumberPad)
        case 92:// 9
            return .character("9", .fromNumberPad)
        case 93...95:// ??
            break
        case 96:// F5
            return .function(5)
        case 97:// F6
            return .function(6)
        case 98:// F7
            return .function(7)
        case 99:// F3
            return .function(3)
        case 100:// F8
            return .function(8)
        case 101:// F9
            return .function(9)
        case 102:// ??
            break
        case 103:// F11
            return .function(11)
        case 104:// ??
            break
        case 105:// F13
            return .function(13)
        case 106:// F16
            return .function(16)
        case 107:// F14
            return .function(14)
        case 108:// ??
            break
        case 109:// F10
            return .function(10)
        case 110:// Applications
            return .contextMenu
        case 111:// F12
            return .function(12)
        case 112:// ??
            break
        case 113:// F15
            return .function(15)
        case 114:// Insert
            return .insert
        case 115:// home
            return .home
        case 116:// page up
            return .pageUp
        case 117:// delete
            return .delete
        case 118:// F4
            return .function(4)
        case 119:// end
            return .end
        case 120:// F2
            return .function(2)
        case 121:// page down
            return .pageDown
        case 122:// F1
            return .function(1)
        case 123:// left
            return .left
        case 124:// right
            return .right
        case 125:// down
            return .down
        case 126:// up
            return .up
        default:
            break
        }

        Log.warn("Key Code \(event.keyCode) is unhandled!")

        return .unhandledPlatformKeyCode(Int(event.keyCode), nil)
    }

    func modifiersFromEvent(_ event: NSEvent) -> KeyboardModifierMask {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var modifiers: KeyboardModifierMask = []
        if flags.contains(.command) {
            modifiers.insert(.host)
        }
        if flags.contains(.control) {
            modifiers.insert(.control)
        }
        if flags.contains(.option) {
            modifiers.insert(.alt)
        }
        if flags.contains(.shift) {
            modifiers.insert(.shift)
        }
        if flags.contains(.capsLock) {
            modifiers.insert(.capsLock)
        }
        if flags.contains(.function) {
            modifiers.insert(.function)
        }
        return modifiers
    }

    override func keyDown(with event: NSEvent) {
        var forward: Bool = true
        if let windowDelegate = window.delegate {
            let key = keyFromEvent(event)
            let modifiers = modifiersFromEvent(event)
            if windowDelegate.keyboardDidhandle(key: key,
                                                character: event.characters?.first,
                                                modifiers: modifiers,
                                                isRepeat: event.isARepeat,
                                                event: .keyDown) {
                forward = false
            }
        }
        if forward {
            super.keyDown(with: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        guard event.isARepeat == false else {return}
        var forward: Bool = true
        if let windowDelegate = window.delegate {
            let key = keyFromEvent(event)
            let modifiers = modifiersFromEvent(event)
            if windowDelegate.keyboardDidhandle(key: key,
                                                character: event.characters?.first,
                                                modifiers: modifiers,
                                                isRepeat: event.isARepeat,
                                                event: .keyUp) {
                forward = false
            }
        }
        if forward {
            super.keyUp(with: event)
        }
    }
    
    override func flagsChanged(with event: NSEvent) {
        var forward: Bool = true
        if let windowDelegate = window.delegate {
            let keyCode = Int(event.keyCode)
            switch keyCode {
            case 56, 60:
                let key: KeyboardKey = keyCode == 56 ? .shift(.left) : .shift(.right)
                forward = windowDelegate.keyboardDidhandle(key: key,
                                                           character: nil,
                                                           modifiers: [],
                                                           isRepeat: false,
                                                           event: .toggle) == false
            case 55, 54:
                let key: KeyboardKey = keyCode == 55 ? .host(.left) : .host(.right)
                forward = windowDelegate.keyboardDidhandle(key: key,
                                                           character: nil,
                                                           modifiers: [],
                                                           isRepeat: false,
                                                           event: .toggle) == false
            case 59, 62:
                let key: KeyboardKey = keyCode == 59 ? .control(.left) : .control(.right)
                forward = windowDelegate.keyboardDidhandle(key: key,
                                                           character: nil,
                                                           modifiers: [],
                                                           isRepeat: false,
                                                           event: .toggle) == false
            case 58, 61:
                let key: KeyboardKey = keyCode == 58 ? .alt(.left) : .alt(.right)
                forward = windowDelegate.keyboardDidhandle(key: key,
                                                           character: nil,
                                                           modifiers: [],
                                                           isRepeat: false,
                                                           event: .toggle) == false
            case 63:
                let key: KeyboardKey = .fn
                forward = windowDelegate.keyboardDidhandle(key: key,
                                                           character: nil,
                                                           modifiers: [],
                                                           isRepeat: false,
                                                           event: .toggle) == false
            case 57:
                let key: KeyboardKey = .capsLock
                forward = windowDelegate.keyboardDidhandle(key: key,
                                                           character: nil,
                                                           modifiers: [],
                                                           isRepeat: false,
                                                           event: .toggle) == false
            default:
                Log.info("Unhandled Modfier Key", event.keyCode)
                break
            }
        }
        if forward {
            super.flagsChanged(with: event)
        }
    }
}
#endif
