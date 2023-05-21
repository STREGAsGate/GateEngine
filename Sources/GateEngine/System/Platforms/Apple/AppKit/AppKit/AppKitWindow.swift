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

class AppKitWindow: WindowBacking {
    unowned let window: Window
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
        
        nsWindow.contentViewController = AppKitViewController(window: self, size: size)

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
        nsWindowController.showWindow(NSApp)
        self.nsWindowController.window?.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(30)) {
            self.restoreSizeAndPosition(ofWindow: self.nsWindowController.window!)
            if UserDefaults.standard.bool(forKey: "\(self.identifier)-WasFullScreen") {
                self.nsWindowController.window!.toggleFullScreen(NSApp)
            }
        }
        if CVDisplayLinkIsRunning(self.displayLink) == false {
            CVDisplayLinkStart(self.displayLink)
        }
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        self.state = .shown
    }
    
    var backingSize: Size2 {
        guard let layer = self.nsWindowController.window?.contentView?.layer ?? self.nsWindowController.contentViewController?.view.layer else {fatalError()}
        return Size2(layer.bounds.size) * Float(layer.contentsScale)
    }
    
    public func close() {
        if CVDisplayLinkIsRunning(self.displayLink) {
            CVDisplayLinkStop(self.displayLink)
        }
        nsWindowController.close()
        self.state = .destroyed
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
}

class UGNSWindow: AppKit.NSWindow {
    unowned let window: Window

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

    func positionFromEvent(_ event: NSEvent) -> Position2 {
        if let contentView = self.contentView ?? self.contentViewController?.view {
            let cgPoint = contentView.convert(event.locationInWindow, from: nil)
            let position = Position2(Float(cgPoint.x), Float(cgPoint.y)) * Size2(Float(self.backingScaleFactor))
            return position
        }
        fatalError()
    }

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
            return .unknown
        }
    }

    override func mouseDown(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonDown, button: .button1, count: event.clickCount, position: positionFromEvent(event), window: window)
        }
        super.mouseDown(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonUp, button: .button1, count: event.clickCount, position: positionFromEvent(event), window: window)
        }
        super.mouseUp(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonDown, button: .button2, count: event.clickCount, position: positionFromEvent(event), window: window)
        }
        super.rightMouseDown(with: event)
    }

    override func rightMouseUp(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseClick(event: .buttonUp, button: .button2, count: event.clickCount, position: positionFromEvent(event), window: window)
        }
        super.rightMouseUp(with: event)
    }

    override func otherMouseDown(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            let button: MouseButton = mouseButtonFromEvent(event)
            windowDelegate.mouseClick(event: .buttonDown, button: button, count: event.clickCount, position: positionFromEvent(event), window: window)
        }
        super.otherMouseDown(with: event)
    }

    override func otherMouseUp(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            let button: MouseButton = mouseButtonFromEvent(event)
            windowDelegate.mouseClick(event: .buttonUp, button: button, count: event.clickCount, position: positionFromEvent(event), window: window)
        }
        super.otherMouseUp(with: event)
    }

    override func mouseEntered(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseChange(event: .entered, position: positionFromEvent(event), window: window)
        }
        super.mouseEntered(with: event)
    }
    override func mouseMoved(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseChange(event: .moved, position: positionFromEvent(event), window: window)
        }
        super.mouseMoved(with: event)
    }
    override func mouseDragged(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseChange(event: .moved, position: positionFromEvent(event), window: window)
        }
        super.mouseDown(with: event)
    }
    override func rightMouseDragged(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseChange(event: .moved, position: positionFromEvent(event), window: window)
        }
        super.rightMouseDragged(with: event)
    }
    override func otherMouseDragged(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseChange(event: .moved, position: positionFromEvent(event), window: window)
        }
        super.otherMouseDragged(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        if let windowDelegate = window.delegate {
            windowDelegate.mouseChange(event: .exited, position: positionFromEvent(event), window: window)
        }
        super.mouseExited(with: event)
    }

    //MARK: - Touches
    private var touchesIDs: [ObjectIdentifier:UUID] = [:]
    private func type(for touch: NSTouch) -> TouchKind {
        switch touch.type {
        case .direct:
            return .physical
        case .indirect:
            return .indirect
        @unknown default:
            return .unknown
        }
    }

    func locationOfTouch(_ touch: NSTouch, from event: NSEvent) -> Position2 {
        switch type(for: touch) {
        case .physical:
            let cgPoint = touch.location(in: nil)
            return Position2(Float(cgPoint.x), Float(cgPoint.y))
        case .indirect:
            let cgPoint = touch.normalizedPosition
            return Position2(Float(cgPoint.x), Float(1 - cgPoint.y))
        default:
            fatalError()
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
                let position = locationOfTouch(touch, from: event)
                windowDelegate.touchChange(id: id, kind: type, event: .began, position: position)
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
                let position = locationOfTouch(touch, from: event)
                windowDelegate.touchChange(id: id, kind: type, event: .moved, position: position)
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
                let position = locationOfTouch(touch, from: event)
                windowDelegate.touchChange(id: id, kind: type, event: .ended, position: position)
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
                let position = locationOfTouch(touch, from: event)
                windowDelegate.touchChange(id: id, kind: type, event: .canceled, position: position)
                touchesIDs[ObjectIdentifier(touch)] = nil
            }
        }
    }

    // MARK: - Keyboard
    func keyFromEvent(_ event: NSEvent) -> KeyboardKey {
        if event.keyCode == 53 {
            return .escape
        }
        if event.keyCode == 51 {
            return .backspace
        }
        if event.keyCode == 126 {
            return .up
        }
        if event.keyCode == 125 {
            return .down
        }
        if event.keyCode == 123 {
            return .left
        }
        if event.keyCode == 124 {
            return .right
        }
        if event.keyCode == 122 {
            return .function(1)
        }
        if event.keyCode == 120 {
            return .function(2)
        }
        if event.keyCode == 99 {
            return .function(3)
        }
        if event.keyCode == 118 {
            return .function(4)
        }
        if event.keyCode == 96 {
            return .function(5)
        }
        if event.keyCode == 97 {
            return .function(6)
        }
        if event.keyCode == 98 {
            return .function(7)
        }
        if event.keyCode == 100 {
            return .function(8)
        }
        if event.keyCode == 101 {
            return .function(9)
        }
        if event.keyCode == 109 {
            return .function(10)
        }
        if event.keyCode == 103 {
            return .function(11)
        }
        if event.keyCode == 111 {
            return .function(12)
        }
        if event.keyCode == 105 {
            return .function(13)
        }
        if event.keyCode == 107 {
            return .function(14)
        }
        if event.keyCode == 113 {
            return .function(15)
        }
        if event.keyCode == 106 {
            return .function(16)
        }
        if event.keyCode == 64 {
            return .function(17)
        }
        if event.keyCode == 79 {
            return .function(18)
        }
        if event.keyCode == 80 {
            return .function(19)
        }
        if event.keyCode == 90 {
            return .function(20)
        }

        if let character: Character = event.charactersIgnoringModifiers?.first {
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

        #if DEBUG
        print("UniversalGraphics is not handling key code:", event.keyCode)
        #endif

        return .nothing
    }

    func modifiersFromEvent(_ event: NSEvent) -> KeyboardModifierMask {
        var modifiers: KeyboardModifierMask = []
        if event.modifierFlags.contains(.command) {
            modifiers.insert(.host)
        }
        if event.modifierFlags.contains(.control) {
            modifiers.insert(.control)
        }
        if event.modifierFlags.contains(.option) {
            modifiers.insert(.alt)
        }
        if event.modifierFlags.contains(.shift) {
            modifiers.insert(.shift)
        }
        return modifiers
    }

    override func keyDown(with event: NSEvent) {
        var forward: Bool = true
        if event.isARepeat == false, let windowDelegate = window.delegate {
            let key = keyFromEvent(event)
            let modifiers = modifiersFromEvent(event)
            forward = windowDelegate.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyDown) == false
        }
        if event.isARepeat == false && forward {
            super.keyDown(with: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        var forward: Bool = true
        if event.isARepeat == false, let windowDelegate = window.delegate {
            let key = keyFromEvent(event)
            let modifiers = modifiersFromEvent(event)
            forward = windowDelegate.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyUp) == false
        }
        if event.isARepeat == false && forward {
            super.keyUp(with: event)
        }
    }
}
#endif
