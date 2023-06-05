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

    internal var activeStreams: Set<WeakCharacterStream> = []
    
    /**
     Gets a ``ButtonState`` associcated with the physical key.
     
     When requesting a key represents multiple buttons, such as with `.character("1", .anyVariation)`, the `ButtonState` returned will be one of the represented physical keys.
     If you keep a reference to the ``ButtonState`` you will only be checking that physical button. Request a new ``ButtonState`` each time to ensure any variation of the ``KeyboardKey`` is returned.
     
     When requesting with a physical ``KeyboardKey``, like `.shift(.leftSide)`,  it is okay to keep a reference to the ``ButtonState``.
     
     - parameter keybordKey: A ``KeyboardKey`` that represents a physical keyboard button.
     - note: Non-physical keys are keys which have no physical button, like `.control(.anything)` or `.character("0", .anyVariation)`
     - returns: A ``ButtonState``, or `nil` if the key is not a physical key.
     */
    public func button(_ keyboardKey: KeyboardKey) -> ButtonState? {
        if let exactMatch = buttons[keyboardKey] {
            return exactMatch
        }
        if let existing = buttons.first(where: { (key: KeyboardKey, value: ButtonState) in
            if case let .character(character1, origin1) = keyboardKey {
                if case let .character(character2, origin2) = key {
                    guard character1 == character2 else {return false}
                    if origin1 == origin2 || origin1 == .anyVariation {
                        return value.isPressed
                    }
                }
                return false
            }
            if case let .enter(origin1) = keyboardKey {
                if case let .enter(origin2) = key {
                    if origin1 == origin2 || origin1 == .anyVariation {
                        return value.isPressed
                    }
                }
                return false
            }
            if case let .shift(alignment1) = keyboardKey {
                if case let .shift(alignment2) = key {
                    if alignment1 == .anyVariation || alignment2 == .anyVariation {
                        return value.isPressed
                    }
                }
                return false
            }
            if case let .control(alignment1) = keyboardKey {
                if case let .control(alignment2) = key {
                    if alignment1 == .anyVariation || alignment2 == .anyVariation {
                        return value.isPressed
                    }
                }
                return false
            }
            if case let .alt(alignment1) = keyboardKey {
                if case let .alt(alignment2) = key {
                    if alignment1 == .anyVariation || alignment2 == .anyVariation {
                        return value.isPressed
                    }
                }
                return false
            }
            if case let .host(alignment1) = keyboardKey {
                if case let .host(alignment2) = key {
                    if alignment1 == .anyVariation || alignment2 == .anyVariation {
                        return value.isPressed
                    }
                }
                return false
            }
            return false
        }) {
            return existing.value
        }
        switch keyboardKey {
        // Non-physical keys can't have a button
        case .shift(.anyVariation), .alt(.anyVariation), .host(.anyVariation),
             .control(.anyVariation), .enter(.anyVariation),
             .character(_, .anyVariation), .unhandledPlatformKeyCode(_, _):
            return nil
        default:
            let button = ButtonState(keyboard: self, key: keyboardKey)
            buttons[keyboardKey] = button
            return button
        }
    }
    
    /// All currently pressed keyboard keys
    @inlinable @inline(__always)
    public func pressedButtons() -> [KeyboardKey:ButtonState] {
        return buttons.filter({$0.value.isPressed})
    }
    
    
    internal func _button(_ keyboardKey: KeyboardKey) -> ButtonState {
        #if GATEENGINE_DEBUG_HID
        switch keyboardKey {
        // Non-physical keys can't have a button
        case .shift(.anyVariation), .alt(.anyVariation), .host(.anyVariation),
             .control(.anyVariation), .enter(.anyVariation),
             .character(_, .anyVariation), .unhandledPlatformKeyCode(_, _):
            assertionFailure("pass physical keys only")
        default:
           break
        }
        #endif
        if let exactMatch = buttons[keyboardKey] {
            return exactMatch
        }
        let button = ButtonState(keyboard: self, key: keyboardKey)
        buttons[keyboardKey] = button
        return button
    }
}



public extension Keyboard {
    @MainActor final class ButtonState: CustomStringConvertible {
        @usableFromInline
        internal unowned let keyboard: Keyboard
        let key: KeyboardKey
        @usableFromInline
        internal var currentRecipt: UInt8 = 0
        
        nonisolated public var description: String {
            switch key {
            case .unhandledPlatformKeyCode(let keyCode, let character):
                let keyCodeString: String
                if let keyCode {
                    keyCodeString = "\(keyCode)"
                }else{
                    keyCodeString = "nil"
                }
                var characterString: String
                if let character{
                    switch character {
                    case "\r":
                        characterString = "\\r"
                    case "\n":
                        characterString = "\\n"
                    default:
                        characterString = String(character)
                    }
                }else{
                    characterString = "nil"
                }
                return "unhandledPlatformKeyCode(\(keyCodeString), \(characterString))"
            case .character(let character, _):
                return "\(character)"
            case .function(let index):
                return "F\(index)"
            case .enter(.standard):
                return "Enter"
            case .enter(.numberPad):
                return "Enter(NumPad)"
            case .alt(.leftSide):
                return "Left Alt"
            case .alt(.rightSide):
                return "Right Alt"
            case .host(.leftSide):
                return "Left Host"
            case .host(.rightSide):
                return "Right Host"
            case .control(.leftSide):
                return "Left Control"
            case .control(.rightSide):
                return "Right Control"
            case .shift(.leftSide):
                return "Left Shift"
            case .shift(.rightSide):
                return "Right Shift"
            default:
                break
            }

            return "\(key)"
        }
        
        @usableFromInline
        internal init(keyboard: Keyboard, key: KeyboardKey) {
            self.keyboard = keyboard
            self.key = key
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
    func keyboardDidhandle(key: KeyboardKey,
                           character: Character?,
                           modifiers: KeyboardModifierMask,
                           isRepeat: Bool,
                           event: KeyboardEvent) -> Bool {
        switch event {
        case .keyDown:
            if isRepeat == false {
                self._button(key).isPressed = true
                self.modifiers = modifiers
            }
            _ = self.updateStreams(with: key, character: character)
        case .keyUp:
            self._button(key).isPressed = false
            self.modifiers = modifiers
        case .toggle:
            if isRepeat == false {
                let button = self._button(key)
                if button.isPressed == false {
                    button.isPressed = true
                }else{
                    button.isPressed = false
                }
            }
        }
        
        return true
    }
}
