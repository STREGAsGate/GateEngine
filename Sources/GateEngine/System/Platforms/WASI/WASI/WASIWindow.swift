/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
import DOM
import WebGL2
import GameMath
import JavaScriptKit
import DOM

final class WASIWindow: WindowBacking {
    unowned let window: Window
    var state: Window.State = .hidden
    let canvas: HTMLCanvasElement
    
    // Stoted Metadata
    var pixelSafeAreaInsets: Insets = .zero
    var pointSafeAreaInsets: Insets = .zero
    var pixelSize: Size2 = Size2(640, 480)
    var pointSize: Size2 = Size2(640, 480)
    var interfaceScaleFactor: Float = 1
    
    // Called from onreseize observer
    func updateStoredMetaData() {
        self.interfaceScaleFactor = Float(globalThis.document.defaultView?.devicePixelRatio ?? 1)
        self.pointSize = Size2(Float(globalThis.window.innerWidth), Float(globalThis.window.innerHeight))
        self.pixelSize = self.pointSize * self.interfaceScaleFactor
        if let doc = globalThis.document.documentElement, let obj = JSObject.global.getComputedStyle?(doc) {
            var insets: Insets = .zero
            if let s = obj.getPropertyValue("--sat").string {
                let v = s[...s.index(before: s.index(before: s.index(before: s.endIndex)))]
                if let value = Float(v) {
                    insets.top = value
                }
            }
            if let s = obj.getPropertyValue("--sal").string {
                let v = s[...s.index(before: s.index(before: s.index(before: s.endIndex)))]
                if let value = Float(v) {
                    insets.leading = value
                }
            }
            if let s = obj.getPropertyValue("--sab").string {
                let v = s[...s.index(before: s.index(before: s.index(before: s.endIndex)))]
                if let value = Float(v) {
                    insets.bottom = value
                }
            }
            if let s = obj.getPropertyValue("--sar").string {
                let v = s[...s.index(before: s.index(before: s.index(before: s.endIndex)))]
                if let value = Float(v) {
                    insets.trailing = value
                }
            }
            self.pointSafeAreaInsets = insets
            self.pixelSafeAreaInsets = self.pointSafeAreaInsets * self.interfaceScaleFactor
        }
    }
    
    required init(window: Window) {
        self.window = window
        
        let document: Document = globalThis.document
        
        let _canvas = document.createElement(localName: "canvas")
        _canvas.id = "mainCanvas"
        canvas = HTMLCanvasElement(from: _canvas)!
        _ = document.body!.appendChild(node: canvas)
    }

    lazy var originalTitle = globalThis.document.title
    var title: String? {
        get {
            return globalThis.document.title
        }
        set {
            _ = originalTitle
            globalThis.document.title = newValue ?? originalTitle
        }
    }

    @preconcurrency @MainActor func vSync(_ deltaTime: Double) {
        self.window.vSyncCalled()
        Game.shared.eventLoop() {
            _ = globalThis.window.requestAnimationFrame(callback: self.vSync(_:))
        }
    }
    
    @MainActor func show() {
        self.state = .shown
        self.updateStoredMetaData()
        self.vSync(0)
        self.addListeners()
    }
    
    func setMouseHidden(_ hidden: Bool) {
        if hidden {
            globalThis.document.documentElement!.attributes["cursor"]?.value = "none"
        }else{
            globalThis.document.documentElement!.attributes["cursor"]?.value = "default"
        }
    }
    
    func setMousePosition(_ position: Position2) {
        // not possible in HTML5
    }

    @MainActor func createWindowRenderTargetBackend() -> any RenderTargetBackend {
        return WebGL2RenderTarget(isWindow: true)
    }
    
    internal struct PointerLock {
        private weak var canvas: HTMLCanvasElement?
        
        fileprivate var locked: Bool = false
        private var requestedLockChange: Bool = false
        private var requestedLock: Bool = false
        
        init(canvas: HTMLCanvasElement) {
            self.canvas = canvas
        }

        fileprivate mutating func setRequestedLockIfNeeded() {
            guard self.requestedLockChange else {return}
            self.requestedLockChange = false
            guard let this = canvas?.jsObject else {return}
            if requestedLock {
                this["requestPointerLock"].function?(this: this)
            }else{
                this["exitPointerLock"].function?(this: this)
            }
        }
        
        internal mutating func requestLock(shouldLock lock: Bool) {
            self.requestedLockChange = true
            self.requestedLock = lock
        }
        
        fileprivate mutating func toggleLocked() {
            self.locked = locked ? false : true
        }
    }

    internal lazy var pointerLock: PointerLock = PointerLock(canvas: canvas)
    
    @MainActor private func performedUserGesture() {
        pointerLock.setRequestedLockIfNeeded()
    }
    
    @inline(__always)
    private func getPositionAndDelta(from event: MouseEvent) -> (position: Position2, delta: Position2) {
        let backingScale = Float(globalThis.document.defaultView?.devicePixelRatio ?? 1)
        let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY)) * backingScale
        let deltaX = Float(event.jsObject["movementX"].jsValue.number ?? 0)
        let deltaY = Float(event.jsObject["movementY"].jsValue.number ?? 0)
        let delta: Position2 = Position2(x: deltaX, y: deltaY) * backingScale
        return (position, delta)
    }
    
    private func addListeners() {
        globalThis.addEventListener(type: "pointerlockchange") { event in
            self.pointerLock.toggleLocked()
            #if GATEENGINE_DEBUG_HID
            Log.info("pointerlockchange", self.pointerLock.locked)
            #endif
            Task {@MainActor in
                if self.pointerLock.locked {
                    Game.shared.hid.mouse.setMode(.locked)
                }else{
                    Game.shared.hid.mouse.setMode(.standard)
                }
            }
        }
        globalThis.addEventListener(type: "pointerlockerror") { event in
            Log.error("PointerLockError.", "Returning mouse to mode 'standard'.")
            self.pointerLock.locked = false
            Task {@MainActor in
                Game.shared.hid.mouse.mode = .standard
            }
        }
        globalThis.onresize = { event -> JSValue in
            self.updateStoredMetaData()
            return .null
        }
        
        globalThis.addEventListener(type: "keydown") { event in
            let event = DOM.KeyboardEvent(unsafelyWrapping: event.jsObject)
            let modifiers = self.modifiers(fromEvent: event)
            let key = self.key(fromEvent: event)
            Task {@MainActor in
                _ = Game.shared.hid.keyboardDidHandle(key: key,
                                                      character: event.key.first,
                                                      modifiers: modifiers,
                                                      isRepeat: event.repeat,
                                                      event: .keyDown)
                if event.isTrusted && key != .escape {
                    self.performedUserGesture()
                }
            }
            event.preventDefault()
        }
        globalThis.addEventListener(type: "keyup") { event in
            let event = DOM.KeyboardEvent(unsafelyWrapping: event.jsObject)
            let modifiers = self.modifiers(fromEvent: event)
            let key = self.key(fromEvent: event)
            Task {@MainActor in
                _ = Game.shared.hid.keyboardDidHandle(key: key,
                                                       character: event.key.first,
                                                       modifiers: modifiers,
                                                       isRepeat: event.repeat,
                                                       event: .keyUp)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mouseenter") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                Game.shared.hid.mouseChange(event: .entered,
                                            position: locations.position,
                                            delta: locations.delta,
                                            window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mousemove") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                Game.shared.hid.mouseChange(event: .moved,
                                            position: locations.position,
                                            delta: locations.delta,
                                            window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mouseleave") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                Game.shared.hid.mouseChange(event: .exited,
                                            position: locations.position,
                                            delta: locations.delta,
                                            window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mousedown") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let button: MouseButton = self.mouseButton(fromEvent: event)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                Game.shared.hid.mouseClick(event: .buttonDown,
                                           button: button,
                                           position: locations.position,
                                           delta: locations.delta,
                                           window: self.window)
                if event.isTrusted {
                    self.performedUserGesture()
                }
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mouseup") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let button: MouseButton = self.mouseButton(fromEvent: event)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                Game.shared.hid.mouseClick(event: .buttonUp,
                                           button: button,
                                           position: locations.position,
                                           delta: locations.delta,
                                           window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "wheel") { event in
            let event = DOM.WheelEvent(unsafelyWrapping: event.jsObject)
            var delta = Position3(Float(event.deltaX), Float(event.deltaY), Float(event.deltaZ))
            let uiDelta: Position3
            switch event.deltaMode {
            case DOM.WheelEvent.DOM_DELTA_PIXEL:
                uiDelta = delta
                delta /= 10
            case DOM.WheelEvent.DOM_DELTA_PAGE:
                #if GATEENGINE_DEBUG_HID
                Log.warn("Scroll Value is DOM_DELTA_PAGE, and is not being converted to expected DOM_DELTA_PIXEL")
                #endif
                fallthrough
            case DOM.WheelEvent.DOM_DELTA_LINE:
                #if GATEENGINE_DEBUG_HID
                Log.warn("Scroll Value is DOM_DELTA_LINE, and is not being converted to expected DOM_DELTA_PIXEL")
                #endif
                fallthrough
            default:
                uiDelta = delta
            }
            let immutableDelta = delta
            Task {@MainActor in
                Game.shared.hid.mouseScrolled(delta: immutableDelta,
                                              uiDelta: uiDelta,
                                              device: 1,
                                              isMomentum: false,
                                              window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "contextmenu") { event in
            event.preventDefault()
        }
        canvas.addEventListener(type: "touchstart") { event in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    Game.shared.hid.screenTouchChange(id: touch.identifier,
                                                      kind: .physical,
                                                      event: .began,
                                                      position: position)
                }
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "touchmove") { event in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    Game.shared.hid.screenTouchChange(id: touch.identifier,
                                                      kind: .physical,
                                                      event: .moved,
                                                      position: position)
                }
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "touchend") { event in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    Game.shared.hid.screenTouchChange(id: touch.identifier,
                                                      kind: .physical,
                                                      event: .ended,
                                                      position: position)
                }
                if event.isTrusted {
                    self.performedUserGesture()
                }
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "touchcancel") { event in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    Game.shared.hid.screenTouchChange(id: touch.identifier,
                                                      kind: .physical,
                                                      event: .canceled,
                                                      position: position)
                }
            }
            event.preventDefault()
        }
    }
    
    @inlinable
    func mouseButton(fromEvent event: DOM.MouseEvent) -> MouseButton {
        let button: MouseButton
        switch event.button {
        case 0:// Mouse Primary
            button = .button1
        case 1:// Mouse Middle
            button = .button3
        case 2:// Mouse Secondary
            button = .button2
        case 3: // Backward
            button = .button4
        case 4: // Forawrd
            button = .button5
        default:
            button = .unknown(Int(event.button))
        }
        return button
    }
    
    @inlinable
    func key(fromEvent event: DOM.KeyboardEvent) -> KeyboardKey {
        switch event.code {
        case "Backquote":
            return .character("`", .standard)
        case "Digit1":
            return .character("1", .standard)
        case "Digit2":
            return .character("2", .standard)
        case "Digit3":
            return .character("3", .standard)
        case "Digit4":
            return .character("4", .standard)
        case "Digit5":
            return .character("5", .standard)
        case "Digit6":
            return .character("6", .standard)
        case "Digit7":
            return .character("7", .standard)
        case "Digit8":
            return .character("8", .standard)
        case "Digit9":
            return .character("9", .standard)
        case "Digit0":
            return .character("0", .standard)
        case "Minus":
            return .character("-", .standard)
        case "Equal":
            return .character("=", .standard)
        case "Backspace":
            return .backspace
        case "Tab":
            return .tab
        case "KeyQ":
            return .character("q", .standard)
        case "KeyW":
            return .character("w", .standard)
        case "KeyE":
            return .character("e", .standard)
        case "KeyR":
            return .character("r", .standard)
        case "KeyT":
            return .character("t", .standard)
        case "KeyY":
            return .character("y", .standard)
        case "KeyU":
            return .character("u", .standard)
        case "KeyI":
            return .character("i", .standard)
        case "KeyO":
            return .character("o", .standard)
        case "KeyP":
            return .character("p", .standard)
        case "BracketLeft":
            return .character("[", .standard)
        case "BracketRight":
            return .character("]", .standard)
        case "Backslash":
            return .character("\\", .standard)
        case "CapsLock":
            return .capsLock
        case "KeyA":
            return .character("a", .standard)
        case "KeyS":
            return .character("s", .standard)
        case "KeyD":
            return .character("d", .standard)
        case "KeyF":
            return .character("f", .standard)
        case "KeyG":
            return .character("g", .standard)
        case "KeyH":
            return .character("h", .standard)
        case "KeyJ":
            return .character("j", .standard)
        case "KeyK":
            return .character("k", .standard)
        case "KeyL":
            return .character("l", .standard)
        case "Semicolon":
            return .character(";", .standard)
        case "Quote":
            return .character("'", .standard)
        case "Enter":
            return .enter(.standard)
        case "ShiftLeft":
            return .shift(.leftSide)
        case "KeyZ":
            return .character("z", .standard)
        case "KeyX":
            return .character("x", .standard)
        case "KeyC":
            return .character("c", .standard)
        case "KeyV":
            return .character("v", .standard)
        case "KeyB":
            return .character("b", .standard)
        case "KeyN":
            return .character("n", .standard)
        case "KeyM":
            return .character("m", .standard)
        case "Comma":
            return .character(",", .standard)
        case "Period":
            return .character(".", .standard)
        case "Slash":
            return .character("/", .standard)
        case "ShiftRight":
            return .shift(.rightSide)
        case "ControlLeft":
            return .control(.leftSide)
        case "AltLeft":
            return .alt(.leftSide)
        case "MetaLeft", "OSLeft":
            return .host(.leftSide)
        case "Space":
            return .space
        case "MetaRight", "OSRight":
            return .host(.rightSide)
        case "AltRight":
            return .alt(.rightSide)
        case "ControlRight":
            return .control(.rightSide)
        case "Home":
            return .home
        case "PageUp":
            return .pageUp
        case "Delete":
            return .delete
        case "End":
            return .end
        case "PageDown":
            return .pageDown
        case "ArrowUp":
            return .up
        case "ArrowDown":
            return .down
        case "ArrowLeft":
            return .left
        case "ArrowRight":
            return .right
        case "NumLock":
            return .numLock
        case "NumpadEqual":
            return .character("=", .numberPad)
        case "NumpadDivide":
            return .character("/", .numberPad)
        case "NumpadMultiply":
            return .character("*", .numberPad)
        case "Numpad7":
            return .character("7", .numberPad)
        case "Numpad8":
            return .character("8", .numberPad)
        case "Numpad9":
            return .character("9", .numberPad)
        case "NumpadSubtract":
            return .character("-", .numberPad)
        case "Numpad4":
            return .character("4", .numberPad)
        case "Numpad5":
            return .character("5", .numberPad)
        case "Numpad6":
            return .character("6", .numberPad)
        case "NumpadAdd":
            return .character("+", .numberPad)
        case "Numpad1":
            return .character("1", .numberPad)
        case "Numpad2":
            return .character("2", .numberPad)
        case "Numpad3":
            return .character("3", .numberPad)
        case "NumpadEnter":
            return .enter(.numberPad)
        case "Numpad0":
            return .character("0", .numberPad)
        case "NumpadDecimal":
            return .character(".", .numberPad)
        case "Escape":
            return .escape
        case "F1":
            return .function(1)
        case "F2":
            return .function(2)
        case "F3":
            return .function(3)
        case "F4":
            return .function(4)
        case "F5":
            return .function(5)
        case "F6":
            return .function(6)
        case "F7":
            return .function(7)
        case "F8":
            return .function(8)
        case "F9":
            return .function(9)
        case "F10":
            return .function(10)
        case "F11":
            return .function(11)
        case "F12":
            return .function(12)
        case "F13":
            return .function(13)
        case "F14":
            return .function(14)
        case "F15":
            return .function(15)
        case "F16":
            return .function(16)
        case "F17":
            return .function(17)
        case "F18":
            return .function(18)
        case "F19":
            return .function(19)
        case "F20":
            return .function(20)
        case "Help":
            switch Game.shared.platform.browser {
            case .safari:
                return .insert
            default:
                break
            }
        case "Insert":
            return .insert
        case "ContextMenu":
            return .contextMenu
        default:
            break
        }
        Log.warnOnce("Key", event.key, event.code, event.keyCode, event.charCode, "is unhandled!")
        return .unhandledPlatformKeyCode(Int(event.keyCode), event.code.first)
    }
    
    @inlinable
    func modifiers(fromEvent event: DOM.KeyboardEvent) -> KeyboardModifierMask {
        var modifiers: KeyboardModifierMask = []
        if event.ctrlKey {
            modifiers.insert(.control)
        }
        if event.shiftKey {
            modifiers.insert(.shift)
        }
        if event.altKey {
            modifiers.insert(.alt)
        }
        if event.metaKey {
            modifiers.insert(.host)
        }
        if event.getModifierState(keyArg: "CapsLock") {
            modifiers.insert(.capsLock)
        }
        return modifiers
    }

    func close() {
        self.state = .destroyed
    }
}

#endif
