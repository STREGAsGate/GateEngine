/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */
#if canImport(UIKit) && canImport(UIKit) && !os(watchOS)

import Foundation
import GameController
import GameMath

internal class UIKitViewController: GCEventViewController {
    unowned let window: UIKitWindow
    init(window: UIKitWindow) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
        self.loadViewIfNeeded()
    }
    
    override func loadView() {
        let size = window.uiWindow.bounds.size
        #if GATEENGINE_FORCE_OPNEGL_APPLE
        self.view = GLKitView(viewController: self, size: size)
        #else
        if MetalRenderer.isSupported {
            self.view = MetalView(viewController: self, size: size)
        }else{
            #if canImport(GLKit)
            self.view = GLKitView(viewController: self, size: size)
            #endif
        }
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if os(iOS)
        if #available(iOS 13.4, *) {
            self.view.interactions.append(UIPointerInteraction(delegate: self))
        }
        if #available(iOS 11.0, *) {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
        #endif
        self.view.setNeedsLayout()
    }
    
    #if os(iOS)
    override var prefersHomeIndicatorAutoHidden: Bool {
        switch window.style {
        case .system:
            return false
        case .bestForGames:
            return true
        }
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        switch window.style {
        case .system:
            return []
        case .bestForGames:
            return .all
        }
    }
    #endif
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @inline(__always)
    private func type(for touch: UITouch) -> TouchKind {
        switch touch.type {
        case .direct:
            return .physical
        case .pencil, .stylus:
            return .stylus
        default:
            return .unknown
        }
    }
    
    @inline(__always)
    func locationOfTouch(_ touch: UITouch, from event: UIEvent?) -> Position2? {
        switch touch.type {
        case .direct, .pencil, .indirectPointer:
            let p = touch.preciseLocation(in: nil)
            return Position2(Float(p.x), Float(p.y))
        case .indirect:
            let p = touch.preciseLocation(in: nil)
            return Position2(Float(p.x), Float(p.y))
        default:
            return nil
        }
    }
    
    #if !os(tvOS)
    @inline(__always)
    func deltaLocationOfTouch(_ touch: UITouch, from event: UIEvent?) -> Position2 {
        let cgL = touch.preciseLocation(in: nil)
        let cgPL = touch.precisePreviousLocation(in: nil)
        return Position2(Float(cgPL.x - cgL.x), Float(cgPL.y - cgL.y))
    }
    
    @available(iOS 13.4, *)
    @inline(__always)
    func mouseButtonFromEvent(_ event: UIEvent?) -> MouseButton {
        guard let event else {return .unknown(nil)}
        switch event.buttonMask {
        case .button(1):
            return .button1
        case .button(2):
            return .button2
        case .button(3):
            return .button3
        case .button(4):
            return .button4
        case .button(5):
            return .button5
        default:
            // TODO: Figure out the button number
            return .unknown(nil)
        }
    }
    #endif
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        for touch in touches {
            guard let position = locationOfTouch(touch, from: event) else {continue}
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                if let event = event {
                    let button = mouseButtonFromEvent(event)
                    Game.shared.windowManager.mouseClick(event: .buttonDown,
                                                         button: button,
                                                         count: touch.tapCount,
                                                         position: position,
                                                         delta: self.deltaLocationOfTouch(touch, from: event),
                                                         window: self.window.window)
                }
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                let type = type(for: touch)
                Game.shared.windowManager.screenTouchChange(id: id, kind: type, event: .began, position: position)
            case .indirect:
                Game.shared.windowManager.surfaceTouchChange(id: id, event: .began, surfaceID: ObjectIdentifier(UIDevice.current), normalizedPosition: position)
            default:
                break
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        for touch in touches {
            guard let position = locationOfTouch(touch, from: event) else {continue}
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                let deltaPosition = deltaLocationOfTouch(touch, from: event)
                Game.shared.windowManager.mouseChange(event: .moved, position: position, delta: deltaPosition, window: self.window.window)
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                let type = type(for: touch)
                Game.shared.windowManager.screenTouchChange(id: id, kind: type, event: .moved, position: position)
            case .indirect:
                Game.shared.windowManager.surfaceTouchChange(id: id, event: .moved, surfaceID: ObjectIdentifier(UIDevice.current), normalizedPosition: position)
            default:
                break
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        for touch in touches {
            guard let position = locationOfTouch(touch, from: event) else {continue}
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                let button = mouseButtonFromEvent(event)
                Game.shared.windowManager.mouseClick(event: .buttonUp,
                                                     button: button,
                                                     count: touch.tapCount,
                                                     position: position,
                                                     delta: self.deltaLocationOfTouch(touch, from: event),
                                                     window: self.window.window)
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                let type = type(for: touch)
                Game.shared.windowManager.screenTouchChange(id: id, kind: type, event: .ended, position: position)
            case .indirect:
                Game.shared.windowManager.surfaceTouchChange(id: id, event: .ended, surfaceID: ObjectIdentifier(UIDevice.current), normalizedPosition: position)
            default:
                break
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        for touch in touches {
            guard let position = locationOfTouch(touch, from: event) else {continue}
            #if !os(tvOS)
            if #available(iOS 13.4, *), touch.type == .indirectPointer {
                let button = mouseButtonFromEvent(event)
                Game.shared.windowManager.mouseClick(event: .buttonUp,
                                                     button: button,
                                                     count: touch.tapCount,
                                                     position: position,
                                                     delta: self.deltaLocationOfTouch(touch, from: event),
                                                     window: self.window.window)
                continue
            }
            #endif
            let id = ObjectIdentifier(touch)
            switch touch.type {
            case .direct, .pencil:
                let type = type(for: touch)
                Game.shared.windowManager.screenTouchChange(id: id, kind: type, event: .canceled, position: position)
            case .indirect:
                Game.shared.windowManager.surfaceTouchChange(id: id, event: .canceled, surfaceID: ObjectIdentifier(UIDevice.current), normalizedPosition: position)
            default:
                break
            }
        }
    }
    
    // MARK: - Keyboard
    @inline(__always)
    func keysFromEvent(_ event: UIPressesEvent) -> Set<KeyboardKey> {
        var keys: Set<KeyboardKey> = []
        for press in event.allPresses {
            guard let key = press.key else {continue}

            switch key.keyCode {
            case .keyboardEscape:
                keys.insert(.escape)
            case .keyboardDeleteOrBackspace:
                keys.insert(.escape)
            case .keyboardUpArrow:
                keys.insert(.up)
            case .keyboardDownArrow:
                keys.insert(.down)
            case .keyboardLeftArrow:
                keys.insert(.left)
            case .keyboardRightArrow:
                keys.insert(.right)
            case .keyboardReturn:
                keys.insert(.return)
            case .keyboardTab:
                keys.insert(.tab)
            case .keyboardSpacebar:
                keys.insert(.space)
            default:
                switch key.keyCode.rawValue {
                case 58 ... 69, 104 ... 115:
                    keys.insert(.function(key.keyCode.rawValue))
                case 4 ... 39, 45 ... 56, 84 ... 100, 103, 133 ... 134:
                    keys.insert(.character(key.charactersIgnoringModifiers.first!))
                default:
                    break
                }
            }
            
            if keys.isEmpty {
                Log.warnOnce("Key Code \(key.keyCode.rawValue) is unhandled!")
                keys.insert(.unhandledPlatformKeyCode(key.keyCode.rawValue, key.characters))
            }
        }
        return keys
    }
    
    @inline(__always)
    func modifiersFromEvent(_ event: UIPressesEvent) -> KeyboardModifierMask {
        var modifiers: KeyboardModifierMask = []
        for press in event.allPresses {
            guard let key = press.key else {continue}
            if key.modifierFlags.contains(.command) {
                modifiers.insert(.host)
            }
            if key.modifierFlags.contains(.control) {
                modifiers.insert(.control)
            }
            if key.modifierFlags.contains(.alternate) {
                modifiers.insert(.alt)
            }
            if key.modifierFlags.contains(.shift) {
                modifiers.insert(.shift)
            }
            if key.modifierFlags.contains(.alphaShift) {
                modifiers.insert(.capsLock)
            }
        }
        return modifiers
    }
    
    @inline(__always)
    func didHandlePressEvent(_ event: UIPressesEvent?, _ keyEvent: KeyboardEvent) -> Bool {
        var handled: Bool = false
        guard let event else {return handled}
        if let windowDelegate = window.window?.delegate {
            let keys = keysFromEvent(event)
            let modifiers = modifiersFromEvent(event)
            for key in keys {
                if windowDelegate.keyboardRequestedHandling(key: key, modifiers: modifiers, event: keyEvent) {
                    handled = true
                }
            }
        }
        return handled
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if didHandlePressEvent(event, .keyDown) == false {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if didHandlePressEvent(event, .keyUp) == false {
            super.pressesEnded(presses, with: event)
        }
    }
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesChanged(presses, with: event)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if didHandlePressEvent(event, .keyUp) == false {
            super.pressesCancelled(presses, with: event)
        }
    }
}

// MARK: - Mouse
#if !os(tvOS)
@available(iOS 13.4, *)
extension UIKitViewController: UIPointerInteractionDelegate {
 
    // Called as the pointer moves within the interaction's view.
    func pointerInteraction(_ interaction: UIPointerInteraction, regionFor request: UIPointerRegionRequest, defaultRegion: UIPointerRegion) -> UIPointerRegion? {
        Game.shared.windowManager.mouseChange(event: .moved, position: Position2(request.location), delta: .zero, window: self.window.window)
        return defaultRegion
    }

    // Called after the interaction receives a new UIPointerRegion from pointerInteraction:regionForRequest:defaultRegion:.
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        if Game.shared.hid.mouse.hidden {
            return UIPointerStyle.hidden()
        }
        return nil
    }
    
    // Called when the pointer enters a given region.
    func pointerInteraction(_ interaction: UIPointerInteraction, willEnter region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
        Game.shared.windowManager.mouseChange(event: .entered, position: .zero, delta: .zero, window: self.window.window)
    }

    // Called when the pointer exists a given region.
    func pointerInteraction(_ interaction: UIPointerInteraction, willExit region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
        Game.shared.windowManager.mouseChange(event: .exited, position: .zero, delta: .zero, window: self.window.window)
    }
}
#endif
#endif
