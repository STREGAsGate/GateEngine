/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@dynamicMemberLookup
public final class Transform2Component: Component {
    @usableFromInline
    internal private(set) var needsUpdate = true
    public var transform: Transform2 = .default {
        didSet {
            needsUpdate = true
        }
    }
    public var previousTransform: Transform2 = .default {
        didSet {
            needsUpdate = true
        }
    }

    public private(set) var _distanceTraveled: Float = 0
    @inlinable
    public func distanceTraveled() -> Float {
        if needsUpdate {
            update()
        }
        return _distanceTraveled
    }

    public private(set) var _directionTraveled: Direction2 = .right
    @inlinable
    public func directionTraveled() -> Direction2 {
        if needsUpdate {
            update()
        }
        return _directionTraveled
    }

    @usableFromInline
    internal func update() {
        needsUpdate = false
        self._distanceTraveled = transform.distance(from: previousTransform)
        self._directionTraveled = Direction2(from: previousTransform.position, to: self.position)
        if self._directionTraveled == .zero {
            self._directionTraveled = .right
        }
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Transform2, T>) -> T {
        get { return transform[keyPath: keyPath] }
        set { transform[keyPath: keyPath] = newValue }
    }

    public init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable
    public var transform2: Transform2 {
        @inlinable get {
            return self[Transform2Component.self].transform
        }
        @inlinable set {
            self[Transform2Component.self].transform = newValue
        }
    }

    @inlinable
    public var position2: Position2 {
        @inlinable get {
            return transform2.position
        }
        @inlinable set {
            transform2.position = newValue
        }
    }

    @inlinable
    public func distance(from position: Position2) -> Float {
        return self.transform2.position.distance(from: position)
    }
}
