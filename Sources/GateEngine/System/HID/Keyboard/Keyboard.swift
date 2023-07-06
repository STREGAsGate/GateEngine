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
    
    private var needsUpdate: UpdateOptions = []
    struct UpdateOptions: OptionSet {
        let rawValue: UInt
        static let pressedButtons = UpdateOptions(rawValue: 1 << 1)
    }
    
    /**
     Gets a ``ButtonState`` associated with the physical key.
     
     When requesting a key represents multiple buttons, such as with `.character("1", .anyVariation)`, the `ButtonState` returned will be one of the represented physical keys.
     If you keep a reference to the ``ButtonState`` you will only be checking that physical button. Request a new ``ButtonState`` each time to ensure any variation of the ``KeyboardKey`` is returned.
     
     When requesting with a physical ``KeyboardKey``, like `.shift(.leftSide)`,  it is okay to keep a reference to the ``ButtonState``.
     
     - parameter keyboardKey: A ``KeyboardKey`` that represents a physical keyboard button.
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
    
    private var _pressedButtons: [(key: KeyboardKey, button: ButtonState)] = []
    /// All currently pressed keyboard key/button pairs
    @inline(__always)
    public func pressedButtons() -> [(key: KeyboardKey, button: ButtonState)] {
        if needsUpdate.contains(.pressedButtons) {
            needsUpdate.remove(.pressedButtons)
            _pressedButtons = buttons.filter({$0.value.isPressed}).map({(($0.key, $0.value))})
        }
        return _pressedButtons
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
        if let exactMatch: ButtonState = buttons[keyboardKey] {
            return exactMatch
        }
        let button: ButtonState = ButtonState(keyboard: self, key: keyboardKey)
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
        internal var currentReceipt: UInt8 = 0
        
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
                    currentReceipt &+= 1
                }
            }
        }
                
        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter modifiers: Key modifiers required for a press to be considered valid.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         - note: This function does **not** store `block` for later execution. If the function fails the block is discarded.
         */
        @inlinable @inline(__always)
        public func isPressed(ifDifferent receipt: inout InputReceipts, andUsing modifiers: KeyboardModifierMask = []) -> Bool {
            guard isPressed, keyboard.modifiers.contains(modifiers) else {return false}
            let key = ObjectIdentifier(self)
            if let receipt = receipt.values[key], receipt == currentReceipt {
                return false
            }
            receipt.values[key] = currentReceipt
            return true
        }
        
        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter modifiers: Key modifiers required for a press to be considered valid.
         - parameter block: A code block, including this button, that is run if the request is true.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         - note: This function does **not** store `block` for later execution. If the function fails the block is discarded.
         */
        @inlinable @inline(__always)
        public func whenPressed(ifDifferent receipt: inout InputReceipts, andUsing modifiers: KeyboardModifierMask = [], run block: (ButtonState)->Void) {
            if isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                block(self)
            }
        }
    }
}

extension Keyboard {
    @inline(__always)
    func keyboardDidHandle(key: KeyboardKey,
                           character: Character?,
                           modifiers: KeyboardModifierMask,
                           isRepeat: Bool,
                           event: KeyboardEvent) -> Bool {
        
        self.needsUpdate.insert(.pressedButtons)
        
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
                let button: Keyboard.ButtonState = self._button(key)
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
