/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@dynamicMemberLookup
public final class Transform3Component: Component {
    @usableFromInline
    internal private(set) var needsUpdate = true

    public var transform: Transform3 = .default {
        didSet {
            needsUpdate = true
        }
    }

    public var previousTransform: Transform3 = .default {
        didSet {
            needsUpdate = true
        }
    }

    public internal(set) var _distanceTraveled: Float = 0
    @inlinable @inline(__always)
    public func distanceTraveled() -> Float {
        if needsUpdate {
            update()
        }
        return _distanceTraveled
    }

    public private(set) var _directionTraveled: Direction3 = .forward
    @inlinable @inline(__always)
    public func directionTraveled() -> Direction3 {
        if needsUpdate {
            update()
        }
        return _directionTraveled
    }

    @usableFromInline @inline(__always)
    internal func update() {
        needsUpdate = false
        self._distanceTraveled = transform.distance(from: previousTransform)
        self._directionTraveled = Direction3(from: previousTransform.position, to: self.position)
        if self._directionTraveled == .zero {
            self._directionTraveled = .forward
        }
    }

    @inlinable @inline(__always)
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Transform3, T>) -> T {
        get { return transform[keyPath: keyPath] }
        set { transform[keyPath: keyPath] = newValue }
    }

    public init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    public var transform3: Transform3 {
        get {
            return self[Transform3Component.self].transform
        }
        set {
            self[Transform3Component.self].transform = newValue
        }
    }

    @inlinable @inline(__always)
    public var position3: Position3 {
        get {
            return transform3.position
        }
        set {
            transform3.position = newValue
        }
    }

    @inlinable @inline(__always)
    public var rotation: Quaternion {
        get {
            return transform3.rotation
        }
        set {
            transform3.rotation = newValue
        }
    }

    @inlinable @inline(__always)
    public func distance(from entity: Entity) -> Float {
        return self.transform3.position.distance(from: entity.transform3.position)
    }

    @inlinable @inline(__always)
    public func distance(from position: Position3) -> Float {
        return self.transform3.position.distance(from: position)
    }
}
