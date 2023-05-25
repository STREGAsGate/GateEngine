/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class Keyboard {
    @usableFromInline
    internal var modifiers: KeyboardModifierMask = []
    @usableFromInline
    internal var buttons: [KeyboardKey:ButtonState] = [:]
    
    @inlinable @inline(__always)
    public func button(_ keyboardKey: KeyboardKey) -> ButtonState {
        if let existing = buttons[keyboardKey] {
            return existing
        }
        let button = ButtonState(keyboard: self)
        buttons[keyboardKey] = button
        return button
    }
}

public extension Keyboard {
    @MainActor final class ButtonState {
        @usableFromInline
        internal unowned let keyboard: Keyboard
        @usableFromInline
        internal var currentRecipt: UInt8 = 0
        
        @usableFromInline
        internal init(keyboard: Keyboard) {
            self.keyboard = keyboard
        }
        
        /// A mask representing special keys that might alter the behavior of this key.
        @inlinable @inline(__always)
        public var modifiers: KeyboardModifierMask {
            return keyboard.modifiers
        }
        
        /// `true` if the button is considered down.
        public internal(set) var isPressed: Bool = false {
            didSet {
                if isPressed != oldValue {
                    currentRecipt &+= 1
                }
            }
        }
                
        /**
         Returns a recipt for the current press or nil if not pressed.
         - parameter recipt: An existing recipt from a previous call to compare to the current pressed state.
         - parameter modifiers: Key modifiers required for a press to be considered valid.
         - returns: A recipt if the key is currently pressed and the was released since the provided recipt.
         */
        @inlinable @inline(__always)
        public func isPressed(ifDifferent recipt: inout InputRecipts, andUsing modifiers: KeyboardModifierMask = []) -> Bool {
            guard isPressed, keyboard.modifiers.contains(modifiers) else {return false}
            let key = ObjectIdentifier(self)
            if let recipt = recipt.values[key], recipt == currentRecipt {
                return false
            }
            recipt.values[key] = currentRecipt
            return true
        }
    }
}

extension Keyboard {
    @inline(__always)
    func keyboardRequestedHandling(key: KeyboardKey,
                                   modifiers: KeyboardModifierMask,
                                   event: KeyboardEvent) -> Bool {
        self.button(key).isPressed = (event == .keyDown)
        self.modifiers = modifiers
        return true
    }
}
