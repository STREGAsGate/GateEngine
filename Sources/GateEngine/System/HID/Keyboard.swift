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
    
    public func button(_ keyboardKey: KeyboardKey) -> ButtonState {
        if let exactMatch = buttons[keyboardKey] {
            return exactMatch
        }
        if let existing = buttons.first(where: { (key: KeyboardKey, value: ButtonState) in
            if case let .character(character1, origin1) = keyboardKey {
                if case let .character(character2, origin2) = key {
                    guard character1 == character2 else {return false}
                    if  origin1 == nil || origin2 == nil {
                        return true
                    }
                    return origin1 == origin2
                }
                return false
            }
            if case let .enter(origin1) = keyboardKey {
                if case let .enter(origin2) = key {
                    if  origin1 == nil || origin2 == nil {
                        return true
                    }
                    return origin1 == origin2
                }
                return false
            }
            return false
        }) {
            return existing.value
        }
        let button = ButtonState(keyboard: self, key: keyboardKey)
        buttons[keyboardKey] = button
        return button
    }
    
    @inlinable @inline(__always)
    public func pressedButtons() -> [KeyboardKey:ButtonState] {
        return buttons.filter({$0.value.isPressed})
    }
}

public final class CharacterStream {
    public internal(set) var string: String
    public var cursor: String.Index
    
    public init() {
        let emptyString = ""
        string = emptyString
        cursor = emptyString.startIndex
    }
    
    internal func insert(_ character: Character?, as key: KeyboardKey) {
        @_transparent
        func insertCharacter(_ character: Character) {
            self.string.insert(character, at: cursor)
            self.cursor = string.index(after: cursor)
        }
        @_transparent
        func moveLeft() {
            if cursor > string.startIndex {
                let index = string.index(before: cursor)
                cursor = index
            }
        }
        @_transparent
        func moveRight() {
            if cursor < string.endIndex {
                let index = string.index(after: cursor)
                cursor = index
            }
        }
        switch key {
        case .character(_, _):
            if let character {
                insertCharacter(character)
            }
        case .tab:
            insertCharacter("\t")
        case .enter(_):
            insertCharacter("\n")
        case .space:
            insertCharacter(" ")
        case .backspace:
            moveLeft()
            if cursor >= string.startIndex, string.isEmpty == false {
                string.remove(at: cursor)
            }
        case .delete:
            guard cursor < string.endIndex else {return}
            string.remove(at: cursor)
        case .left:
            moveLeft()
        case .right:
            moveRight()
        default:
            break
        }
    }
    
    /// Clear the string
    public func erase() {
        string.removeAll(keepingCapacity: true)
        cursor = string.startIndex
    }
    public func startCapture() {
        Task { @MainActor in
            Game.shared.hid.keyboard.insertStream(self)
        }
    }
    public func stopCapture() {
        Task { @MainActor in
            Game.shared.hid.keyboard.removeStream(self)
        }
    }
    deinit {
        stopCapture()
    }
}

internal extension Keyboard {
    struct WeakCharacterStream: Hashable {
        let id: ObjectIdentifier
        weak var stream: CharacterStream? = nil
        init(stream: CharacterStream) {
            self.id = ObjectIdentifier(stream)
            self.stream = stream
        }
        static func ==(lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    func insertStream(_ stream: CharacterStream) {
        let wrapper = Keyboard.WeakCharacterStream(stream: stream)
        self.activeStreams.insert(wrapper)
    }
    
    func removeStream(_ stream: CharacterStream) {
        let wrapper = Keyboard.WeakCharacterStream(stream: stream)
        self.activeStreams.remove(wrapper)
    }
    
    func updateStreams(with key: KeyboardKey, character: Character?) -> Bool {
        var handled: Bool = false
        for wrapper in activeStreams {
            if let stream = wrapper.stream {
                stream.insert(character, as: key)
                handled = true
            }
        }
        return handled
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
            if case .unhandledPlatformKeyCode(let keyCode, let character) = key {
                let keyCodeString: String
                if let keyCode {
                    keyCodeString = "\(keyCode)"
                }else{
                    keyCodeString = "nil"
                }
                var characterString: String
                if let character, character.isEmpty == false {
                    switch character {
                    case "\r":
                        characterString = "\\r"
                    case "\n":
                        characterString = "\\n"
                    default:
                        characterString = character
                    }
                }else{
                    characterString = "nil"
                }
                return "unhandledPlatformKeyCode(\(keyCodeString), \(characterString))"
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
                self.button(key).isPressed = true
                self.modifiers = modifiers
            }
            _ = self.updateStreams(with: key, character: character)
        case .keyUp:
            self.button(key).isPressed = false
            self.modifiers = modifiers
        case .toggle:
            if isRepeat == false {
                if self.button(key).isPressed == false {
                    self.button(key).isPressed = true
                }else{
                    self.button(key).isPressed = false
                }
            }
        }
        
        return true
    }
}
