/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public extension HID {
    @MainActor final class SurfaceDevices {
        public private(set) var surfaces: Set<TouchSurface> = []
        
        @inline(__always)
        internal func surfaceForID(_ surfaceID: AnyHashable) -> TouchSurface {
            if let existing = surfaces.first(where: {$0.id == surfaceID}) {
                return existing
            }
            let new = TouchSurface(id: surfaceID)
            surfaces.insert(new)
            return new
        }
        
        @inline(__always)
        func surfaceTouchChange(id: AnyHashable, event: TouchChangeEvent, surfaceID: AnyHashable, normalizedPosition: Position2) {
            self.surfaceForID(surfaceID).touchChange(id: id, event: event, normalizedPosition: normalizedPosition)
        }
        
        @inlinable @inline(__always)
        public var any: TouchSurface? {
            return surfaces.first(where: {$0.touches.isEmpty == false}) ?? surfaces.first
        }
        
        @inline(__always)
        func update() {
            for surface in surfaces {
                surface.update()
            }
        }
    }
    
    @MainActor final class TouchSurface {
        @usableFromInline
        nonisolated let id: AnyHashable
        public internal(set) var touches: Set<SurfaceTouch> = []
        internal var nextTouches: Set<SurfaceTouch> = []
        
        internal init(id: AnyHashable) {
            self.id = id
        }
        
        public enum Gesture {
            case touchDown
            case touchUp
        }
        
        @inlinable @inline(__always)
        public func anyTouch(if gesture: Gesture) -> SurfaceTouch? {
            return touches.first { touch in
                return (gesture == .touchUp && touch.phase == .up) || (gesture == .touchDown && touch.phase == .down)
            }
        }
        
        @inlinable @inline(__always)
        public func anyTouch(withPhase phase: SurfaceTouch.Phase) -> SurfaceTouch? {
            return touches.first(where: {$0.phase == phase})
        }
        
        @inline(__always)
        private func existingTouch(_ id: AnyHashable) -> SurfaceTouch? {
            return touches.first(where: {$0.id == id})
        }
        
        @usableFromInline
        internal func touchChange(id: AnyHashable, event: TouchChangeEvent, normalizedPosition: Position2) {
            let touch: SurfaceTouch
            if let existing = self.existingTouch(id) {
                touch = existing
                touch.position = normalizedPosition
            }else{
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
        
        @inline(__always)
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
    @_transparent
    nonisolated public static func ==(lhs: HID.TouchSurface, rhs: HID.TouchSurface) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor public class SurfaceTouch {
    public internal(set) var id: AnyHashable
    public internal(set) var position: Position2
    public internal(set) var phase: Phase
    public enum Phase {
        case down
        case up
        case cancelled
    }
    
    init(id: AnyHashable, normalizedPosition: Position2, phase: Phase) {
        self.id = id
        self.position = normalizedPosition
        self.phase = phase
    }
}

extension SurfaceTouch: Equatable {
    @_transparent
    public static func ==(lhs: SurfaceTouch, rhs: SurfaceTouch) -> Bool {
        return lhs.id == rhs.id
    }
}
extension SurfaceTouch: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
