/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public extension Collision3DComponent {
    enum Kind {
        case `static`
        case dynamic
    }
    struct Options: OptionSet {
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
    
    @available(*, unavailable /*0.0.5*/, message: "Primitive colliders are generated automatically now.")
    public var primitiveCollider: AxisAlignedBoundingBox3D = AxisAlignedBoundingBox3D(center: .zero, offset: .zero, radius: .one)
    @available(*, deprecated /*0.0.5*/, renamed: "collider", message: "Set the collider property directly.")
    @inlinable @inline(__always)
    public var detailCollider: Collider3D! {
        get {return collider}
        set {collider = newValue}
    }
    public var collider: Collider3D = AxisAlignedBoundingBox3D(center: .zero, offset: .zero, radius: .one)
    
    var touching: [(triangle: CollisionTriangle, interpenetration: Interpenetration3D)] = []
    var intersecting: [(entity: Entity, interpenetration: Interpenetration3D)] = []
    
    public var offset: Transform3 = .default
    
    /// The distance down for a surface to be considered a ledge. Option `ledgeDetection` required.
    public var ledgeHeight: Float = 0.5
    
    public var triangleFilter: ((CollisionTriangle)->(Bool))? = nil
    public var entityFilter: ((Entity)->(Bool))? = nil
    
    @inlinable @inline(__always)
    func interpenetration(comparing: Collider3D) -> Interpenetration3D? {
        return collider.interpenetration(comparing: comparing)
    }
    @inlinable @inline(__always)
    func interpenetration(comparing: Collision3DComponent) -> Interpenetration3D? {
        let lhs = collider
        let rhs = comparing.collider
        return lhs.interpenetration(comparing: rhs)
    }
    @inlinable @inline(__always)
    func updateColliders(_ transform: Transform3) {
        self.collider.update(transform: transform)
    }
    
    @inlinable @inline(__always)
    func update(sizeAndOffsetUsingTransform transform: Transform3) {
        self.collider.update(sizeAndOffsetUsingTransform: transform)
    }
    
    public required init(){}
    public static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inlinable @inline(__always)
    var collision3DComponent: Collision3DComponent {
        return self[Collision3DComponent.self]
    }
}
