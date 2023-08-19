/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

extension HID {
    @MainActor public final class TouchScreen {
        public internal(set) var touches: Set<Touch> = []
        internal var nextTouches: Set<Touch> = []

        public enum Gesture {
            case touchDown
            case touchUp
        }

        @inlinable @inline(__always)
        public func anyTouch(withGesture gesture: Gesture) -> Touch? {
            return touches.first { touch in
                return (gesture == .touchUp && touch.phase == .up)
                    || (gesture == .touchDown && touch.phase == .down)
            }
        }

        @inlinable @inline(__always)
        public func anyTouch(withPhase phase: Touch.Phase) -> Touch? {
            return touches.first(where: { $0.phase == phase })
        }

        @inline(__always)
        private func existingTouch(_ id: AnyHashable) -> Touch? {
            return touches.first(where: { $0.id == id })
        }

        @usableFromInline
        internal func touchChange(
            id: AnyHashable,
            kind: TouchKind,
            event: TouchChangeEvent,
            position: Position2
        ) {
            let touch: Touch
            if let existing = self.existingTouch(id) {
                touch = existing
                touch.position = position
            } else {
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
