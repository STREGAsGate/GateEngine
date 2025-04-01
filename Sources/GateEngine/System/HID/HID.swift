/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct InputReceipts {
    @usableFromInline
    var values: [ObjectIdentifier: UInt8] = [:]

    @inlinable
    func receipt(for object: AnyObject) -> UInt8? {
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
    public private(set) lazy var gamePads: GamePadManger = GamePadManger()

    /// The most recent input method used by the end user
    public private(set) var recentInputMethod: InputMethod = .mouseKeyboard

    func update(_ deltaTime: Float) {
        self.mouse.update()
        self.screen.update()
        self.surfaces.update()
        self.gamePads.update()
    }

    internal init() {}
}

extension HID {
    internal func mouseChange(
        event: Mouse.ChangeEvent,
        position: Position2,
        delta: Position2,
        window: Window?
    ) {
        recentInputMethod = .mouseKeyboard
        mouse.mouseChange(event: event, position: position, delta: delta, window: window)
        window?.mouseChange(event: event, position: position, delta: delta)
    }

    internal func mouseClick(
        event: Mouse.ClickEvent,
        button: MouseButton,
        multiClickTime: Double = 0.5,
        position: Position2?,
        delta: Position2?,
        window: Window?
    ) {
        recentInputMethod = .mouseKeyboard
        mouse.mouseClick(
            event: event,
            button: button,
            multiClickTime: multiClickTime,
            position: position,
            delta: delta,
            window: window
        )
        window?.mouseClick(
            event: event, 
            button: button, 
            multiClickTime: multiClickTime, 
            position: position, 
            delta: delta
        )
    }

    internal func mouseScrolled(
        delta: Position3,
        uiDelta: Position3,
        device: Int,
        isMomentum: Bool,
        window: Window?
    ) {
        recentInputMethod = .mouseKeyboard
        mouse.mouseScrolled(
            delta: delta,
            uiDelta: uiDelta,
            device: device,
            isMomentum: isMomentum,
            window: window
        )
        window?.mouseScrolled(
            delta: delta, 
            uiDelta: uiDelta, 
            device: device, 
            isMomentum: isMomentum
        )
    }

    internal func screenTouchChange(
        id: AnyHashable,
        kind: TouchKind,
        event: TouchChangeEvent,
        position: Position2,
        precisionPosition: Position2?,
        pressure: Float,
        window: Window
    ) {
        recentInputMethod = .touchScreen
        screen.touchChange(id: id, kind: kind, event: event, position: position, precisionPosition: precisionPosition, pressure: pressure)
        window.touchChange(id: id, kind: kind, event: event, position: position, precisionPosition: precisionPosition, pressure: pressure)
    }
    
    internal func surfaceTouchChange(
        id: AnyHashable,
        event: TouchChangeEvent,
        surfaceID: AnyHashable,
        normalizedPosition: Position2,
        pressure: Float,
        window: Window?
    ) {
        recentInputMethod = .touchSurface
        surfaces.surfaceTouchChange(
            id: id,
            event: event,
            surfaceID: surfaceID,
            normalizedPosition: normalizedPosition
        )
        window?.surfaceTouchChange(id: id, kind: .unknown, event: event, normalizedPosition: normalizedPosition, pressure: pressure, mouse: self.mouse)
    }

    internal func keyboardDidHandle(
        key: KeyboardKey,
        character: Character?,
        modifiers: KeyboardModifierMask,
        isRepeat: Bool,
        event: KeyboardEvent
    ) -> Bool {
        recentInputMethod = .mouseKeyboard
        return keyboard.keyboardDidHandle(
            key: key,
            character: character,
            modifiers: modifiers,
            isRepeat: isRepeat,
            event: event
        )
    }
}
