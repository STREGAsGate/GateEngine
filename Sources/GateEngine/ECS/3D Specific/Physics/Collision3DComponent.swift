/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

extension CollisionComponent {
    enum Kind {
        case `static`
        case dynamic
    }
}

class CollisionComponent: Component {
    struct Options: OptionSet {
        let rawValue: UInt32
        
        static let skipEntities = Options(rawValue: 1 << 1)
        static let skipTriangles = Options(rawValue: 1 << 2)
        
        /// Prevent high velocity objects from skipping collision detection
        static let robustProtection = Options(rawValue: 1 << 3)
        /// Keep object from falling off ledges
        static let ledgeDetection = Options(rawValue: 1 << 4)
        
        init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    var isEnabled: Bool = true
    var kind: Kind = .static
    
    var options: Options = []
    
    var primitiveCollider: AxisAlignedBoundingBox3D = AxisAlignedBoundingBox3D(center: .zero, offset: .zero, radius: .one)
    var detailCollider: Collider3D? = nil
    var collider: Collider3D {
        return detailCollider ?? primitiveCollider
    }
    
    var touching: [(triangle: CollisionTriangle, interpenetration: Interpenetration3D)] = []
    var intersecting: [(entity: Entity, interpenetration: Interpenetration3D)] = []
    
    var offset: Transform3 = .default
    
    /// The distance down for a surface to be considered a ledge. Option `ledgeDetection` required.
    var ledgeHeight: Float = 0.5
    
    var triangleFilter: ((CollisionTriangle)->(Bool))? = nil
    var entityFilter: ((Entity)->(Bool))? = nil
    
    func interpenetration(comparing: Collider3D) -> Interpenetration3D? {
        return (self.detailCollider ?? self.primitiveCollider).interpenetration(comparing: comparing)
    }
    func interpenetration(comparing: CollisionComponent) -> Interpenetration3D? {
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
    
    required init(){}
    static let componentID: ComponentID = ComponentID()
}

extension Entity {
    @inline(__always)
    var collisionComponent: CollisionComponent {
        return self[CollisionComponent.self]
    }
}
