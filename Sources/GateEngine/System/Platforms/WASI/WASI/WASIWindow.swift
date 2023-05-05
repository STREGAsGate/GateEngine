/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if os(WASI) || GATEENGINE_WASI_IDE_SUPPORT
import DOM
import WebGL2
import GameMath
import JavaScriptKit
import DOM

class WASIWindow: WindowBacking {
    unowned let window: Window
    let style: WindowStyle
    let identifier: String?

    let canvas: HTMLCanvasElement
    required init(identifier: String?, style: WindowStyle, window: Window) {
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
            fatalError()
        }
        set {
            fatalError()
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

    var backingSize: Size2 {
        var size = Size2(Float(globalThis.window.innerWidth), Float(globalThis.window.innerHeight))
        if let pxRatio = globalThis.document.defaultView?.devicePixelRatio {
            size *= Float(pxRatio)
        }
        return size
    }

    var safeAreaInsets: Insets = .zero

    @MainActor func vSync(_ deltaTime: Double) {
        self.window.vSyncCalled()
        _ = globalThis.window.requestAnimationFrame(callback: vSync(_:))
    }
    @MainActor func show() {
        vSync(0)
        addListeners()
    }
    
    func addListeners() {
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
            print("SafeArea:\(insets)")
            self.safeAreaInsets = insets
            return .null
        }
        
        canvas.onkeydown = { event -> JSValue in
            let event = DOM.KeyboardEvent(unsafelyWrapping: event.jsObject)
            guard event.repeat == false else {return .null}
            let modifiers = self.modifiers(fromEvent: event)
            let key = self.key(fromEvent: event)
            Task {@MainActor in
                _ = self.window.delegate?.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyDown)
            }
            event.preventDefault()
            return .null
        }
        canvas.onkeyup = { event -> JSValue in
            let event = DOM.KeyboardEvent(unsafelyWrapping: event.jsObject)
            let modifiers = self.modifiers(fromEvent: event)
            let key = self.key(fromEvent: event)
            Task {@MainActor in
                _ = self.window.delegate?.keyboardRequestedHandling(key: key, modifiers: modifiers, event: .keyUp)
            }
            event.preventDefault()
            return .null
        }
        canvas.onmouseenter = { event -> JSValue in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY))
            Task {@MainActor in
                self.window.delegate?.mouseChange(event: .entered, position: position)
            }
            event.preventDefault()
            return .null
        }
        canvas.onmousemove = { event -> JSValue in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY))
            Task {@MainActor in
                self.window.delegate?.mouseChange(event: .moved, position: position)
            }
            event.preventDefault()
            return .null
        }
        canvas.onmouseleave = { event -> JSValue in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY))
            Task {@MainActor in
                self.window.delegate?.mouseChange(event: .exited, position: position)
            }
            event.preventDefault()
            return .null
        }
        canvas.onmousedown = { event -> JSValue in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY))
            let button: MouseButton = self.mouseButton(fromEvent: event)
            Task {@MainActor in
                self.window.delegate?.mouseClick(event: .buttonDown, button: button, count: nil, position: position)
            }
            event.preventDefault()
            return .null
        }
        canvas.onmouseup = { event -> JSValue in
            let event = DOM.MouseEvent(unsafelyWrapping: event.jsObject)
            let position: Position2 = Position2(x: Float(event.pageX), y: Float(event.pageY))
            let button: MouseButton = self.mouseButton(fromEvent: event)
            Task {@MainActor in
                self.window.delegate?.mouseClick(event: .buttonUp, button: button, count: nil ,position: position)
            }
            event.preventDefault()
            return .null
        }
        canvas.oncontextmenu = { event -> JSValue in
            return .boolean(false)
        }
        canvas.ontouchstart = { event -> JSValue in
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
            return .null
        }
        canvas.ontouchmove = { event -> JSValue in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .moved, position: position)
                }
            }
            event.preventDefault()
            return .null
        }
        canvas.ontouchend = { event -> JSValue in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .ended, position: position)
                    print("Touch End", position)
                }
            }
            event.preventDefault()
            return .null
        }
        canvas.ontouchcancel = { event -> JSValue in
            let event = DOM.TouchEvent(unsafelyWrapping: event.jsObject)
            Task {@MainActor in
                for index in 0 ..< event.changedTouches.length {
                    guard let touch = event.changedTouches.item(index: index) else {continue}
                    let position: Position2 = Position2(x: Float(touch.pageX), y: Float(touch.pageY))
                    self.window.delegate?.touchChange(id: touch.identifier, kind: .physical, event: .canceled, position: position)
                }
            }
            event.preventDefault()
            return .null
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
        
    }
}

#endif
