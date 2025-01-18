/*
 * Copyright © 2025 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class ObjectAnimation3DSystem: System {
    var checkedIDs: Set<ObjectIdentifier> = []
    func getFarAway(from entities: Set<Entity>) -> Entity? {
        func filter(_ entity: Entity) -> Bool {
            if let objectAnimation = entity.component(ofType: ObjectAnimation3DComponent.self) {
                return objectAnimation.disabled == false && objectAnimation.deltaAccumulator > 0
                    && checkedIDs.contains(entity.id) == false
            }
            return false
        }
        if let entity = entities.first(where: { filter($0) }) {
            checkedIDs.insert(entity.id)
            return entity
        }
        checkedIDs.removeAll(keepingCapacity: true)
        if let entity = entities.first(where: { filter($0) }) {
            checkedIDs.insert(entity.id)
            return entity
        }
        return nil
    }

    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        func shouldAccumulate(entity: Entity) -> Bool {
            guard
                let cameraTransform = context.cameraEntity?.component(ofType: Transform3Component.self)
            else {
                return false
            }
            guard let transform = entity.component(ofType: Transform3Component.self) else {
                return false
            }
            guard let objectAnimation = entity.component(ofType: ObjectAnimation3DComponent.self) else {
                return false
            }
            return cameraTransform.position.distance(from: transform.position)
                > objectAnimation.slowAnimationsPastDistance
        }
        func updateAnimation(for entity: Entity) {
            if let component = entity.component(ofType: ObjectAnimation3DComponent.self), 
                component.disabled == false {
                if let animation = component.activeAnimation, animation.isReady {
                    component.update(
                        deltaTime: deltaTime + component.deltaAccumulator,
                        objectScale: entity.component(ofType: Transform3Component.self)?.scale ?? .one
                    )
                    if component.playbackState != .pause {
                        animation.applyAnimation(
                            atTime: animation.accumulatedTime,
                            repeating: animation.repeats,
                            interpolateProgress: component.blendingProgress,
                            to: &entity.transform3
                        )
                        component.deltaAccumulator = 0
                    }
                }
            }
        }

        let slowEntity = getFarAway(from: context.entities)
        if let entity = slowEntity {
            updateAnimation(for: entity)
        }
        for entity in context.entities {
            guard entity != slowEntity else { continue }
            if let component = entity.component(ofType: ObjectAnimation3DComponent.self),
                component.disabled == false
            {
                if shouldAccumulate(entity: entity) {
                    component.deltaAccumulator += deltaTime
                } else {
                    updateAnimation(for: entity)
                }
            }
        }
    }

    public override class var phase: System.Phase { .simulation }
    public override class func sortOrder() -> SystemSortOrder? { .objectAnimation3DSystem }
}
