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
    
    @usableFromInline
    internal var buttons: [MouseButton:ButtonState] = [:]
    
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
    internal var scrollers: [MouseScroller:ScrollerState] = [:]
    
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
    public var hidden: Bool {
        get {return self._hidden}
        set {
            window?.setMouseHidden(newValue)
            self._hidden = newValue
        }
    }
    
    /// The location in the window to lock the curosr at
    public var preferredLockPosition: Position2! = nil
    /// Lock or Unlock the mouse cursor's position
    public var locked: Bool = false {
        didSet {
            if locked, self.preferredLockPosition == nil {
                self.preferredLockPosition = Position2(window!.size / 2)
            }
        }
    }
    
    private var _nextDeltaPosition: Position2 = .zero
    /// The distance the cursor moved since it's last postion change
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
        get {return _position}
        set {
            if let window, let newValue {
                window.setMousePosition(newValue)
            }
            self._position = newValue
        }
    }
    
    @inlinable @inline(__always)
    internal func setPosition(_ position: Position2, inWindow window: Window) {
        self._window = window
        window.setMousePosition(position)
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
                self.position = newValue * window.interfaceScale
            }else{
                self.position = nil
            }
        }
    }
    
    @inline(__always)
    func update() {
        self.deltaPosition = self._nextDeltaPosition
        self._nextDeltaPosition = .zero
    }
}

extension Mouse {
    @inline(__always)
    func mouseChange(event: MouseChangeEvent, position: Position2, delta: Position2, window: Window?) {
        switch event {
        case .entered, .moved:
            if locked, let preferredLockPosition {
                // discard high values
                if abs(delta.min) < 500 && abs(delta.max) < 500 {
                    self._nextDeltaPosition += delta
                }
                self.position = preferredLockPosition
            }else{
                self._position = position
            }
            self._window = window
        case .exited:
            self._position = nil
            self._window = nil
        }
    }
    @inline(__always)
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2?, delta: Position2?, window: Window?) {
        if let position {
            self._position = position
        }
        if let delta {
            self._nextDeltaPosition = delta
        }
        if let window {
            self._window = window
        }
        let button = self.button(button)
        button.isPressed = (event == .buttonDown)
        button.pressCount = count
    }
    
    @inline(__always)
    func mouseScrolled(delta: Position3, device: Int, window: Window?) {
        if let window {
            self._window = window
        }
        
        self.scrollers[.x]?.setDelta(delta.x, device: device)
        self.scrollers[.y]?.setDelta(delta.y, device: device)
        self.scrollers[.z]?.setDelta(delta.z, device: device)
    }
}
