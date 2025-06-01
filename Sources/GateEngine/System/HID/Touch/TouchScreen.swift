/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

extension HID {
    @MainActor public final class TouchScreen {
        public internal(set) var touches: Set<Touch> = []
        internal var nextTouches: Set<Touch> = []

        public enum Gesture {
            case touchDown
            case touchUp
        }

        public func anyTouch(withGesture gesture: Gesture) -> Touch? {
            return touches.first { touch in
                return (gesture == .touchUp && touch.phase == .up)
                    || (gesture == .touchDown && touch.phase == .down)
            }
        }

        public func anyTouch(withPhase phase: Touch.Phase) -> Touch? {
            return touches.first(where: { $0.phase == phase })
        }

        private func existingTouch(_ id: UUID) -> Touch? {
            return touches.first(where: { $0.id == id })
        }

        internal func touchChange(
            id: UUID,
            kind: TouchKind,
            event: TouchChangeEvent,
            position: Position2,
            precisionPosition: Position2?,
            pressure: Float
        ) {
            let touch: Touch
            if let existing = self.existingTouch(id) {
                touch = existing
                touch.position = position
            } else {
                touch = Touch(
                    id: id, 
                    position: position, 
                    precisionPosition: precisionPosition, 
                    pressure: pressure, 
                    phase: .down, 
                    kind: kind
                )
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

        func update() {
            let oldTouches = touches
            touches = nextTouches
            nextTouches = oldTouches
            nextTouches.removeAll(keepingCapacity: true)
        }
    }
}
