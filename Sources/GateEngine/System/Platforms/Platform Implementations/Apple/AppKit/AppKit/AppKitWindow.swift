/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(macOS)
import AppKit
import MetalKit
import Carbon

final class AppKitWindow: WindowBacking {
    weak var window: Window!
    let nsWindowController: NSWindowController

    var state: Window.State = .hidden

    // Stoted Metadata
    var pointSafeAreaInsets: Insets = .zero
    var pixelSafeAreaInsets: Insets = .zero
    var pointSize: Size2 = Size2(640, 480)
    var pixelSize: Size2 = Size2(640, 480)
    var interfaceScaleFactor: Float = 1

    // Called from AppKitViewController
    @MainActor func updateStoredMetaData() {
        if let window = self.nsWindowController.window {
            self.interfaceScaleFactor = Float(window.backingScaleFactor)
            if let view = nsWindowController.window?.contentViewController?.view {
                self.pointSize = Size2(view.bounds.size)
                self.pixelSize = self.pointSize * self.interfaceScaleFactor
                if #available(macOS 11.0, *) {
                    self.pointSafeAreaInsets = Insets(
                        top: Float(view.safeAreaInsets.top),
                        leading: Float(view.safeAreaInsets.left),
                        bottom: Float(view.safeAreaInsets.bottom),
                        trailing: Float(view.safeAreaInsets.right)
                    )
                    self.pixelSafeAreaInsets = self.pointSafeAreaInsets * self.interfaceScaleFactor
                }
            }
        }
    }

    required init(window: Window) {
        self.window = window

        var styleMask: NSWindow.StyleMask = [.titled, .resizable, .miniaturizable]

        switch window.style {
        case .minimalSystemDecorations:
            styleMask.insert(.fullSizeContentView)
        case .system:
            break
        }

        if window.isMainWindow || window.options.contains(.userClosable) {
            styleMask.insert(.closable)
        }

        let size = Size2(640, 480)

        let nsWindow = UGNSWindow(
            window: window,
            contentRect: NSRect(x: 0, y: 0, width: CGFloat(size.width), height: CGFloat(size.height)),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        self.nsWindowController = NSWindowController(window: nsWindow)
        nsWindow.isReleasedWhenClosed = false
        if window.style == .minimalSystemDecorations {
            nsWindow.titlebarAppearsTransparent = true
            nsWindow.titleVisibility = .hidden
        }

        nsWindow.contentViewController = AppKitViewController(window: self)

        nsWindow.center()
        let frameIsAcceptable = nsWindow.setFrameAutosaveName(window.identifier)
        assert(frameIsAcceptable, "Must use unique window identifiers.")
        if #available(macOS 10.12, *) {
            nsWindow.tabbingMode = .disallowed
        }

        nsWindow.title = window.identifier

        self.setupNotifications()
    }

    @MainActor private func restoreSizeAndPosition(ofWindow nsWindow: NSWindow) {

        // restore size and relative position
        nsWindow.setFrameUsingName(window.identifier)

        #if DEBUG
        let restoreMainWindow = true
        #else
        let restoreMainWindow = window.isMainWindow == false
        #endif
        if restoreMainWindow {
            // Restore screen position, but not for the primary window unless debugging (cuz it gets annoying with multiple monitors)
            // Users expect the main window to appear on the main screen. macOS will do that for us.
            let screenID = CGDirectDisplayID(
                UserDefaults.standard.integer(forKey: "ScreenID_\(window.identifier)")
            )
            for screen in NSScreen.screens
            where screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID == screenID
            && nsWindow.screen !== screen {
                // If the screen isn't the last screen the user preferred, move the window to the correct screen
                if nsWindow.screen !== screen {
                    var frame = nsWindow.frame
                    if let currentScreen = nsWindow.screen {
                        // Remove the current screen offset
                        frame.origin.x -= currentScreen.frame.origin.x
                        frame.origin.y -= currentScreen.frame.origin.y
                    }
                    // Add the deired screen offset
                    frame.origin.x += screen.frame.origin.x
                    frame.origin.y += screen.frame.origin.y
                    nsWindow.setFrame(frame, display: false)
                }
                break
            }
        }

        if nsWindow.styleMask.contains(.fullScreen) == false {
            if window.options.contains(.forceFullScreen)
                || UserDefaults.standard.bool(forKey: "\(window.identifier)-WasFullScreen") {
                nsWindowController.window?.toggleFullScreen(nil)
            } else if window.options.contains(.firstLaunchFullScreen)
                      && UserDefaults.standard.object(forKey: "\(window.identifier)-WasFullScreen") == nil {
                nsWindowController.window?.toggleFullScreen(nil)
            }
        }
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillMiniaturize(_:)),
            name: NSWindow.willMiniaturizeNotification,
            object: nsWindowController.window
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidDeminiaturize(_:)),
            name: NSWindow.didDeminiaturizeNotification,
            object: nsWindowController.window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nsWindowController.window
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidChangeScreen(_:)),
            name: NSWindow.didChangeScreenNotification,
            object: nsWindowController.window
        )
    }

    @MainActor @objc func windowDidDeminiaturize(_ notification: Notification) {
        self.state = .shown
    }

    @MainActor @objc func windowWillMiniaturize(_ notification: Notification) {
        self.state = .hidden
    }

    @MainActor @objc func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.set(
            nsWindowController.window?.styleMask.contains(.fullScreen) == true,
            forKey: "\(window.identifier)-WasFullScreen"
        )
        UserDefaults.standard.synchronize()
        self.state = .closing
        Game.shared.windowManager.removeWindow(window.identifier)
    }

    @MainActor @objc func windowDidChangeScreen(_ notification: Notification) {
        if let screenID = self.nsWindowController.window?.screen?.deviceDescription[
            NSDeviceDescriptionKey("NSScreenNumber")
        ] as? CGDirectDisplayID {
            UserDefaults.standard.set(screenID, forKey: "ScreenID_\(window.identifier)")
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
            } else if let screenID = self.nsWindowController.window?.screen?.deviceDescription[
                NSDeviceDescriptionKey("NSScreenNumber")
            ] as? CGDirectDisplayID {
                if let device = CGDirectDisplayCopyCurrentMetalDevice(screenID) {
                    Game.shared.renderer.device = device
                    let mtkView = nsWindowController.contentViewController?.view as? MTKView
                    mtkView!.device = device
                }
            }
        }
    }

    @MainActor func show() {
        self.restoreSizeAndPosition(ofWindow: self.nsWindowController.window!)
        if UserDefaults.standard.bool(forKey: "\(window.identifier)-WasFullScreen") {
            self.nsWindowController.window!.toggleFullScreen(NSApp)
        }
        
        NSApplication.shared.activate(ignoringOtherApps: true)

        if self.window.isMainWindow {
            self.nsWindowController.window?.makeMain()
        }
        nsWindowController.showWindow(nil)

        self.state = .shown
    }

    @MainActor public func close() {
        if window?.state != .closing && window?.state != .destroyed {
            nsWindowController.close()
        }
        self.state = .destroyed
    }

    @MainActor func createWindowRenderTargetBackend() -> any RenderTargetBackend {
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

    func setMouseHidden(_ hidden: Bool) {
        if hidden {
            CGDisplayHideCursor(kCGNullDirectDisplay)
        } else {
            CGDisplayShowCursor(kCGNullDirectDisplay)
        }
    }

    func setMousePosition(_ position: Position2) {
        guard let nsWindow = self.nsWindowController.window else { return }
        guard let nsScreen = nsWindow.screen else { return }
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
    private var touchesIDs: [ObjectIdentifier: UUID] = [:]
    private var surfaceIDs: [ObjectIdentifier: UUID] = [:]
    
    func id(forTouch touch: NSTouch) -> UUID {
        let objectID = ObjectIdentifier(touch.identity)
        if let id = touchesIDs[objectID] {
            return id
        }
        let id = UUID()
        touchesIDs[objectID] = id
        return id
    }
    func id(forSurface device: AnyObject) -> UUID {
        let objectID = ObjectIdentifier(device)
        if let id = surfaceIDs[objectID] {
            return id
        }
        let id = UUID()
        surfaceIDs[objectID] = id
        return id
    }

    init(window: Window,
         contentRect: NSRect,
         styleMask style: NSWindow.StyleMask,
         backing backingStoreType: NSWindow.BackingStoreType,
         defer flag: Bool) {
        self.window = window
        super.init(contentRect: contentRect,
                   styleMask: style,
                   backing: backingStoreType,
                   defer: flag)
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return self.window?.isMainWindow ?? false
    }
}

// MARK: - Mouse
extension UGNSWindow {
    func positionFromEvent(_ event: NSEvent) -> Position2? {
        if let contentView = self.contentView ?? self.contentViewController?.view {
            let cgPoint = contentView.convert(event.locationInWindow, from: nil)
            let position = Position2(cgPoint)
            return position
        }
        return nil
    }

    func deltaPositionFromEvent(_ event: NSEvent) -> Position2 {
        guard event.type == .mouseMoved || event.type == .mouseEntered || event.type == .mouseExited
        else { return .zero }
        return Position2(Float(event.deltaX), Float(event.deltaY))
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
            return .unknown(event.buttonNumber)
        }
    }

    override func mouseDown(with event: NSEvent) {
        Game.shared.hid.mouseClick(
            event: .buttonDown,
            button: .button1,
            multiClickTime: NSEvent.doubleClickInterval,
            position: positionFromEvent(event),
            delta: deltaPositionFromEvent(event),
            window: window
        )
    }

    override func mouseUp(with event: NSEvent) {
        Game.shared.hid.mouseClick(
            event: .buttonUp,
            button: .button1,
            multiClickTime: NSEvent.doubleClickInterval,
            position: positionFromEvent(event),
            delta: deltaPositionFromEvent(event),
            window: window
        )
    }

    override func rightMouseDown(with event: NSEvent) {
        Game.shared.hid.mouseClick(
            event: .buttonDown,
            button: .button2,
            multiClickTime: NSEvent.doubleClickInterval,
            position: positionFromEvent(event),
            delta: deltaPositionFromEvent(event),
            window: window
        )
    }

    override func rightMouseUp(with event: NSEvent) {
        Game.shared.hid.mouseClick(
            event: .buttonUp,
            button: .button2,
            multiClickTime: NSEvent.doubleClickInterval,
            position: positionFromEvent(event),
            delta: deltaPositionFromEvent(event),
            window: window
        )
    }

    override func otherMouseDown(with event: NSEvent) {
        Game.shared.hid.mouseClick(
            event: .buttonDown,
            button: mouseButtonFromEvent(event),
            multiClickTime: NSEvent.doubleClickInterval,
            position: positionFromEvent(event),
            delta: deltaPositionFromEvent(event),
            window: window
        )
    }

    override func otherMouseUp(with event: NSEvent) {
        Game.shared.hid.mouseClick(
            event: .buttonUp,
            button: mouseButtonFromEvent(event),
            multiClickTime: NSEvent.doubleClickInterval,
            position: positionFromEvent(event),
            delta: deltaPositionFromEvent(event),
            window: window
        )
    }

    override func mouseEntered(with event: NSEvent) {
        if let position = positionFromEvent(event) {
            Game.shared.hid.mouseChange(
                event: .entered,
                position: position,
                delta: deltaPositionFromEvent(event),
                window: window
            )
        }
    }
    override func mouseMoved(with event: NSEvent) {
        if let position = positionFromEvent(event) {
            Game.shared.hid.mouseChange(
                event: .moved,
                position: position,
                delta: deltaPositionFromEvent(event),
                window: window
            )
        }
    }
    override func mouseDragged(with event: NSEvent) {
        if let position = positionFromEvent(event) {
            Game.shared.hid.mouseChange(
                event: .moved,
                position: position,
                delta: deltaPositionFromEvent(event),
                window: window
            )
        }
    }
    override func rightMouseDragged(with event: NSEvent) {
        if let position = positionFromEvent(event) {
            Game.shared.hid.mouseChange(
                event: .moved,
                position: position,
                delta: deltaPositionFromEvent(event),
                window: window
            )
        }
    }
    override func otherMouseDragged(with event: NSEvent) {
        if let position = positionFromEvent(event) {
            Game.shared.hid.mouseChange(
                event: .moved,
                position: position,
                delta: deltaPositionFromEvent(event),
                window: window
            )
        }
    }

    override func mouseExited(with event: NSEvent) {
        if let position = positionFromEvent(event) {
            Game.shared.hid.mouseChange(
                event: .exited,
                position: position,
                delta: deltaPositionFromEvent(event),
                window: window
            )
        }
    }

    override func scrollWheel(with event: NSEvent) {
        let delta = Position3(
            Float(event.isDirectionInvertedFromDevice ? event.deltaX : event.deltaX * -1),
            Float(event.isDirectionInvertedFromDevice ? event.deltaY * -1 : event.deltaY),
            Float(event.deltaZ)
        )
        let uiDelta = Position3(
            Float(event.scrollingDeltaX),
            Float(event.scrollingDeltaY),
            Float(event.deltaZ)
        )
        let isMomentum: Bool
        switch event.momentumPhase {
        case [], .cancelled, .ended:
            isMomentum = false
        default:
            isMomentum = true
        }
        Game.shared.hid.mouseScrolled(
            delta: delta,
            uiDelta: uiDelta,
            device: event.deviceID,
            isMomentum: isMomentum,
            window: window
        )
    }
}

// MARK: - Touches
extension UGNSWindow {
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
        let touches = event.touches(matching: .began, in: nil)

        for touch in touches {
            let id = self.id(forTouch: touch)
            let type = type(for: touch)
            if let position = locationOfTouch(touch, from: event) {
                switch touch.type {
                case .direct:
                    Game.shared.hid.screenTouchChange(
                        id: id,
                        kind: type,
                        event: .began,
                        position: position,
                        precisionPosition: nil,
                        pressure: 0,
                        window: window
                    )
                case .indirect:
                    if let device = touch.device as? AnyObject {
                        Game.shared.hid.surfaceTouchChange(
                            id: id,
                            event: .began,
                            surfaceID: self.id(forSurface: device),
                            normalizedPosition: position,
                            pressure: 0,
                            window: window
                        )
                    }
                default:
                    break
                }
            }
        }
    }

    override func touchesMoved(with event: NSEvent) {
        let touches = event.touches(matching: .moved, in: nil)

        for touch in touches {
            let id = self.id(forTouch: touch)
            let type = type(for: touch)
            if let position = locationOfTouch(touch, from: event) {
                switch touch.type {
                case .direct:
                    Game.shared.hid.screenTouchChange(
                        id: id,
                        kind: type,
                        event: .moved,
                        position: position,
                        precisionPosition: nil,
                        pressure: 0,
                        window: window
                    )
                case .indirect:
                    if let device = touch.device as? AnyObject {
                        Game.shared.hid.surfaceTouchChange(
                            id: id,
                            event: .moved,
                            surfaceID: self.id(forSurface: device),
                            normalizedPosition: position,
                            pressure: 0,
                            window: window
                        )
                    }
                default:
                    break
                }
            }
        }
    }

    override func touchesEnded(with event: NSEvent) {
        let touches = event.touches(matching: .ended, in: nil)

        for touch in touches {
            let id = self.id(forTouch: touch)
            let type = type(for: touch)
            if let position = locationOfTouch(touch, from: event) {
                switch touch.type {
                case .direct:
                    Game.shared.hid.screenTouchChange(
                        id: id,
                        kind: type,
                        event: .ended,
                        position: position,
                        precisionPosition: nil,
                        pressure: 0,
                        window: window
                    )
                case .indirect:
                    if let device = touch.device as? AnyObject {
                        Game.shared.hid.surfaceTouchChange(
                            id: id,
                            event: .ended,
                            surfaceID: self.id(forSurface: device),
                            normalizedPosition: position,
                            pressure: 0,
                            window: window
                        )
                    }
                default:
                    break
                }
            }
            touchesIDs[ObjectIdentifier(touch)] = nil
        }
    }

    override func touchesCancelled(with event: NSEvent) {
        let touches = event.touches(matching: .cancelled, in: nil)

        for touch in touches {
            let id = self.id(forTouch: touch)
            let type = type(for: touch)
            if let position = locationOfTouch(touch, from: event) {
                switch touch.type {
                case .direct:
                    Game.shared.hid.screenTouchChange(
                        id: id,
                        kind: type,
                        event: .canceled,
                        position: position,
                        precisionPosition: nil,
                        pressure: 0,
                        window: window
                    )
                case .indirect:
                    if let device = touch.device as? AnyObject {
                        Game.shared.hid.surfaceTouchChange(
                            id: id,
                            event: .canceled,
                            surfaceID: self.id(forSurface: device),
                            normalizedPosition: position,
                            pressure: 0,
                            window: window
                        )
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
extension UGNSWindow {
    // TODO: Test performance with `if` vs `switch`
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func keyFromEvent(_ event: NSEvent) -> KeyboardKey {
        let keyCode = event.keyCode
        switch keyCode {
        case 0:  // A
            return .character("a", .standard)
        case 1:  // S
            return .character("s", .standard)
        case 2:  // D
            return .character("d", .standard)
        case 3:  // F
            return .character("f", .standard)
        case 4:  // H
            return .character("h", .standard)
        case 5:  // G
            return .character("g", .standard)
        case 6:  // Z
            return .character("z", .standard)
        case 7:  // X
            return .character("x", .standard)
        case 8:  // C
            return .character("c", .standard)
        case 9:  // V
            return .character("v", .standard)
        #if GATEENGINE_DEBUG_HID
        case 10:  // ??
            break
        #endif
        case 11:  // B
            return .character("b", .standard)
        case 12:  // Q
            return .character("q", .standard)
        case 13:  // W
            return .character("w", .standard)
        case 14:  // E
            return .character("e", .standard)
        case 15:  // R
            return .character("r", .standard)
        case 16:  // Y
            return .character("y", .standard)
        case 17:  // T
            return .character("t", .standard)
        case 18:  // 1
            return .character("1", .standard)
        case 19:  // 2
            return .character("2", .standard)
        case 20:  // 3
            return .character("3", .standard)
        case 21:  // 4
            return .character("4", .standard)
        case 22:  // 6
            return .character("6", .standard)
        case 23:  // 5
            return .character("5", .standard)
        case 24:  // =
            return .character("=", .standard)
        case 25:  // 9
            return .character("9", .standard)
        case 26:  // 7
            return .character("7", .standard)
        case 27:  // -
            return .character("-", .standard)
        case 28:  // 8
            return .character("8", .standard)
        case 29:  // 0
            return .character("0", .standard)
        case 30:  // ]
            return .character("]", .standard)
        case 31:  // O
            return .character("o", .standard)
        case 32:  // U
            return .character("u", .standard)
        case 33:  // [
            return .character("[", .standard)
        case 34:  // I
            return .character("i", .standard)
        case 35:  // P
            return .character("p", .standard)
        case 36:  // return
            return .enter(.standard)
        case 37:  // L
            return .character("l", .standard)
        case 38:  // J
            return .character("j", .standard)
        case 39:  // '
            return .character("'", .standard)
        case 40:  // K
            return .character("k", .standard)
        case 41:  // ;
            return .character(";", .standard)
        case 42:  // \
            return .character("\\", .standard)
        case 43:  // ,
            return .character(",", .standard)
        case 44:  // /
            return .character("/", .standard)
        case 45:  // N
            return .character("n", .standard)
        case 46:  // M
            return .character("m", .standard)
        case 47:  // .
            return .character(".", .standard)
        case 48:  // \t
            return .tab
        case 49:  // space
            return .space
        case 50:  // `
            return .character("`", .standard)
        case 51:  // delete
            return .backspace
        #if GATEENGINE_DEBUG_HID
        case 52:  // ??
            break
        #endif
        case 53:  // esc
            return .escape
        case 54:  // r-cmd
            return .host(.rightSide)
        case 55:  // l-cmd
            return .host(.leftSide)
        case 56:  // l-shift
            return .shift(.leftSide)
        case 57:  // capslock
            return .capsLock
        case 58:  // l-alt
            return .alt(.leftSide)
        case 59:  // l-ctrl
            return .control(.leftSide)
        case 60:  // r-shift
            return .shift(.rightSide)
        case 61:  // r-alt
            return .alt(.rightSide)
        case 62:  // r-ctrl
            return .control(.rightSide)
        case 63:  // Fn
            return .fn
        case 64:  // F17
            return .function(17)
        case 65:  // .
            return .character(".", .numberPad)
        #if GATEENGINE_DEBUG_HID
        case 66:  // ??
            break
        #endif
        case 67:  // *
            return .character("*", .numberPad)
        #if GATEENGINE_DEBUG_HID
        case 68:  // ??
            break
        #endif
        case 69:  // +
            return .character("+", .numberPad)
        #if GATEENGINE_DEBUG_HID
        case 70:  // ??
            break
        #endif
        case 71:  // clear/numlock
            return .clear
        #if GATEENGINE_DEBUG_HID
        case 72 ... 74:  // ??
            break
        #endif
        case 75:  // /
            return .character("/", .numberPad)
        case 76:  // enter
            return .enter(.numberPad)
        #if GATEENGINE_DEBUG_HID
        case 77:  // ??
            break
        #endif
        case 78:  // -
            return .character("-", .numberPad)
        case 79:  // F18
            return .function(18)
        case 80:  // F19
            return .function(19)
        case 81:  // =
            return .character("=", .numberPad)
        case 82:  // 0
            return .character("0", .numberPad)
        case 83:  // 1
            return .character("1", .numberPad)
        case 84:  // 2
            return .character("2", .numberPad)
        case 85:  // 3
            return .character("3", .numberPad)
        case 86:  // 4
            return .character("4", .numberPad)
        case 87:  // 5
            return .character("5", .numberPad)
        case 88:  // 6
            return .character("6", .numberPad)
        case 89:  // 7
            return .character("7", .numberPad)
        case 90:  // F20
            return .function(20)
        case 91:  // 8
            return .character("8", .numberPad)
        case 92:  // 9
            return .character("9", .numberPad)
        #if GATEENGINE_DEBUG_HID
        case 93 ... 95:  // ??
            break
        #endif
        case 96:  // F5
            return .function(5)
        case 97:  // F6
            return .function(6)
        case 98:  // F7
            return .function(7)
        case 99:  // F3
            return .function(3)
        case 100:  // F8
            return .function(8)
        case 101:  // F9
            return .function(9)
        #if GATEENGINE_DEBUG_HID
        case 102:  // ??
            break
        #endif
        case 103:  // F11
            return .function(11)
        #if GATEENGINE_DEBUG_HID
        case 104:  // ??
            break
        #endif
        case 105:  // F13
            return .function(13)
        case 106:  // F16
            return .function(16)
        case 107:  // F14
            return .function(14)
        #if GATEENGINE_DEBUG_HID
        case 108:  // ??
            break
        #endif
        case 109:  // F10
            return .function(10)
        case 110:  // Applications
            return .contextMenu
        case 111:  // F12
            return .function(12)
        #if GATEENGINE_DEBUG_HID
        case 112:  // ??
            break
        #endif
        case 113:  // F15
            return .function(15)
        case 114:  // Insert
            return .insert
        case 115:  // home
            return .home
        case 116:  // page up
            return .pageUp
        case 117:  // delete
            return .delete
        case 118:  // F4
            return .function(4)
        case 119:  // end
            return .end
        case 120:  // F2
            return .function(2)
        case 121:  // page down
            return .pageDown
        case 122:  // F1
            return .function(1)
        case 123:  // left
            return .left
        case 124:  // right
            return .right
        case 125:  // down
            return .down
        case 126:  // up
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
        if Game.shared.hid.keyboardDidHandle(
            key: keyFromEvent(event),
            character: event.characters?.first,
            modifiers: modifiersFromEvent(event),
            isRepeat: event.isARepeat,
            event: .keyDown
        ) {
            forward = false
        }
        if forward {
            super.keyDown(with: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        var forward: Bool = true
        if Game.shared.hid.keyboardDidHandle(
            key: keyFromEvent(event),
            character: event.characters?.first,
            modifiers: modifiersFromEvent(event),
            isRepeat: event.isARepeat,
            event: .keyUp
        ) {
            forward = false
        }
        if forward {
            super.keyUp(with: event)
        }
    }

    // swiftlint:disable:next function_body_length
    override func flagsChanged(with event: NSEvent) {
        var forward: Bool = true
        let keyCode = event.keyCode
        switch keyCode {
        case 56, 60:
            let key: KeyboardKey = keyCode == 56 ? .shift(.leftSide) : .shift(.rightSide)
            forward = Game.shared.hid.keyboardDidHandle(key: key,
                                                        character: nil,
                                                        modifiers: [],
                                                        isRepeat: false,
                                                        event: .toggle) == false
        case 55, 54:
            let key: KeyboardKey = keyCode == 55 ? .host(.leftSide) : .host(.rightSide)
            forward = Game.shared.hid.keyboardDidHandle(key: key,
                                                        character: nil,
                                                        modifiers: [],
                                                        isRepeat: false,
                                                        event: .toggle) == false
        case 59, 62:
            let key: KeyboardKey = keyCode == 59 ? .control(.leftSide) : .control(.rightSide)
            forward = Game.shared.hid.keyboardDidHandle(key: key,
                                                        character: nil,
                                                        modifiers: [],
                                                        isRepeat: false,
                                                        event: .toggle) == false
        case 58, 61:
            let key: KeyboardKey = keyCode == 58 ? .alt(.leftSide) : .alt(.rightSide)
            forward = Game.shared.hid.keyboardDidHandle(key: key,
                                                        character: nil,
                                                        modifiers: [],
                                                        isRepeat: false,
                                                        event: .toggle) == false
        case 63:
            let key: KeyboardKey = .fn
            forward = Game.shared.hid.keyboardDidHandle(key: key,
                                                        character: nil,
                                                        modifiers: [],
                                                        isRepeat: false,
                                                        event: .toggle) == false
        case 57:
            let key: KeyboardKey = .capsLock
            forward = Game.shared.hid.keyboardDidHandle(key: key,
                                                        character: nil,
                                                        modifiers: [],
                                                        isRepeat: false,
                                                        event: .toggle) == false
        default:
            #if GATEENGINE_DEBUG_HID
            Log.info("Unhandled Modifier Key", event.keyCode)
            #else
            break
            #endif
        }
        if forward {
            super.flagsChanged(with: event)
        }
    }
}
#endif // swiftlint:disable:this file_length
