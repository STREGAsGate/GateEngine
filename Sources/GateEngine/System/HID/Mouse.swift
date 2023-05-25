/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class Mouse {
    public internal(set) weak var window: Window? = nil
    
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
    internal var _position: Position2? = nil
    @inlinable @inline(__always)
    public var position: Position2? {
        get {return _position}
        set {
            if let window, let newValue {
                Game.shared.internalPlatform.setMousePosition(newValue, window: window)
            }
            self._position = newValue
        }
    }
    
    @inlinable @inline(__always)
    public var interfacePosition: Position2? {
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
}

public extension Mouse {
    @MainActor final class ButtonState {
        @usableFromInline
        internal unowned let mouse: Mouse
        @usableFromInline
        internal var currentRecipt: UInt8 = 0
        
        @usableFromInline
        internal init(mouse: Mouse) {
            self.mouse = mouse
        }
        
        /// The location of the mouse in the windows native pixels
        @inlinable @inline(__always)
        public var position: Position2? {
            return mouse.position
        }
        
        /// The location of the mouse in the window
        @inlinable @inline(__always)
        public var interfacePosition: Position2? {
            return mouse.interfacePosition
        }
        
        /// The current platform's preference for "Double Click" gesture
        public internal(set) var pressCount: Int? = nil
        
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
         - returns: A recipt if the key is currently pressed and the was released since the provided recipt.
         */
        @inlinable @inline(__always)
        public func isPressed(ifDifferent recipt: inout InputRecipts) -> Bool {
            guard isPressed else {return false}
            let key = ObjectIdentifier(self)
            if let recipt = recipt.values[key], recipt == currentRecipt {
                return false
            }
            recipt.values[key] = currentRecipt
            return true
        }
    }
}

extension Mouse {
    @usableFromInline
    func mouseChange(event: MouseChangeEvent, position: Position2, window: Window?) {
        self.window = window
        switch event {
        case .entered, .moved:
            self._position = position
        case .exited:
            self.position = nil
        }
    }
    @usableFromInline
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2, window: Window?) {
        self.window = window
        self._position = position
        let button = self.button(button)
        button.isPressed = (event == .buttonDown)
        button.pressCount = count
    }
}
