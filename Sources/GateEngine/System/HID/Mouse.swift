/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public final class Mouse {
    public internal(set) weak var window: Window? = nil
    public internal(set) var position: Position2? = nil
    public var interfacePosition: Position2? {
        if let position, let window {
            return position / window.interfaceScale
        }
        return position
    }
    internal var buttons: [MouseButton:ButtonState] = [:]
    
    public func button(_ mouseButton: MouseButton) -> ButtonState {
        if let existing = buttons[mouseButton] {
            return existing
        }
        let button = ButtonState(mouse: self)
        buttons[mouseButton] = button
        return button
    }
}

public extension Mouse {
    @MainActor final class ButtonState {
        internal unowned let mouse: Mouse
        internal var currentRecipt: UInt8 = 0
        
        internal init(mouse: Mouse) {
            self.mouse = mouse
        }
        
        /// The location of the mouse in the windows native pixels
        public var position: Position2? {
            return mouse.position
        }
        
        /// The location of the mouse in the window
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
            self.position = position
        case .exited:
            self.position = nil
        }
    }
    @usableFromInline
    func mouseClick(event: MouseClickEvent, button: MouseButton, count: Int?, position: Position2, window: Window?) {
        self.window = window
        self.position = position
        let button = self.button(button)
        button.isPressed = (event == .buttonDown)
        button.pressCount = count
    }
}
