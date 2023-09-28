/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

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

    public var normalizedPosition: Position2 {
        var p = position
        if let bounds = window?.size {
            p.x = (1 / bounds.width) * p.x
            p.y = (1 / bounds.height) * p.y
        }
        return p
    }

    init(id: AnyHashable, window: Window? = nil, position: Position2, phase: Phase, kind: TouchKind)
    {
        self.id = id
        self.window = window
        self.position = position
        self.phase = phase
        self.kind = kind
    }
}

extension Touch: Equatable {
    @_transparent
    public static func == (lhs: Touch, rhs: Touch) -> Bool {
        return lhs.id == rhs.id
    }
}
extension Touch: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
