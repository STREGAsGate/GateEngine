/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public struct Ray3D: Sendable {
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
    
    @inlinable
    internal func movedInsideEllipsoidSpace(_ ellipsoidRadius: Size3) -> Ray3D {
        return Ray3D(from: self.origin / ellipsoidRadius, toward: (self.direction / ellipsoidRadius).normalized)
    }
}

public extension Transform3 {
    @inlinable
    func createRay() -> Ray3D {
        return Ray3D(from: position, toward: rotation.forward)
    }
}
