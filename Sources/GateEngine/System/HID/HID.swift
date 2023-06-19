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

public enum InputMethod {
    case mouseKeyboard
    case touchScreen
    case touchSurface
    case gamePad
}

@MainActor public final class HID {
    public let keyboard: Keyboard = Keyboard()
    public let mouse: Mouse = Mouse()
    public let screen: TouchScreen = TouchScreen()
    public let surfaces: SurfaceDevices = SurfaceDevices()
    public internal(set) lazy var gamePads: GamePadManger = GamePadManger(hid: self)
    
    /// The most recent input method used by the end user
    public private(set) var recentInputMethod: InputMethod = .mouseKeyboard
    
    @inline(__always)
    func update(_ deltaTime: Float) {
        self.mouse.update()
        self.screen.update()
        self.surfaces.update()
        self.gamePads.update()
    }
    
    internal init() {}
}

extension HID {
    @_transparent
    func mouseChange(event: Mouse.ChangeEvent, position: Position2, delta: Position2, window: Window?) {
        recentInputMethod = .mouseKeyboard
        mouse.mouseChange(event: event, position: position, delta: delta, window: window)
    }
    @_transparent
    func mouseClick(event: Mouse.ClickEvent, button: MouseButton, count: Int, position: Position2?, delta: Position2?, window: Window?) {
        recentInputMethod = .mouseKeyboard
        mouse.mouseClick(event: event, button: button, count: count, position: position, delta: delta, window: window)
    }
    @_transparent
    func mouseScrolled(delta: Position3, uiDelta: Position3, device: Int, isMomentum: Bool, window: Window?) {
        recentInputMethod = .mouseKeyboard
        mouse.mouseScrolled(delta: delta, uiDelta: uiDelta, device: device, isMomentum: isMomentum, window: window)
    }

    @_transparent
    func screenTouchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2) {
        recentInputMethod = .touchScreen
        screen.touchChange(id: id, kind: kind, event: event, position: position)
    }
    @_transparent
    func surfaceTouchChange(id: AnyHashable, event: TouchChangeEvent, surfaceID: AnyHashable, normalizedPosition: Position2) {
        recentInputMethod = .touchSurface
        surfaces.surfaceTouchChange(id: id, event: event, surfaceID: surfaceID, normalizedPosition: normalizedPosition)
    }

    @_transparent
    func keyboardDidhandle(key: KeyboardKey,
                           character: Character?,
                           modifiers: KeyboardModifierMask,
                           isRepeat: Bool,
                           event: KeyboardEvent) -> Bool {
        recentInputMethod = .mouseKeyboard
        return keyboard.keyboardDidhandle(key: key, character: character, modifiers: modifiers, isRepeat: isRepeat, event: event)
    }
}
