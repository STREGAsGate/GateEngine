/**
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

import Foundation

public final class FinalizeSimulation: System {
    public override func update(context: ECSContext, input: HID, withTimePassed deltaTime: Float) async {
        for entity in context.entities {
            if let timedDeathComponent = entity.component(ofType: TimedDeathComponent.self) {
                timedDeathComponent.timeRemaining -= deltaTime
                if timedDeathComponent.timeRemaining < 0 {
                    context.removeEntity(entity)
                    continue
                }
            }
            
            if let relationshipComponent = entity.component(ofType: ParentRelationshipComponent.self) {
                if let parentID = relationshipComponent.parent {
                    if let parent = context.entity(withID: parentID) {
                        if let transform = relationshipComponent.relativeTransform {
                            if relationshipComponent.options.contains(.relativePosition) {
                                entity.transform3.position = parent.transform3.position + transform.position
                            }
                            if relationshipComponent.options.contains(.relativeRotation) {
                                entity.transform3.rotation = (parent.transform3.rotation * transform.rotation).normalized
                            }
                            if relationshipComponent.options.contains(.relativeScale) {
                                entity.transform3.scale = parent.transform3.scale + transform.scale
                            }
                        }else{
                            if relationshipComponent.options.contains(.relativePosition) {
                                entity.transform3.position = parent.transform3.position
                            }
                            if relationshipComponent.options.contains(.relativeRotation) {
                                entity.transform3.rotation = parent.transform3.rotation
                            }
                            if relationshipComponent.options.contains(.relativeScale) {
                                entity.transform3.scale = parent.transform3.scale
                            }
                        }
                    }else{
                        context.removeEntity(entity)
                        continue
                    }
                }
            }
        }
        
        cullMaxQuantityEntities()
    }
    
    func cullMaxQuantityEntities() {
        var maxQuantities: [Int:Int] = [:]
        var quantities: [Int:Int] = [:]
        var quantityEntities: [Int:[Entity]] = [:]
        for entity in context.entities {
            guard let maxQuantityComponent = entity.component(ofType: MaxQuantityComponent.self) else {continue}
            maxQuantities[maxQuantityComponent.quantityMatchID] = min(maxQuantityComponent.maxQuantity, maxQuantities[maxQuantityComponent.quantityMatchID] ?? .max)
            
            let count = quantities[maxQuantityComponent.quantityMatchID] ?? 0
            quantities[maxQuantityComponent.quantityMatchID] = count + 1
            
            var entities = quantityEntities[maxQuantityComponent.quantityMatchID] ?? []
            entities.append(entity)
            quantityEntities[maxQuantityComponent.quantityMatchID] = entities
        }
        
        for key in quantities.keys {
            let quantity = quantities[key]!
            let max = maxQuantities[key]!
            if quantity >= max {
                var entities = quantityEntities[key]!
                entities.sort(by: {$0[MaxQuantityComponent.self] < $1[MaxQuantityComponent.self]})
                
                for entity in entities[max...] {
                    context.removeEntity(entity)
                }
            }
        }
    }
    
    public override class var phase: System.Phase {.deferred}
    public override nonisolated class func sortOrder() -> SystemSortOrder? {
        return .last
    }
}
