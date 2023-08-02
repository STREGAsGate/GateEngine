/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Physics3DSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        // Skip Physics if we don't have at least 20 fps
        guard deltaTime < 1/20 else {return}
        
        for entity in game.entities {
            guard let physicsComponent = entity.component(ofType: Physics3DComponent.self) else {continue}
            guard entity.hasComponent(Transform3Component.self) else {continue}
            await entity.configure(Transform3Component.self) { transformComponent in
                var deltaTime = deltaTime
                if let scale = entity.component(ofType: TimeScaleComponent.self)?.scale {
                    deltaTime *= scale
                }
                
                if physicsComponent.shouldApplyGravity {
                    var gravity = physicsComponent.velocity
                    gravity.y = physicsComponent.effectiveGravity().y
                    if let collisionComponent = entity.component(ofType: Collision3DComponent.self) {
                        if collisionComponent.touching.first(where: {$0.triangle.surfaceType.isWalkable}) != nil {
                            // Skip gravity if we're on the floor
                            gravity.y = 0
                        }
                    }
                    // Apply Gravity
                    physicsComponent.velocity = physicsComponent.velocity.interpolated(to: gravity, .linear(Float(deltaTime * 10)))
                }
                
                physicsComponent.update(deltaTime)
                
                transformComponent.previousTransform = transformComponent.transform
                transformComponent.position.y += physicsComponent.velocity.y * deltaTime
            }
        }
    }
    
    public override class var phase: System.Phase {.simulation}
    public override class func sortOrder() -> SystemSortOrder? {
        return .physics3DSystem
    }
}

extension Physics3DSystem {
    func applyGravity(entity: Entity, component: Physics3DComponent, deltaTime: Float) {
        var gravity = component.velocity
        gravity.y = component.effectiveGravity().y
        component.velocity = component.velocity.interpolated(to: gravity, .linear(deltaTime))
    }
}
