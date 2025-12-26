/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension Collision3DComponent {
    public enum Kind {
        case `static`
        case dynamic(_ priority: Int)
    }
    public struct Options: OptionSet, Sendable {
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

public final class Collision3DComponent: Component {
    public var isEnabled: Bool = true

    public var kind: Kind = .static

    public var options: Options = []

    public var collider: any Collider3D = AxisAlignedBoundingBox3D(
        center: .zero,
        offset: .zero,
        radius: .one
    )
    
    public var rayCastCollider: (any Collider3D)? = nil

    public internal(set) var touching: [(triangle: CollisionTriangle, interpenetration: Interpenetration3D)] = []

    public internal(set) var intersecting: [(entity: Entity, interpenetration: Interpenetration3D)] = []

    public var offset: Transform3 = .default

    /// The distance down for a surface to be considered a ledge. Option `ledgeDetection` required.
    public var ledgeHeight: Float = 0.5

    public var triangleFilter: ((CollisionTriangle) -> (Bool))? = nil

    public var entityFilter: ((Entity) -> (Bool))? = nil

    @inlinable
    public func interpenetration(comparing: some Collider3D) -> Interpenetration3D? {
        return collider.interpenetration(comparing: comparing)
    }

    @inlinable
    public func interpenetration(comparing: Collision3DComponent) -> Interpenetration3D? {
        let lhs = collider
        let rhs = comparing.collider
        return lhs.interpenetration(comparing: rhs)
    }

    @inlinable
    public func updateColliders(_ transform: Transform3) {
        self.collider.update(transform: transform)
        self.rayCastCollider?.update(transform: transform)
    }
    
    @MainActor
    @inlinable
    internal func updateColliders(_ rigComponent: Rig3DComponent) {
        // Update collider from animation
        if let colliderJointName = rigComponent.updateColliderFromBoneNamed {
            if let joint = rigComponent.skeleton.jointNamed(colliderJointName) {
                let matrix = joint.modelSpace
                self.update(sizeAndOffsetUsingTransform: matrix.transform)
                self.rayCastCollider?.update(sizeAndOffsetUsingTransform: matrix.transform)
            } else {
                fatalError("Failed to find joint \(colliderJointName).")
            }
        }
    }

    @inlinable
    public func update(sizeAndOffsetUsingTransform transform: Transform3) {
        self.collider.update(sizeAndOffsetUsingTransform: transform)
        self.rayCastCollider?.update(sizeAndOffsetUsingTransform: transform)
    }

    public required init() {}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable
    public var collision3DComponent: Collision3DComponent {
        return self[Collision3DComponent.self]
    }
}
