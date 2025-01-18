/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Keyboard {
    internal var modifiers: KeyboardModifierMask = []
    internal var buttons: [KeyboardKey: ButtonState] = [:]

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
     - returns: A ``ButtonState``.
     */
    public func button(_ keyboardKey: KeyboardKey) -> ButtonState {
        if let exactMatch = buttons[keyboardKey] {
            return exactMatch
        }
        switch keyboardKey {
        case .shift(.anyVariation), .alt(.anyVariation), .host(.anyVariation),
            .control(.anyVariation), .enter(.anyVariation),
            .character(_, .anyVariation):
            // Non-physical keys can't have a button
            return ButtonState(keyboard: self, key: keyboardKey, isKeyVirtual: true)
        default:
            let button = ButtonState(keyboard: self, key: keyboardKey, isKeyVirtual: false)
            buttons[keyboardKey] = button
            return button
        }
    }

    private var _pressedButtons: [(key: KeyboardKey, button: ButtonState)] = []
    /// All currently pressed keyboard key/button pairs
    public func pressedButtons() -> [(key: KeyboardKey, button: ButtonState)] {
        if needsUpdate.contains(.pressedButtons) {
            needsUpdate.remove(.pressedButtons)
            _pressedButtons = buttons.filter({ $0.value.isPressed }).map({ (($0.key, $0.value)) })
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
        let button: ButtonState = ButtonState(keyboard: self, key: keyboardKey, isKeyVirtual: false)
        buttons[keyboardKey] = button
        return button
    }
    
    /// - returns: true if any key in keys has isPressed == true
    public func anyKeyIsPressed(in keys: [KeyboardKey]) -> Bool {
        for key in keys {
            if self.button(key).isPressed {
                return true
            }
        }
        return false
    }
}

extension Keyboard {
    public final class ButtonState: CustomStringConvertible {
        internal unowned let keyboard: Keyboard
        let key: KeyboardKey
        // true if the key is a representation instead of a physical key
        // such as .shift(anyVariation)
        let isKeyVirtual: Bool
        internal var currentReceipt: UInt8 = 0

        nonisolated public var description: String {
            switch key {
            case .unhandledPlatformKeyCode(let keyCode, let character):
                let keyCodeString: String
                if let keyCode {
                    keyCodeString = "\(keyCode)"
                } else {
                    keyCodeString = "nil"
                }
                var characterString: String
                if let character {
                    switch character {
                    case "\r":
                        characterString = "\\r"
                    case "\n":
                        characterString = "\\n"
                    default:
                        characterString = String(character)
                    }
                } else {
                    characterString = "nil"
                }
                return "unhandledPlatformKeyCode(\(keyCodeString), \(characterString))"
            case .character(let character, _):
                return "\(character)"
            case .function(let index):
                return "F\(index)"
            case .return:
                return "Return"
            case .enter(.numberPad):
                return "Enter"
            case .alt(.leftSide):
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                return "Left Option"
                #else
                return "Left Alt"
                #endif
            case .alt(.rightSide):
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                return "Right Option"
                #else
                return "Right Alt"
                #endif
            case .host(.leftSide):
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                return "Left Command"
                #elseif os(Windows)
                return "Left Flag"
                #else
                return "Left Host"
                #endif
            case .host(.rightSide):
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                return "Right Command"
                #elseif os(Windows)
                return "Right Flag"
                #else
                return "Right Host"
                #endif
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

        internal init(keyboard: Keyboard, key: KeyboardKey, isKeyVirtual: Bool) {
            self.keyboard = keyboard
            self.key = key
            self.isKeyVirtual = isKeyVirtual
        }

        /// A mask representing special keys that might alter the behavior of this key.
        public var modifiers: KeyboardModifierMask {
            return keyboard.modifiers
        }
        
        internal var _isPressed: Bool = false

        /// `true` if the button is considered down.
        public internal(set) var isPressed: Bool {
            set {
                if isKeyVirtual == false {
                    if _isPressed != newValue {
                        _isPressed = newValue
                        currentReceipt &+= 1
                    }
                }
            }
            get {
                if isKeyVirtual == false {
                    return _isPressed
                }
                switch self.key {
                case .shift(.anyVariation):
                    if keyboard.button(.shift(.leftSide)).isPressed {
                        return true
                    }
                    if keyboard.button(.shift(.rightSide)).isPressed {
                        return true
                    }
                case .alt(.anyVariation):
                    if keyboard.button(.alt(.leftSide)).isPressed {
                        return true
                    }
                    if keyboard.button(.alt(.rightSide)).isPressed {
                        return true
                    }
                case .host(.anyVariation):
                    if keyboard.button(.host(.leftSide)).isPressed {
                        return true
                    }
                    if keyboard.button(.host(.rightSide)).isPressed {
                        return true
                    }
                case .control(.anyVariation):
                    if keyboard.button(.control(.leftSide)).isPressed {
                        return true
                    }
                    if keyboard.button(.control(.rightSide)).isPressed {
                        return true
                    }
                case .enter(.anyVariation):
                    if keyboard.button(.enter(.standard)).isPressed {
                        return true
                    }
                    if keyboard.button(.enter(.numberPad)).isPressed {
                        return true
                    }
                case .character(let character, .anyVariation):
                    if keyboard.button(.character(character, .standard)).isPressed {
                        return true
                    }
                    if keyboard.button(.character(character, .numberPad)).isPressed {
                        return true
                    }
                default:
                    break
                }
                return false
            }
        }

        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter modifiers: Key modifiers required for a press to be considered valid.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         - note: This function does **not** store `block` for later execution. If the function fails the block is discarded.
         */
        public func isPressed(
            ifDifferent receipt: inout InputReceipts,
            andUsing modifiers: KeyboardModifierMask = []
        ) -> Bool {
            guard isPressed, keyboard.modifiers.contains(modifiers) else { return false }
            let key = ObjectIdentifier(self)
            if isKeyVirtual == false {
                if let receipt = receipt.values[key], receipt == currentReceipt {
                    return false
                }
                receipt.values[key] = currentReceipt
                return true
            }
            switch self.key {
            case .shift(.anyVariation):
                if keyboard.button(.shift(.leftSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
                if keyboard.button(.shift(.rightSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
            case .alt(.anyVariation):
                if keyboard.button(.alt(.leftSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
                if keyboard.button(.alt(.rightSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
            case .host(.anyVariation):
                if keyboard.button(.host(.leftSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
                if keyboard.button(.host(.rightSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
            case .control(.anyVariation):
                if keyboard.button(.control(.leftSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
                if keyboard.button(.control(.rightSide)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
            case .enter(.anyVariation):
                if keyboard.button(.enter(.standard)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
                if keyboard.button(.enter(.numberPad)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
            case .character(let character, .anyVariation):
                if keyboard.button(.character(character, .standard)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
                if keyboard.button(.character(character, .numberPad)).isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                    return true
                }
            default:
                break
            }
            return false
        }

        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter modifiers: Key modifiers required for a press to be considered valid.
         - parameter block: A code block, including this button, that is run if the request is true.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         - note: This function does **not** store `block` for later execution. If the function fails the block is discarded.
         */
        public func whenPressed(
            ifDifferent receipt: inout InputReceipts,
            andUsing modifiers: KeyboardModifierMask = [],
            run block: (ButtonState) -> Void
        ) {
            if isPressed(ifDifferent: &receipt, andUsing: modifiers) {
                block(self)
            }
        }
    }
}

extension Keyboard {
    func keyboardDidHandle(
        key: KeyboardKey,
        character: Character?,
        modifiers: KeyboardModifierMask,
        isRepeat: Bool,
        event: KeyboardEvent
    ) -> Bool {

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
                } else {
                    button.isPressed = false
                }
            }
        }

        return true
    }
}
