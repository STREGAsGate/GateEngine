/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Collision3DSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        let staticEntities = context.entities.filter({
            guard let collisionComponenet = $0.component(ofType: Collision3DComponent.self) else {return false}
            if case .static = collisionComponenet.kind {
                return true
            }
            return false
        })
        for entity in staticEntities {
            entity.collision3DComponent.updateColliders(entity.transform3)
        }
        let dynamicEntities = context.entities.filter({
            guard let collisionComponenet = $0.component(ofType: Collision3DComponent.self) else {return false}
            if case .dynamic(_) = collisionComponenet.kind {
                return true
            }
            return false
        }).sorted { entity1, entity2 in
            if case .dynamic(let priority1) = entity1[Collision3DComponent.self].kind {
                if case .dynamic(let priority2) = entity2[Collision3DComponent.self].kind {
                    return priority1 > priority2
                }
            }
            return false
        }
        for entity in dynamicEntities {
            entity.collision3DComponent.updateColliders(entity.transform3)
        }

        var finishedPairs: Set<Set<ObjectIdentifier>> = []

        let octrees = self.getOctrees()

        for dynamicEntity in dynamicEntities {
            guard
                let collisionComponent = dynamicEntity.component(ofType: Collision3DComponent.self)
            else { continue }
            guard collisionComponent.isEnabled else { continue }
            guard let transformComponent = dynamicEntity.component(ofType: Transform3Component.self)
            else { continue }

            @_transparent
            func updateCollider() {
                collisionComponent.updateColliders(transformComponent.transform)
            }

            // Update collider from animation
            if let rigComponent = dynamicEntity.component(ofType: Rig3DComponent.self) {
                if let colliderJointName = rigComponent.updateColliderFromBoneNamed {
                    if let joint = rigComponent.skeleton.jointNamed(colliderJointName) {
                        let position =
                            (transformComponent.transform.matrix() * joint.modelSpace).position
                            - transformComponent.position
                        let rotation =
                            transformComponent.rotation * joint.modelSpace.rotation.conjugate
                        let scale = joint.modelSpace.scale
                        let transform = Transform3(
                            position: position,
                            rotation: rotation,
                            scale: scale
                        )
                        collisionComponent.update(sizeAndOffsetUsingTransform: transform)
                    } else {
                        fatalError("Failed to find joint \(colliderJointName).")
                    }
                }
            }

            collisionComponent.touching.removeAll(keepingCapacity: true)
            collisionComponent.intersecting.removeAll(keepingCapacity: true)

            if collisionComponent.options.contains(.ledgeDetection) {
                updateCollider()
                self.performLedgeDetection(
                    dynamicEntity,
                    transformComponent: transformComponent,
                    collisionComponent: collisionComponent
                )
                updateCollider()
            }

            if collisionComponent.options.contains(.robustProtection) {
                updateCollider()
                self.performRobustnessProtection(
                    dynamicEntity,
                    transformComponent: transformComponent,
                    collisionComponent: collisionComponent
                )
                updateCollider()
            }

            if collisionComponent.options.contains(.skipTriangles) == false {
                var triangles: [CollisionTriangle] = []

                for entity in entitiesProbablyHit(by: collisionComponent.collider.boundingBox) {
                    guard let mesh = entity[Collision3DComponent.self].collider as? MeshCollider
                    else { continue }
                    triangles.append(contentsOf: mesh.triangles())
                }
                for octree in octrees.filter({
                    $0.boundingBox.isColiding(with: collisionComponent.collider.boundingBox)
                }) {
                    triangles.append(
                        contentsOf: octree.trianglesNear(collisionComponent.collider.boundingBox)
                    )
                }

                triangles = sortedTrianglesProbablyHitting(
                    entity: dynamicEntity,
                    triangles: triangles
                )
                if let filter = collisionComponent.triangleFilter {
                    triangles = triangles.filter(filter)
                }

                updateCollider()
                for triangle in triangles {
                    if respondToCollision(dynamicEntity: dynamicEntity, triangle: triangle) {
                        updateCollider()
                    }
                }
            }

            if collisionComponent.options.contains(.skipEntities) == false {
                for entity in staticEntities {
                    guard entity != dynamicEntity else { continue }

                    guard collisionComponent.entityFilter?(entity) ?? true else { continue }
                    guard let staticComponent = entity.component(ofType: Collision3DComponent.self)
                    else { continue }
                    guard staticComponent.isEnabled else { continue }
                    guard staticComponent.collider is MeshCollider == false else { continue }
                    guard staticComponent.options.contains(.skipEntities) == false else { continue }
                    guard
                        collisionComponent.collider.boundingBox.isColiding(
                            with: staticComponent.collider.boundingBox
                        )
                    else { continue }

                    let dynamicCollider = collisionComponent.collider
                    let staticCollider = staticComponent.collider

                    let interpenetration = staticCollider.interpenetration(
                        comparing: dynamicCollider
                    )

                    if let interpenetration = interpenetration, interpenetration.isColiding == true
                    {
                        collisionComponent.intersecting.append((entity, interpenetration))
                        respondToCollision(
                            dynamicEntity: dynamicEntity,
                            staticEntity: entity,
                            interpenetration: interpenetration
                        )
                        updateCollider()
                    }
                }

                for entity in dynamicEntities {
                    guard entity != dynamicEntity else { continue }
                    guard collisionComponent.entityFilter?(entity) ?? true else { continue }
                    guard let dynamicComponent = entity.component(ofType: Collision3DComponent.self) else { continue }
                    guard dynamicComponent.entityFilter?(dynamicEntity) ?? true else { continue }
                    guard dynamicComponent.isEnabled else { continue }
                    guard dynamicComponent.collider is MeshCollider == false else { continue }
                    guard dynamicComponent.options.contains(.skipEntities) == false else {
                        continue
                    }

                    let pair: Set = [dynamicEntity.id, entity.id]
                    guard finishedPairs.contains(pair) == false else { continue }
                    finishedPairs.insert(pair)
                    
                    if case .dynamic(let priority1) = collisionComponent.kind {
                        if case .dynamic(let priority2) = dynamicComponent.kind {
                            if priority1 < priority2 {
                                continue
                            }
                        }
                    }

                    guard
                        collisionComponent.collider.boundingBox.isColiding(
                            with: dynamicComponent.collider.boundingBox
                        )
                    else { continue }

                    let dynamicCollider1 = collisionComponent.collider
                    let dynamicCollider2 = dynamicComponent.collider

                    let interpenetration = dynamicCollider1.interpenetration(
                        comparing: dynamicCollider2
                    )

                    if let interpenetration = interpenetration, interpenetration.isColiding == true {
                        collisionComponent.intersecting.append((entity, interpenetration))
                        dynamicComponent.intersecting.append((dynamicEntity, interpenetration))
                        respondToCollision(
                            sourceEntity: dynamicEntity,
                            dynamicEntity: entity,
                            interpenetration: interpenetration
                        )
                        updateCollider()
                    }
                }
            }
        }
    }

    public override class var phase: System.Phase { .simulation }
    public override class func sortOrder() -> SystemSortOrder? {
        return .collision3DSystem
    }
}

extension Collision3DSystem {
    @inline(__always)
    func performRobustnessProtection(
        _ entity: Entity,
        transformComponent: Transform3Component,
        collisionComponent: Collision3DComponent
    ) {
        guard collisionComponent.options.contains(.robustProtection) else { return }
        
        let distanceTraveled = transformComponent.distanceTraveled()
        let directionTraveled = transformComponent.directionTraveled()
        var previousPosition = transformComponent.previousTransform.position
        
        guard distanceTraveled.isFinite && directionTraveled.isFinite else {
            transformComponent.transform.position = previousPosition
            return
        }

        let collider = collisionComponent.collider
        
        previousPosition += collider.offset
        
        let point = previousPosition.moved(
            -collider.boundingBox.size.max,
            toward: directionTraveled
        )
        
        let ray = Ray3D(from: point, toward: directionTraveled)
        let filter = collisionComponent.triangleFilter
        guard let hit = trianglesHit(by: ray, triangleFilter: filter).first else { 
            return 
        }
        guard hit.position.distance(from: previousPosition) < distanceTraveled else {
            return
        }

        // Move the collider back in front of the triangle. 
        // Collision response will act on it later.
        transformComponent.position = hit.position.moved(
            -0.1,
            toward: directionTraveled
        )
    }

    @inline(__always)
    func performLedgeDetection(
        _ entity: Entity,
        transformComponent: Transform3Component,
        collisionComponent: Collision3DComponent
    ) {
        guard
            let collider: BoundingEllipsoid3D = collisionComponent.collider as? BoundingEllipsoid3D
        else { 
            return 
        }

        @inline(__always)
        func wall(_ position: Position3, _ direction: Direction3) -> (
            position: Position3, triangle: CollisionTriangle
        )? {
            let wFilter: (CollisionTriangle) -> Bool = {
                $0.surfaceType == .wall && $0.plane.classifyPoint(position) == .front
            }
            return trianglesHit(by: Ray3D(from: position, toward: direction), triangleFilter: wFilter).first
        }

        @inline(__always)
        func floor(_ position: Position3) -> (position: Position3, triangle: CollisionTriangle)? {
            let tFilter: (CollisionTriangle) -> Bool = {
                $0.surfaceType.isWalkable && $0.plane.classifyPoint(collider.position) == .front
            }
            return trianglesHit(by: Ray3D(from: position, toward: .down), triangleFilter: tFilter).first
        }

        @inline(__always)
        func processDirection(_ direction: Direction3) -> Bool {
            defer {
                collisionComponent.updateColliders(transformComponent.transform)
            }
            let inFrontOfEntity = collider.position.moved(
                collider.size.x * 0.6666666667,
                toward: direction
            )
            if let wall = wall(inFrontOfEntity, direction) {
                if wall.position.distance(from: transformComponent.position) < collider.radius.x {
                    return false  // Wall in front, can't be a ledge
                }
            }

            let inFrontOfLedge = inFrontOfEntity.moved(collider.radius.y + 0.05, toward: .down)
            if let floor = floor(inFrontOfLedge) {
                let entityY = transformComponent.position.y
                let floorY = floor.position.y
                if max(entityY, floorY) - min(entityY, floorY) < collisionComponent.ledgeHeight {
                    return false  // Can drop down, not a ledge
                }
            }

            let inFrontOfLedgeRelativeToEntity = transformComponent.position.addingTo(y: -0.05)
            if let wall = wall(
                inFrontOfLedge,
                Direction3(from: inFrontOfLedge, to: inFrontOfLedgeRelativeToEntity)
            ) {
                let wallPosition = wall.triangle.closestSurfacePoint(from: collider.position)
                if wallPosition.distance(from: transformComponent.position) < collider.radius.x {
                    // Ledge found. Push back
                    let wallPosition = wallPosition.moved(
                        -collider.radius.x,
                        toward: wall.triangle.normal
                    )
                    transformComponent.position.x = wallPosition.x
                    transformComponent.position.z = wallPosition.z
                    return true
                }
            } else {
                // No floor in front and no wall benath to get push backdirection. Use triangle edge for push back direction.
                //                doTriangleCollision = true
            }
            return false
        }

        let directions1: [Direction3] = {
            let r = transformComponent.rotation
            let forward = r.forward
            return [
                r.right.interpolated(to: forward, .linear(0.5)),
                r.left.interpolated(to: forward, .linear(0.5)),
            ]
        }()
        var doSides = false
        for direction in directions1 {
            if processDirection(direction) {
                doSides = true
                break
            }
        }

        if doSides {
            @_transparent
            var directions2: [Direction3] {
                let r = transformComponent.rotation
                return [
                    r.right,
                    r.left,
                ]
            }
            for direction in directions2 {
                if processDirection(direction) {
                    doSides = true
                    break
                }
            }
        }

        //        if doTriangleCollision {
        //            _performTriangleLedgeDetection(entity, transformComponent: transformComponent, collisionComponent: collisionComponent)
        //        }
    }

    @inline(__always)
    func _performTriangleLedgeDetection(
        _ entity: Entity,
        transformComponent: Transform3Component,
        collisionComponent: Collision3DComponent
    ) {
        guard var collider = collisionComponent.collider as? BoundingEllipsoid3D else { return }
        let filter: (CollisionTriangle) -> Bool = {
            $0.surfaceType.isWalkable && $0.plane.classifyPoint(collider.position) == .front
        }
        var sphere = BoundingSphere3D(
            center: transformComponent.position,
            offset: .zero,
            radius: collider.radius.x
        )
        let triangles = trianglesNear(
            collisionComponent.collider.boundingBox, 
            filter: filter
        ).filter({ $0.interpenetration(comparing: sphere)?.isColiding == true })

        var match: [(
            edge: Line3D, 
            point: Position3, 
            angle: Degrees, 
            distance: Float,
            triangle: CollisionTriangle
        )] = []
        for triangle in triangles {
            let edge = triangle.edgeNear(transformComponent.position)
            let point = edge.pointNear(transformComponent.position)

            if point.distance(from: transformComponent.position) < collider.radius.x {
                let projected = point.moved(
                    collider.radius.x,
                    toward: transformComponent.rotation.forward
                ).addingTo(y: collider.radius.y)

                lazy var angle: Degrees = {
                    let d1 = Degrees(transformComponent.rotation.forward.angleAroundY)
                    let d2 = Degrees(
                        Direction3(from: transformComponent.position, to: point).angleAroundY
                    )
                    return d1.shortestAngle(to: d2)
                }()

                lazy var distance: Float = point.distance(from: transformComponent.position)

                if let hit = trianglesHit(by: Ray3D(from: projected, toward: .down), triangleFilter: filter)
                    .first
                {
                    let y1 = transformComponent.position.y
                    let y2 = hit.position.y
                    if max(y1, y2) - min(y1, y2) >= collisionComponent.ledgeHeight {
                        match.append((edge, point, angle, distance, triangle))
                    }
                } else {
                    match.append((edge, point, angle, distance, triangle))
                }
            }
        }

        match.sort(by: { $0.angle < $0.angle && $0.distance > $1.distance })

        for hit in match {
            sphere.update(center: transformComponent.position)
            if sphere.contains(hit.point) {
                let edgeNormal = hit.triangle.normal.cross(
                    Direction3(from: hit.edge.p1, to: hit.edge.p2)
                )
                let position = hit.point.moved(collider.radius.x, toward: edgeNormal)
                transformComponent.position = position
                collider.update(transform: transformComponent.transform)
            }
            break
        }
    }

    @inline(__always)
    func sortedTrianglesProbablyHitting(
        entity: Entity, 
        triangles: [CollisionTriangle]
    ) -> [CollisionTriangle] {
        let collider = entity.collision3DComponent.collider.boundingBox
        
        var values: [CollisionTriangle] = triangles.filter({
            return $0.isPotentiallyColliding(with: collider)
        })
        
        values.sort(by: { $0.surfaceType.rawValue < $1.surfaceType.rawValue })
        
        return values
    }

    @inline(__always)
    func respondToCollision(dynamicEntity: Entity, triangle: CollisionTriangle) -> Bool {
        guard 
            let collisionComponent = dynamicEntity.component(ofType: Collision3DComponent.self),
            let interpenetration = triangle.interpenetration(comparing: collisionComponent.collider), 
                interpenetration.isColiding
        else { 
            return false 
        }
        collisionComponent.touching.append((triangle, interpenetration))
        guard 
            let transformComponent = dynamicEntity.component(ofType: Transform3Component.self)
        else { 
            return false 
        }
        let depth = interpenetration.depth + 0.001  //Keep the objects touching a little
        switch triangle.surfaceType {
        case .floor, .ramp:
            transformComponent.position -= Position3(Direction3.up * depth)
        case .ceiling:
            transformComponent.position -= Position3(Direction3.down * depth)
        case .wall:
            transformComponent.position -= Position3(interpenetration.direction * depth)
        }
        return true
    }

    @inline(__always)
    func respondToCollision(
        dynamicEntity: Entity,
        staticEntity: Entity,
        interpenetration: Interpenetration3D
    ) {
        if let transformComponent = dynamicEntity.component(ofType: Transform3Component.self) {
            let depth = interpenetration.depth + 0.001  //Keep the objects touching a little
            transformComponent.position -= Position3(interpenetration.direction * depth)
        }
    }

    @inline(__always)
    func respondToCollision(
        sourceEntity: Entity,
        dynamicEntity: Entity,
        interpenetration: Interpenetration3D
    ) {
        if let transformComponent = dynamicEntity.component(ofType: Transform3Component.self) {
            let depth = interpenetration.depth + 0.001  //Keep the objects touching a little
            transformComponent.position -= Position3(interpenetration.direction * depth)
        }
    }
}

extension Collision3DSystem {
    private func getOctrees(entityFilter: ((Entity)->Bool)? = nil) -> [OctreeComponent] {
        if let entityFilter {
            return context.entities.filter({entityFilter($0)}).compactMap({ $0.component(ofType: OctreeComponent.self) })
        }
        return context.entities.compactMap({ $0.component(ofType: OctreeComponent.self) })
    }

    @inline(__always)
    public func trianglesNear(
        _ box: AxisAlignedBoundingBox3D,
        filter: ((CollisionTriangle) -> Bool)? = nil
    ) -> [CollisionTriangle] {
        var hits: [CollisionTriangle] = []

        for octree in self.getOctrees().filter({ $0.boundingBox.isColiding(with: box) }) {
            let triangles = octree.trianglesNear(box)
            if triangles.isEmpty == false {
                hits.append(contentsOf: triangles)
                break
            }
        }
        if let filter = filter {
            return hits.filter({ filter($0) })
        }
        return hits
    }

    @inline(__always)
    public func trianglesHit(
        by ray: Ray3D, 
        useRayCastCollider: Bool = false, 
        triangleFilter: ((CollisionTriangle) -> Bool)? = nil,
        entityFilter: ((Entity) -> Bool)? = nil
    ) -> [(position: Position3, triangle: CollisionTriangle)] {
        var hits: [(position: Position3, triangle: CollisionTriangle)] = []

        for entity in entitiesProbablyHit(by: ray, filter: entityFilter) {
            let component = entity[Collision3DComponent.self]
            let collider = useRayCastCollider ? (component.rayCastCollider ?? component.collider) : component.collider
            switch collider {
            case let meshCollider as MeshCollider:
                hits.append(contentsOf: meshCollider.trianglesHit(by: ray, filter: triangleFilter))
            case let skinCollider as SkinCollider:
                hits.append(contentsOf: skinCollider.trianglesHit(by: ray, filter: triangleFilter))
            default:
                break
            }
        }

        for octree in self.getOctrees(entityFilter: entityFilter) {
            let triangles = octree.trianglesHit(by: ray, filter: triangleFilter)
            if triangles.isEmpty == false {
                hits.append(contentsOf: triangles)
            }
        }
        
        hits.sort(by: {
            $0.position.distance(from: ray.origin) < $1.position.distance(from: ray.origin)
        })
        
        return hits
    }

    @inline(__always)
    public func entitiesProbablyHit(
        by ray: Ray3D, 
        useRayCastCollider: Bool = false, 
        filter: ((Entity) -> Bool)? = nil
    ) -> [Entity] {
        var entities: [Entity] = []

        for entity in context.entities {
            if let collisionComponent = entity.component(ofType: Collision3DComponent.self), filter?(entity) ?? true {
                let collider = useRayCastCollider ? (collisionComponent.rayCastCollider ?? collisionComponent.collider) : collisionComponent.collider
                if collider.boundingBox.surfacePoint(for: ray) != nil {
                    entities.append(entity)
                }
            }
        }

        return entities
    }

    @inline(__always)
    public func entitiesProbablyHit(
        by collider: some Collider3D, 
        filter: ((Entity) -> Bool)? = nil
    ) -> [Entity] {
        var entities: [Entity] = []

        for entity in context.entities {
            if
                let collisionComponent = entity.component(ofType: Collision3DComponent.self),
                filter?(entity) ?? true,
                collisionComponent.collider.boundingBox.interpenetration(comparing: collider)?.isColiding == true
            {
                entities.append(entity)
            }
        }

        return entities
    }

    @inline(__always)
    public func entitiesHit(
        by ray: Ray3D, useRayCastCollider: Bool = false, 
        filter: ((Entity) -> Bool)? = nil
    ) -> [(surfaceImpact: SurfaceImpact3D, entity: Entity)] {
        let entities = entitiesProbablyHit(by: ray, useRayCastCollider: useRayCastCollider, filter: filter)

        var hits: [(surfaceImpact: SurfaceImpact3D, entity: Entity)] = []
        for entity in entities {
            if let collisionComponent = entity.component(ofType: Collision3DComponent.self) {
                let collider = useRayCastCollider ? (collisionComponent.rayCastCollider ?? collisionComponent.collider) : collisionComponent.collider
                if let impact = collider.surfaceImpact(comparing: ray) {
                    hits.append((impact, entity))
                }
            }
        }

        return hits.sorted(by: {
            $0.surfaceImpact.position.distance(from: ray.origin) < $1.surfaceImpact.position.distance(from: ray.origin)
        })
    }

    @inline(__always)
    public func closestHit(
        from ray: Ray3D,
        useRaycastCollider: Bool = false,
        entityFilter: ((Entity) -> Bool)? = nil,
        triangleFilter: ((CollisionTriangle) -> Bool)? = nil
    ) -> (
        position: Position3,
        surfaceDirection: Direction3,
        triangle: CollisionTriangle?,
        entity: Entity?
    )? {
        let entityHit = entitiesHit(by: ray, useRayCastCollider: useRaycastCollider, filter: entityFilter).first
        guard let triangleHit = trianglesHit(by: ray, useRayCastCollider: useRaycastCollider, triangleFilter: triangleFilter).first else {
            if let entityHit {
                return (
                    entityHit.surfaceImpact.position,
                    entityHit.surfaceImpact.normal,
                    entityHit.surfaceImpact.triangle,
                    entityHit.entity
                )
            } else {
                return nil
            }
        }
        guard let entityHit else {
            return (triangleHit.position, triangleHit.triangle.normal, triangleHit.triangle, nil)
        }
        let triangleDistance = triangleHit.position.distance(from: ray.origin)
        let entityDistance = entityHit.surfaceImpact.position.distance(from: ray.origin)
        if triangleDistance < entityDistance {
            return (triangleHit.position, triangleHit.triangle.normal, triangleHit.triangle, nil)
        } else {
            return (
                entityHit.surfaceImpact.position,
                entityHit.surfaceImpact.normal,
                entityHit.surfaceImpact.triangle,
                entityHit.entity
            )
        }
    }
}

@MainActor extension ECSContext {
    @_transparent
    public var collision3DSystem: Collision3DSystem {
        return self.system(ofType: Collision3DSystem.self)
    }
}
