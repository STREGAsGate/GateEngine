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

    private var touchesIDs: [ObjectIdentifier:UUID] = [:]
    private func type(for touch: UITouch) -> TouchKind {
        switch touch.type {
        case .direct:
            return .physical
        case .pencil, .stylus:
            return .stylus
        case .indirect, .indirectPointer:
            return .indirect
        @unknown default:
            return .unknown
        }
    }
    func locationOfTouch(_ touch: UITouch, from event: UIEvent?) -> Position2 {
        switch type(for: touch) {
        case .physical:
            let p = touch.location(in: nil)
            return Position2(Float(p.x), Float(p.y))
        case .indirect:
            let p = touch.location(in: nil)
            return Position2(Float(p.x), Float(p.y))
        default:
            fatalError()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        for touch in touches {
            let id = UUID()
            touchesIDs[ObjectIdentifier(touch)] = id
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .began, position: position)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        for touch in touches {
            let id = touchesIDs[ObjectIdentifier(touch)]!
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .moved, position: position)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        for touch in touches {
            let id = touchesIDs[ObjectIdentifier(touch)]!
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .ended, position: position)
            touchesIDs[ObjectIdentifier(touch)] = nil
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        for touch in touches {
            let id = touchesIDs[ObjectIdentifier(touch)]!
            let type = type(for: touch)
            let position = locationOfTouch(touch, from: event)
            window.window.delegate?.touchChange(id: id, kind: type, event: .canceled, position: position)
            touchesIDs[ObjectIdentifier(touch)] = nil
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
#endif
