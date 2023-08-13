/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Collision2DSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        guard let quadtreeEntity = game.entities.first(where: {$0.hasComponent(QuadtreeComponent.self)}) else {return}
        let quadtree = quadtreeEntity[QuadtreeComponent.self].quadtree!
        
        for entity in game.entities {
            guard entity.hasComponent(Collision2DComponent.self) else {continue}
            guard entity.hasComponent(Transform2Component.self) else {continue}
            await entity.configure(Transform2Component.self) { transformComponent in
                let object = entity[Collision2DComponent.self]
                object.primitive.update(transform: transformComponent.transform)
                
                let colliders = quadtree.colliders(near: object.primitive, inLayer: "Base")
                var objectCollider = object.complex ?? object.primitive!
                
                var impactCount = 0
                var hits: [(collider: any Collider2D, interpenetration: Interpenetration2D)] = []
                for collider in colliders {
                    objectCollider.update(transform: transformComponent.transform)
                    guard let interpenetration = collider.interpenetration(comparing: objectCollider), interpenetration.isColiding else {continue}
                    hits.append((collider, interpenetration))
                    guard impactCount < 2 else {break}
                    impactCount += 1
                }
                
                for hit in hits.sorted(by: {$0.collider.position.distance(from: objectCollider.position) < $1.collider.position.distance(from: objectCollider.position)}) {
                    objectCollider.update(transform: transformComponent.transform)
                    if let interpenetration = hit.collider.interpenetration(comparing: objectCollider), interpenetration.isColiding {
                        transformComponent.position -= Position2(hit.interpenetration.direction * hit.interpenetration.depth)
                    }
                }
            }
        }
    }

    public override class var phase: System.Phase {.simulation}
    public override class func sortOrder() -> SystemSortOrder? {
        return .collision2DSystem
    }
}

@MainActor public extension Game {
    var collision2DSystem: Collision2DSystem {
        return self.system(ofType: Collision2DSystem.self)
    }
}
