/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public class RigSystem: System {
    var checkedIDs: Set<ObjectIdentifier> = []
    func getFarAway(from entites: [Entity]) -> Entity? {
        func filter(_ entity: Entity) -> Bool {
            if let rig = entity.component(ofType: RigComponent.self) {
                return rig.disabled == false && rig.deltaAccumulator > 0 && checkedIDs.contains(entity.id) == false
            }
            return false
        }
        if let entity = entites.first(where: {filter($0)}) {
            checkedIDs.insert(entity.id)
            return entity
        }
        checkedIDs.removeAll(keepingCapacity: true)
        if let entity = entites.first(where: {filter($0)}) {
            checkedIDs.insert(entity.id)
            return entity
        }
        return nil
    }
    
    public override func update(game: Game, input: HID, layout: WindowLayout, withTimePassed deltaTime: Float) {
        func shouldAccumulate(entity: Entity) -> Bool {
            guard let cameraTransform = game.cameraEntity?.component(ofType: Transform3Component.self) else {return false}
            guard let transform = entity.component(ofType: Transform3Component.self) else {return false}
            guard let rig = entity.component(ofType: RigComponent.self) else {return false}
            return cameraTransform.position.distance(from: transform.position) > rig.slowAnimationsPastDistance
        }
        func updateAnimation(for entity: Entity) {
            if let component = entity.component(ofType: RigComponent.self), component.disabled == false {
                if let animation = component.activeAnimation {
                    if let scale = entity.component(ofType: Transform3Component.self)?.scale {
                        component.update(deltaTime: deltaTime + component.deltaAccumulator, objectScale: scale)
                    }else{
                        component.update(deltaTime: deltaTime + component.deltaAccumulator, objectScale: .one)
                    }
                    if component.playbackState != .pause {
                        for animation in animation.subAnimations {
                            component.skeleton.applyAnimation(animation.skeletalAnimation, withTime: animation.accumulatedTime, duration: animation.duration, repeating: animation.repeats, skipJoints: animation.skipJoints, interpolateProgress: component.blendingProgress)
                            
                        }
                        component.deltaAccumulator = 0
                    }
                    for key in component.additionalTransforms.keys {
                        if let transform = component.additionalTransforms[key] {
                            applyAdditionalTransform(transform, toJoint: key, inSkeleton: component.skeleton)
                        }
                    }
                }
            }
        }
        
        let slowEntity = getFarAway(from: game.entities)
        if let entity = slowEntity {
            updateAnimation(for: entity)
        }
        for entity in game.entities {
            guard entity != slowEntity else {continue}
            if let component = entity.component(ofType: RigComponent.self), component.disabled == false {
                if shouldAccumulate(entity: entity) {
                    component.deltaAccumulator += deltaTime
                }else{
                    updateAnimation(for: entity)
                }
            }
        }
 
        for entity in game.entities {
            if let rigAttachmentComponenet = entity.component(ofType: RigAttachmentComponent.self) {
                updateRigAttachmentTransform(game, entity: entity, rigAttachmentComponenet: rigAttachmentComponenet)
            }
        }
    }
    
    private func applyAdditionalTransform(_ transform: Transform3, toJoint jointName: String, inSkeleton skeleton: Skeleton) {
        guard let joint = skeleton.jointNamed(jointName) else {return}
        joint.localTransform.position += transform.position
        joint.localTransform.rotation = transform.rotation * joint.localTransform.rotation
        joint.localTransform.rotation.normalize()
        joint.localTransform.scale = (joint.localTransform.scale + transform.scale) / 2
    }
    
    private func updateRigAttachmentTransform(_ game: Game, entity: Entity, rigAttachmentComponenet: RigAttachmentComponent) {
        guard let parent = game.entities.first(where: {$0.id == rigAttachmentComponenet.parentEntityID}) else {
            //If the parent is gone trash the attachment
            game.removeEntity(entity)
            return
        }
        guard let parentTransform = parent.component(ofType: Transform3Component.self) else {return}
        guard let parentRig = parent.component(ofType: RigComponent.self) else {return}
        guard let joint = parentRig.skeleton.jointNamed(rigAttachmentComponenet.parentJointName) else {return}
        entity.configure(Transform3Component.self) { component in
            let transform = (parentTransform.transform.createMatrix() * joint.modelSpace).transform
            component.transform.position = transform.position
            component.rotation = parentTransform.rotation * joint.modelSpace.rotation.conjugate * Quaternion(90°, axis: .right)
        }
    }
    
    public override class var phase: System.Phase {.simulation}
}
