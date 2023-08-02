/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class Mouse {
    @usableFromInline
    internal weak var _window: Window? = nil
    @inlinable @inline(__always)
    public var window: Window? {
        return _window
    }

    public enum Mode {
        /// Regular cursor behavior
        case standard
        /// The cursor position is locked. Use deltaPosition.
        case locked
    }
    public var mode: Mode {
        get { return _mode }
        set {
            #if os(WASI) || GATEENGINE_ENABLE_WASI_IDE_SUPPORT
            if let wasiWindow = Game.shared.windowManager.mainWindow?.windowBacking as? WASIWindow {
                wasiWindow.pointerLock.requestLock(shouldLock: newValue == .locked)
            }
            #else
            self.setMode(newValue)
            #endif
        }
    }

    internal var _mode: Mode = .standard
    internal func setMode(_ mode: Mode) {
        self._mode = mode
        if mode == .locked {
            self.hidden = true
            self.locked = true
        } else {
            self.hidden = false
            self.locked = false
        }
    }

    @usableFromInline
    internal var buttons: [MouseButton: ButtonState] = [:]

    @inlinable @inline(__always)
    public func button(_ mouseButton: MouseButton) -> ButtonState {
        if let existing = buttons[mouseButton] {
            return existing
        }
        let button = ButtonState(mouse: self)
        buttons[mouseButton] = button
        return button
    }

    @usableFromInline
    internal var scrollers: [MouseScroller: ScrollerState] = [:]

    @inlinable @inline(__always)
    public func scroller(_ mouseScroller: MouseScroller) -> ScrollerState {
        if let existing = scrollers[mouseScroller] {
            return existing
        }
        let scroller = ScrollerState(mouse: self)
        scrollers[mouseScroller] = scroller
        return scroller
    }

    @usableFromInline
    internal var _hidden: Bool = false
    /// Hide or Unhide the mouse cursor
    @inlinable @inline(__always)
    internal var hidden: Bool {
        get { return self._hidden }
        set {
            window?.setMouseHidden(newValue)
            self._hidden = newValue
        }
    }

    /// The location in the window to lock the curosr at
    internal var preferredLockPosition: Position2! = nil
    /// Lock or Unlock the mouse cursor's position
    internal var locked: Bool = false {
        didSet {
            if locked, self.preferredLockPosition == nil {
                self.preferredLockPosition = Position2(window!.size / 2)
            }
        }
    }

    private var _nextDeltaPosition: Position2 = .zero
    /// The distance the cursor moved since it's last update
    public internal(set) var deltaPosition: Position2 = .zero

    @usableFromInline
    internal var _position: Position2? = nil
    /**
     The user interface scaled position of the mouse cursor

     Setting this value will "warp" the mouse to that position.
     - SeeAlso ``interfacePosition``
    */
    @inlinable @inline(__always)
    public internal(set) var position: Position2? {
        get { return _position }
        set {
            if let window, let newValue {
                window.setMousePosition(newValue)
            }
            self._position = newValue
        }
    }

    /**
     The user interface scaled position of the mouse cursor

     Setting this value will "warp" the mouse to that position.
     - SeeAlso ``position``
     */
    @inlinable @inline(__always)
    public internal(set) var interfacePosition: Position2? {
        get {
            if let position, let window {
                return position / window.interfaceScale
            }
            return position
        }
        set {
            if let newValue, let window {
                self._position = newValue * window.interfaceScale
            } else {
                self._position = nil
            }
        }
    }

    @inline(__always)
    func update() {
        self.deltaPosition = self._nextDeltaPosition
        self._nextDeltaPosition = .zero
        if locked {
            self.position = preferredLockPosition
        }
    }
}

extension Mouse {
    public enum ChangeEvent {
        case entered
        case moved
        case exited
    }
    @inline(__always)
    func mouseChange(event: ChangeEvent, position: Position2, delta: Position2, window: Window?) {
        switch event {
        case .entered, .moved:
            self._nextDeltaPosition += delta
            self._position = position
            self._window = window
        case .exited:
            self._position = nil
            self._window = nil
        }
    }

    public enum ClickEvent {
        case buttonDown
        case buttonUp
    }
    @inline(__always)
    func mouseClick(
        event: ClickEvent,
        button: MouseButton,
        multiClickTime: Double,
        position: Position2?,
        delta: Position2?,
        window: Window?
    ) {
        if let position {
            self._position = position
        }
        if let delta {
            self._nextDeltaPosition = delta
        }
        if let window {
            self._window = window
        }
        self.button(button).setIsPressed((event == .buttonDown), multiClickTime: multiClickTime)
    }

    @inline(__always)
    func mouseScrolled(
        delta: Position3,
        uiDelta: Position3,
        device: Int,
        isMomentum: Bool,
        window: Window?
    ) {
        if let window {
            self._window = window
        }

        self.scrollers[.x]?.setDelta(
            delta.x,
            uiDelta: uiDelta.x,
            device: device,
            isMomentum: isMomentum
        )
        self.scrollers[.y]?.setDelta(
            delta.y,
            uiDelta: uiDelta.y,
            device: device,
            isMomentum: isMomentum
        )
        self.scrollers[.z]?.setDelta(
            delta.z,
            uiDelta: uiDelta.z,
            device: device,
            isMomentum: isMomentum
        )
    }
}
