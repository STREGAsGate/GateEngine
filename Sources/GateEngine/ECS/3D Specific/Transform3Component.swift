/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

@dynamicMemberLookup
public struct Transform3Component: Component {
    private var needsUpdate = true
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
    public private(set) var _distanceTraveled: Float = 0
    public mutating func distanceTraveled() -> Float {
        if needsUpdate {
            update()
        }
        return _distanceTraveled
    }
    public private(set) var _directionTraveled: Direction3 = .forward
    public mutating func directionTraveled() -> Direction3 {
        if needsUpdate {
            update()
        }
        return _directionTraveled
    }
    
    @_transparent
    private mutating func update() {
        needsUpdate = false
        self._distanceTraveled = transform.distance(from: previousTransform)
        self._directionTraveled = Direction3(from: previousTransform.position, to: self.position)
        if self._directionTraveled == .zero {
            self._directionTraveled = .forward
        }
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Transform3, T>) -> T {
        get {return transform[keyPath: keyPath]}
        set {transform[keyPath: keyPath] = newValue}
    }

    public init() {}
    public static let componentID: ComponentID = ComponentID()
}

public extension Entity {
    @inlinable
    var transform3: Transform3 {
        @inlinable get {
            return self[Transform3Component.self].transform
        }
        @inlinable set {
            self[Transform3Component.self].transform = newValue
        }
    }
    @inlinable
    var position3: Position3 {
        @inlinable get {
            return transform3.position
        }
        @inlinable set {
            transform3.position = newValue
        }
    }
    @inlinable
    var rotation: Quaternion {
        @inlinable get {
            return transform3.rotation
        }
        @inlinable set {
            transform3.rotation = newValue
        }
    }
    @inlinable
    func distance(from entity: Entity) -> Float {
        return self.transform3.position.distance(from: entity.transform3.position)
    }
    @inlinable
    func distance(from position: Position3) -> Float {
        return self.transform3.position.distance(from: position)
    }
}
