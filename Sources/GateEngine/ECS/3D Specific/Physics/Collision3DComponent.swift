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
    
    public var primitiveCollider: AxisAlignedBoundingBox3D = AxisAlignedBoundingBox3D(center: .zero, offset: .zero, radius: .one)
    public var detailCollider: Collider3D? = nil
    
    public var collider: Collider3D {
        return detailCollider ?? primitiveCollider
    }
    
    var touching: [(triangle: CollisionTriangle, interpenetration: Interpenetration3D)] = []
    var intersecting: [(entity: Entity, interpenetration: Interpenetration3D)] = []
    
    public var offset: Transform3 = .default
    
    /// The distance down for a surface to be considered a ledge. Option `ledgeDetection` required.
    public var ledgeHeight: Float = 0.5
    
    public var triangleFilter: ((CollisionTriangle)->(Bool))? = nil
    public var entityFilter: ((Entity)->(Bool))? = nil
    
    func interpenetration(comparing: Collider3D) -> Interpenetration3D? {
        return (self.detailCollider ?? self.primitiveCollider).interpenetration(comparing: comparing)
    }
    func interpenetration(comparing: Collision3DComponent) -> Interpenetration3D? {
        let lhs = self.detailCollider ?? self.primitiveCollider
        let rhs = comparing.detailCollider ?? comparing.primitiveCollider
        return lhs.interpenetration(comparing: rhs)
    }
    
    func updateColliders(_ transform: Transform3) {
        self.primitiveCollider.update(transform: transform)
        self.detailCollider?.update(transform: transform)
        if let oobb = detailCollider as? OrientedBoundingBox3D {
            self.primitiveCollider = AxisAlignedBoundingBox3D(oobb.verticies)
        }
    }
    
    func update(sizeAndOffsetUsingTransform transform: Transform3) {
        self.primitiveCollider.update(sizeAndOffsetUsingTransform: transform)
        self.detailCollider?.update(sizeAndOffsetUsingTransform: transform)
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
