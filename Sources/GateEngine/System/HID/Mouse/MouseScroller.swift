/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public enum MouseScroller: Hashable {
    case x
    case y
    case z
    
    @_transparent
    public static var horizontal: Self {.x}
    @_transparent
    public static var vertical: Self {.y}
    @_transparent
    public static var depth: Self {.z}
}

public extension Mouse {
    @MainActor final class ScrollerState {
        @usableFromInline
        internal unowned let mouse: Mouse
        @usableFromInline
        internal var currentRecipt: UInt8 = 0
        
        private var mostRecentDevice: Int = 0
        @usableFromInline
        internal var lastValueWasMomentum: Bool = false
        
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
        private var ranges: [Int:DeviceRange] = [:]
        internal func setDelta(_ delta: Float, uiDelta: Float, device: Int, isMomentum: Bool) {
            self.delta = delta
            self.uiDelta = uiDelta
            self.mostRecentDevice = device
            self.lastValueWasMomentum = isMomentum
            
            if delta != 0 {
                currentRecipt &+= 1
            }
            if delta == 0 {
                direction = nil
            }else if delta < 0 {
                direction = .negative
            }else{
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
        
        public enum Direction {
            case positive
            case negative
        }
        
        /**
         Returns a recipt for the current press or nil if not pressed.
         - parameter recipt: An existing recipt from a previous call to compare to the current pressed state.
         - returns: A recipt if the key is currently pressed and the was released since the provided recipt.
         */
        @inlinable @inline(__always)
        public func didScroll(ifDifferent recipt: inout InputRecipts, includingMomentum includeMomentum: Bool = false) -> Bool {
            guard delta != 0 else {return false}
            let key = ObjectIdentifier(self)
            
            if let recipt = recipt.values[key], recipt == currentRecipt {
                return false
            }
            recipt.values[key] = currentRecipt
            if includeMomentum == false && lastValueWasMomentum {
                return false
            }
            return true
        }
    }
}
