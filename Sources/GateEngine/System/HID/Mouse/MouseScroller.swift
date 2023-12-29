/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum MouseScroller: Hashable {
    case x
    case y
    case z

    @_transparent
    public static var horizontal: Self { .x }
    @_transparent
    public static var vertical: Self { .y }
    @_transparent
    public static var depth: Self { .z }
}

extension Mouse {
    @MainActor public final class ScrollerState {
        internal unowned let mouse: Mouse
        internal var currentReceipt: UInt8 = 0

        private var mostRecentDevice: Int = 0
        internal var lastValueWasMomentum: Bool = false

        public enum Direction {
            case positive
            case negative
        }
        public private(set) var direction: Direction? = nil
        public private(set) var delta: Float = 0
        public private(set) var uiDelta: Float = 0

        public var ticks: Int {
            if lastValueWasMomentum == false {
                if let min = ranges[mostRecentDevice]?.min {
                    let ticks = Int(delta / min)
                    return ticks
                }
            }
            return 0
        }

        struct DeviceRange {
            var min: Float = .greatestFiniteMagnitude
            var max: Float = -.greatestFiniteMagnitude
        }
        private var ranges: [Int: DeviceRange] = [:]
        internal func setDelta(_ delta: Float, uiDelta: Float, device: Int, isMomentum: Bool) {
            self.delta = delta
            self.uiDelta = uiDelta
            self.mostRecentDevice = device
            self.lastValueWasMomentum = isMomentum

            if delta != 0 {
                currentReceipt &+= 1
            }
            if delta == 0 {
                direction = nil
            } else if delta < 0 {
                direction = .negative
            } else {
                direction = .positive
            }

            if isMomentum == false {
                var deviceRange = ranges[device] ?? DeviceRange()
                deviceRange.max = Float.maximum(deviceRange.max, abs(delta))
                let min = Float.minimum(deviceRange.min, abs(delta))
                if min > 0 {
                    deviceRange.min = min
                }
                ranges[device] = deviceRange
            }
        }

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

        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter includeMomentum: When set to false, excludes values that were generated as momentum effects. Only works on some platforms (like macOS).
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         */
        public func didScroll(
            ifDifferent receipt: inout InputReceipts,
            includingMomentum includeMomentum: Bool = false
        ) -> Bool {
            guard delta != 0 else { return false }
            let key = ObjectIdentifier(self)

            if let receipt = receipt.values[key], receipt == currentReceipt {
                return false
            }
            receipt.values[key] = currentReceipt
            if includeMomentum == false && lastValueWasMomentum {
                return false
            }
            return true
        }

        /**
         Returns a receipt for the current press or nil if not pressed.
         - parameter receipt: An existing receipt from a previous call to compare to the current pressed state.
         - parameter includeMomentum: When set to false, excludes values that were generated as momentum effects. Only works on some platforms (like macOS).
         - parameter block: A code block, including this scroller, that is run if the request is true.
         - returns: A receipt if the key is currently pressed and the was released since the provided receipt.
         */
        public func whenScrolled(
            ifDifferent receipt: inout InputReceipts,
            includingMomentum includeMomentum: Bool = false,
            run block: (_ scroller: ScrollerState) -> Void
        ) {
            if didScroll(ifDifferent: &receipt, includingMomentum: includeMomentum) {
                block(self)
            }
        }
    }
}
