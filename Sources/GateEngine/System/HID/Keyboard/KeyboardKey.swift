/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

/// A physical key representation. All values are stored as qwerty layout characters.
/// These keys are for development use for binding actions. Do not use this for text input!
///
/// If you use a layout that is not qwerty, you can use the translation API.
/// ```
/// input.keyboard.button(.qwerty("w")).isPressed
/// input.keyboard.button(.qwertz("w")).isPressed
/// input.keyboard.button(.azerty("z")).isPressed
/// ```
/// The underlying key is still the qwerty representation.
public enum KeyboardKey: Hashable {
    /// The Esc key
    case escape

    case capsLock
    case numLock
    case scrollLock

    case clear

    case contextMenu

    case home
    case end
    case delete
    case pageUp
    case pageDown

    case printScreen
    case insert
    case pauseBreak

    case volumeUp
    case volumeDown
    case mute

    case mediaPlayPause
    case mediaStop
    case mediaNextTrack
    case mediaPreviousTrack
    /**
     F keys on the top of a keyboard
     - parameter number: The F key's number F1, F2, F3, etc...
     */
    case function(_ number: Int)

    public enum KeyOrigin {
        // Any part of the keyboard
        case anyVariation
        // The main keyboard area
        case standard
        // The numeric key pad area
        case numberPad
    }
    /**
     The primary (not shift) symbol on the face of a physical key.
     - parameter character: The character on your keyboard, assuming your keyboard layout is \"qwerty\".
     - parameter origin: The location of the key on the keyboard.
     - note: `character` is in qwerty layout. If you use another layoit for development you can use the following function to translate:
     ``KeyboardKey.qwerty(_,_)``, ``KeyboardKey.qwertz(_,_)``, ``KeyboardKey.azerty(_,_)``
     */
    case character(_ character: Character, _ origin: KeyOrigin = .anyVariation)

    /// The backspace or delete key
    case backspace
    /// The spacebar
    case space
    /// An enter / return key
    case enter(_ origin: KeyOrigin)
    /// An alias for the return key
    public static let `return`: KeyboardKey = .enter(.standard)
    /// The tab key
    case tab
    /// The up arrow
    case up
    /// The down arrow
    case down
    /// The left arrow
    case left
    /// The right arrow
    case right
    /**
     Gives an opportunity to handle keyboard events not handled by GateEngine.
     
     - parameter int: The key code described by the host srepresented as an Int. This is not guaranteed
     - parameter string: The key represented as a String as recommended by the host, if there is any.
     - warning: It is strongly recommended you do not use this for any reason!
     If a keyboard key is not available that you would like to use please file an issue on GitHub and we'll see about adding it.
     */
    case unhandledPlatformKeyCode(_ int: Int?, _ string: Character?)

    public enum Alignment {
        // Any key
        case anyVariation
        // On the left of the space bar
        case leftSide
        // On the right of the space bar
        case rightSide
    }
    case alt(_ alignment: Alignment)
    case host(_ alignment: Alignment)
    case control(_ alignment: Alignment)
    case shift(_ alignment: Alignment)
    // The Fn key
    case fn

    @inline(__always)
    var asModifierMask: KeyboardModifierMask {
        switch self {
        case .alt(_):
            return .alt
        case .host(_):
            return .host
        case .control(_):
            return .control
        case .shift(_):
            return .shift
        case .fn:
            return .function
        default:
            return []
        }
    }
}

extension KeyboardKey {

    /**
     Maps the \"qwerty\" represented character to the default (qwerty) character.

     If your development machine uses \"qwerty\" keyboard layout, then use this function to visually see your own characters.

     The physical location of the keys is always the same. The character is simply for developers to reason about the key.
     - parameter character: The character on your keyboard, assuming your keyboard layout is \"qwerty\".
     - parameter origin: The location of the key on the keyboard. `nil` means any instance of the key.
     - note: If you are solo and use qwerty, this function can be omitted as the unerlying representation is already \"qwerty\".
     */
    @inlinable @inline(__always) @_transparent
    public static func qwerty(_ character: Character, origin: KeyOrigin = .anyVariation) -> Self {
        return .character(character, origin)
    }

    /**
     Maps the \"qwertz\" represented character to the default (qwerty) character.

     If your development machine uses \"qwertz\" keyboard layout, then use this function to visually see your own characters.

     The physical location of the keys is always the same. The character is simply for developers to reason about the key.
     - parameter character: The character on your keyboard, assuming your keyboard layout is \"qwertz\".
     - parameter origin: The location of the key on the keyboard. `nil` means any instance of the key.
     */
    @inlinable @inline(__always)
    public static func qwertz(_ character: Character, origin: KeyOrigin = .anyVariation) -> Self {
        switch character {
        case "<":
            return .character("`", origin)

        case "ß":
            return .character("-", origin)
        case "´":
            return .character("=", origin)

        case "z":
            return .character("y", origin)

        case "ü":
            return .character("[", origin)
        case "+":
            return .character("]", origin)
        case "#":
            return .character("\\", origin)

        case "ö":
            return .character(";", origin)
        case "ä":
            return .character("'", origin)

        case "y":
            return .character("z", origin)

        case "-":
            return .character("/", origin)

        default:
            return .character(character, origin)
        }
    }

    /**
     Maps the \"azerty\" represented character to the default (qwerty) character.

     If your development machine uses \"azerty\" keyboard layout, then use this function to visually see your own characters.

     The physical location of the keys is always the same. The character is simply for developers to reason about the key.
     - parameter character: The character on your keyboard, assuming your keyboard layout is \"azerty\".
     - parameter origin: The location of the key on the keyboard. `nil` means any instance of the key.
     */
    @inlinable @inline(__always)
    public static func azerty(_ character: Character, origin: KeyOrigin = .anyVariation) -> Self {
        switch character {
        case "<":
            return .character("`", origin)
        case "&":
            return .character("1", origin)
        case "é":
            return .character("2", origin)
        case "\"":
            return .character("3", origin)
        case "'":
            return .character("4", origin)
        case "(":
            return .character("5", origin)
        case "§":
            return .character("6", origin)
        case "è":
            return .character("7", origin)
        case "!":
            return .character("8", origin)
        case "ç":
            return .character("9", origin)
        case "à":
            return .character("0", origin)
        case ")":
            return .character("-", origin)
        case "-":
            return .character("=", origin)

        case "a":
            return .character("q", origin)
        case "z":
            return .character("w", origin)

        case "^":
            return .character("[", origin)
        case "$":
            return .character("]", origin)
        case "`":
            return .character("\\", origin)

        case "q":
            return .character("a", origin)
        case "m":
            return .character(";", origin)
        case "ù":
            return .character("'", origin)

        case "w":
            return .character("z", origin)

        case ";":
            return .character(",", origin)
        case ":":
            return .character(".", origin)
        case "=":
            return .character("/", origin)

        default:
            return .character(character, origin)
        }
    }
}

extension KeyboardKey: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Character

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .character(value, .standard)
    }
}
