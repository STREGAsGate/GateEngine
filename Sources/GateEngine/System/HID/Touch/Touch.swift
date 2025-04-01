/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@MainActor public class Touch {
    public internal(set) var id: AnyHashable
    public internal(set) weak var window: Window?
    public internal(set) var position: Position2
    internal var _precisionPosition: Position2?
    public var precisionPosition: Position2 {
        return _precisionPosition ?? position
    }
    
    public internal(set) var pressure: Float
    
    public internal(set) var phase: Phase
    public internal(set) var kind: TouchKind
    public enum Phase {
        case down
        case up
        case cancelled
    }

    public var normalizedPosition: Position2 {
        var p = position
        if let bounds = window?.size {
            p.x = (1 / bounds.width) * p.x
            p.y = (1 / bounds.height) * p.y
        }
        return p
    }

    init(id: AnyHashable, window: Window? = nil, position: Position2, precisionPosition: Position2?, pressure: Float, phase: Phase, kind: TouchKind) {
        self.id = id
        self.window = window
        self.position = position
        self._precisionPosition = precisionPosition
        self.pressure = pressure
        self.phase = phase
        self.kind = kind
    }
    
    public func locationInView(_ view: View) -> Position2 {
        return view.convert(position, from: window!)
    }
    
    public func isInsideView(_ view: View) -> Bool {
        return view.bounds.contains(locationInView(view))
    }
}

extension Touch: Equatable {
    @inlinable
    public static func == (lhs: Touch, rhs: Touch) -> Bool {
        return lhs.id == rhs.id
    }
}
extension Touch: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
