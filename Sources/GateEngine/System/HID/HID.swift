/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct InputRecipts {
    @usableFromInline
    var values: [ObjectIdentifier:UInt8] = [:]
    
    @inlinable
    func recipt(for object: AnyObject) -> UInt8? {
        let key = ObjectIdentifier(object)
        return values[key]
    }
    
    public init() {
        
    }
}

@MainActor public final class HID {
    public let keyboard: Keyboard = Keyboard()
    public let mouse: Mouse = Mouse()
    public let screen: Screen = Screen()
    public internal(set) lazy var gamePads: GamePadManger = GamePadManger(hid: self)
    
    internal init() {}
}

extension HID /*WindowDelegate*/ {
    @_transparent
    func mouseChange(event: MouseChangeEvent, position: Position2) {
        mouse.mouseChange(event: event, position: position)
    }
    @_transparent
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2) {
        mouse.mouseClick(event: event, button: button, count: count, position: position)
    }

    @_transparent
    func touchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2) {
        screen.touchChange(id: id, kind: kind, event: event, position: position)
    }

    @_transparent
    func keyboardRequestedHandling(key: KeyboardKey,
                                   modifiers: KeyboardModifierMask,
                                   event: KeyboardEvent) -> Bool {
        return keyboard.keyboardRequestedHandling(key: key, modifiers: modifiers, event: event)
    }
}
