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
    public let screen: TouchScreen = TouchScreen()
    public let surfaces: SurfaceDevices = SurfaceDevices()
    public internal(set) lazy var gamePads: GamePadManger = GamePadManger(hid: self)
    
    @inline(__always)
    func update(_ deltaTime: Float) {
        self.mouse.update()
        self.screen.update()
        self.surfaces.update()
        self.gamePads.update()
    }
    
    internal init() {}
}

extension HID /*WindowDelegate*/ {
    @_transparent
    func mouseChange(event: MouseChangeEvent, position: Position2, delta: Position2, window: Window?) {
        mouse.mouseChange(event: event, position: position, delta: delta, window: window)
    }
    @_transparent
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2?, delta: Position2?, window: Window?) {
        mouse.mouseClick(event: event, button: button, count: count, position: position, delta: delta, window: window)
    }

    @_transparent
    func screenTouchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2) {
        screen.touchChange(id: id, kind: kind, event: event, position: position)
    }
    @_transparent
    func surfaceTouchChange(id: AnyHashable, event: TouchChangeEvent, surfaceID: AnyHashable, normalizedPosition: Position2) {
        surfaces.surfaceTouchChange(id: id, event: event, surfaceID: surfaceID, normalizedPosition: normalizedPosition)
    }

    @_transparent
    func keyboardRequestedHandling(key: KeyboardKey,
                                   modifiers: KeyboardModifierMask,
                                   event: KeyboardEvent) -> Bool {
        return keyboard.keyboardRequestedHandling(key: key, modifiers: modifiers, event: event)
    }
}
