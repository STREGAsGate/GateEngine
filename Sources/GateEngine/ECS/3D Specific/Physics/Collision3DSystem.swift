/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Collision3DSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        let staticEntities = game.entities.filter({
            $0.component(ofType: Collision3DComponent.self)?.kind == .static
        })
        for entity in staticEntities {
            entity.collision3DComponent.updateColliders(entity.transform3)
        }
        let dynamicEntities = game.entities.filter({
            $0.component(ofType: Collision3DComponent.self)?.kind == .dynamic
        })
        for entity in dynamicEntities {
            entity.collision3DComponent.updateColliders(entity.transform3)
        }

        var finishedPairs: Set<Set<ObjectIdentifier>> = []

        let octrees = self.octrees

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
                    dynamic: dynamicEntity,
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
                    guard let dynamicComponent = entity.component(ofType: Collision3DComponent.self)
                    else { continue }
                    guard dynamicComponent.isEnabled else { continue }
                    guard dynamicComponent.collider is MeshCollider == false else { continue }
                    guard dynamicComponent.options.contains(.skipEntities) == false else {
                        continue
                    }

                    let pair: Set = [dynamicEntity.id, entity.id]
                    guard finishedPairs.contains(pair) == false else { continue }
                    finishedPairs.insert(pair)

                    guard dynamicComponent.options.contains(.skipEntities) == false else {
                        continue
                    }
                    guard
                        collisionComponent.collider.boundingBox.isColiding(
                            with: dynamicComponent.collider.boundingBox
                        )
                    else { continue }

                    let dynamicCollider1 = collisionComponent.collider
                    let dynamicCollider2 = dynamicComponent.collider

                    let interpenetration = dynamicCollider2.interpenetration(
                        comparing: dynamicCollider1
                    )

                    if let interpenetration = interpenetration, interpenetration.isColiding == true
                    {
                        collisionComponent.intersecting.append((entity, interpenetration))
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
        @inline(__always)
        func revert() {
            transformComponent.transform.position = transformComponent.previousTransform.position
        }
        guard collisionComponent.options.contains(.robustProtection) else { return }
        guard
            transformComponent.distanceTraveled().isFinite
                && transformComponent.directionTraveled().isFinite
        else {
            revert()
            return
        }

        let collider = collisionComponent.collider

        let previousPosition = transformComponent.previousTransform.position + collider.offset
        let point = previousPosition.moved(
            -collisionComponent.collider.boundingBox.size.max,
            toward: transformComponent.directionTraveled()
        )
        let ray = Ray3D(from: point, toward: transformComponent.directionTraveled())
        guard let hit = self.trianglesHit(by: ray, filter: collisionComponent.triangleFilter).first
        else { return }
        guard hit.position.distance(from: previousPosition) < transformComponent.distanceTraveled()
        else { return }

        //Move the collider back in front of the triangle. Collision response will act on it later
        transformComponent.position = hit.position.moved(
            -0.001,
            toward: transformComponent.directionTraveled()
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
        else { return }

        @inline(__always)
        func wall(_ position: Position3, _ direction: Direction3) -> (
            position: Position3, triangle: CollisionTriangle
        )? {
            let wFilter: (CollisionTriangle) -> Bool = {
                $0.surfaceType == .wall && $0.plane.classifyPoint(position) == .front
            }
            return trianglesHit(by: Ray3D(from: position, toward: direction), filter: wFilter).first
        }

        @inline(__always)
        func floor(_ position: Position3) -> (position: Position3, triangle: CollisionTriangle)? {
            let tFilter: (CollisionTriangle) -> Bool = {
                $0.surfaceType.isWalkable && $0.plane.classifyPoint(collider.position) == .front
            }
            return trianglesHit(by: Ray3D(from: position, toward: .down), filter: tFilter).first
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
            @inline(__always)
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
        let triangles = trianglesNear(collisionComponent.collider.boundingBox, filter: filter)
            .filter({ $0.interpenetration(comparing: sphere)?.isColiding == true })

        var match:
            [(
                edge: Line3D, point: Position3, angle: Degrees, distance: Float,
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

                if let hit = trianglesHit(by: Ray3D(from: projected, toward: .down), filter: filter)
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
    func sortedTrianglesProbablyHitting(dynamic: Entity, triangles: [CollisionTriangle])
        -> [CollisionTriangle]
    {
        let collider = dynamic.collision3DComponent.collider.boundingBox

        var values: [CollisionTriangle] = []
        values.reserveCapacity(triangles.count)

        for triangle in triangles {
            if triangle.isProbablyColliding(with: collider) {
                values.append(triangle)
            }
        }

        values.sort(by: { $0.surfaceType.rawValue < $1.surfaceType.rawValue })

        return values
    }

    @inline(__always)
    func respondToCollision(dynamicEntity: Entity, triangle: CollisionTriangle) -> Bool {
        guard let collisionComponent = dynamicEntity.component(ofType: Collision3DComponent.self)
        else { return false }
        guard
            let interpenetration = triangle.interpenetration(
                comparing: collisionComponent.collider
            ), interpenetration.isColiding
        else { return false }
        collisionComponent.touching.append((triangle, interpenetration))
        guard let transformComponent = dynamicEntity.component(ofType: Transform3Component.self)
        else { return false }
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
        guard let transformComponent = dynamicEntity.component(ofType: Transform3Component.self)
        else { return }
        let depth = interpenetration.depth + 0.001  //Keep the objects touching a little
        transformComponent.position -= Position3(interpenetration.direction * depth)
    }

    @inline(__always)
    func respondToCollision(
        sourceEntity: Entity,
        dynamicEntity: Entity,
        interpenetration: Interpenetration3D
    ) {
        guard let transformComponent = dynamicEntity.component(ofType: Transform3Component.self)
        else { return }
        let depth = interpenetration.depth + 0.001  //Keep the objects touching a little
        transformComponent.position -= Position3(interpenetration.direction * depth)
    }
}

extension Collision3DSystem {
    private var octrees: [OctreeComponent] {
        return game.entities.filter({ $0.hasComponent(OctreeComponent.self) }).map({
            $0[OctreeComponent.self]
        })
    }

    @inline(__always)
    public func trianglesNear(
        _ box: AxisAlignedBoundingBox3D,
        filter: ((CollisionTriangle) -> Bool)? = nil
    ) -> [CollisionTriangle] {
        var hits: [CollisionTriangle] = []

        for octree in self.octrees.filter({ $0.boundingBox.isColiding(with: box) }) {
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
    public func trianglesHit(by ray: Ray3D, filter: ((CollisionTriangle) -> Bool)? = nil) -> [(
        position: Position3, triangle: CollisionTriangle
    )] {
        var hits: [(position: Position3, triangle: CollisionTriangle)] = []

        for entity in entitiesProbablyHit(by: ray) {
            guard let mesh = entity[Collision3DComponent.self].collider as? MeshCollider else {
                continue
            }
            hits.append(contentsOf: mesh.trianglesHit(by: ray))
        }

        for octree in octrees {
            let triangles = octree.trianglesHit(by: ray, filter: filter)
            if triangles.isEmpty == false {
                hits.append(contentsOf: triangles)
            }
        }
        return hits.sorted(by: {
            $0.position.distance(from: ray.origin) < $1.position.distance(from: ray.origin)
        })
    }

    @inline(__always)
    public func entitiesProbablyHit(by ray: Ray3D, filter: ((Entity) -> Bool)? = nil) -> [Entity] {
        var entities: [Entity] = []

        for entity in game.entities {
            guard let collisionComponent = entity.component(ofType: Collision3DComponent.self)
            else { continue }
            guard filter?(entity) ?? true else { continue }
            guard collisionComponent.collider.boundingBox.surfacePoint(for: ray) != nil else {
                continue
            }
            entities.append(entity)
        }

        return entities
    }

    @inline(__always)
    public func entitiesProbablyHit(by collider: some Collider3D, filter: ((Entity) -> Bool)? = nil)
        -> [Entity]
    {
        var entities: [Entity] = []

        for entity in game.entities {
            guard let collisionComponent = entity.component(ofType: Collision3DComponent.self)
            else { continue }
            guard filter?(entity) ?? true else { continue }
            guard
                collisionComponent.collider.boundingBox.interpenetration(comparing: collider)?
                    .isColiding == true
            else { continue }
            entities.append(entity)
        }

        return entities
    }

    @inline(__always)
    public func entitiesHit(by ray: Ray3D, filter: ((Entity) -> Bool)? = nil) -> [(
        position: Position3, surfaceDirection: Direction3, entity: Entity
    )] {
        let entities = entitiesProbablyHit(by: ray, filter: filter)

        var hits: [(position: Position3, surfaceDirection: Direction3, entity: Entity)] = []
        for entity in entities {
            guard let collisionComponent = entity.component(ofType: Collision3DComponent.self)
            else { continue }
            let collider = collisionComponent.collider
            guard collider is MeshCollider == false else { continue }
            if let impact = collider.surfaceImpact(comparing: ray) {
                hits.append((impact.position, impact.normal, entity))
            }
        }

        return hits.sorted(by: {
            $0.position.distance(from: ray.origin) < $1.position.distance(from: ray.origin)
        })
    }

    @inline(__always)
    public func closestHit(
        from ray: Ray3D,
        entityFilter: ((Entity) -> Bool)? = nil,
        triangleFilter: ((CollisionTriangle) -> Bool)? = nil
    ) -> (
        position: Position3, surfaceDirection: Direction3, triangle: CollisionTriangle?,
        entity: Entity?
    )? {
        let _entity = entitiesHit(by: ray, filter: entityFilter).first
        guard let triangle = trianglesHit(by: ray, filter: triangleFilter).first else {
            if let entity = _entity {
                return (entity.position, entity.surfaceDirection, nil, entity.entity)
            } else {
                return nil
            }
        }
        guard let entity = _entity else {
            return (triangle.position, triangle.triangle.normal, triangle.triangle, nil)
        }
        if triangle.position.distance(from: ray.origin) < entity.position.distance(from: ray.origin)
        {
            return (triangle.position, triangle.triangle.normal, triangle.triangle, nil)
        } else {
            return (entity.position, entity.surfaceDirection, nil, entity.entity)
        }
    }
}

@MainActor extension Game {
    @_transparent
    public var collision3DSystem: Collision3DSystem {
        return self.system(ofType: Collision3DSystem.self)
    }
}
