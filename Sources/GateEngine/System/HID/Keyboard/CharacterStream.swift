/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

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
            guard cursor < string.endIndex else { return }
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
    @MainActor
    public func startCapture() {
        Game.shared.hid.keyboard.insertStream(self)
    }
    @MainActor
    public func stopCapture() {
        Game.shared.hid.keyboard.removeStream(self)
    }
}

extension Keyboard {
    struct WeakCharacterStream: Hashable {
        let id: ObjectIdentifier
        weak var stream: CharacterStream? = nil
        init(stream: CharacterStream) {
            self.id = ObjectIdentifier(stream)
            self.stream = stream
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
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
