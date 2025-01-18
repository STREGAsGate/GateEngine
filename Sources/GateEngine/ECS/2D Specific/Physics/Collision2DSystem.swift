/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Collision2DSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for entity in context.entities {
            guard entity.hasComponent(Collision2DComponent.self) else { continue }
            guard entity.hasComponent(Transform2Component.self) else { continue }
            entity[Collision2DComponent.self].updateColliders(entity.transform2)
        }
        
        guard
            let quadtreeEntity = context.entities.first(where: {
                $0.hasComponent(QuadtreeComponent.self)
            })
        else {
            return
        }
        let quadtree = quadtreeEntity[QuadtreeComponent.self].quadtree!

        for entity in context.entities {
            guard entity.hasComponent(Collision2DComponent.self) else { continue }
            if let transformComponent = entity.component(ofType: Transform2Component.self) {
                let object = entity[Collision2DComponent.self]
                object.updateColliders(transformComponent.transform)

                let colliders = quadtree.colliders(near: object.collider.boundingBox, inLayer: "Base")
                var objectCollider = object.collider

                var impactCount = 0
                var hits: [(collider: any Collider2D, interpenetration: Interpenetration2D)] = []
                for collider in colliders {
                    objectCollider.update(transform: transformComponent.transform)
                    guard
                        let interpenetration = collider.interpenetration(comparing: objectCollider),
                        interpenetration.isColiding
                    else {
                        continue
                    }
                    hits.append((collider, interpenetration))
                    guard impactCount < 2 else { break }
                    impactCount += 1
                }

                for hit in hits.sorted(by: {
                    let distance1 = $0.collider.position.distance(from: objectCollider.position)
                    let distance2 = $1.collider.position.distance(from: objectCollider.position)
                    return distance1 < distance2
                }) {
                    objectCollider.update(transform: transformComponent.transform)
                    if let interpenetration = hit.collider.interpenetration(
                        comparing: objectCollider
                    ) {
                        if interpenetration.isColiding {
                            let direction = hit.interpenetration.direction
                            let depth = hit.interpenetration.depth
                            transformComponent.position -= Position2(direction * depth)
                        }
                    }
                }
            }
        }
    }

    public override class var phase: System.Phase { .simulation }
    public override class func sortOrder() -> SystemSortOrder? { .collision2DSystem }
}
