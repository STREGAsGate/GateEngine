/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation
import GameMath

extension HID {
    @MainActor public final class SurfaceDevices {
        public private(set) var surfaces: Set<TouchSurface> = []

        internal func surfaceForID(_ surfaceID: UUID) -> TouchSurface {
            if let existing = surfaces.first(where: { $0.id == surfaceID }) {
                return existing
            }
            let new = TouchSurface(id: surfaceID)
            surfaces.insert(new)
            return new
        }

        func surfaceTouchChange(
            id: UUID,
            event: TouchChangeEvent,
            surfaceID: UUID,
            normalizedPosition: Position2
        ) {
            self.surfaceForID(surfaceID).touchChange(
                id: id,
                event: event,
                normalizedPosition: normalizedPosition
            )
        }

        public var any: TouchSurface? {
            return surfaces.first(where: { $0.touches.isEmpty == false }) ?? surfaces.first
        }

        func update() {
            for surface in surfaces {
                surface.update()
            }
        }
    }

    @MainActor public final class TouchSurface {
        public let id: UUID
        public internal(set) var touches: Set<SurfaceTouch> = []
        internal var nextTouches: Set<SurfaceTouch> = []

        internal init(id: UUID) {
            self.id = id
        }

        public enum Gesture {
            case touchDown
            case touchUp
        }

        public func anyTouch(if gesture: Gesture) -> SurfaceTouch? {
            return touches.first { touch in
                return (gesture == .touchUp && touch.phase == .up)
                    || (gesture == .touchDown && touch.phase == .down)
            }
        }

        public func anyTouch(withPhase phase: SurfaceTouch.Phase) -> SurfaceTouch? {
            return touches.first(where: { $0.phase == phase })
        }

        private func existingTouch(_ id: UUID) -> SurfaceTouch? {
            return touches.first(where: { $0.id == id })
        }

        internal func touchChange(
            id: UUID,
            event: TouchChangeEvent,
            normalizedPosition: Position2
        ) {
            let touch: SurfaceTouch
            if let existing = self.existingTouch(id) {
                touch = existing
                touch.position = normalizedPosition
            } else {
                touch = SurfaceTouch(id: id, normalizedPosition: normalizedPosition, phase: .down)
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

extension HID.TouchSurface: Hashable {
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    nonisolated public static func == (lhs: HID.TouchSurface, rhs: HID.TouchSurface) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor public class SurfaceTouch {
    public let id: UUID
    public internal(set) var position: Position2
    public internal(set) var phase: Phase
    public enum Phase {
        case down
        case up
        case cancelled
    }

    init(id: UUID, normalizedPosition: Position2, phase: Phase) {
        self.id = id
        self.position = normalizedPosition
        self.phase = phase
    }
}

extension SurfaceTouch: Equatable {
    @inlinable
    public nonisolated static func == (lhs: SurfaceTouch, rhs: SurfaceTouch) -> Bool {
        return lhs.id == rhs.id
    }
}
extension SurfaceTouch: Hashable {
    @inlinable
    public nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
