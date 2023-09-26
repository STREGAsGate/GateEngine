/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension Collision2DComponent {
    public enum Kind {
        case `static`
        case dynamic
    }
    public struct Options: OptionSet {
        public let rawValue: UInt32

        public static let skipEntities = Options(rawValue: 1 << 1)
        public static let skipTriangles = Options(rawValue: 1 << 2)

        /// Prevent high velocity objects from skipping collision detection
        public static let robustProtection = Options(rawValue: 1 << 3)
        /// Keep object from falling off ledges
        public static let ledgeDetection = Options(rawValue: 1 << 4)

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

public final class Collision2DComponent: Component {
    public var isEnabled: Bool = true

    public var kind: Kind = .static

    public var options: Options = []

    public var collider: any Collider2D = AxisAlignedBoundingBox2D(
        center: .zero,
        offset: .zero,
        radius: .one
    )

    var touching: [(triangle: CollisionTriangle, interpenetration: Interpenetration2D)] = []

    var intersecting: [(entity: Entity, interpenetration: Interpenetration2D)] = []

    public var offset: Transform2 = .default

    /// The distance down for a surface to be considered a ledge. Option `ledgeDetection` required.
    public var ledgeHeight: Float = 0.5

    public var triangleFilter: ((CollisionTriangle) -> (Bool))? = nil

    public var entityFilter: ((Entity) -> (Bool))? = nil

    @inlinable @inline(__always)
    func interpenetration(comparing: any Collider2D) -> Interpenetration2D? {
        return collider.interpenetration(comparing: comparing)
    }

    @inlinable @inline(__always)
    func interpenetration(comparing: Collision2DComponent) -> Interpenetration2D? {
        let lhs = collider
        let rhs = comparing.collider
        return lhs.interpenetration(comparing: rhs)
    }

    @inlinable @inline(__always)
    func updateColliders(_ transform: Transform2) {
        self.collider.update(transform: transform)
    }

    @inlinable @inline(__always)
    func update(sizeAndOffsetUsingTransform transform: Transform2) {
        self.collider.update(sizeAndOffsetUsingTransform: transform)
    }

    public required init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    var collision2DComponent: Collision2DComponent {
        return self[Collision2DComponent.self]
    }
}
