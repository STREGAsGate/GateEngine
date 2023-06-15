/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum MouseButton: Hashable {
    case button1
    case button2
    case button3
    case button4
    case button5
    case unknown(_ index: Int?)
    
    @_transparent
    public static var primary: Self {.button1}
    @_transparent
    public static var secondary: Self {.button2}
    @_transparent
    public static var middle: Self {.button3}
    @_transparent
    public static var backward: Self {.button4}
    @_transparent
    public static var forward: Self {.button5}
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
