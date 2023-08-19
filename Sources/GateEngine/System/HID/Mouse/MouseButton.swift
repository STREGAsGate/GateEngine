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
    public static var primary: Self { .button1 }
    @_transparent
    public static var secondary: Self { .button2 }
    @_transparent
    public static var middle: Self { .button3 }
    @_transparent
    public static var backward: Self { .button4 }
    @_transparent
    public static var forward: Self { .button5 }
}

extension Mouse {
    @MainActor public final class ButtonState {
        @usableFromInline
        internal unowned let mouse: Mouse
        @usableFromInline
        internal var currentReceipt: UInt8 = 0

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
        public var pressCount: Int { multiClick.count }

        /// `true` if the button is considered down.
        public internal(set) var isPressed: Bool = false

        public enum Gesture {
            case singleClick
            case doubleClick
            case tripleClick
        }

        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter gesture: A repetition based gesture to require for success.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         */
        @inlinable @inline(__always)
        public func isPressed(
            ifDifferent receipt: inout InputReceipts,
            andGesture gesture: Gesture? = nil
        ) -> Bool {
            guard isPressed else { return false }
            let key = ObjectIdentifier(self)
            if let receipt = receipt.values[key], receipt == currentReceipt {
                return false
            }
            receipt.values[key] = currentReceipt
            switch gesture {
            case .singleClick:
                return pressCount == 1
            case .doubleClick:
                return pressCount == 2
            case .tripleClick:
                return pressCount == 3
            case nil:
                return true
            }
        }

        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter block: A code block, including this button, that is run if the request is true.
         - parameter gesture: A repetition based gesture to require for success.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         - note: This function does **not** store `block` for later execution. If the function fails the block is discarded.
         */
        @inlinable @inline(__always)
        public func whenPressed(
            ifDifferent receipt: inout InputReceipts,
            andGesture gesture: Gesture? = nil,
            run block: (_ button: ButtonState) -> Void
        ) {
            if isPressed(ifDifferent: &receipt, andGesture: gesture) {
                block(self)
            }
        }

        private struct MultiClick {
            var count: Int = 0
            var previousTime: Double = 0
            var previousPosition: Position2? = nil
        }
        private var multiClick: MultiClick = MultiClick()
        internal func setIsPressed(_ pressed: Bool, multiClickTime: Double) {
            if pressed != isPressed {
                currentReceipt &+= 1
            }

            self.isPressed = pressed

            if pressed {  // On Down increment multi-click
                let now: Double = Game.shared.platform.systemTime()
                let delta: Double = now - multiClick.previousTime
                var isMultiClick = delta <= multiClickTime
                if isMultiClick {
                    if let position = mouse.position,
                        let previousPosition = multiClick.previousPosition
                    {
                        if position.distance(from: previousPosition) > 16 {
                            // If the cursor moved too much cancel multi-click
                            isMultiClick = false
                        }
                    }
                }

                if isMultiClick {
                    multiClick.count += 1
                    multiClick.previousPosition = mouse.position
                } else {
                    multiClick.count = 1
                    multiClick.previousPosition = nil
                }
                multiClick.previousTime = now
            }
        }
    }
}
