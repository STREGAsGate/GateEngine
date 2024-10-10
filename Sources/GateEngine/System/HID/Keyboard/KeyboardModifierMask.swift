/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct KeyboardModifierMask: OptionSet, Sendable {
    public typealias RawValue = UInt32
    public let rawValue: RawValue

    /// The Platform specific key. Command for Apple, Flag for Windows, etc...
    public static let host = KeyboardModifierMask(rawValue: 1 << 1)
    /// Any shift key is down
    public static let shift = KeyboardModifierMask(rawValue: 1 << 2)
    /// Any control key is down
    public static let control = KeyboardModifierMask(rawValue: 1 << 3)
    /// Any alt key is down. This is option for Apple
    public static let alt = KeyboardModifierMask(rawValue: 1 << 4)
    /// capslock is enabled
    public static let capsLock = KeyboardModifierMask(rawValue: 1 << 5)
    /// fn is down
    public static let function = KeyboardModifierMask(rawValue: 1 << 6)

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

extension KeyboardModifierMask: CustomStringConvertible {
    public var description: String {
        var text = "["
        if self.contains(.shift) {
            text += "shift, "
        }
        if self.contains(.control) {
            text += "control, "
        }
        if self.contains(.alt) {
            text += "alt, "
        }
        if self.contains(.host) {
            text += "host, "
        }
        if self.contains(.function) {
            text += "fn, "
        }
        if text.hasSuffix(", ") {
            text = String(text[..<text.lastIndex(of: ",")!])
        }
        return text + "]"
    }
}
