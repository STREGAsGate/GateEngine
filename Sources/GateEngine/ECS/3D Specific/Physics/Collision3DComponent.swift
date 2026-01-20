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
    
    @MainActor
    @inlinable
    public func updateColliders(_ entity: Entity) {
        guard let transformComponent = entity.component(ofType: Transform3Component.self) else {return}
        
        if let rig3DComponent = entity.rig3DComponent {
            if let colliderJointName = rig3DComponent.updateColliderFromBoneNamed {
                if let joint = rig3DComponent.skeleton?.jointNamed(colliderJointName) {
                    // Move the joint into world space
                    var transform = (transformComponent.transform.matrix() * joint.modelSpace).transform
                    // Subtract the entity poistion so the joint is relative to zero, to make the transform represent only size and offset
                    transform.position -= transformComponent.position
                    // Update the collider size and offset
                    self.collider.update(withLocalTransform: transform)
                    self.rayCastCollider?.update(withLocalTransform: transform)
                }
            }
        }
        
        // Update the collider world transform
        self.collider.update(withWorldTransform: transformComponent.transform)
        self.rayCastCollider?.update(withWorldTransform: transformComponent.transform)
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
