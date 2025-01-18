/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Physics3DSystem: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        // Skip Physics if we don't have at least 20 fps
        guard deltaTime < 1 / 20 else { return }

        for entity in context.entities {
            var deltaTime = deltaTime
            if let scale = entity.component(ofType: TimeScaleComponent.self)?.scale {
                deltaTime *= scale
            }
            
            guard let physicsComponent = entity.component(ofType: Physics3DComponent.self) else {
                continue
            }
            
            if let transformComponent = entity.component(ofType: Transform3Component.self) {
                transformComponent.previousTransform = transformComponent.transform

                if physicsComponent.shouldApplyGravity {
                    let velocity = physicsComponent.velocity
                    var gravity = velocity
                    gravity.y = physicsComponent.effectiveGravity().y
                    if let collisionComponent = entity.component(ofType: Collision3DComponent.self)
                    {
                        if collisionComponent.touching.first(where: {
                            return $0.triangle.surfaceType.isWalkable
                        }) != nil {
                            // Skip gravity if we're on the floor
                            gravity.y = 0
                        }
                    }
                    // Apply Gravity
                    let newVelocity = velocity.interpolated(
                        to: gravity,
                        .linear(Float(deltaTime * 10))
                    )
                    physicsComponent.velocity = newVelocity
                    transformComponent.position.y += physicsComponent.velocity.y * deltaTime
                }

                physicsComponent.update(deltaTime)
            }
        }
    }

    public override class var phase: System.Phase { .simulation }
    public override class func sortOrder() -> SystemSortOrder? { .physics3DSystem }
}

extension Physics3DSystem {
    func applyGravity(entity: Entity, component: Physics3DComponent, deltaTime: Float) {
        var gravity = component.velocity
        gravity.y = component.effectiveGravity().y
        component.velocity = component.velocity.interpolated(to: gravity, .linear(deltaTime))
    }
}
