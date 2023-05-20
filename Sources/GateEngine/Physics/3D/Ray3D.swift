/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public struct Ray3D {
    public var origin: Position3
    public var direction: Direction3
    public init(from origin: Position3, toward direction: Direction3) {
        self.origin = origin
        self.direction = direction
    }
    
    public init(from origin: Position3, toward destination: Position3) {
        self.origin = origin
        self.direction = Direction3(from: origin, to: destination)
    }
    
    @inlinable @inline(__always)
    internal func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Ray3D {
        return Ray3D(from: self.origin / ellipsoidRadius, toward: (self.direction / ellipsoidRadius).normalized)
    }
}

public extension Transform3 {
    @inlinable @inline(__always)
    func createRay() -> Ray3D {
        return Ray3D(from: position, toward: rotation.forward)
    }
}
