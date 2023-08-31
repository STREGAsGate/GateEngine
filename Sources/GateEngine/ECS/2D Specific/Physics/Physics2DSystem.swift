/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import GameMath

public final class Physics2DSystem: System {
    public override func update(game: Game, input: HID, withTimePassed deltaTime: Float) async {
        // Skip Physics if we don't have at least 20 fps
        guard deltaTime < 1 / 20 else { return }

        for entity in game.entities {
            guard let physicsComponent = entity.component(ofType: Physics2DComponent.self) else {
                continue
            }
            guard entity.hasComponent(Transform2Component.self) else { continue }
            await entity.configure(Transform2Component.self) { transformComponent in
                var deltaTime = deltaTime
                if let scale = entity.component(ofType: TimeScaleComponent.self)?.scale {
                    deltaTime *= scale
                }

                transformComponent.previousTransform = transformComponent.transform
                
                physicsComponent.update(deltaTime)
                transformComponent.position += Position2(physicsComponent.velocity.normalized * physicsComponent.speed)
            }
        }
    }

    public override class var phase: System.Phase { .simulation }
    public override class func sortOrder() -> SystemSortOrder? { .physics3DSystem }
}
