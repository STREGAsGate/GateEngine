/*
 * Copyright © 2023-2024 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

@available(*, unavailable /* 0.1.3 */, renamed: "Rig3DSystem")
public final class RigSystem {}

public final class Rig3DSystem: System {
    var checkedIDs: Set<ObjectIdentifier> = []
    func getFarAway(from entities: Set<Entity>) -> Entity? {
        func filter(_ entity: Entity) -> Bool {
            if let rig = entity.component(ofType: Rig3DComponent.self) {
                return rig.disabled == false && rig.deltaAccumulator > 0
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
            guard let rig = entity.component(ofType: Rig3DComponent.self) else {
                return false
            }
            return cameraTransform.position.distance(from: transform.position)
                > rig.slowAnimationsPastDistance
        }
        func updateAnimation(for entity: Entity) {
            if let component = entity.component(ofType: Rig3DComponent.self),
                component.disabled == false
            {
                if let animation = component.activeAnimation, animation.isReady {
                    component.update(
                        deltaTime: deltaTime + component.deltaAccumulator,
                        objectScale: entity.component(ofType: Transform3Component.self)?.scale ?? .one
                    )
                    if component.playbackState != .pause {
                        for animation in animation.subAnimations {
                            component.skeleton.applyAnimation(
                                animation.skeletalAnimation,
                                atTime: animation.accumulatedTime,
                                duration: animation.duration,
                                repeating: animation.repeats,
                                skipJoints: animation.skipJoints,
                                interpolateProgress: component.blendingProgress
                            )
                        }
                        component.deltaAccumulator = 0
                    }
                    for key in component.additionalTransforms.keys {
                        if let transform = component.additionalTransforms[key] {
                            applyAdditionalTransform(
                                transform,
                                toJoint: key,
                                inSkeleton: component.skeleton
                            )
                        }
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
            if let component = entity.component(ofType: Rig3DComponent.self),
                component.disabled == false
            {
                if shouldAccumulate(entity: entity) {
                    component.deltaAccumulator += deltaTime
                } else {
                    updateAnimation(for: entity)
                }
            }
        }

        for entity in context.entities {
            if let rigAttachmentComponent = entity.component(ofType: RigAttachmentComponent.self) {
                updateRigAttachmentTransform(
                    game,
                    entity: entity,
                    rigAttachmentComponent: rigAttachmentComponent
                )
            }
        }
    }

    private func applyAdditionalTransform(
        _ transform: Transform3,
        toJoint jointName: String,
        inSkeleton skeleton: Skeleton
    ) {
        guard let joint = skeleton.jointNamed(jointName) else { return }
        joint.localTransform.position += transform.position
        joint.localTransform.rotation = transform.rotation * joint.localTransform.rotation
        joint.localTransform.rotation.normalize()
        joint.localTransform.scale = (joint.localTransform.scale + transform.scale) / 2
    }

    private func updateRigAttachmentTransform(
        _ game: Game,
        entity: Entity,
        rigAttachmentComponent: RigAttachmentComponent
    ) {
        guard
            let parent = context.entities.first(where: {
                $0.id == rigAttachmentComponent.parentEntityID
            })
        else {
            //If the parent is gone trash the attachment
            context.removeEntity(entity)
            return
        }
        guard let parentTransform = parent.component(ofType: Transform3Component.self) else {
            return
        }
        guard let parentRig = parent.component(ofType: Rig3DComponent.self) else { return }
        guard let joint = parentRig.skeleton.jointNamed(rigAttachmentComponent.parentJointName)
        else { return }
        if let transformComponent = entity.component(ofType: Transform3Component.self) {
            let transform = (parentTransform.transform.createMatrix() * joint.modelSpace).transform
            transformComponent.transform.position = transform.position
            transformComponent.rotation =
                parentTransform.rotation * joint.modelSpace.rotation.conjugate
                * Quaternion(90°, axis: .right)
        }
    }

    public override class var phase: System.Phase { .simulation }
    public override class func sortOrder() -> SystemSortOrder? { .rigSystem }
}
