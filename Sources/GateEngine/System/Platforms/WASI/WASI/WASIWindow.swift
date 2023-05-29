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

class WASIWindow: WindowBacking {
    unowned let window: Window
    let style: WindowStyle
    let identifier: String
    var state: Window.State = .hidden
    let canvas: HTMLCanvasElement
    required init(identifier: String, style: WindowStyle, window: Window) {
        self.window = window
        self.style = style
        self.identifier = identifier
        
        let document: Document = globalThis.document
        
        let _canvas = document.createElement(localName: "canvas")
        _canvas.id = "mainCanvas"
        canvas = HTMLCanvasElement(from: _canvas)!
        _ = document.body!.appendChild(node: canvas)
    }

    var title: String? {
        get {
            return nil
        }
        set {
            // can't
        }
    }

    var frame: Rect {
        get {
            return Rect(size: Size2(Float(globalThis.window.innerWidth), Float(globalThis.window.innerHeight)))
        }
        set {
            // can't
        }
    }

    @inline(__always)
    var backingSize: Size2 {
        let size = Size2(Float(globalThis.window.innerWidth), Float(globalThis.window.innerHeight))
        return size * backingScaleFactor
    }
    
    @inline(__always)
    var backingScaleFactor: Float {
        if let pxRatio = globalThis.document.defaultView?.devicePixelRatio {
            return Float(pxRatio)
        }
        return 1
    }

    var safeAreaInsets: Insets = .zero

    @preconcurrency @MainActor func vSync(_ deltaTime: Double) {
        self.window.vSyncCalled()
        _ = globalThis.window.requestAnimationFrame(callback: vSync(_:))
    }
    
    @MainActor func show() {
        self.state = .shown
        vSync(0)
        addListeners()
    }
    
    func setMouseHidden(_ hidden: Bool) {
        if hidden {
            globalThis.document.documentElement!.attributes["cursor"]?.value = "none"
        }else{
            globalThis.document.documentElement!.attributes["cursor"]?.value = "default"
        }
    }
    
    func setMousePosition(_ position: Position2) {

    }
    
    var didRequestPointerLock: Bool = false
    func setPointerLock(_ lock: Bool) {
        let this = canvas.jsObject
        if lock {
            this["requestPointerLock"].function!(this: this)
            didRequestPointerLock = true
        }else{
            this["exitPointerLock"].function!(this: this)
            didRequestPointerLock = false
        }
    }
    
    var didSetup: Bool = false
    @MainActor func performedUserGesture() {
        if didRequestPointerLock == false && Game.shared.hid.mouse.locked {
            setPointerLock(true)
        }else if didRequestPointerLock && Game.shared.hid.mouse.locked == false {
            setPointerLock(false)
        }
        if didSetup == false {
            didSetup = true
            Game.shared.insertSystem(AudioSystem.self)
        }
    }
    
    @inline(__always)
    func getPositionAndDelta(from event: MouseEvent) -> (position: Position2, delta: Position2) {
        let backingScale = Float(globalThis.document.defaultView?.devicePixelRatio ?? 1)
        let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY)) * backingScale
        let deltaX = Float(event.jsObject["movementX"].jsValue.number ?? 0)
        let deltaY = Float(event.jsObject["movementY"].jsValue.number ?? 0)
        let delta: Position2 = Position2(x: deltaX, y: deltaY) * backingScale
        return (position, delta)
    }
    
    func addListeners() {
        globalThis.addEventListener(type: "pointerlockchange") { event in
            Task {@MainActor in
                if self.didRequestPointerLock {
                    Game.shared.hid.mouse.locked = false
                }
            }
        }
        globalThis.addEventListener(type: "pointerlockerror") { event in
            print("[GateEngine] Error: Mouse lock failed")
            Task {@MainActor in
                Game.shared.hid.mouse.locked = false
            }
        }
        globalThis.onresize = { event -> JSValue in
            guard let doc = globalThis.document.documentElement, let obj = JSObject.global.getComputedStyle?(doc) else {return .null}
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
            self.safeAreaInsets = insets
            return .null
        }
        
        globalThis.addEventListener(type: "keydown") { event in
            let event = DOM.KeyboardEvent(unsafelyWrapping: event.jsObject)
            guard event.repeat == false else {return}
            let modifiers = self.modifiers(fromEvent: event)
            let key = self.key(fromEvent: event)
            Task {@MainActor in
                _ = self.window.delegate?.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyDown)
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
                _ = self.window.delegate?.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyUp)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mouseenter") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                self.window.delegate?.mouseChange(event: .entered, position: locations.position, delta: locations.delta, window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mousemove") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                self.window.delegate?.mouseChange(event: .moved, position: locations.position, delta: locations.delta, window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mouseleave") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let locations = self.getPositionAndDelta(from: event)
            Task {@MainActor in
                self.window.delegate?.mouseChange(event: .exited, position: locations.position, delta: locations.delta, window: self.window)
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mousedown") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = {
                var position = Position2(x: Float(event.pageX), y: Float(event.pageY))
                if let pixelRatio = globalThis.document.defaultView?.devicePixelRatio {
                    position *= Float(pixelRatio)
                }
                return position
            }()
            let button: MouseButton = self.mouseButton(fromEvent: event)
            Task {@MainActor in
                self.window.delegate?.mouseClick(event: .buttonDown, button: button, count: nil, position: position, window: self.window)
                if event.isTrusted {
                    self.performedUserGesture()
                }
            }
            event.preventDefault()
        }
        canvas.addEventListener(type: "mouseup") { event in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = {
                var position = Position2(x: Float(event.pageX), y: Float(event.pageY))
                if let pixelRatio = globalThis.document.defaultView?.devicePixelRatio {
                    position *= Float(pixelRatio)
                }
                return position
            }()
            let button: MouseButton = self.mouseButton(fromEvent: event)
            Task {@MainActor in
                self.window.delegate?.mouseClick(event: .buttonUp, button: button, count: nil, position: position, window: self.window)
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
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .began, position: position)
                    print("Touch Start", position)
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
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .moved, position: position)
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
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .ended, position: position)
                    print("Touch End", position)
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
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .canceled, position: position)
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
        case 3:
            button = .button4
        case 4:
            button = .button5
        default:
            button = .unknown
        }
        return button
    }
    
    @inlinable
    func key(fromEvent event: DOM.KeyboardEvent) -> KeyboardKey {
        let key = event.key
        if key.count == 1, let char = key.first {
            return .character(char)
        }
        if key.count > 1, key[key.startIndex] == "F", let index = Int(String(key[key.index(after: key.startIndex)...])) {
            return .function(index)
        }
        switch key.lowercased() {
        case "tab": return .tab
        case "enter": return .return
        case "space": return .space
        case "escape": return .escape
        case "backspace": return .backspace
        case "arrowup": return .up
        case "arrowdown": return .down
        case "arrowleft": return .left
        case "arrowright": return .right
        default: return .nothing
        }
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
        return modifiers
    }

    func close() {
        self.state = .destroyed
    }
}

#endif
