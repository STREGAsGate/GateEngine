/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public extension HID {
    @MainActor final class TouchScreen {
        public internal(set) var touches: Set<Touch> = []
        internal var nextTouches: Set<Touch> = []
        
        public enum Gesture {
            case touchDown
            case touchUp
        }
        
        @inlinable @inline(__always)
        public func anyTouch(if gesture: Gesture) -> Touch? {
            return touches.first { touch in
                return (gesture == .touchUp && touch.phase == .up) || (gesture == .touchDown && touch.phase == .down)
            }
        }
        
        @inlinable @inline(__always)
        public func anyTouch(withPhase phase: Touch.Phase) -> Touch? {
            return touches.first(where: {$0.phase == phase})
        }
        
        @inline(__always)
        private func existingTouch(_ id: AnyHashable) -> Touch? {
            return touches.first(where: {$0.id == id})
        }
        
        @usableFromInline
        internal func touchChange(id: AnyHashable, kind: TouchKind, event: TouchChangeEvent, position: Position2) {
            let touch: Touch
            if let existing = self.existingTouch(id) {
                touch = existing
                touch.position = position
            }else{
                touch = Touch(id: id, position: position, phase: .down, kind: kind)
            }
            switch event {
            case .began:
                touch.phase = .down
            case .moved:
                touch.phase = .down
            case .ended:
                touch.phase = .up
            case .canceled:
                touch.phase = .cancelled
            }

            nextTouches.insert(touch)
        }
        
        @inline(__always)
        func update() {
            let oldTouches = touches
            touches = nextTouches
            nextTouches = oldTouches
            nextTouches.removeAll(keepingCapacity: true)
        }
    }
}

@MainActor public class Touch {
    public internal(set) var id: AnyHashable
    public internal(set) weak var window: Window?
    public internal(set) var position: Position2
    public internal(set) var phase: Phase
    public internal(set) var kind: TouchKind
    public enum Phase {
        case down
        case up
        case cancelled
    }
    
    @inlinable @inline(__always)
    public var normalizedPosition: Position2 {
        var p = position
        if let bounds = window?.size {
            p.x = (1 / bounds.width) * p.x
            p.y = (1 / bounds.height) * p.y
        }
        return p
    }
    
    init(id: AnyHashable, window: Window? = nil, position: Position2, phase: Phase, kind: TouchKind) {
        self.id = id
        self.window = window
        self.position = position
        self.phase = phase
        self.kind = kind
    }
}

extension Touch: Equatable {
    @_transparent
    public static func ==(lhs: Touch, rhs: Touch) -> Bool {
        return lhs.id == rhs.id
    }
}
extension Touch: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
